extends Node2D

@export_group("Spawn Settings")
## Add your Tree, Bush, and Bone scenes to this array in the Inspector
@export var environment_objects: Array[PackedScene] = []
@export var spawn_count: int = 550
@export var nav_region : NavigationRegion2D

@export_group("Boundary Settings")
## Link your empty StaticBody2D boundary node here
@export var boundary_body: StaticBody2D
## Buffer distance in pixels to keep spawned objects away from the absolute edge of the map walls
@export var wall_buffer: float = 32.0
## How thick the outer invisible physics wall should be
@export var wall_thickness: float = 500.0

# Internal boundary variables calculated from the Navigation Mesh
var min_x: float = 0.0
var max_x: float = 0.0
var min_y: float = 0.0
var max_y: float = 0.0

func _ready():
	# Wait for a physics frame to ensure the Navigation Map resource is loaded and ready
	await get_tree().physics_frame
	
	if nav_region and nav_region.navigation_polygon:
		_calculate_boundaries_from_nav()
		
		if boundary_body:
			_generate_dynamic_walls()

		spawn_environment()
	else:
		print("Warning: Missing NavigationRegion2D or NavigationPolygon! Spawning aborted.")

func _generate_dynamic_walls() -> void:
	# 1. Create a new CollisionPolygon2D node via code
	var collision_poly = CollisionPolygon2D.new()
	boundary_body.add_child(collision_poly)
	
	# 2. Define a massive outer frame box that completely surrounds the map
	var outer_min_x = min_x - wall_thickness
	var outer_max_x = max_x + wall_thickness
	var outer_min_y = min_y - wall_thickness
	var outer_max_y = max_y + wall_thickness
	
	# 3. Create the points array for a hollow polygon (The "Donut" Geometry Trick)
	var boundary_points: PackedVector2Array = PackedVector2Array()
	
	# Draw the outer container clock-wise
	boundary_points.append(Vector2(outer_min_x, outer_min_y))
	boundary_points.append(Vector2(outer_max_x, outer_min_y))
	boundary_points.append(Vector2(outer_max_x, outer_max_y))
	boundary_points.append(Vector2(outer_min_x, outer_max_y))
	boundary_points.append(Vector2(outer_min_x, outer_min_y)) # Close outer loop
	
	# Draw the inner playable space counter-clock-wise (this cuts a physical hole)
	boundary_points.append(Vector2(min_x, min_y))
	boundary_points.append(Vector2(min_x, max_y))
	boundary_points.append(Vector2(max_x, max_y))
	boundary_points.append(Vector2(max_x, min_y))
	boundary_points.append(Vector2(min_x, min_y)) # Close inner hole
	
	# 4. Assign the generated layout directly to the physics engine
	collision_poly.polygon = boundary_points
	print("Dynamic physics boundaries successfully built around the map layout!")

func _calculate_boundaries_from_nav() -> void:
	var points: PackedVector2Array = nav_region.navigation_polygon.vertices
	
	if points.is_empty():
		print("Navigation polygon has no vertices. Try baking it in the editor once first!")
		return

	# Initialize boundaries with the first vertex
	min_x = points[0].x
	max_x = points[0].x
	min_y = points[0].y
	max_y = points[0].y

	# Find the absolute minimum and maximum coordinates of the navigation shape
	for point in points:
		if point.x < min_x: min_x = point.x
		if point.x > max_x: max_x = point.x
		if point.y < min_y: min_y = point.y
		if point.y > max_y: max_y = point.y
		
	print("--- MAP BOUNDARIES DETECTED ---")
	print("X Range: ", min_x, " to ", max_x)
	print("Y Range: ", min_y, " to ", max_y)

func spawn_environment():
	if environment_objects.is_empty():
		print("No objects to spawn!")
		return
		
	# Apply the wall buffer to prevent objects from clipping into or spawning past your physical borders
	var safe_min_x = min_x + wall_buffer
	var safe_max_x = max_x - wall_buffer
	var safe_min_y = min_y + wall_buffer
	var safe_max_y = max_y - wall_buffer
		
	for i in range(spawn_count):
		# Pick a random scene from our list (Tree, Bush, or Bone)
		var random_scene = environment_objects.pick_random()
		var instance = random_scene.instantiate()
		
		# Generate a random position strictly within the safe calculated map limits
		var random_pos = Vector2(
			randf_range(safe_min_x, safe_max_x),
			randf_range(safe_min_y, safe_max_y)
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
