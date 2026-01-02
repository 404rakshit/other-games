extends Area2D

#exports
@export var experience_amount: int = 10
@export var speed: float = 400.0

# state
var target: CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if target:
		global_position = global_position.move_toward(target.global_position, speed * delta)
		speed += 10.0 * delta
		
		if global_position.distance_to(target.global_position) < 10:
			collect()
			
func collect():
	if target.has_method("gain_experience"):
		target.gain_experience(experience_amount)

func start_magnet(player_node):
	target = player_node
