class_name BaseEnemy
extends CharacterBody2D

# --- EXPORTS ---
@export var speed: float = 150.0
@export var max_health: int = 50
@export var stun_time: float = 0.2

# --- VARIABLES & REFS ---
const player_group_name = "player"
var player: Node2D = null
var stun_timer: Timer

# State Machine
enum State { CHASING, ATTACKING, DEAD, STUNNED }
var current_state: State = State.CHASING

# Components (Assumes these exist in your Base Enemy scene)
@onready var health_component = $HealthComponent
@onready var animated_sprite = $Visuals/AnimatedSprite2D
@onready var hit_sfx : AudioStreamPlayer2D = $Sound/HitSound
@onready var dead_sfx : AudioStreamPlayer2D = $Sound/DeadSound

const GEM_SCENE = preload("res://scenes/game/exp_gem.tscn")

func _ready() -> void:
	player = get_tree().get_first_node_in_group(player_group_name)
	# Set health component to max health
	if health_component and health_component.has_method("set_max_health"):
		health_component.set_max_health(max_health)
	
	setup_timers()
	_custom_setup() # A hook for child classes to run their own ready logic

func _physics_process(delta: float) -> void:
	if not player or current_state == State.DEAD:
		return
		
	match current_state:
		State.CHASING:
			_process_movement(delta)
			_check_attack_triggers()
		State.ATTACKING:
			_process_attack_state(delta)
		State.STUNNED:
			velocity = Vector2.ZERO 
			move_and_slide()

# --- BASE BEHAVIORS ---

func _process_movement(_delta: float):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
		
	move_and_slide()

func take_damage(amount: int):
	if current_state == State.DEAD: return
	
	health_component.damage(amount)
	hit_sfx.pitch_scale = randf_range(0.8, 1.2)
	hit_sfx.play()
	
	if current_state != State.ATTACKING:
		current_state = State.STUNNED
		animated_sprite.play("take_damage")
		stun_timer.start(stun_time)
	
	# Damage Flash
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _on_health_component_died() -> void:
	current_state = State.DEAD
	dead_sfx.play()
	SoundManager.play_sound(dead_sfx.stream, global_position, get_tree().current_scene)
	
	drop_exp_gem()
	queue_free()

func drop_exp_gem():
	var new_gem: Area2D = GEM_SCENE.instantiate()
	new_gem.global_position = global_position
	new_gem.rotate(randf_range(1.57, 1.84))
	new_gem.z_index = -1
	get_parent().call_deferred("add_child", new_gem)

func setup_timers():	
	stun_timer = Timer.new()
	stun_timer.one_shot = true
	stun_timer.timeout.connect(_on_stun_timer_timeout)
	add_child(stun_timer)

func _on_stun_timer_timeout():
	current_state = State.CHASING
	animated_sprite.play("run")

# --- VIRTUAL FUNCTIONS (To be overridden by child classes) ---

func _custom_setup():
	pass # Override in child to setup timers or specific variables

func _check_attack_triggers():
	pass # Override in child to check distances or cooldowns

func _process_attack_state(_delta: float):
	pass # Override in child to handle the actual attack animation/logic

func _process_stunned_state(_delta: float):
	pass # Override in child to handle the actual attack animation/logic
