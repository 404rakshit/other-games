extends Node2D
class_name HealthComponent

signal died
signal health_changed(new_health: int)

@export var max_health : int = 10
var current_health : int

func _ready() -> void:
	current_health = max_health
	
func damage(attack_amount: int):
	current_health -= attack_amount
	current_health = max(current_health, 0)
	
	health_changed.emit(current_health)
	
	if current_health <= 0:
		died.emit()
