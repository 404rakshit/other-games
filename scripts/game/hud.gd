extends CanvasLayer

@onready var health_bar = $Control/HealthBar
@onready var xp_bar = $Control/XPBar
@onready var joystick = $"Virtual Joystick"

func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		joystick.visible = true
	else:
		joystick.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func set_max_health(value: int):
	health_bar.max_value = value
	health_bar.value = value
	
func update_health(new_value: int):
	health_bar.value = new_value
	
func update_xp(current_xp: int, max_xp_for_level: int):
	xp_bar.value = current_xp
	xp_bar.max_value = max_xp_for_level
