extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var game_over_anim = $ColorRect/Menu/GameOverAnimation	
@onready var final_kills_label = $ColorRect/Menu/KillLabel	
@onready var final_time_label = $ColorRect/Menu/TimeLabel		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	color_rect.material.set_shader_parameter("dissolve_amount", 0.0)
	game_over_anim.hide()

func game_over(kills: int, survival_time: String):
	visible = true
	final_kills_label.text = "Kills: " + str(kills)
	final_time_label.text = "Time: " + survival_time
	get_tree().paused =  true
	$Music/GameOver.play()
	
	var tween = create_tween()
	
	tween.tween_method(set_dissolve_amount, 0.0, 1.0, 1.5)
	
	# Optional: You can yield/await the tween to finish before showing your menu buttons
	await tween.finished
	
	game_over_anim.show()
	game_over_anim.play("default")
 
func _on_restart_button_pressed() -> void:
	get_tree().paused =  false
	get_tree().reload_current_scene()

func set_dissolve_amount(value: float):
	color_rect.material.set_shader_parameter("dissolve_amount", value)

func _on_main_menu_button_pressed() -> void:
	get_tree().paused =  false
	get_tree().change_scene_to_file("res://scenes/game/menu.tscn")
