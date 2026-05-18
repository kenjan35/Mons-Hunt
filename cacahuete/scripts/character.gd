extends CharacterBody3D

@export var speed = 7.0
@export var jump_velocity = 7.0

@onready var spring_arm = $SpringArm3D

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward = spring_arm.global_transform.basis.z
	var right = spring_arm.global_transform.basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
	var direction = (forward * input_dir.y + right * input_dir.x).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
