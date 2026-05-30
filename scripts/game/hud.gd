extends CanvasLayer

@onready var health_bar = $Control/HealthBar
@onready var xp_bar = $Control/XPBar
@onready var joystick = $"JoyStick"
@onready var damage_flash: ColorRect = $DamageFlash
@onready var dash_progress_bar: TextureProgressBar = $Control2/DashButtonProgress
@onready var nuke_progress_bar: TextureProgressBar = $Control3/NukeProgressBar 
@onready var nuke_button: TouchScreenButton = $Control3/NukeButton

@onready var dash_touch_button: TouchScreenButton = $Control2/TouchScreenButton

@onready var nuke_flash: ColorRect = $NukeFlash # Path to your white screen
@onready var nuke_sfx: AudioStreamPlayer = $NukeSound

const ASH_PARTICLES_SCENE = preload("res://scenes/enemy/ash_particles.tscn")

@onready var nuke_requirement_label: Label = $Control3/NukeButton/NukeRequirementLabel

@export var kills_for_nuke: int = 70
var current_nuke_charge: int = 0
var is_nuke_active: bool = false

signal menu_paused()
#signal nuke_triggered()

var flash_tween: Tween

# Cache the bus index and effect index for performance
var music_bus_idx: int
var lpf_effect_idx: int = 0 # Assuming the LowPassFilter is the first effect (index 0) on the bus

var nuke_pulse_tween: Tween

func _ready() -> void:
	_set_shader_intensity(0.0)
	_set_music_muffle(2000)
	ready_nuke()
	
	music_bus_idx = AudioServer.get_bus_index("Music")
	dash_progress_bar.value = 100.0
	
	if DisplayServer.is_touchscreen_available():
		joystick.visible = true
	else:
		joystick.visible = false
		
	if dash_touch_button:
		dash_touch_button.pressed.connect(_on_dash_button_pressed)
		
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("nuke"):
			_on_nuke_button_pressed()
			
func _on_dash_button_pressed():
	# You can pass your exact cooldown time here
	start_hud_dash_cooldown(1.0)

func ready_nuke():
	nuke_progress_bar.max_value = kills_for_nuke
	nuke_progress_bar.value = 0
	is_nuke_active = false
	update_nuke_ui()
	
	GameEvents.enemy_died.connect(_on_enemy_killed)

func update_nuke_ui() -> void:
	var kills_left = kills_for_nuke - current_nuke_charge
	
	if kills_left > 0:
		nuke_requirement_label.text = str(kills_left) + " Kills"

func _on_enemy_killed() -> void:
	
	if is_nuke_active:
		return
		
	# If the nuke is already fully charged, don't keep counting
	if current_nuke_charge >= kills_for_nuke:
		nuke_requirement_label.text = "READY!"
		return
		
	# Add charge and update the progress bar visual
	current_nuke_charge += 1
	update_nuke_ui()
	nuke_progress_bar.value = current_nuke_charge
	
	# Check if we hit the 100 threshold
	if current_nuke_charge >= kills_for_nuke:
		_nuke_ready()

