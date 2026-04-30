extends CanvasLayer

const TARGET_SCENE = "res://scenes/game/menu.tscn"

func _ready() -> void:
	visible = false

func toggle_puase_menu():
	visible = !visible
	get_tree().paused = !get_tree().paused 


func _on_resume_button_pressed() -> void:
	toggle_puase_menu()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_exit_to_main_menu_btn_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TARGET_SCENE)
