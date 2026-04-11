extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10

var direction: Vector2 = Vector2.ZERO

func _ready():
	# If your bullet isn't a perfect circle, you can rotate it to face its travel direction
	rotation = direction.angle()

func _physics_process(delta: float):
	position += direction * speed * delta
	rotation += rad_to_deg(0.08)

# Connect the "body_entered" signal of the Area2D to this function
func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free() # Destroy the bullet after hitting the player

# Connect the "screen_exited" signal of the VisibleOnScreenNotifier2D to this function
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Destroy bullet if it misses and flies off screen
