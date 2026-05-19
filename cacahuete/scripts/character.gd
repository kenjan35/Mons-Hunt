extends CharacterBody3D

@export var walk_speed = 7.0
@export var run_speed = 14.0
@export var jump_velocity = 7.0
@export var rotation_speed = 10.0

# Acceleration rate for switching between walking and running
@export var acceleration_speed = 5.0 

# Camera FOV settings for the zoom effect
@export var normal_fov = 75.0
@export var run_fov = 90.0

@onready var spring_arm = $SpringArm3D
@onready var mesh = $MeshInstance3D
@onready var camera = $SpringArm3D/Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed = 7.0
var is_game_paused: bool = false

func _physics_process(delta):
	manage_pause()
	if is_game_paused == false:
		apply_gravity(delta)
		
		var direction = get_movement_direction()
		
		handle_speed_and_zoom(direction, delta)
		handle_movement(direction, delta)
		handle_jump()
		
		move_and_slide()

func manage_pause():
	if Input.is_action_just_pressed("pause_game"):
		is_game_paused = not is_game_paused

# This is the tru way to pause the entire game !
# Since there is no UI for now, I will use mine to pause the player
#func manage_pause():
#	if Input.is_action_just_pressed("pause_game"):
#		get_tree().paused = not get_tree().paused

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta


func handle_jump():
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity


func get_movement_direction() -> Vector3:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward = spring_arm.global_transform.basis.z
	var right = spring_arm.global_transform.basis.x
	
	forward.y = 0
	right.y = 0
	
	return (forward * input_dir.y + right * input_dir.x).normalized()


func handle_speed_and_zoom(direction: Vector3, delta: float):
	var target_speed = walk_speed
	var target_fov = normal_fov
	
	if Input.is_action_pressed("run") and direction != Vector3.ZERO and is_on_floor():
		target_speed = run_speed
		target_fov = run_fov
		
	current_speed = lerp(current_speed, target_speed, acceleration_speed * delta)
	
	if camera:
		camera.fov = lerp(camera.fov, target_fov, acceleration_speed * delta)


func handle_movement(direction: Vector3, delta: float):
	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		var target_look = global_position + direction
		var target_basis = mesh.global_transform.looking_at(target_look, Vector3.UP).basis
		mesh.global_transform.basis = mesh.global_transform.basis.slerp(target_basis, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
