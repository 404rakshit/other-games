extends CanvasLayer

@onready var health_bar = $Control/HealthBar
@onready var xp_bar = $Control/XPBar
@onready var joystick = $"JoyStick"
@onready var damage_flash: ColorRect = $DamageFlash
@onready var dash_progress_bar: TextureProgressBar = $Control2/DashButtonProgress
@onready var nuke_progress_bar: TextureProgressBar = $Control3/NukeProgressBar 
@onready var nuke_button: TouchScreenButton = $Control3/NukeButton

@onready var dash_touch_button: TouchScreenButton = $Control2/TouchScreenButton

@export var kills_for_nuke: int = 1
var current_nuke_charge: int = 0

signal menu_paused()
signal nuke_triggered()

var flash_tween: Tween

func _ready() -> void:
	_set_shader_intensity(0.0)
	ready_nuke()
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
	
	GameEvents.enemy_died.connect(_on_enemy_killed)
	
func _on_enemy_killed() -> void:
	# If the nuke is already fully charged, don't keep counting
	if current_nuke_charge >= kills_for_nuke:
		return
		
	# Add charge and update the progress bar visual
	current_nuke_charge += 1
	nuke_progress_bar.value = current_nuke_charge
	
	# Check if we hit the 100 threshold
	if current_nuke_charge >= kills_for_nuke:
		_nuke_ready()

func _nuke_ready() -> void:
	
	# Optional: Add a little pulse animation so the player knows it's ready
	var tween = create_tween().set_loops()
	tween.tween_property(nuke_button, "modulate", Color(1.5, 0.5, 0.5, 1.0), 0.5)
	tween.tween_property(nuke_button, "modulate", Color.WHITE, 0.5)

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
	
	if current_nuke_charge < kills_for_nuke:
		return
	# 1. Broadcast to the world that the nuke was fired
	nuke_triggered.emit()
	
	# 2. Reset the HUD state
	current_nuke_charge = 0
	nuke_progress_bar.value = 0
	nuke_button.modulate = Color.WHITE # Reset the glowing animation
