extends CharacterBody2D

# exports
@export var speed: float = 150.0
@export var damage_amount: int = 10

# variables
const player_group_name = "player"

# components
@onready var health_component = $HealthComponent
@onready var damage_zone = $DamageZone

# refs (states)
var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group(player_group_name)

func _physics_process(_delta: float) -> void:
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
	var overlapping_bodies = damage_zone.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)

func take_damage(amount: int):
	health_component.damage(amount)
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _on_health_component_died() -> void:
	queue_free()

#func _on_damage_zone_body_entered(body: Node2D) -> void:
	#print("body: ", body)
	#if body.has_method("take_damage"):
		#print("entered if check")
		#body.take_damage(damage_amount)
