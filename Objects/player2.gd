extends CharacterBody2D
class_name player2

@export var inv:Inv
@export var walk_speed: float = 100.0
@onready var floor: TileMapLayer = $"../Floor" #for footstep sounds

@onready var anim_player: AnimationPlayer = $sprite2/AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_status = false

var last_anim_direction: String = "Down"
var last_dir: Vector2

var is_walking : bool = false
var can_move : bool = false
var current_surface: String = "wood"

var last_surface : String = ""

func _physics_process(delta):
	
	if can_move:
		print("can move")
		var direction = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
		)

		last_dir = direction

		# Movement
		if gravity_status == true:
			velocity.y += gravity * delta 
			if direction:
				# Assign the horizontal speed to velocity.x
				velocity.x = walk_speed * direction.normalized().x 
			else:
				# low down to a stop when no keys are pressed
				velocity.x = move_toward(velocity.x, 0, walk_speed)

		else: #normal top down walking
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
		
		
func gravity_call():
	gravity_status = true
	print("gravity on")
	
func gravity_disable():
	gravity_status = false
	print("gravity false")

#detects which surface the player is on
func update_surface():
	var tile_position = floor.local_to_map(floor.to_local(global_position))
	
	var tile_data = floor.get_cell_tile_data(tile_position)
	
	if tile_data:
		current_surface = tile_data.get_custom_data("footstep_type")
		#print("current surface: " + current_surface)
	
func player():
	pass

func collect(item):
	inv.insert(item)

func disable_movement():
	can_move = false #not written yet
	
	print("disabling movement")

func enable_movement():
	can_move = true
	print("enabling movement")
