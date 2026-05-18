extends CharacterBody3D

@export var speed = 7.0
@export var jump_velocity = 7.0
@export var rotation_speed = 10.0

@onready var spring_arm = $SpringArm3D
@onready var mesh = $MeshInstance3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta


func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity


func get_movement_direction() -> Vector3:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Calculate vectors relative to the SpringArm
	var forward = spring_arm.global_transform.basis.z
	var right = spring_arm.global_transform.basis.x
	
	# Flatten them on the Y axis so the player doesn't move vertically
	forward.y = 0
	right.y = 0
	
	return (forward * input_dir.y + right * input_dir.x).normalized()


func handle_movement(direction: Vector3, delta: float):
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Handle mesh rotation: so the player will kind of turn visually
		var target_look = global_position + direction
		var target_basis = mesh.global_transform.looking_at(target_look, Vector3.UP).basis
		mesh.global_transform.basis = mesh.global_transform.basis.slerp(target_basis, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	
	var direction = get_movement_direction()
	
	handle_movement(direction, delta)
	
	move_and_slide()
