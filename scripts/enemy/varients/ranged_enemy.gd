extends BaseEnemy

# --- RANGED EXPORTS ---
@export var shoot_range: float = 250.0
@export var fire_rate: float = 1.5
@export var projectile_scene: PackedScene # Drag your enemy_projectile.tscn here in the inspector!

# --- REFS ---
@onready var shoot_point = $ShootPoint
var fire_timer: Timer

func _custom_setup():
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true # We will manually restart it to sync with animations
	add_child(fire_timer)

func _check_attack_triggers():
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# If player gets close enough, stop and shoot!
	if distance_to_player <= shoot_range:
		current_state = State.ATTACKING
		velocity = Vector2.ZERO # Stop moving

# In BaseEnemy, we made this virtual function specifically for handling attack logic
func _process_attack_state(_delta: float):
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if the player ran away out of range
	if distance_to_player > shoot_range:
		current_state = State.CHASING # Go back to chasing them!
		return
		
	# Make sure the enemy still faces the player while standing still and shooting
	var direction = global_position.direction_to(player.global_position)
	animated_sprite.flip_h = direction.x < 0
	
	# If ready to fire, shoot!
	if fire_timer.is_stopped():
		_shoot(direction)

func _shoot(direction: Vector2):
	# 1. Play animation/sound
	animated_sprite.play("shoot") 
	# hit_sfx.play() # (Optional: Add a shoot sound here)
	
	# 2. Spawn the projectile
	var projectile = projectile_scene.instantiate()
	
	# 3. Set its starting position and direction
	projectile.global_position = shoot_point.global_position
	projectile.direction = direction
	
	# 4. Add it to the MAIN game scene, NOT as a child of the enemy.
	# If we added it to the enemy, the bullet would disappear if the enemy died!
	get_tree().current_scene.add_child(projectile)
	
	# 5. Start the cooldown
	fire_timer.start()
