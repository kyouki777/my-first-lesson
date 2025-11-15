extends Control

signal puzzle_solved

@export var grid_size: Vector2i = Vector2i(5, 5)
@onready var grid_container: GridContainer = $GridContainer
const WIRE_TILE_1 = preload("uid://dke7puuixdikp")
const WIRE_TILE_2 = preload("uid://dlipg8xl40bl7")
const WIRE_TILE_3 = preload("uid://c872wjrm7d1ra")
const WIRE_TILE_4 = preload("uid://bpxshvmw3y1da")

signal winsignal

# 0=empty, 1=straight, 2=bend
# This is a 1D array representing your 5x5 grid.
var tile_types: Array[int] = [
	2, 1, 0, 0, 0,
	2, 1, 1, 2, 0,
	0, 2, 1, 2, 0,
	0, 2, 2, 2, 0,
	0, 0, 2, 1, 1
]

# We need references to our start and end points
var start_node_index: int = 0 # Top-left
var end_node_index: int = 24  # Bottom-right
var grid_nodes: Array[Node] = []

func _ready():
	grid_container.columns = grid_size.x
	generate_board()

func start_puzzle():
	GlobalState.is_in_minigame = true
	show()
	check_for_win() # Check if it's already solved
	
func generate_board():
	# Make sure the scene variable is set
	for i in tile_types.size():
		# 1. Instantiate AND cast to your script's class_name
		# This is the most important fix.
		var tile
		
		if tile_types[i] == 1: # Straight
			tile = WIRE_TILE_1.instantiate()
		elif tile_types[i] == 2: # Bend
			tile = WIRE_TILE_2.instantiate()
		elif tile_types[i] == 3: # full
			tile = WIRE_TILE_4.instantiate()
		else: # Empty
			tile = WIRE_TILE_3.instantiate()
		tile.custom_minimum_size = Vector2(60, 60)
		# Randomly rotate the tile
		var random_rotations = randi_range(0, 3)
		tile.current_rotation_step = random_rotations
		
		# 2. FIX: You must use get_node() on the 'tile' variable
		var texture_rect = tile.get_node("WireTexture") as TextureRect
		if texture_rect:
			texture_rect.rotation_degrees = random_rotations * 90
		else:
			print("Error: Could not find 'WireTexture' node in tile instance.")
		
		# 3. FIX: Add the tile ONLY to the GridContainer.
		#    (The 'add_child(tile)' line from before was an error)
		grid_container.add_child(tile)
		grid_nodes.append(tile)
		
		tile.rotated.connect(check_for_win)


func check_for_win():
	var q = [start_node_index]
	var visited = [start_node_index] # Nodes we've already checked
	var path_found = false
	
	while q.size() > 0:
		var current_index = q.pop_front()
		
		if current_index == end_node_index:
			path_found = true
			print("something?")
			break # We found the end!

		var current_tile = grid_nodes[current_index]

		# Check all 4 neighbors
		var neighbors = [
			current_index - grid_size.x, # Top
			current_index + 1,           # Right
			current_index + grid_size.x, # Bottom
			current_index - 1            # Left
		]
		for i in 4:
			var n_index = neighbors[i]
			
			# Check for valid index (on grid, not wrapped around)
			if n_index < 0 or n_index >= grid_nodes.size(): continue
			if i == 1 and n_index % grid_size.x == 0: continue # Wrapped left
			if i == 3 and n_index % grid_size.x == (grid_size.x - 1): continue # Wrapped right
			
			if n_index not in visited:
				# 5. FIX: You MUST cast this node too
				var neighbor_tile = grid_nodes[n_index] as WireTile
				
				if not neighbor_tile:
					continue
					
				# Check if the tiles connect
				if current_tile.can_connect_to(i) and neighbor_tile.can_connect_to((i + 2) % 4):
					visited.append(n_index)
					q.push_back(n_index)

	if path_found:
		print("PUZZLE SOLVED!")
		GlobalState.is_in_minigame = false
		hide()
		winsignal.emit()
