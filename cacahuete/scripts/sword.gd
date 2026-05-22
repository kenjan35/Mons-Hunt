extends Node3D

@onready var zone = $RayCast3D

func _process(_delta: float) -> void:
	if zone.is_colliding():
		var target = zone.get_collider()
		print(target)
