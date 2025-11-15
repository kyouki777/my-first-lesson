extends CharacterBody2D

@export var attack_speed: float = 800.0
@export var wait_time: float = 2.9
@export var area_group_name: String = "targets"  # All 7 Area2Ds should be in this group

var chasing = false
var target: Node2D
var timer: Timer

func _ready():
	# Find nearest target
	target = _find_nearest_target()
	if not target:
		print("No target found!")
		return

	# Create 2-second delay before moving
	timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)
	timer.start()

func _find_nearest_target() -> Node2D:
	var areas = get_tree().get_nodes_in_group(area_group_name)
	var nearest: Node2D = null
	var nearest_dist = INF

	for area in areas:
		if area is Node2D:
			var dist = global_position.distance_to(area.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = area

	return nearest

func _on_timer_timeout():
	chasing = true

func _physics_process(delta):
	if not chasing or not target:
		return

	var direction = (target.global_position - global_position).normalized()
	velocity = direction * attack_speed
	move_and_slide()

	# Optional: when it reaches the target, do something
	if global_position.distance_to(target.global_position) < 16:
		_on_reach_target()

func _on_reach_target():
	chasing = false
	velocity = Vector2.ZERO
	print("Reached target: ", target.name)
	# Add your jumpscare / effect here
