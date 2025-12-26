extends Area2D

@export var damage = 1

var speed : float = 400.0
var direction = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	# "Duck Typing"
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		queue_free()
