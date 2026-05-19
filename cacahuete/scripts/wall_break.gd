extends StaticBody3D

func execute() -> void:
	print("destroying the wall !")
	queue_free()
