extends Node2D

const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")
const DETONATOR_SCENE = preload("res://scenes/enemy/varients/detonator_enemy.tscn")
const RANGED_ENEMY = preload("res://scenes/enemy/varients/ranged_enemy.tscn")

@onready var player = $Player
@onready var hud = $HUD
@onready var stopwatch_label: Label = $HUD/Control/TimerLabel
@onready var level_up_screen = $LevelUpScreen
@onready var game_over_screen = $GameOverScreen
@onready var pause_menu_screen = $PauseMenuScreen

var stopwatch : Stopwatch

# --- NEW: Spawn Weights ---
# Higher number = more common. 
var enemy_spawn_weights = {
	ENEMY_SCENE: 65,       # 65% relative chance
	RANGED_ENEMY: 25,      # 25% relative chance
	DETONATOR_SCENE: 10    # 10% relative chance
}
var total_weight: int = 0

func _ready() -> void:
	# Calculate the total weight once when the game starts
	for weight in enemy_spawn_weights.values():
		total_weight += weight
		
	var max_health = player.health_component.max_health
	hud.set_max_health(max_health)
	hud.menu_paused.connect(pause_menu_screen.toggle_puase_menu)
	
	stopwatch = get_tree().get_first_node_in_group("stopwatch")
	
	player.health_component.health_changed.connect(hud.update_health)
	player.experience_gained.connect(hud.update_xp)
	#player.leveled_up.connect(_on_player_leveled_up)

func _process(_delta: float) -> void:
	update_stopwatch_label()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu_screen.toggle_puase_menu()

func update_stopwatch_label():
	stopwatch_label.text = stopwatch.time_to_str()

func _on_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy():
	# 1. Pick a scene based on our weights
	var chosen_scene = get_random_enemy_scene()
	
	# 2. Instantiate it
	var new_enemy : CharacterBody2D = chosen_scene.instantiate()
	
	# 3. Position it dynamically around the player
	new_enemy.global_position = get_spawn_position()
	
	add_child(new_enemy)

# --- HELPER FUNCTIONS ---

func get_random_enemy_scene() -> PackedScene:
	# Pick a random number between 0 and our total weight
	var random_value = randi() % total_weight
	var current_weight = 0
	
	# Loop through the dictionary to find which bracket the random number fell into
	for scene in enemy_spawn_weights.keys():
		current_weight += enemy_spawn_weights[scene]
		if random_value < current_weight:
			return scene
			
	return ENEMY_SCENE # Fallback

func get_spawn_position() -> Vector2:
	# 1. Define how far away the enemies should spawn (adjust this so they spawn just off-screen)
	var spawn_radius: float = 700.0 
	
	# 2. Pick a random angle between 0 and 360 degrees (TAU is 2 * PI radians in Godot)
	var random_angle: float = randf() * TAU
	
	# 3. Use Trigonometry to convert the angle and radius into X and Y offsets
	var offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
	
	# 4. Add the offset to the player's current position
	return player.global_position + offset

# --- EXISTING FUNCTIONS ---

func _on_player_leveled_up(_new_level: int):
	level_up_screen.show_options()

func _on_level_up_screen_upgrade_selected(upgrade_item: Upgrade) -> void:
	player.apply_upgrade(upgrade_item)

func _on_player_player_died() -> void:
	$Sound/ThemeMusic.stop()
	game_over_screen.game_over()
