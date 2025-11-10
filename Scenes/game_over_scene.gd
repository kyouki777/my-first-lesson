extends Node2D

@onready var mc = $CanvasLayer/MC # your SpriteAnimator2D or AnimatedSprite2D
@onready var retry_button = $CanvasLayer/RetryButton
@onready var fade = $CanvasLayer/ColorRect

func _ready():
	retry_button.visible = false
	retry_button.connect("pressed", _on_retry_pressed)

	# Start fully black, then fade in
	fade.modulate.a = 1.0
	var tween = fade.create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 3.5)

	mc.scale = Vector2(4, 4)
	mc.position = get_viewport_rect().size / 2
	# Play MC crying animation
	mc.play("cry")





	# Wait a bit before showing retry button
	await get_tree().create_timer(2.5).timeout
	retry_button.visible = true


func _on_retry_pressed():
	# Fade out before reloading main menu
	var tween = fade.create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.5)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
