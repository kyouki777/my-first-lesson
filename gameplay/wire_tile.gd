class_name WireTile
extends Button

# Signal to tell the main puzzle we were clicked
signal rotated
@onready var wire_texture: TextureRect = $WireTexture

# 0=0°, 1=90°, 2=180°, 3=270°
var current_rotation_step: int = 0

# The 4 directions this tile connects to (top, right, bottom, left)
# We will set this when we create the tile.
# Example for a bendy wire (connects top and right): [true, true, false, false]
@export var connections: Array[bool] = [false, false, false, false]

func _ready():
	# Connect the button's own "pressed" signal to a function
	pressed.connect(_on_pressed)
	await get_tree().process_frame
	wire_texture.pivot_offset = wire_texture.size / 2.0

func _on_pressed():
	# 1. Rotate 90 degrees
	current_rotation_step = (current_rotation_step + 1) % 4
	
	# 2. Update the visual rotation
	wire_texture.rotation_degrees = current_rotation_step * 90
	
	# 3. Tell the main puzzle we changed
	rotated.emit()

# This checks if we can connect to a neighbor in a specific direction
# (0=top, 1=right, 2=bottom, 3=left)
func can_connect_to(direction_index: int) -> bool:
	# Get the connection for our *current* rotation
	var rotated_connections = connections.duplicate()
	for i in current_rotation_step:
		rotated_connections.insert(0, rotated_connections.pop_back())
		
	return rotated_connections[direction_index]
