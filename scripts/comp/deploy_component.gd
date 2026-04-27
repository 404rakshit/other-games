extends Node2D
class_name DeployComponent

# --- Exported Variables ---
# This allows you to drag-and-drop the specific ability (like TimeMine) 
# into the Inspector panel in the editor.
@export var current_deployable: PackedScene
@export var cooldown: float = 3.0

# --- State ---
var is_ready: bool = true
var cooldown_timer: Timer

func _ready() -> void:
	# Generate a Timer node via code so we don't have to manually 
	# build it in the editor every time we use this component.
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	add_child(cooldown_timer)

func trigger_deployment() -> void:
	# 1. Guard clauses to prevent errors or spamming
	if not is_ready:
		return
	if current_deployable == null:
		push_error("DeployComponent tried to deploy, but no scene is assigned!")
		return
		
	# 2. Instantiate the item
	var item_instance = current_deployable.instantiate()
	
	# 3. Setup the properties (Type-checking ensures it's actually a deployable)
	if item_instance is Deployable:
		item_instance.creator = get_parent() # The Player (or whoever owns this component)
		
	# 4. Add to the world
	# Pro-tip: Use current_scene instead of root to avoid breaking UI/level transitions later
	get_tree().current_scene.add_child(item_instance)
	
	# 5. Position it at the exact location of this Component
	item_instance.global_position = global_position
	
	# 6. Trigger Cooldown
	is_ready = false
	cooldown_timer.start()

func _on_cooldown_finished() -> void:
	is_ready = true

# Optional: A function to swap abilities mid-game
func set_deployable(new_scene: PackedScene, new_cooldown: float) -> void:
	current_deployable = new_scene
	cooldown = new_cooldown
	cooldown_timer.wait_time = cooldown
