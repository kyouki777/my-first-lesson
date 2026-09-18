extends Node2D

@onready var inv_ui = $UI/Inventory
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inv_ui.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
