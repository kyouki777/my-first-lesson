# DialogTrigger.gd (attached to the Area2D trigger)
extends Area2D

@export var hidden_room_path: String = "res://HiddenRoom.tscn"

func open_hidden_room():
	var hidden_scene = load(hidden_room_path).instantiate()
	var main_node = get_tree().current_scene

	# Hide main scene
	main_node.visible = false

	# Add hidden scene
	get_tree().root.add_child(hidden_scene)

	# Wait a short moment
	await get_tree().create_timer(0.25).timeout

	# Remove hidden scene and show main again
	hidden_scene.queue_free()
	main_node.visible = true

	# Disable all triggers permanently
	disable_all_triggers()

func disable_all_triggers():
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if child is Area2D:
				child.monitoring = false
				child.set_deferred("monitorable", false)
