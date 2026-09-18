extends CharacterBody2D

@export var inv:Inv
@export var walk_speed: float = 100.0
@onready var floor: TileMapLayer = $"../Floor"

@onready var anim_player: AnimationPlayer = $sprite2/AnimationPlayer

var last_anim_direction: String = "Down"
var last_dir: Vector2

var is_walking : bool = false
var current_surface: String = "wood"

var last_surface : String = ""

func _ready() -> void:
	pass
func _physics_process(delta):
	
	
	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	last_dir = direction

	# Movement
	velocity = direction.normalized() * walk_speed
	move_and_slide()

	# Animation
	update_animation(direction)
	
	is_walking = direction != Vector2.ZERO
	
	if is_walking:
		update_surface()
		
		if current_surface != last_surface:
			AudioManager.play_footsteps(current_surface)
			last_surface = current_surface
			
		if not AudioManager.footsteps_audio.playing:
			AudioManager.play_footsteps(current_surface)
	else:
		AudioManager.stop_footsteps()

func update_animation(direction: Vector2):
	var anim_to_play: String = ""
	var new_anim_direction: String = last_anim_direction

	if direction != Vector2.ZERO:
		# Determine whether the player is moving
		# horizontally or vertically
		if abs(direction.x) > abs(direction.y):
			new_anim_direction = "Right" if direction.x > 0 else "Left"
		else:
			new_anim_direction = "Down" if direction.y > 0 else "Up"

		# Walking animation
		anim_to_play = new_anim_direction

		# Remember the direction
		last_anim_direction = new_anim_direction

	else:
		# Idle animation
		anim_to_play = "Idle_" + last_anim_direction

	# Only change animation if necessary
	if anim_player.current_animation != anim_to_play:
		anim_player.play(anim_to_play)
		
#detects which surface the player is on
func update_surface():
	var tile_position = floor.local_to_map(floor.to_local(global_position))
	
	var tile_data = floor.get_cell_tile_data(tile_position)
	
	if tile_data:
		current_surface = tile_data.get_custom_data("footstep_type")
		#print("current surface: " + current_surface)
	
	
