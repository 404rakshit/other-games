extends Deployable

# --- Node References ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var detonation_timer: Timer = $DetonationTimer
@onready var blast_radius: Area2D = $BlastRadius
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# NEW: We need to reference the shape to know how big to draw the debug circle
@onready var collision_shape: CollisionShape2D = $BlastRadius/CollisionShape2D

var is_exploding: bool = false

func _ready() -> void:
	base_damage = 5.0 
	detonation_timer.timeout.connect(_on_timer_timeout)
	activate()

func activate() -> void:
	# Debug print so you know it actually spawned
	#print("⏱️ Mine Armed! Counting down 2 seconds...")
	detonation_timer.start(2.0)
	
	if animation_player.has_animation("blink"):
		animation_player.play("blink")

func _on_timer_timeout() -> void:
	trigger_effect()

func trigger_effect() -> void:
	# 1. Trigger the Visual Debugger
	is_exploding = true
	queue_redraw() # This tells Godot to run the _draw() function right now
	
	# 2. Get Targets
	var bodies_in_blast = blast_radius.get_overlapping_bodies()
	
	# Debug print exactly what the mine sees
	#print("💥 MINE DETONATED! Total bodies caught in blast: ", bodies_in_blast.size())
	
	# 3. Deal Damage
	for body in bodies_in_blast:
		if body == creator:
			continue 
			
		if body.has_method("take_damage"):
			# Debug print to confirm damage is firing
			#print("   -> 🩸 Dealt ", base_damage, " damage to: ", body.name)
			body.take_damage(base_damage)
			
	# 4. Cleanup
	sprite.visible = false 
	
	# Failsafe: If you haven't assigned a sound file yet, it won't hang forever
	if explosion_sound.stream != null:
		explosion_sound.play()
		await explosion_sound.finished
	else:
		await get_tree().create_timer(0.3).timeout # Keep the red circle on screen for 0.3s
		
	destroy()

# NEW: Godot's built-in drawing function
func _draw() -> void:
	# Only draw this exactly when the explosion happens
	if is_exploding and collision_shape and collision_shape.shape is CircleShape2D:
		var radius = collision_shape.shape.radius
		# Draws a highly visible, semi-transparent red circle
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.0, 0.0, 0.5))
