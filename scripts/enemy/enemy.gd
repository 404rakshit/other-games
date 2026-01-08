extends CharacterBody2D

# exports
@export var speed: float = 150.0
@export var damage_amount: int = 10

# variables
const player_group_name = "player"

# components
@onready var health_component = $HealthComponent
@onready var damage_zone = $DamageZone
@onready var animated_sprite = $Visuals/AnimatedSprite2D
@onready var hit_sfx : AudioStreamPlayer2D = $Sound/HitSound
@onready var dead_sfx : AudioStreamPlayer2D = $Sound/DeadSound
# refs (states)
var player: Node2D = null

# scenes
const GEM_SCENE = preload("res://scenes/game/exp_gem.tscn")

func _ready() -> void:
	player = get_tree().get_first_node_in_group(player_group_name)
	
	var random_shade = randf_range(0.8, 1.2)
	modulate = Color(random_shade, random_shade, random_shade, 1.0)
	
func change_dir(direction: Vector2):
		if direction.x > 0:
			animated_sprite.flip_h = false
		elif direction.x < 0:
			animated_sprite.flip_h = true

func _physics_process(_delta: float) -> void:
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		
		change_dir(direction)
		move_and_slide()
		
	var overlapping_bodies = damage_zone.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)

func take_damage(amount: int):
	health_component.damage(amount)
	
	hit_sfx.pitch_scale = randf_range(0.8, 1.2)
	hit_sfx.play()
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
func drop_exp_gem():
	var new_gem: Area2D = GEM_SCENE.instantiate()
	new_gem.global_position = global_position
	new_gem.rotate(randf_range(1.57, 1.84))
	new_gem.z_index = -1
	
	# We use call_deferred to safely add nodes during a physics callback
	get_parent().call_deferred("add_child", new_gem)

func _on_health_component_died() -> void:
	#dead_sfx.pitch_scale = randf_range(0.8, 1.2)
	dead_sfx.play()
	
	SoundManager.play_sound(dead_sfx.stream, global_position, get_tree().current_scene)
	
	drop_exp_gem()
	# remove enemy from the tree
	queue_free()

#func _on_damage_zone_body_entered(body: Node2D) -> void:
	#print("body: ", body)
	#if body.has_method("take_damage"):
		#print("entered if check")
		#body.take_damage(damage_amount)
