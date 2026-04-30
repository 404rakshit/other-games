#extends Control
#
#@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer/Label
#
#@onready var menu_1: VBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer/Menu1
#@onready var menu_2: VBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer/Menu2
#
#var menu_state
#
#func _on_start_btn_pressed() -> void:
	## Change to your actual game scene path
	#get_tree().change_scene_to_file("res://scenes/game/world.tscn")
#
#func _on_option_btn_button_up() -> void:
	#print("Open Options Menu")
	#
#
#func _on_exit_btn_pressed() -> void:
	#get_tree().quit()
#
#
#func _on_level_btn_pressed() -> void:
	#pass # Replace with function body.
#
#
#func _on_back_to_menu_btn_pressed() -> void:
	#pass # Replace with function body.

extends Control

# --- UI References ---
@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer/Label
@onready var menu_1: VBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer/Menu1
@onready var menu_2: VBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer/Menu2

# --- Audio Reference ---
@onready var bg_music: AudioStreamPlayer = $BackgroundMusic

# --- Constants for Sci-Fi Text ---
const HEADER_MAIN = "SYSTEM_MAIN"
const HEADER_LEVEL = "SECTOR_SELECT"

func _ready() -> void:
	# Initialize the menu to state 1
	_switch_menu(true)
	bg_music.autoplay = true
	if not bg_music.playing:
		bg_music.play()
	#bg_music.volume_db = 0.0

# --- Core Logic ---

## Handles the transition between Menu 1 and Menu 2
## If 'show_main' is true, shows Menu 1. If false, shows Menu 2.
func _switch_menu(show_main: bool) -> void:
	if show_main:
		menu_1.show()
		menu_2.hide()
		label.text = HEADER_MAIN
		# Optional: Reset focus to the first button for controller support
		menu_1.get_child(0).grab_focus() 
	else:
		menu_1.hide()
		menu_2.show()
		label.text = HEADER_LEVEL
		# Optional: Focus the back button or first level button
		menu_2.get_child(0).grab_focus()

# --- Music Transition Logic ---

func _fade_out_and_load(target_scene: String) -> void:
	#if bg_music:
		#var tween = create_tween()
		#
		## Ensure the transition is chained correctly
		#tween.tween_property(bg_music, "volume_db", -80.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		#
		## Connect the finished signal using a lambda
		#tween.finished.connect(func(): 
			#get_tree().change_scene_to_file(target_scene)
		#)
	#else:
		# Fallback if music node is missing
		get_tree().change_scene_to_file(target_scene)

# --- Button Signals ---

# Logic for Menu 1 (Main)
func _on_start_btn_pressed() -> void:
	_switch_menu(false) # Go to Level Select

func _on_option_btn_button_up() -> void:
	# Add your options logic here
	print("ACCESSING_SETTINGS...")

func _on_exit_btn_pressed() -> void:
	get_tree().quit()

# Logic for Menu 2 (Level Select)
func _on_back_to_menu_btn_pressed() -> void:
	_switch_menu(true) # Return to Main Menu

func _on_level_btn_pressed() -> void:
	# Replace path with your actual world scene
	_fade_out_and_load("res://scenes/game/world.tscn")
	#var world_path = "res://scenes/game/world.tscn"
	#
	#if ResourceLoader.exists(world_path):
		#get_tree().change_scene_to_file(world_path)
	#else:
		#printerr("ERROR: Scene not found at ", world_path)


func _on_level_btn_2_pressed() -> void:
	_fade_out_and_load("res://scenes/game/world-forest.tscn")
