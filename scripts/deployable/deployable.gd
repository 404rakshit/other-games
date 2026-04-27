extends Node2D
class_name Deployable

# --- Shared Properties ---
# Every deployable will have these, so we define them once here.
var creator: Node2D
var base_damage: float = 10.0
var lifespan: float = 0.0 # 0 can mean infinite until triggered

# --- Virtual Functions ---
# These do nothing here, but act as a template.
# Child scripts will "override" these to do specific things.

func activate() -> void:
	# Called right after the item is spawned into the world
	pass 

func trigger_effect() -> void:
	# The main event (the explosion, the heal, the trap springing)
	pass 

func destroy() -> void:
	# Standard cleanup
	queue_free()
