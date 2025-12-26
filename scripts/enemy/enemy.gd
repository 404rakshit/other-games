extends CharacterBody2D

# exports
@export var speed: float = 150.0

# variables
const player_group_name = "player"

# refs (states)
var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group(player_group_name)

func _physics_process(_delta: float) -> void:
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
