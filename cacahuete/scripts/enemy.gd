extends CharacterBody3D

const SPEED = 5

@export var player_path: NodePath

@onready var agent = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player = null

func _ready() -> void:
	player = get_node(player_path)
	
func _physics_process(_delta: float) -> void:
	
	agent.set_target_position(player.global_position)
	if agent.is_target_reachable():
		var next_path = agent.get_next_path_position()
		velocity = (next_path - global_position).normalized() * SPEED 
	else:
		velocity = Vector3.ZERO
	apply_gravity(_delta)
	move_and_slide()

func apply_gravity(_delta):
	if not is_on_floor():
		velocity.y -= gravity
