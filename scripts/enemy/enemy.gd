extends CharacterBody2D

# exports
@export var speed: float = 150.0
@export var damage_amount: int = 10
@export var attack_windup_time: float = 0.3 # Time before damage hits
@export var attack_cooldown_time: float = 1.0 # Time between attacks
@export var stun_time: float = 0.4

# variables
const player_group_name = "player"

# ENUM for State Machine
enum State { CHASING, ATTACKING, STUNNED }
var current_state: State = State.CHASING

# components
@onready var health_component = $HealthComponent
@onready var damage_zone = $DamageZone
@onready var animated_sprite = $Visuals/AnimatedSprite2D
@onready var hit_sfx : AudioStreamPlayer2D = $Sound/HitSound
@onready var dead_sfx : AudioStreamPlayer2D = $Sound/DeadSound

# Timers (Add these nodes to your scene or create them in code like this)
var windup_timer: Timer
var cooldown_timer: Timer
var stun_timer: Timer

# refs
var player: Node2D = null

const GEM_SCENE = preload("res://scenes/game/exp_gem.tscn")

func _ready() -> void:
	player = get_tree().get_first_node_in_group(player_group_name)
	
	# Setup Timers via code so you don't have to add them manually in the editor
	setup_timers()
	
	var random_shade = randf_range(0.8, 1.2)
	modulate = Color(random_shade, random_shade, random_shade, 1.0)
	
func setup_timers():
	windup_timer = Timer.new()
	windup_timer.one_shot = true
	windup_timer.timeout.connect(_on_windup_timer_timeout)
	add_child(windup_timer)
	
	stun_timer = Timer.new()
	stun_timer.one_shot = true
	stun_timer.timeout.connect(_on_stun_timer_timeout)
	add_child(stun_timer)
	
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	#cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	add_child(cooldown_timer)

func _physics_process(_delta: float) -> void:
	if not player:
		return
		
	match current_state:
		State.CHASING:
			process_chasing()
		State.ATTACKING:
			# Stop moving while attacking
			velocity = Vector2.ZERO
			move_and_slide()
		State.STUNNED:
			velocity = Vector2.ZERO 
			move_and_slide()

func process_chasing():
	# Movement logic
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	change_dir(direction)
	move_and_slide()
	
	# Check if player is in range to start an attack
	if is_player_in_range() and cooldown_timer.is_stopped():
		start_attack()

func is_player_in_range() -> bool:
	var overlapping_bodies = damage_zone.get_overlapping_bodies()
	return player in overlapping_bodies

func start_attack():
	current_state = State.ATTACKING
	animated_sprite.play("attack") # Play your attack animation here!
	windup_timer.start(attack_windup_time)

func _on_windup_timer_timeout():
	# The animation reached the "hit" frame. 
	# Check if the player is STILL in range before dealing damage!
	if is_player_in_range():
		if player.has_method("take_damage"):
			player.take_damage(damage_amount)
	
	# Start cooldown and go back to chasing
	cooldown_timer.start(attack_cooldown_time)
	animated_sprite.play("run") # or idle, depending on your animations
	current_state = State.CHASING

func change_dir(direction: Vector2):
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func take_damage(amount: int):
	health_component.damage(amount)
	
	spawn_hit_particles()
	
	hit_sfx.pitch_scale = randf_range(0.8, 1.2)
	hit_sfx.play()
	
	current_state = State.STUNNED
	animated_sprite.play("take_damage")
	stun_timer.start(stun_time)
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func spawn_hit_particles():
# Trigger the particle burst
	$HitParticles.emitting = true
	
	# Optional: Randomize the rotation so the spray 
	# doesn't look identical every time
	$HitParticles.rotation = randf_range(0, TAU)

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

func _on_stun_timer_timeout():
	current_state = State.CHASING
	animated_sprite.play("run")
