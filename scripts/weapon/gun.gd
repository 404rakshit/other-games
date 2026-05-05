extends Node2D

const BULLET_SCENE = preload("res://scenes/weapon/projectile.tscn")

# components
@onready var sprite: Sprite2D = $Sprite2D
@onready var shooting_point: Marker2D = $Sprite2D/ShootingPoint
@onready var range_area: Area2D = $Range
@onready var timer: Timer = $Timer
@onready var shoot_sound: AudioStreamPlayer2D = $ShootingSound

# stats
var current_damage = 1

# Recoil Variables 
var recoil_distance: float = 12.0
var recovery_speed: float = 15.0  
var current_recoil: float = 0.0

# Orbit & Bobbing Variables 
@export var orbit_radius: float = 55.0   
@export var orbit_angle: float = 0.0     
var bob_speed: float = 5.0       
var bob_amount: float = 4.0      
var time_passed: float = 0.0

# Fluid Aiming Variables
var aim_speed: float = 12.0 

var valid_targets = []
	
func _on_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not valid_targets.has(body):
		valid_targets.append(body)

func _on_range_body_exited(body: Node2D) -> void:
	if valid_targets.has(body):
		valid_targets.erase(body)

func _process(delta: float) -> void:
	# ---------------------------------------------------------
	# 1. ORBIT & HOVERING
	# ---------------------------------------------------------
	time_passed += delta
	var bob_offset_y = sin(time_passed * bob_speed) * bob_amount
	var orbit_position = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	
	var target_position = orbit_position + Vector2(0, bob_offset_y)
	position = position.lerp(target_position, 10.0 * delta)

# ---------------------------------------------------------
	# 2. FLUID AIMING & RESTING STATE (OPTIMIZED)
	# ---------------------------------------------------------
	var target_angle: float = 0.0 
	
	# REPLACEMENT: Check the list instead of scanning physics
	if valid_targets.size() > 0:
		# If the enemy we were targeting died or became invalid, clean the list
		if not is_instance_valid(valid_targets[0]):
			valid_targets.remove_at(0)
		else:
			var target_enemy = valid_targets[0]
			target_angle = global_position.direction_to(target_enemy.global_position).angle()
	else:
		target_angle = orbit_angle
		
	global_rotation = lerp_angle(global_rotation, target_angle, aim_speed * delta)
		
	# Sprite Flip Logic
	# Note: We use fmod to keep the angle within a -180 to 180 range so the flip works consistently
	var normalized_rotation = fmod(global_rotation_degrees, 360.0)
	if normalized_rotation > 180.0: normalized_rotation -= 360.0
	elif normalized_rotation < -180.0: normalized_rotation += 360.0
		
	if abs(normalized_rotation) > 90:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

	# ---------------------------------------------------------
	# 3. RECOIL RECOVERY 
	# ---------------------------------------------------------
	if current_recoil > 0:
		current_recoil = lerpf(current_recoil, 0.0, recovery_speed * delta)
		
	sprite.position.x = -current_recoil

func _on_timer_timeout() -> void:
	shoot()
	
func increase_damage(damage_value: float):
	current_damage += damage_value
	
func increase_attack_rate(attack_rate: float):
	timer.wait_time = timer.wait_time * (1.0 - attack_rate)
	timer.wait_time = max(timer.wait_time, 0.05)

func shoot():
	# REPLACEMENT: Use the list we are already maintaining
	if valid_targets.size() > 0:
		# Double check the enemy still exists in memory
		if not is_instance_valid(valid_targets[0]):
			valid_targets.remove_at(0)
			return # Exit and wait for next shot
			
		current_recoil = recoil_distance
		
		var bullet: Area2D = BULLET_SCENE.instantiate()
		get_tree().root.add_child(bullet)
		
		bullet.global_position = shooting_point.global_position
		bullet.rotation = global_rotation
		bullet.damage = current_damage
		bullet.direction = Vector2.RIGHT.rotated(global_rotation) 
		
		shoot_sound.pitch_scale = randf_range(0.9, 1.2)
		shoot_sound.play()
