extends Node2D

@export_group("Spawn Settings")
## Add your Tree, Bush, and Bone scenes to this array in the Inspector
@export var environment_objects: Array[PackedScene] = []
@export var spawn_count: int = 150
@export var spawn_area: Vector2 = Vector2(5000, 5000)
@export var nav_region : NavigationRegion2D

func _ready():
	# Use call_deferred to ensure the scene tree is fully ready
	spawn_environment()

func spawn_environment():
	
	if environment_objects.is_empty():
		print("No objects to spawn!")
		return
		
	for i in range(spawn_count):
		# Pick a random scene from our list (Tree, Bush, or Bone)
		var random_scene = environment_objects.pick_random()
		var instance = random_scene.instantiate()
		
		var random_pos = Vector2(
			randf_range(-spawn_area.x / 2, spawn_area.x / 2),
			randf_range(-spawn_area.y / 2, spawn_area.y / 2)
		)
		
		instance.position = random_pos
		if nav_region:
			nav_region.add_child(instance)
	
	# CRITICAL: We must wait for the next frame so the engine 
	# sees the new tree collision shapes before baking.
	await get_tree().process_frame
	_update_navigation()

func _update_navigation():
	if nav_region:
		# Use 'on_thread = true' to prevent the game from freezing while baking
		nav_region.bake_navigation_polygon(true)
		print("Navigation Map Re-baked with trees!")
	else:
		print("Warning: NavigationRegion2D not found!")
