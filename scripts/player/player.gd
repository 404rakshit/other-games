extends CharacterBody2D

# exports
@export var speed : float = 300.0

@onready var health_component: HealthComponent = $HealthComponent

func _process(_delta: float) -> void:
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
func take_damage(amount: int):
	health_component.damage(amount)
	print("Player got damage: ", health_component.current_health)

func _on_health_component_died() -> void:
	print("Game Over!")
	get_tree().paused = true
