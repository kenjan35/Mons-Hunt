extends CharacterBody3D

const SPEED = 8.0

@export var player_path: NodePath
@onready var agent = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player = null

func _ready() -> void:
	player = get_node(player_path)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	agent.set_target_position(player.global_position)
	if agent.is_target_reachable():
		var next_path = agent.get_next_path_position()
		var move_dir = (next_path - global_position).normalized() * SPEED
		velocity.x = move_dir.x
		velocity.z = move_dir.z
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
