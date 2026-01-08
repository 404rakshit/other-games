extends Node
class_name Stopwatch

var time = 0.0
var stopped = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stopped:
		return
	time += delta

func reset():
	stopped = false
	#time = 0.0

func time_to_str() -> String:
	var sec = fmod(time, 60)
	var mint = time / 60
	
	var format_str = "%02d : %02d"
	var actual_str = format_str % [mint, sec]
	return actual_str
	
