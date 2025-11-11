extends CharacterBody2D

@export var speed: float = 150.0

@onready var anim_player: AnimationPlayer = $sprite2/AnimationPlayer
@onready var heartbeat: AudioStreamPlayer2D = $Heartbeat
@onready var footsteps: AudioStreamPlayer2D = $Footsteps
@onready var caretaker = get_tree().get_first_node_in_group("Caretaker")

var last_anim_direction: String = "Down"
var last_dir: Vector2
var max_volume = 0.0
var min_volume = -30.0
var max_distance = 500.0

#@onready var anim = $AnimationPlayer
@export var mash_prompt: Node

var is_caught = false
var mash_count = 0
var required_mash = 5   # how many presses needed to break free
var mash_timeout = 0.1   # seconds before mash_count slowly decays

var mash_timer := 0.0

func _ready():
	print("Player ready")
	if heartbeat and not heartbeat.playing:
		heartbeat.play()
	
	mash_prompt.visible = false

func _physics_process(delta):
	if GlobalState.is_game_paused or is_caught:
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation(last_dir)
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	last_dir = direction
	velocity = direction.normalized() * speed
	move_and_slide()

	update_animation(direction)
	update_heartbeat()
	update_footsteps(direction)

	#if caretaker:
		#print("Distance to caretaker:", global_position.distance_to(caretaker.global_position))
	#else:
		#print("Caretaker is null!")

func _process(delta: float) -> void:
	if is_caught:
		# simply check for success (no decay timer)
		if mash_count >= required_mash:
			print("required mash fulfilled")
			_break_free()


func _input(event):
	if is_caught and event.is_action_pressed("ui_accept"):  # space by default
		mash_count += 1
		# no timer used now
		#anim.play("struggle")  # quick animation while mashing
		print("Mash count:", mash_count)
		# optional: update mash prompt text if it's a Label
		if mash_prompt and mash_prompt is Label:
			mash_prompt.text = str(mash_count) + " / " + str(required_mash)



func _on_CatchTrigger_body_entered(body):
	if body == self:
		_get_caught()


func _get_caught():
	is_caught = true
	mash_count = 0
	mash_prompt.visible = true
	#anim.play("caught")   # play caught animation
	velocity = Vector2.ZERO


func _break_free():
	is_caught = false
	mash_prompt.visible = false
	#anim.play("escape")   # play breaking free animation
	print("Player escaped!")




func update_animation(direction: Vector2):
	var anim_to_play: String = ""
	var new_anim_direction: String = last_anim_direction
	if GlobalState.is_game_paused:
		anim_to_play = "Idle_" + last_anim_direction
		anim_player.play(anim_to_play)
	

	if direction != Vector2.ZERO:
		# Determine dominant axis for movement
		if abs(direction.x) > abs(direction.y):
			new_anim_direction = "Right" if direction.x > 0 else "Left"
		else:
			new_anim_direction = "Down" if direction.y > 0 else "Up"

		anim_to_play = new_anim_direction  # movement animation
	else:
		# Idle animation depends on last movement direction
		anim_to_play = "Idle_" + last_anim_direction

	# Update last direction if moving
	if direction != Vector2.ZERO:
		last_anim_direction = new_anim_direction

	# Only play if different from current
	if anim_player.current_animation != anim_to_play:
		anim_player.play(anim_to_play)


func update_heartbeat():
	if not heartbeat:
		return
	if not caretaker:
		heartbeat.volume_db = min_volume
		return

	var distance = global_position.distance_to(caretaker.global_position)
	var t = clamp(distance / max_distance, 0.0, 1.0)

	# Louder and faster when closer
	heartbeat.volume_db = lerp(min_volume, max_volume, 1.0 - t)
	heartbeat.pitch_scale = lerp(1.0, 1.5, 1.0 - t)

func update_footsteps(direction: Vector2):
	if not footsteps:
		return

	if direction != Vector2.ZERO:
		# Walking
		if not footsteps.playing:
			footsteps.play()
	else:
		# Idle
		if footsteps.playing:
			footsteps.stop()


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == self:
		_get_caught()

func _on_area_2d_2_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == self:
		_get_caught()

func _on_area_2d_3_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == self:
		_get_caught()
		
func _on_area_2d_4_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == self:
		_get_caught()

func _on_area_2d_5_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == self:
		_get_caught()
