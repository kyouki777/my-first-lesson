extends Node2D

@onready var player_2: player2 = $Player2
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

@onready var stair2: CollisionShape2D = $collisions/stair2/CollisionShape2D2
@onready var stair2_2: CollisionShape2D = $collisions/stair2/CollisionShape2D2/stair2/CollisionShape2D3

@onready var stair3: CollisionShape2D = $collisions/stair3/CollisionShape2D2
@onready var stair3_2: CollisionShape2D = $collisions/stair3/stair3/CollisionShape2D2

@onready var stair4: CollisionShape2D = $collisions/stair4/CollisionShape2D2

@onready var stair5: CollisionShape2D = $collisions/stair5/CollisionShape2D2

@onready var inv_ui = $UI/Inventory
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inv_ui.visible = false
	player_2.gravity_call()
	canvas_modulate.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_trigger_zone_body_entered(body: Node2D) -> void:
	if body is player2: 
		stair2.set_deferred("disabled", false)
		print("Player entered trigger 1")

func _on_trigger_zone_2_body_entered(body: Node2D) -> void:
	if body is player2: 
		stair3.set_deferred("disabled", false)
		stair2_2.set_deferred("disabled", true)
		print("Player entered trigger 1")

func _on_trigger_zone_3_body_entered(body: Node2D) -> void:
	if body is player2: 
		stair4.set_deferred("disabled", false)
		stair3_2.set_deferred("disabled", true)
		print("Player entered trigger 1")

func _on_trigger_zone_4_body_entered(body: Node2D) -> void:
	if body is player2: 
		stair5.set_deferred("disabled", false)
		print("Player entered trigger 1")
