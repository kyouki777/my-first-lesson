extends CanvasLayer
@onready var play: Control = $play

@export var label_text: String = "Default Value"
@onready var label: Label = $play/Label

@export var minigame: Control
@onready var win: Control = $win
func _ready() -> void:
	if label:
		label.text = label_text
	
# targetobject.connect("theirsignal", our method)
func _on_button_pressed() -> void:
	play.visible = false
	minigame.visible = true
	
	#signal name has to be same
	minigame.connect("winsignal", togglewin)
	
func togglewin():
	minigame.visible = false
	win.visible = true
	AudioManager.play_sfx("clicksfx")


func _on_exit_pressed() -> void:
	# for Canvas UI parent to dissapear on use
	get_parent().visible = false
