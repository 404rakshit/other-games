extends GPUParticles2D

func _ready() -> void:
	# Start the explosion the moment this is spawned
	emitting = true
	
	# Godot 4 GPUParticles2D have a built-in signal that fires when the lifetime ends.
	# We connect it directly to the node's own deletion function.
	finished.connect(queue_free)
