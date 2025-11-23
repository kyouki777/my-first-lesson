extends CharacterBody2D

@export var speed: float = 150.0

@onready var anim_player: AnimationPlayer = $sprite2/AnimationPlayer
@onready var heartbeat: AudioStreamPlayer2D = $Heartbeat
@onready var footsteps: AudioStreamPlayer2D = $Footsteps
var caretaker: Node = null
#@onready var qte_sprite: Sprite2D = $QTE_Animation   # your separate QTE sprite
@export var qte_anim: AnimatedSprite2D
@onready var player_sprite: Sprite2D = $sprite2      # your normal walking sprite

#@export var mash_prompt: Node
#@export var mash_bar: ProgressBar
@export var mash_label: Label

@export var heavy_breathing : AudioStreamPlayer2D
@export var wood_breaking : AudioStreamPlayer2D



var last_anim_direction: String = "Down"
var last_dir: Vector2
var max_volume = 0.0
var min_volume = -30.0
var max_distance = 500.0


var is_caught = false
var mash_count = 0
var required_mash = 10   # how many presses needed to break free
var mash_timeout = 0.1   # seconds before mash_count slowly decays

var mash_timer := 0.0

func _ready():
	print("Player ready")
	if heartbeat and not heartbeat.playing:
		heartbeat.play()
	
	# hide mash UI and QTE animation
	mash_label.visible = false
	#mash_bar.value = 0
	#mash_label.text = ""
	if qte_anim:
		qte_anim.visible = false

func _physics_process(delta):
	if GlobalState.is_game_paused or is_caught or GlobalState.is_in_minigame:
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation(last_dir)
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	last_dir = direction
	velocity = direction.normalized() * speed
	move_and_slide()

	# Ensure caretaker reference is always valid
	if not is_instance_valid(caretaker):
		caretaker = get_tree().get_first_node_in_group("Caretaker")

	# Only update heartbeat if caretaker actually exists and is valid
	if is_instance_valid(caretaker):
		update_heartbeat()
	else:
		# If caretaker doesn't exist, stop the heartbeat
		if heartbeat.playing:
			heartbeat.stop()

	update_animation(direction)
	update_footsteps(direction)

	if is_caught:
		# update progress bar
		#if mash_bar:
			#mash_bar.value = mash_count / float(required_mash) * 100

		if mash_label:
			mash_label.visible = int(Time.get_ticks_msec() / 200) % 2 == 0
			#mash_label.text = str(mash_count) + " / " + str(required_mash)


		# check completion
		if mash_count >= required_mash:
			_break_free()
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
	if is_caught and event.is_action_pressed("ui_accept"):
		mash_count += 1
		print("Mash count:", mash_count)

		# Update progress bar
		#if mash_bar:
			#mash_bar.value = mash_count

		# Optional: flash the text


var mash_label_tween: Tween = null

func _start_label_flash():
	if not mash_label:
		return

	# Stop previous tween if any
	if mash_label_tween and mash_label_tween.is_valid():
		mash_label_tween.kill()

	# Make a new tween that loops
	var c = mash_label.modulate
	mash_label_tween = mash_label.create_tween()
	mash_label_tween.tween_property(mash_label, "modulate", Color(c.r, c.g, c.b, 0.2), 0.3)
	mash_label_tween.tween_property(mash_label, "modulate", Color(c.r, c.g, c.b, 1.0), 0.3)
	mash_label_tween.set_loops()  # infinite loop
	mash_label_tween.play()


func _stop_label_flash():
	if mash_label_tween and mash_label_tween.is_valid():
		mash_label_tween.kill()
	mash_label.modulate.a = 1.0  # restore full alpha


func _on_CatchTrigger_body_entered(body):
	if body == self:
		_get_caught()



func _get_caught():
	is_caught = true
	mash_count = 0

# show QTE animation
	if qte_anim:
		qte_anim.visible = true
		qte_anim.play("struggle")

# show mash UI
	mash_label.visible = true
	#mash_bar.visible = true
	#mash_bar.value = 0
#mash_label.text = "0 / " + str(required_mash)
	player_sprite.visible = false
# stop player
	velocity = Vector2.ZERO
	heavy_breathing.play()
	wood_breaking.play()
	
	_start_label_flash()




func _break_free():
	is_caught = false

	

	# hide QTE animation
	if qte_anim:
		qte_anim.stop()
		qte_anim.visible = false

	# hide mash UI
	mash_label.visible = false
	#mash_bar.visible = false
	#mash_bar.value = 0
	#mash_label.text = ""
	
	player_sprite.visible = true
	heavy_breathing.stop()
	_stop_label_flash()
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

	# Find any active caretaker in the scene tree
	var caretakers = get_tree().get_nodes_in_group("Caretaker")

	if caretakers.size() == 0:
		# No caretaker at all → stop heartbeat completely
		if heartbeat.playing:
			heartbeat.stop()
		return

	var caretaker = caretakers[0]
	var distance = global_position.distance_to(caretaker.global_position)
	var max_distance = 500.0

	# When caretaker is within detection range
	if distance <= max_distance:
		# Start heartbeat if not already playing
		if not heartbeat.playing:
			heartbeat.play()

		# Adjust volume and pitch dynamically
		var t = clamp(distance / max_distance, 0.0, 1.0)
		heartbeat.volume_db = lerp(-30.0, 0.0, 1.0 - t)
		heartbeat.pitch_scale = lerp(1.0, 1.5, 1.0 - t)
	else:
		# Too far → fade out and stop
		if heartbeat.playing:
			heartbeat.stop()


func update_footsteps(direction: Vector2):
	if not footsteps:
		return

	if direction != Vector2.ZERO or GlobalState.is_game_paused == true:
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
