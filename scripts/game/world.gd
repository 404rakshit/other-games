extends Node2D

const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")

func _on_timer_timeout() -> void:
	spawn_enwmy()

func spawn_enwmy():
	var new_enemy : CharacterBody2D = ENEMY_SCENE.instantiate()
	
	var random_pos := Vector2(randf_range(0, 1000), randf_range(0, 600))
	new_enemy.global_position = random_pos
	
	add_child(new_enemy)
