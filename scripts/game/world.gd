extends Node2D

const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")

@onready var player = $Player
@onready var hud = $HUD
@onready var level_up_screen = $LevelUpScreen
@onready var game_over_screen = $GameOverScreen

func _on_timer_timeout() -> void:
	spawn_enemy()

func _ready() -> void:
	var max_health = player.health_component.max_health
	hud.set_max_health(max_health)
	
	player.health_component.health_changed.connect(hud.update_health)
	player.experience_gained.connect(hud.update_xp)
	#player.leveled_up.connect(_on_player_leveled_up)

func spawn_enemy():
	var new_enemy : CharacterBody2D = ENEMY_SCENE.instantiate()
	
	var random_pos := Vector2(randf_range(0, 1000), randf_range(0, 600))
	new_enemy.global_position = random_pos
	
	add_child(new_enemy)

func _on_player_leveled_up(_new_level: int):
	level_up_screen.show_options()


func _on_level_up_screen_upgrade_selected(upgrade_item: Upgrade) -> void:
	player.apply_upgrade(upgrade_item)


func _on_player_player_died() -> void:
	$Sound/ThemeMusic.stop()
	game_over_screen.game_over()
