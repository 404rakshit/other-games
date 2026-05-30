extends Camera2D

@export_group("Shake Settings")
@export var decay: float = 0.75
@export var max_offset: Vector2 = Vector2(30, 20)
@export var max_roll: float = 0.05
@export var noise_speed: float = 80.0  # Higher = more frantic shake

var trauma: float = 0.0
var trauma_power: float = 3.5  # Float for finer tuning; higher = snappier falloff
var noise_y: float = 0.0

var noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	randomize()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.8
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3       # Layered noise = more organic rumble
	noise.fractal_lacunarity = 2.0  # Gap between octave frequencies

func _process(_delta: float) -> void:
	var real_delta = get_process_delta_time() / max(Engine.time_scale, 0.01)

	if trauma > 0:
		trauma = max(trauma - decay * real_delta, 0.0)
		_apply_shake(real_delta)
	else:
		offset = Vector2.ZERO
		rotation = 0.0

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

## Nuke-specific trigger: slams hard then sustains a rumble
## Call this once when the nuke fires
func trigger_nuke_shake() -> void:
	trauma = 1.0  # Instant full trauma

func _apply_shake(delta: float) -> void:
	var amount = pow(trauma, trauma_power)
	noise_y += delta * noise_speed

	rotation = max_roll * amount * noise.get_noise_2d(0, noise_y)

	# Clamp so the camera can never leave the safe shake zone
	offset.x  = max_offset.x * amount * noise.get_noise_2d(100, noise_y)
	offset.y  = max_offset.y * amount * noise.get_noise_2d(200, noise_y)
