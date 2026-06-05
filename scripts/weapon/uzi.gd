extends GunBase

func _init() -> void:
	base_damage = 0.4
	fire_rate = 0.15 # Very fast
	projectiles_per_shot = 1
	spread_degrees = 8.0 # Spray and pray
	recoil_distance = 7.0 # Low kick per shot
	recovery_speed = 25.0
	
	is_continuous_audio = true
