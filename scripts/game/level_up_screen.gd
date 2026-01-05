extends CanvasLayer

signal upgrade_selected(option_index: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
func show_options():
	get_tree().paused = true
	visible = true
	
func finish_upgrade_selection(option_index: int):
	visible = false
	get_tree().paused = false
	
	upgrade_selected.emit(option_index)


func _on_option_pressed() -> void:
	finish_upgrade_selection(1)

func _on_option_2_pressed() -> void:
	finish_upgrade_selection(2)

func _on_option_3_pressed() -> void:
	finish_upgrade_selection(3)