func _nuke_ready() -> void:
	# If a pulse is already running, don't start another one
	if nuke_pulse_tween and nuke_pulse_tween.is_valid():
		return 
		
	# Assign the looping tween to our tracker variable
	nuke_pulse_tween = create_tween().set_loops()
	nuke_pulse_tween.tween_property(nuke_button, "modulate", Color(1.5, 0.5, 0.5, 1.0), 0.5)
	nuke_pulse_tween.tween_property(nuke_button, "modulate", Color.WHITE, 0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func start_hud_dash_cooldown(cooldown_time: float) -> void:
	# 1. Instantly drop the fill value to 0 right when the button is pressed
	dash_progress_bar.value = 0.0
	
	# 2. Create a linear tween to fill the meter gradually
	var progress_tween = create_tween()
	
	# 3. Animate the 'value' property from 0 to 100 over the designated cooldown timeline
	progress_tween.tween_property(dash_progress_bar, "value", 100.0, cooldown_time)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
		
	# 4. Optional UI Polish effect when complete
	progress_tween.tween_callback(_on_dash_fully_charged)

func _on_dash_fully_charged() -> void:
	# Brief visual pop to let the player know the skill is active again!
	var pop_tween = create_tween()
	pop_tween.tween_property(dash_progress_bar, "scale", Vector2(1.1, 1.1), 0.05)
	pop_tween.tween_property(dash_progress_bar, "scale", Vector2(1.0, 1.0), 0.05)

func set_max_health(value: int):
	health_bar.max_value = value
	health_bar.value = value
	
func update_health(new_value: int):
	health_bar.value = new_value
	
func update_xp(current_xp: int, max_xp_for_level: int):
	xp_bar.value = current_xp
	xp_bar.max_value = max_xp_for_level

func play_damage_flash() -> void:
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
		
	flash_tween = create_tween()
	
	# 1. Sudden Burn: Rapidly increase the shader intensity parameter to 2.5 over 0.05 seconds
	flash_tween.tween_method(_set_shader_intensity, 0.0, 2.5, 0.05)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	# 2. Cinematic Bleed: Slowly melt the corner intensity back to 0.0 over 0.5 seconds
	flash_tween.tween_method(_set_shader_intensity, 2.5, 0.0, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

## Helper function to directly talk to the shader's rendering grid
func _set_shader_intensity(value: float) -> void:
	if damage_flash and damage_flash.material:
		damage_flash.material.set_shader_parameter("multiplier", value)

func _on_button_pressed() -> void:
	menu_paused.emit()

#func _on_texture_button_pressed() -> void:
	#Input.action_press("dash")
	#
	## 2. Force an internal input flush so the engine registers the 'just_pressed' state
	#Input.flush_buffered_events()
	#
	## 3. Release it instantly so it can be pressed again next time
	#Input.action_release("dash")


func _on_nuke_button_pressed() -> void:
	
	is_nuke_active = true
	
	if current_nuke_charge < kills_for_nuke:
		return
	# 1. Broadcast to the world that the nuke was fired
	#nuke_triggered.emit()
	_execute_nuke()
	
	# 2. Reset the HUD state
	current_nuke_charge = 0
	update_nuke_ui()
	nuke_progress_bar.value = 0
	nuke_button.modulate = Color.WHITE # Reset the glowing animation

func _execute_nuke() -> void:
	# 1. Create a cinematic tween that ignores our slow-mo effect
	var cinematic = create_tween()
	cinematic.set_ignore_time_scale(true) 
	
	# === PHASE 1: THE INHALATION ===
	# Instantly drop game speed to 10%
	Engine.time_scale = 0.1 
	
	cinematic.tween_method(_set_music_muffle, 20000.0, 500.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# Wait 0.5 real-time seconds in slow-mo
	cinematic.tween_interval(0.5) 
	
	# === PHASE 2: THE FLASH ===
	# Instantly turn the screen pure white
	cinematic.tween_callback(func():
		nuke_flash.modulate.a = 1.0
		nuke_sfx.play() # Play the massive boom
		
		get_tree().call_group("camera", "add_trauma", 1.0)
		#await get_tree().create_timer(0.3).timeout
  		#get_tree().call_group("camera", "trigger_nuke_shake")
	)
	
	# === PHASE 3: THE PURGE ===
	# While the screen is white, kill everything
	cinematic.tween_callback(_vaporize_all_enemies)
	
	# === PHASE 4: THE RECOVERY ===
	# Slowly fade the white screen away over 1.5 seconds
	cinematic.tween_property(nuke_flash, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_SINE)
	
	cinematic.parallel().tween_property(Engine, "time_scale", 1.0, 0.5)
	
	# Restore game speed back to 1.0 safely
	cinematic.tween_property(Engine, "time_scale", 1.0, 0.5)
	cinematic.parallel().tween_method(_set_music_muffle, 500.0, 20000.0, 1.5).set_trans(Tween.TRANS_SINE)
	
	await cinematic.finished
	
	finish_nuke_sequence()

func finish_nuke_sequence() -> void:
	current_nuke_charge = 0
	is_nuke_active = false
	
	if nuke_pulse_tween and nuke_pulse_tween.is_valid():
		nuke_pulse_tween.kill() # Instantly stops the loop
		
	nuke_progress_bar.value = current_nuke_charge
	update_nuke_ui()

## Helper function to apply the frequency directly to the audio server
func _set_music_muffle(freq: float) -> void:
	# Grab the live effect from the AudioServer
	var effect = AudioServer.get_bus_effect(music_bus_idx, lpf_effect_idx)
	
	# Safety check to ensure we are actually editing a LowPassFilter
	if effect is AudioEffectLowPassFilter:
		effect.cutoff_hz = freq

func _vaporize_all_enemies() -> void:
	var active_enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in active_enemies:
		
		if not enemy is Node2D:
			continue
			
		if enemy.has_method("_on_health_component_died"):
			enemy._on_health_component_died()
			
		# Optional: Spawn an ash/dust particle at enemy.global_position here
		
		var ash_effect = ASH_PARTICLES_SCENE.instantiate()
		
		# 2. Match its position to the dying enemy
		ash_effect.global_position = enemy.global_position
		
		# 3. Add it to the WORLD (not the enemy) so it survives
		add_child(ash_effect)
		
		# Immediately delete the enemy
		enemy.queue_free()
