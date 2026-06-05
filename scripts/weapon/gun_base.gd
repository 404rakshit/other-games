class_name GunBase extends Node2D

@export var bullet_scene: PackedScene = preload("res://scenes/weapon/projectile.tscn")

# --- WEAPON STATS (Child classes will change these) ---
@export var base_damage: float = 1
@export var fire_rate: float = 1.0 # Time between shots
@export var projectiles_per_shot: int = 1
@export var spread_degrees: float = 0.0 # How inaccurate the gun is
@export var recoil_distance: float = 12.0
@export var recovery_speed: float = 15.0
@export var is_continuous_audio: bool = false

# --- COMPONENTS ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var shooting_point: Marker2D = $Sprite2D/ShootingPoint
@onready var range_area: Area2D = $Range
@onready var timer: Timer = $Timer
@onready var shoot_sound: AudioStreamPlayer2D = $ShootingSound
@onready var muzzle_flash: Sprite2D = $MuzzleFlash

var current_recoil: float = 0.0
@export var orbit_radius: float = 55.0   
@export var orbit_angle: float = 0.0     
var bob_speed: float = 5.0       
var bob_amount: float = 4.0      
var time_passed: float = 0.0
var aim_speed: float = 12.0 
var valid_targets = []

func _ready() -> void:
	# Set the timer based on the specific gun's fire rate
	timer.wait_time = fire_rate
	timer.timeout.connect(shoot)

func _on_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not valid_targets.has(body):
		valid_targets.append(body)

func _on_range_body_exited(body: Node2D) -> void:
	if valid_targets.has(body):
		valid_targets.erase(body)

func _process(delta: float) -> void:
	
	if valid_targets.is_empty() and is_continuous_audio and shoot_sound.playing:
		shoot_sound.stop()

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

func use_muzzle() -> void:
	muzzle_flash.show()
	muzzle_flash.modulate.a = 1.0 # 'a' is Alpha (transparency)
	muzzle_flash.scale = Vector2(0.5, 0.5) 
	
	# 2. Create a Tween to animate it
	var tween = create_tween()
	
	# 3. Animate the scale to get bigger (the "pop")
	# This takes 0.05 seconds
	tween.tween_property(muzzle_flash, "scale", Vector2(0.04, 0.04), 0.05)
	
	# 4. Animate it fading away
	# This also takes 0.05 seconds
	tween.tween_property(muzzle_flash, "modulate:a", 0.0, 0.05)
	
	# 5. Hide it completely when the animation finishes
	tween.tween_callback(muzzle_flash.hide)
	

func shoot():
	if valid_targets.is_empty(): return
	if not is_instance_valid(valid_targets[0]):
		valid_targets.remove_at(0)
		return
		
	current_recoil = recoil_distance
	use_muzzle()
	
	if is_continuous_audio:
		# If it's a looping sound, only start playing if it isn't already
		if not shoot_sound.playing:
			shoot_sound.play()
	else:
		# If it's a single shot (Revolver/Shotgun), pitch it and play it
		shoot_sound.pitch_scale = randf_range(0.9, 1.2)
		shoot_sound.play()
	
	# Loop to spawn the correct number of bullets (1 for Uzi, ~5 for Shotgun)
	for i in range(projectiles_per_shot):
		spawn_projectile()

func spawn_projectile() -> void:
	var bullet: Area2D = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	
	# Calculate spread
	var random_spread = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	var final_rotation = global_rotation + random_spread
	
	bullet.global_position = shooting_point.global_position
	bullet.rotation = final_rotation
	bullet.damage = base_damage
	bullet.direction = Vector2.RIGHT.rotated(final_rotation)
