extends CanvasLayer

signal upgrade_selected(upgrade_item: Upgrade)

@export var upgrade_options: Array[Upgrade]

# Grouping your buttons into an array makes iterating over them much easier!
@onready var option_btns: Array[Button] = [
	$ColorRect/LevelUpMenu/HBoxContainer/Option,
	$ColorRect/LevelUpMenu/HBoxContainer/Option2,
	$ColorRect/LevelUpMenu/HBoxContainer/Option3
]

func _ready() -> void:
	visible = false
	# It's usually better to populate the options right before showing them,
	# but we can leave it here if your options are static from the start.
	setup_options()

func setup_options() -> void:
	for i in range(option_btns.size()):
		var btn = option_btns[i]
		
		# Check if we actually have an upgrade for this button slot
		if i < upgrade_options.size():
			var item = upgrade_options[i]
			
			# 1. Set the text
			btn.text = item.title + "\n" + item.description 
			
			# 2. Set the dynamic logo
			if item.icon:
				print(item.icon)
				btn.icon = item.icon
				#btn.expand_icon = true # Ensures the image resizes to fit the button
			
			# 3. Dynamic Signal Connection
			# We use .bind(item) to pass the specific upgrade data straight to the function
			if not btn.pressed.is_connected(_on_option_pressed):
				btn.pressed.connect(_on_option_pressed.bind(item))
				
			btn.show()
		else:
			# Hide the button if we have fewer upgrades than buttons (e.g., only 2 upgrades left)
			btn.hide()

func show_options() -> void:
	# If you randomize your array during gameplay, call setup_options() here instead!
	# setup_options() 
	visible = true
	get_tree().paused = true

func finish_upgrade_selection(upgrade_item: Upgrade) -> void:
	visible = false
	get_tree().paused = false
	upgrade_selected.emit(upgrade_item)

# Notice how we only need ONE function now! 
# Because we used .bind() above, Godot automatically hands us the correct item.
func _on_option_pressed(upgrade_item: Upgrade) -> void:
	finish_upgrade_selection(upgrade_item)
