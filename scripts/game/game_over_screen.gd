extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func game_over():
	visible = true
	get_tree().paused =  true
	$Music/GameOver.play()

func _on_restart_button_pressed() -> void:
	get_tree().paused =  false
	get_tree().reload_current_scene()
