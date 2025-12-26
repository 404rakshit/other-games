extends Node2D

const BULLET_SCENE = preload("res://scenes/weapon/projectile.tscn")

@onready var shooting_point: Marker2D = $ShootingPoint
@onready var range_area: Area2D = $Range

func _on_timer_timeout() -> void:
	shoot()

func shoot():
	var enemies_in_range = range_area.get_overlapping_bodies()
	#print("enemies_in_range", enemies_in_range)
	
	if enemies_in_range.size() > 0:
		
		var target_enemy = enemies_in_range[0]
		look_at(target_enemy.global_position)
		
		var bullet: Area2D = BULLET_SCENE.instantiate()
		
		get_tree().root.add_child(bullet)
		bullet.global_position = shooting_point.global_position
		bullet.rotation = global_rotation
		
		bullet.direction = Vector2.RIGHT.rotated(global_rotation) 
