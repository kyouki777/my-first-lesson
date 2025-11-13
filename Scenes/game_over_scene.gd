extends Node2D

@onready var mc = $CanvasLayer/MC
@onready var retry_button = $CanvasLayer/RetryButton
@onready var fade = $CanvasLayer/ColorRect

var dialog_instance: Node = null

func _ready():
		# Wait before starting Dialogic

	#_start_dialogic_test()

	# Make sure no Dialogic scene or UI is active at start

	Dialogic.end_timeline()
	Dialogic.clear()

	retry_button.visible = false
	retry_button.connect("pressed", _on_retry_pressed)

	# Fade in from black
	fade.modulate.a = 1.0
	var tween = fade.create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 3.5)

	mc.scale = Vector2(4, 4)
	mc.position = get_viewport_rect().size / 2
	mc.play("cry")


	# Wait before showing retry button
	await get_tree().create_timer(2.5).timeout
	retry_button.visible = true


#func _start_dialogic_test():
	#dialog_instance = Dialogic.start("test")
	#add_child(dialog_instance)
	#dialog_instance.connect("timeline_end", Callable(self, "_on_dialogic_finished"))


#func _on_dialogic_finished():
	#print("Dialogic finished — stopping it completely.")
	#Dialogic.end_timeline()
	#Dialogic.clear()
	#dialog_instance = null


func _on_retry_pressed():
	print("Leaving scene — re-enabling Dialogic for next scene.")
	# Re-enable for next scene (optional)
	Dialogic.paused = false

	var tween = fade.create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.5)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
