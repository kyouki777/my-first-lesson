extends CharacterBody2D

@export var speed: float = 150.0
@onready var anim_player: AnimationPlayer = $sprite2/AnimationPlayer

var last_anim_direction: String = "Down"

func _physics_process(delta):

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# We normalize the direction to prevent faster diagonal movement
	# and then multiply by our speed.
	velocity = direction.normalized() * speed
	move_and_slide()
	
	update_animation(direction)

func update_animation(direction: Vector2):
	
	var anim_to_play: String = ""
	var new_anim_direction: String = last_anim_direction
	
	# --- Check if we are moving ---
	if direction != Vector2.ZERO:
		# We are moving. Decide which direction has priority (for diagonals).
		
		# Check if horizontal movement (x-axis) is stronger than vertical (y-axis).
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				new_anim_direction = "Right"
			else:
				new_anim_direction = "Left"
		else:
			# Vertical movement is stronger (or equal).
			if direction.y > 0:
				new_anim_direction = "Down"
			else:
				new_anim_direction = "Up"
		
		# Set the animation to the "Run" version of our direction.
		anim_to_play = new_anim_direction
		
	# --- We are NOT moving ---
	else:
		# We are idle. Play the "Idle" animation based on the LAST direction we moved.
		anim_to_play = "Idle"
	
	
	# --- Play the animation ---
	
	# If we are moving, update the last_anim_direction for the next idle state.
	if direction != Vector2.ZERO:
		last_anim_direction = new_anim_direction
	
	# This check is important!
	# We only call .play() if the animation we want to play
	# is different from the one currently playing.
	# This prevents the animation from restarting on every frame.
	if anim_player.current_animation != anim_to_play:
		anim_player.play(anim_to_play)
