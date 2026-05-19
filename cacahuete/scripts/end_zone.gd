extends Area3D

func _on_body_entered(_body: Node3D) -> void:
	print("You fall from the island, stupid")
	get_tree().quit()
