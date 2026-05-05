extends Node2D

@export var map_size = Vector2(10000, 10000)
@export var min_dist = 800.0
@onready var multimesh_node = $MultiMeshInstance2D
@onready var nav_region = $".." # Assumes it's a child of NavigationRegion2D

var grid = {} 
var cell_size = 300.0
var final_positions = []

func _ready():
	# 1. Run math-heavy generation
	generate_data()
	# 2. Tell the GPU to draw them all at once
	apply_to_multimesh()
	# 3. Tell AI to find paths around them
	bake_nav()

func generate_data():
	var step = 80
	for x in range(0, map_size.x, step):
		for y in range(0, map_size.y, step):
			var pos = Vector2(x, y) + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			
			# OPTIMIZED: Grid-based distance check (Fast)
			if is_far_enough(pos):
				final_positions.append(pos)
				add_to_grid(pos)

func is_far_enough(pos):
	var grid_pos = Vector2i(pos / cell_size)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var neighbor = grid_pos + Vector2i(x, y)
			if grid.has(neighbor):
				for other in grid[neighbor]:
					if pos.distance_to(other) < min_dist:
						return false
	return true

func add_to_grid(pos):
	var grid_pos = Vector2i(pos / cell_size)
	if not grid.has(grid_pos): grid[grid_pos] = []
	grid[grid_pos].append(pos)

func apply_to_multimesh():
	var mm = multimesh_node.multimesh
	mm.instance_count = final_positions.size()
	for i in range(final_positions.size()):
		var xform = Transform2D(randf_range(0, TAU), final_positions[i])
		mm.set_instance_transform_2d(i, xform)

func bake_nav():
	# Wait for objects to "exist" in the physics world
	await get_tree().process_frame 
	nav_region.bake_navigation_polygon()
