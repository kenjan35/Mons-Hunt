extends CharacterBody3D

const CHASE = 10.0
const WALK = 3.0

@export var player_path: NodePath
@onready var agent = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player = null
var patrol_target_position : Vector3 = Vector3.ZERO
var is_waiting : bool = false
var is_map_ready : bool = false
var start_chase: float = 15.0
var last_known_position : Vector3 = Vector3.ZERO
var is_investigating : bool = false

func _ready() -> void:
	player = get_node(player_path)
	
	await get_tree().create_timer(0.1).timeout
	
	is_map_ready = true
	choose_random_patrol_position()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if not is_map_ready:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return
		
	agent.set_target_position(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player < start_chase and agent.is_target_reachable():
		is_investigating = false 
		
		last_known_position = player.global_position 
		
		var next_path = agent.get_next_path_position()
		var move_dir = (next_path - global_position).normalized() * CHASE
		velocity.x = move_dir.x
		velocity.z = move_dir.z
		
	elif last_known_position != Vector3.ZERO:
		run_investigation_logic()
		
	else:
		run_patrol_logic()
	
	move_and_slide()


func run_investigation_logic():
	agent.set_target_position(last_known_position)
	
	if is_waiting:
		velocity.x = 0
		velocity.z = 0
		return
		
	if agent.is_navigation_finished():
		handle_investigation_arrival()
		return

	var next_path = agent.get_next_path_position()
	var move_dir = (next_path - global_position).normalized() * CHASE
	velocity.x = move_dir.x
	velocity.z = move_dir.z


func handle_investigation_arrival():
	is_waiting = true
	velocity.x = 0
	velocity.z = 0
	
	await get_tree().create_timer(3.0).timeout
	last_known_position = Vector3.ZERO 
	
	choose_random_patrol_position()
	is_waiting = false


func run_patrol_logic():
	agent.set_target_position(patrol_target_position)
	
	if is_waiting:
		velocity.x = 0
		velocity.z = 0
		return
	if agent.is_navigation_finished():
		handle_waypoint_arrival()
		return

	var next_path = agent.get_next_path_position()
	var move_dir = (next_path - global_position).normalized() * WALK
	velocity.x = move_dir.x
	velocity.z = move_dir.z


func choose_random_patrol_position():
	var random_radius = randf_range(8.0, 12.0)
	var random_angle = randf_range(0, 2 * PI)
	var offset_x = cos(random_angle) * random_radius
	var offset_z = sin(random_angle) * random_radius
	var potential_target = global_position + Vector3(offset_x, 0, offset_z)
	
	patrol_target_position = NavigationServer3D.map_get_closest_point(agent.get_navigation_map(), potential_target)


func handle_waypoint_arrival():
	is_waiting = true
	velocity.x = 0
	velocity.z = 0
	
	await get_tree().create_timer(2.0).timeout
	
	if is_map_ready:
		choose_random_patrol_position()
	is_waiting = false


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
