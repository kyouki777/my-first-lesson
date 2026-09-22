extends StaticBody2D

#script can be assigned to any new objects as long as the item in the inspector is assigned accordingly

@export var item:InvItem

var player = null
var player_in_range = false

func _ready():
	if item == null:
		print("WARNING! ITEM.TRES NOT ASSIGNED")

func _process(delta):
	if player_in_range == true:
		if Input.is_action_just_pressed("interact") :
			print("interacted")
			playercollect()
			await get_tree().create_timer(0.1).timeout
			self.queue_free()

func playercollect():
	player.collect(item)
	print("player collect func")

func _on_interactable_area_body_entered(body):
	print("in range")
	player = body
	player_in_range = true
