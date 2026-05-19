extends Control

@onready var base = $Base
@onready var handle = $Handle

@export var max_distance := 100.0
var joystick_center := Vector2.ZERO
var touch_index := -1

# Define which actions correlate to which direction
@export var action_left = "move_left"
@export var action_right = "move_right"
@export var action_up = "move_up"
@export var action_down = "move_down"

func _ready():
	# Hide the visual parts, but keep the root Control node active!
	base.hide()
	handle.hide()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			
			# --- NEW: Boundary Check based on the Node's size ---
			# get_global_rect() creates a box using this Control node's size and position.
			# If the touch is NOT inside this box, ignore it.
			if not get_global_rect().has_point(event.position):
				return 
			# ----------------------------------------------------
			
			touch_index = event.index
			joystick_center = event.position
			
			# Move the visual BASE and HANDLE, not the root Control node
			base.global_position = joystick_center
			handle.global_position = joystick_center
			
			base.show()
			handle.show()
			
		elif not event.pressed and event.index == touch_index:
			_reset_joystick()

	if event is InputEventScreenDrag and event.index == touch_index:
		var offset = event.position - joystick_center
		offset = offset.limit_length(max_distance)
		
		# Move the handle relative to the base's global position
		handle.global_position = base.global_position + offset
		
		# Calculate normalized strength (0.0 to 1.0)
		var strength = offset / max_distance
		_feed_input_system(strength)

func _feed_input_system(strength: Vector2):
	_set_action_strength(action_right, max(0, strength.x))
	_set_action_strength(action_left, max(0, -strength.x))
	_set_action_strength(action_down, max(0, strength.y))
	_set_action_strength(action_up, max(0, -strength.y))

func _set_action_strength(action: String, magnitude: float):
	var ev = InputEventAction.new()
	ev.action = action
	ev.pressed = magnitude > 0.1 
	ev.strength = magnitude
	Input.parse_input_event(ev)

func _reset_joystick():
	_feed_input_system(Vector2.ZERO)
	touch_index = -1
	
	# Hide the visual parts again
	base.hide()
	handle.hide()
