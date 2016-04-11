
extends KinematicBody2D

#Imported classes
var TileDB = preload('TileDB.gd')
var Cell = preload('Cell.gd')
var CellSet = preload('CellSet.gd')

#Constants
const TILE_WIDTH=16
const TILE_HEIGHT=16
const TILE_SIZE=Vector2(TILE_WIDTH,TILE_HEIGHT)

#Export variables to control on the scene editor/inspector
export var movement = 0

#Member variables
var tileDB
var tilemap
var hit
var close 
var path
var can_move_player

func _ready():
	add_to_group ("characters", true)
	set_process_input(true)
	set_fixed_process(true)
	set_process(true)
	tilemap = get_node('../TileMap')
	tileDB = TileDB.new()
	hit = false
	close = []
	path = []
	can_move_player = false

func _process(delta):
	if (can_move_player and path.size() > 0):
		for i in path:
			print(i.to_string())
			move_to(i.get_pos())
			"""
			while get_pos() != i.get_pos():
				if (get_pos().x < i.get_pos().x):
					move(delta*Vector2(20,0))
				if (get_pos().x > i.get_pos().x):
					move(delta*Vector2(-20,0))
				if (get_pos().y < i.get_pos().y):
					move(delta*Vector2(0,20))
				if (get_pos().y > i.get_pos().y):
					move(delta*Vector2(0,-20))
			"""		
		can_move_player = !can_move_player

func _fixed_process(delta):
	update() #Runs _draw() function

func _draw():
	#Draws squares from the closed list
	if hit==true:
		for location in close:
			#draw_rect(Rect2(location.get_pos()-get_pos(), TILE_SIZE), Color(1,1,0,0.75))
			draw_rect(Rect2(location.get_pos()-get_pos(), TILE_SIZE), Color(0,255,255,0.75))
			draw_lines(location.get_pos()-get_pos())
			
		for i in path:
			draw_rect(Rect2(i.get_pos()-get_pos(), TILE_SIZE), Color(1,1,0,0.75))

func show_moveable_areas():
	"""
	Function calculates the amount a character can move based on tile cost
	"""
	var open = []
	var cell_set = CellSet.new()
	
	#Insert initial position into open list
	open.append(Cell.new(-1, get_pos(), null))
		
	while !open.empty():
		var current_location = open[0]
		var is_location_occupied = false
		
		if (current_location.get_pos() != get_pos()):
			for node in get_tree().get_nodes_in_group("characters"):
				if (node.get_pos() == current_location.get_pos()):
					is_location_occupied = true
		
		if (current_location.get_cost() < movement && !is_location_occupied):
			for neighbor in get_neighbors(current_location.get_pos()):
				var new_cost = current_location.get_cost() + get_tile_from_pos(neighbor).get_cost()
				var cell = Cell.new(new_cost, neighbor, current_location)
				
				if !cell_set.contains(cell):
					open.append(cell)
					cell_set.add(cell)
					
			close.append(current_location)
		open.pop_front()
		
func draw_lines(pos):
	"""
	Function draws outline around rectangles
	"""
	draw_line(pos, pos+Vector2(0,16), Color(0,0,0), 1)
	draw_line(pos, pos+Vector2(16,0), Color(0,0,0), 1)
	draw_line(pos+Vector2(16,16), pos+Vector2(16,0), Color(0,0,0), 1)
	draw_line(pos+Vector2(16,16), pos+Vector2(0,16), Color(0,0,0), 1)

func get_neighbors(pos):
	"""
	Function to get the neighboring cells based of of grid size
	"""
	var neighbors = []
	neighbors.append(Vector2(pos.x + TILE_WIDTH, pos.y))
	neighbors.append(Vector2(pos.x - TILE_WIDTH, pos.y))
	neighbors.append(Vector2(pos.x, pos.y + TILE_HEIGHT))
	neighbors.append(Vector2(pos.x, pos.y - TILE_HEIGHT))
	return neighbors

func get_tile_from_pos(pos):
	"""
	Decorator function to retrieve tile from a given position
	@See class TileDB.gd
	"""
	return tileDB.get_tile_from_pos(tilemap, pos)
	
func follow_mouse(mouse_pos):
	
	var current = null
	
	for i in close:
		if (i.get_pos() == mouse_pos):
			current = i
	
	if (current != null):
		path.clear()
		path.append(current)
		
		while current.get_pos() != get_pos():
		   current = current.get_parent()
		   path.append(current)
		
		path.invert()
	else:
		path.clear()
	
func _input(event):
	"""
	Tracks events being executed. In this case if a character is clicked on.
	"""
	if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed() and !event.is_echo():
		if tilemap.world_to_map(event.pos) == tilemap.world_to_map(get_pos()):
			hit = !hit
			close.clear()
			path.clear()
			show_moveable_areas()
		else:
			hit = false
			can_move_player = !can_move_player
			close.clear()
		
	if (event.type==InputEvent.MOUSE_MOTION):
		follow_mouse(tilemap.map_to_world(tilemap.world_to_map(event.pos)))
		#print("Mouse Motion at: ", tilemap.map_to_world(tilemap.world_to_map(event.pos)))
			
	#if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed() and !event.is_echo():
	#	print(get_tile(event.pos).get_name())
	
			
			