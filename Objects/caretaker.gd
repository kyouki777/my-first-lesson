extends CharacterBody2D

@export var speed: float = 120.0

var player_node: Node2D = null

# --- Node References ---
@onready var path_update_timer: Timer = $PathUpdateTimer
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


# --- Godot Functions ---

func _ready():

	player_node = get_tree().get_first_node_in_group("player")
	path_update_timer.timeout.connect(update_target_location)
	update_target_location()

func _physics_process(delta):
	if player_node == null or nav_agent.is_target_reached():
		velocity = Vector2.ZERO
		print('hi')
		move_and_slide()
		return
	
	# --- Path Following Logic ---
	
	# 1. Get the current position
	var current_pos = global_position
	
	# 2. Get the *next* point on the path from the agent
	var next_path_pos = nav_agent.get_next_path_position()
	
	# 3. Calculate the direction to that *next* point
	var new_direction = current_pos.direction_to(next_path_pos)
	
	# 4. Set velocity and move
	velocity = new_direction * speed
	move_and_slide()

func update_target_location():
	if player_node != null:
		# Instead of getting the whole path,
		# we just tell the agent *where we want to go*.
		nav_agent.target_position = player_node.global_position
