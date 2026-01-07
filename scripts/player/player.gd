extends CharacterBody2D

# signal
signal experience_gained(current_xp: int, max_xp: int)
signal leveled_up(new_level: int)
signal player_died()

# exports
@export var speed : float = 300.0

# comp
@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_interval_timer: Timer = $DamageIntervalTimer 
@onready var animated_sprite = $Visuals/AnimatedSprite2D
@onready var gem_collect_sfx: AudioStreamPlayer2D = $Sound/GemCollect

# enum
enum State { IDLE, RUN, HURT, DEAD }

# states
var current_experience: int = 0
var current_level: int = 1
var current_state: State = State.IDLE
var xp_to_next_level: int = 100

func _process(_delta: float) -> void:
	
	if current_state == State.DEAD:
		return
	
	handle_movement()

func set_state(new_state: State):
	
	if current_state == State.DEAD:
		return
		
	current_state = new_state
	
	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.HURT:
			animated_sprite.play("hurt")
		State.RUN:
			animated_sprite.play("run")
		#State.DEAD:
			#animated_sprite.play("idle")

func handle_movement():
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction:
		velocity = direction * speed
		if direction.x > 0:
			animated_sprite.flip_h = false
		elif direction.x < 0:
			animated_sprite.flip_h = true
		
		if current_state != State.RUN or current_state != State.HURT:
			set_state(State.RUN)
		
		#animated_sprite.play("run")
	else:
		velocity = Vector2.ZERO
		if current_state != State.IDLE or current_state != State.HURT:
			set_state(State.IDLE)
		#animated_sprite.play("idle")
	
	move_and_slide()

func apply_upgrade(upgrade: Upgrade):
	print("Apply upgrade: ", upgrade.title)
	
	match upgrade.upgrade_id:
		"move_speed":
			speed += speed * upgrade.value
			print("New Speed: ", speed)
			
		"damage":
			var gun = $Gun
			if gun:
				gun.increase_damage(upgrade.value)
				
		"attack_rate":
			var gun = $Gun
			if gun:
				gun.increase_attack_rate(upgrade.value)

func take_damage(amount: int):
	if not damage_interval_timer.is_stopped():
		return
	
	health_component.damage(amount)
	print("Player got damage: ", health_component.current_health)
	
	damage_interval_timer.start()
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	set_state(State.HURT)


func gain_experience(exp_amount: int):
	current_experience += exp_amount
	
	if current_experience >= xp_to_next_level:
		current_level += 1
		xp_to_next_level += 50
		leveled_up.emit(current_level)
		print("LEVEL UP")
	
	gem_collect_sfx.play()
	experience_gained.emit(current_experience, xp_to_next_level)

# signal func triggers

func _on_health_component_died() -> void:
	print("Game Over!")
	player_died.emit()
	#get_tree().paused = true

func _on_scan_area_area_entered(area: Area2D) -> void:
	if area.has_method("start_magnet"):
		area.start_magnet(self)

func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == State.HURT:
		set_state(State.IDLE)
