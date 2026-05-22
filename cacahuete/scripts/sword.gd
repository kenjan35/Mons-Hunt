extends Node3D

@onready var weapon_ray_cast = $RayCast3D

var can_attack : bool = true
var attack_cooldown : float = 0.5

func use_weapon():
	if not can_attack:
		return
		
	can_attack = false
	
	if weapon_ray_cast.is_colliding():
		var target = weapon_ray_cast.get_collider()
		if target.has_method("take_damage"):
			target.take_damage(10)
			
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
