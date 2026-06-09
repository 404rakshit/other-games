class_name BaseEnemy
extends CharacterBody2D

# --- EXPORTS ---
@export var speed: float = 150.0
@export var max_health: int = 50
@export var stun_time: float = 0.2
@export var path_update_interval: float = 0.1

# --- VARIABLES & REFS ---
const player_group_name = "player"
var player: Node2D = null
var stun_timer: Timer
var path_timer: float = 0.0

# State Machine
enum State { CHASING, ATTACKING, DEAD, STUNNED }
var current_state: State = State.CHASING
var current_health: float

# Components (Assumes these exist in your Base Enemy scene)
@onready var health_component = $HealthComponent
@onready var animated_sprite = $Visuals/AnimatedSprite2D
@onready var health_bar: ProgressBar = $Visuals/HealthBar
@onready var hit_sfx : AudioStreamPlayer2D = $Sound/HitSound
@onready var dead_sfx : AudioStreamPlayer2D = $Sound/DeadSound
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

const GEM_SCENE = preload("res://scenes/map/desert/gem.tscn")

func _ready() -> void:
	player = get_tree().get_first_node_in_group(player_group_name)
	
	if health_component and health_component.has_method("set_max_health"):
		health_component.set_max_health(max_health)
	
	setup_timers()
	setup_nav_agent()
	ready_health_bar()
	_custom_setup() # A hook for child classes to run their own ready logic

func ready_health_bar():
	current_health = health_component.max_health
	
	# Initialize the health bar
	health_bar.max_value = health_component.max_health
	health_bar.value = current_health
	
	# Optional: Hide the health bar initially so it only shows when damaged
	health_bar.hide()

func setup_nav_agent():
	if nav_agent:
		nav_agent.path_desired_distance = 15.0
		nav_agent.target_desired_distance = 15.0
		nav_agent.avoidance_enabled = true

func _physics_process(delta: float) -> void:
	if not player or current_state == State.DEAD:
		return
		
	match current_state:
		State.CHASING:
			# OPTIMIZATION 1: Check attacks BEFORE moving!
			_check_attack_triggers()
			
			# If the trigger changed our state to ATTACKING, we skip moving entirely
			if current_state == State.CHASING:
				_process_movement(delta)
				
		State.ATTACKING:
			_process_attack_state(delta)
			
		State.STUNNED:
			# Call the virtual function first in case child classes add knockback logic
			_process_stunned_state(delta)
			velocity = Vector2.ZERO 
			move_and_slide()

# --- BASE BEHAVIORS ---

func _process_movement(delta: float):
	# OPTIMIZATION 2: Countdown Timer (Slightly faster than checking bounds and resetting)
	path_timer -= delta
	if path_timer <= 0.0:
		path_timer = path_update_interval
		nav_agent.target_position = player.global_position

	# OPTIMIZATION 3: Early exit if we reached the player
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	# Navigation Logic
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	
	velocity = direction * speed
	
	# Flip sprite based on movement direction
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
		
	move_and_slide()
	
func take_damage(amount: float):
	if current_state == State.DEAD: return
	
	current_health -= amount
	
	# --- NEW: INSTANT DEATH CHECK ---
	if current_health <= 0:
		current_state = State.DEAD # Instantly lock out the other 4 shotgun pellets!
		current_health = 0 # Clamp health so the UI doesn't show negative numbers
		
		# Update the health component ONE time
		health_component.damage(amount) 
		
		# Trigger your actual death logic here (e.g., die(), queue_free(), add score)
		# Note: If health_component handles the kill count, it will now only trigger once.
		return # CRITICAL: Exit the function early so the dead enemy doesn't flash or get stunned
	# --------------------------------
	
	flash_damage()
	
	if health_bar.visible == false:
		health_bar.show()
	
	var health_bar_tween = create_tween()
	health_bar_tween.tween_property(health_bar, "value", current_health, 0.15).set_trans(Tween.TRANS_SINE)
	
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

func flash_damage() -> void:
	# Ensure the sprite has our shader material before trying to change it
	if animated_sprite.material and animated_sprite.material is ShaderMaterial:
		animated_sprite.material.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(animated_sprite.material, "shader_parameter/flash_modifier", 0.0, 0.15)

func _on_health_component_died() -> void:
	health_bar.hide()
	current_state = State.DEAD
	dead_sfx.play()
	SoundManager.play_sound(dead_sfx.stream, global_position, get_tree().current_scene)
	
	GameEvents.enemy_died.emit()
	
	drop_exp_gem()
	queue_free()

func drop_exp_gem():
	var new_gem: Area2D = GEM_SCENE.instantiate()
	new_gem.global_position = global_position
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
	pass

func _check_attack_triggers():
	pass 

func _process_attack_state(_delta: float):
	pass 

func _process_stunned_state(_delta: float):
	pass
