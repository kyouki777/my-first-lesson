extends Area2D

@export var dialog_name: String
@export var hidden_room_path: String = "res://Scenes/hidden_room.tscn"

# Inspector-assigned audio nodes
@export var door_open_player: AudioStreamPlayer2D
@export var door_close_player: AudioStreamPlayer2D

var player_in_area: bool = false
var dialog_started: bool = false  # prevent multiple triggers

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		dialog_started = false  # allow retrigger if player leaves

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact") and not dialog_started:
		dialog_started = true
		Dialogic.start(dialog_name)

		# Only connect this Area2D's handler
		if Dialogic.timeline_ended.is_connected(_on_dialog_end):
			Dialogic.timeline_ended.disconnect(_on_dialog_end)
		Dialogic.timeline_ended.connect(_on_dialog_end)

func _on_dialog_end():
	# Only trigger if Dialogic variable 'open_room' was set by the timeline
	if Dialogic.VAR.has("open_room") and Dialogic.VAR.get("open_room") == true:
		open_hidden_room()
		# reset the variable so other dialogues won’t trigger it accidentally
		Dialogic.VAR.set("open_room", false)


func open_hidden_room():
	print("hidden room func called")  # for debugging

	# Play door opening sound
	if door_open_player:
		door_open_player.play()

	var hidden_scene = load(hidden_room_path).instantiate()
	var main_node = get_tree().current_scene

	# Hide main scene
	main_node.visible = false

	# Add hidden room scene
	get_tree().root.add_child(hidden_scene)

	# Wait briefly for the flash
	await get_tree().create_timer(3).timeout

	# Remove hidden scene and show main again
	hidden_scene.queue_free()
	main_node.visible = true

	# Play door closing sound
	if door_close_player:
		door_close_player.play()

	# Disable all triggers permanently
	disable_all_triggers()

func disable_all_triggers():
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if child is Area2D:
				child.monitoring = false
				child.set_deferred("monitorable", false)
