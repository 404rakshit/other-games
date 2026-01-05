extends Node2D

const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")

@onready var player = $Player
@onready var hud = $HUD
@onready var level_up_screen = $LevelUpScreen

func _on_timer_timeout() -> void:
	spawn_enwmy()

func _ready() -> void:
	var max_health = player.health_component.max_health
	hud.set_max_health(max_health)
	
	player.health_component.health_changed.connect(hud.update_health)
	player.experience_gained.connect(hud.update_xp)
	#player.leveled_up.connect(_on_player_leveled_up)

func spawn_enwmy():
	var new_enemy : CharacterBody2D = ENEMY_SCENE.instantiate()
	
	var random_pos := Vector2(randf_range(0, 1000), randf_range(0, 600))
	new_enemy.global_position = random_pos
	
	add_child(new_enemy)

func _on_player_leveled_up(_new_level: int):
	level_up_screen.show_options()
	
