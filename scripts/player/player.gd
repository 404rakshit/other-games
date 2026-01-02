extends CharacterBody2D

# exports
@export var speed : float = 300.0

# comp
@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_interval_timer: Timer = $DamageIntervalTimer 

# states
var current_experience: int = 0

func _process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
func take_damage(amount: int):
	if not damage_interval_timer.is_stopped():
		return
	
	health_component.damage(amount)
	print("Player got damage: ", health_component.current_health)
	
	damage_interval_timer.start()
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func gain_experience(exp_amount: int):
	current_experience += exp_amount

func _on_health_component_died() -> void:
	print("Game Over!")
	get_tree().paused = true


func _on_scan_area_area_entered(area: Area2D) -> void:
	if area.has_method("start_magnet"):
		area.start_magnet(self)
