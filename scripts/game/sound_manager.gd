extends Node
class_name SoundManager

static func play_sound(stream: AudioStream, position: Vector2, parent: Node):
	var player = AudioStreamPlayer2D.new()
	player.stream = stream
	player.global_position = position
	player.finished.connect(player.queue_free)
	
	parent.add_child(player)
	player.play()
	
