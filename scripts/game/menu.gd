extends Control

@onready var main_menu = $CenterContainer/MainMenu
@onready var level_selection = $CenterContainer/LevelSelection
@onready var fade_rect = $LoadingOverlay # Adjust the path if needed

func _ready() -> void:
	# Hide level selection immediately on start
	level_selection.visible = false
	level_selection.modulate.a = 0.0

func _on_play_pressed() -> void:
	transition_to(level_selection, main_menu)

func _on_exit_pressed() -> void:
	get_tree().quit()

# Logic to swap menus with a fade + scale effect
func transition_to(enter_node: Control, exit_node: Control):
	# Optional: Disable clicking during transition to prevent bugs
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	
	# 1. Fade OUT the current menu
	# We don't use .set_parallel() here so it finishes the fade before the next step
	tween.tween_property(exit_node, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	
	# 2. Swap visibility
	exit_node.visible = false
	enter_node.visible = true
	
	# Ensure the new menu starts transparent before fading in
	enter_node.modulate.a = 0.0
	
	# 3. Fade IN the new menu
	var tween_in = create_tween()
	tween_in.tween_property(enter_node, "modulate:a", 1.0, 0.2)
	
	await tween_in.finished
	
	# Re-enable clicking
	mouse_filter = Control.MOUSE_FILTER_PASS

# --- Other Signals ---
func _on_settings_pressed() -> void:
	pass 

func show_loading__screen():
	# 1. Block clicks so player doesn't click twice
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_rect.visible = true
	
	# 2. Fade to black
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	
	await tween.finished

func _on_desert_map_pressed() -> void:
	await show_loading__screen()
	get_tree().change_scene_to_file("res://scenes/game/world.tscn")

func _on_forest_map_pressed() -> void:
	await show_loading__screen()
	get_tree().change_scene_to_file("res://scenes/game/world-forest.tscn")


func _on_bac_pressed() -> void:
	# We want to enter the MainMenu and exit the LevelSelection
	transition_to(main_menu, level_selection)
