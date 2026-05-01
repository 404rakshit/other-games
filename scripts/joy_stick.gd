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
	hide() # Start hidden until a touch occurs

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			joystick_center = event.position
			self.global_position = joystick_center
			show()
		elif not event.pressed and event.index == touch_index:
			_reset_joystick()

	if event is InputEventScreenDrag and event.index == touch_index:
		var offset = event.position - joystick_center
		offset = offset.limit_length(max_distance)
		handle.position = offset
		
		# Calculate normalized strength (0.0 to 1.0)
		var strength = offset / max_distance
		_feed_input_system(strength)

func _feed_input_system(strength: Vector2):
	# Simulate 'analog' strength for each direction
	# This feeds directly into Input.get_vector()
	_set_action_strength(action_right, max(0, strength.x))
	_set_action_strength(action_left, max(0, -strength.x))
	_set_action_strength(action_down, max(0, strength.y))
	_set_action_strength(action_up, max(0, -strength.y))

func _set_action_strength(action: String, magnitude: float):
	# This creates a 'fake' event that the engine treats as real
	var ev = InputEventAction.new()
	ev.action = action
	ev.pressed = magnitude > 0.1 # Threshold to consider it 'pressed'
	ev.strength = magnitude
	Input.parse_input_event(ev)

func _reset_joystick():
	# Clear the inputs so the player stops moving
	_feed_input_system(Vector2.ZERO)
	touch_index = -1
	handle.position = Vector2.ZERO
	hide()
