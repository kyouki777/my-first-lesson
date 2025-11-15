extends CharacterBody2D

@export var speed: float = 120.0
@export var jumpscare_overlay: TextureRect   # Must be child of a CanvasLayer
@export var jumpscare_sound: AudioStreamPlayer2D
@export var game_over_scene: String = "res://Scenes/GameOverScene.tscn"

var player_node: Node2D = null

@onready var path_update_timer: Timer = $PathUpdateTimer
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var jumpscare_triggered: bool = false


func _ready():
	player_node = get_tree().get_first_node_in_group("player")
	path_update_timer.timeout.connect(update_target_location)
	update_target_location()

	# Hide jumpscare initially
	if jumpscare_overlay:
		jumpscare_overlay.visible = false
		

	# Ensure sound does not loop



func _physics_process(delta):
	if player_node == null or nav_agent.is_target_reached():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Path Following
	if not GlobalState.is_game_paused:
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		velocity = direction * speed
		move_and_slide()
	
	# Check collision with player
	if not jumpscare_triggered and player_node.global_position.distance_to(global_position) < 16:
		jumpscare_triggered = true
		_trigger_jumpscare()

func update_target_location():
	if player_node != null:
		nav_agent.target_position = player_node.global_position

func _trigger_jumpscare():
	# Freeze only the player
	if player_node.has_method("set_process"):
		player_node.set_process(false)

	# Show jumpscare instantly
	if jumpscare_overlay:
		jumpscare_overlay.visible = true

	# Play sound
	if jumpscare_sound:
		jumpscare_sound.play()

	# Delay then switch to GameOver
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1.0
	add_child(timer)
	timer.timeout.connect(_go_game_over)
	timer.start()

func _go_game_over():
	get_tree().change_scene_to_file(game_over_scene)
