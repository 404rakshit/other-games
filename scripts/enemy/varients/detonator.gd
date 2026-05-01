extends BaseEnemy # Notice we are extending our custom class!

# --- DETONATOR EXPORTS ---
@export var explosion_damage: int = 30
@export var explosion_delay: float = 0.8 # Time between stopping and exploding
@export var trigger_range: float = 100.0 # How close the player needs to be to trigger it

# --- REFS ---
@onready var explosion_zone : Area2D = $ExplosionZone
var explosion_timer: Timer

func _process(_delta: float) -> void:
	if explosion_timer and !explosion_timer.is_stopped():
		queue_redraw()

# 1. We override _custom_setup to add our specific timers
func _custom_setup():
	explosion_timer = Timer.new()
	explosion_timer.one_shot = true
	explosion_timer.timeout.connect(_explode)
	add_child(explosion_timer)
	
	if current_state == State.ATTACKING:
		queue_redraw()

# 2. We override _check_attack_triggers to define when to attack
func _check_attack_triggers():
	# Check distance to the player
	if global_position.distance_to(player.global_position) <= trigger_range:
		_start_detonation()

func _draw():
	# Only draw if the timer is counting down
	if explosion_timer and !explosion_timer.is_stopped():
		# 1. Get the radius dynamically from the Area2D's CollisionShape
		var shape_owner = explosion_zone.shape_owner_get_owner(0)
		var radius = 50.0 # Default fallback
		
		if shape_owner is CollisionShape2D and shape_owner.shape is CircleShape2D:
			radius = shape_owner.shape.radius
		
		# 2. Calculate progress (0.0 to 1.0)
		var progress = 1.0 - (explosion_timer.time_left / explosion_delay)
		
		# 3. Drawing coordinates (relative to the enemy)
		var center = explosion_zone.position 
		
		# Draw the static "Limit" border so the player knows the max range
		draw_arc(center, radius, 0, TAU, 64, Color(1, 0.3, 0, 0.8), 2.0)
		
		# Draw the filling warning circle
		# It starts transparent and gets more opaque/red as it nears detonation
		var warning_color = Color(1, 0, 0, 0.2 + (progress * 0.4)) 
		draw_circle(center, radius * progress, warning_color)

# 3. Custom logic for the Detonator
func _start_detonation():
	current_state = State.ATTACKING
	velocity = Vector2.ZERO # Stop in place
	
	# Start the fuse!
	explosion_timer.start(explosion_delay)
	
	# Visual/Audio warnings for the player
	animated_sprite.play("windup") # Play your swelling/flashing animation
	
	# Optional: Create a rapid flashing effect to warn the player
	var tween = create_tween().set_loops()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _explode():
	# 1. Grab everything inside the blast radius
	var overlapping_bodies = explosion_zone.get_overlapping_bodies()
	
	# 2. Deal damage to them
	for body in overlapping_bodies:
		if body.has_method("take_damage") and body != self:
			body.take_damage(explosion_damage)
			
	# 3. Add explosion VFX/SFX here!
	# (e.g., instantiate an explosion particle effect scene)
	
	# 4. Destroy this enemy (Exploding kills it!)
	# We use queue_free() directly instead of taking damage so it doesn't trigger 
	# standard death logic, but you can call _on_health_component_died() if you 
	# STILL want it to drop an XP gem after exploding.
	queue_free()
