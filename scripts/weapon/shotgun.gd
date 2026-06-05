extends GunBase

func _init() -> void:
	base_damage = 2
	fire_rate = 1.2
	projectiles_per_shot = 6 # Shoots 6 pellets at once
	spread_degrees = 20.0 # Wide cone of damage
	recoil_distance = 20.0 # Massive kick
	recovery_speed = 8.0
