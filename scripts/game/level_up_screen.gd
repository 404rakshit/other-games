extends CanvasLayer

signal upgrade_selected(upgrade_item: Upgrade)

# exports
@export var upgrade_options: Array[Upgrade]

@onready var option_1_btn = $ColorRect/LevelUpMenu/Option
@onready var option_2_btn = $ColorRect/LevelUpMenu/Option2
@onready var option_3_btn = $ColorRect/LevelUpMenu/Option3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	var item1 = upgrade_options[0]
	option_1_btn.text = item1.title + "\n" + item1.description 
	
	var item2 = upgrade_options[1]
	option_2_btn.text = item2.title + "\n" + item2.description 
	
	var item3 = upgrade_options[2]
	option_3_btn.text = item3.title + "\n" + item3.description 
	
func show_options():
	visible = true
	get_tree().paused = true
	
	
	
func finish_upgrade_selection(upgrade_item: Upgrade):
	visible = false
	get_tree().paused = false
	
	# senting the whole resource with the signal
	upgrade_selected.emit(upgrade_item)


func _on_option_pressed() -> void:
	finish_upgrade_selection(upgrade_options[0])

func _on_option_2_pressed() -> void:
	finish_upgrade_selection(upgrade_options[1])

func _on_option_3_pressed() -> void:
	finish_upgrade_selection(upgrade_options[2])
	#finish_upgrade_selection(3)
