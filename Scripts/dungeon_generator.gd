extends Node

@export var grid_width: int = 20
@export var grid_height: int = 15
@export var extra_connection_chance: float = 0.12

var visited: Array = []
var horizontal_walls: Array = []  # walls between (x,y) and (x+1,y)
var vertical_walls: Array = []    # walls between (x,y) and (x,y+1)

func _ready() -> void:
	generate()
	print_maze()

func generate() -> void:
	visited.clear()
	horizontal_walls.clear()
	vertical_walls.clear()
	
	for x in grid_width:
		visited.append([])
		horizontal_walls.append([])
		vertical_walls.append([])
		for y in grid_height:
			visited[x].append(false)
			horizontal_walls[x].append(true)  # true = wall present
			vertical_walls[x].append(true)
	
	var start_x = randi() % grid_width
	var start_y = randi() % grid_height
	visited[start_x][start_y] = true
	
	var frontier: Array = []
	add_frontier_walls(start_x, start_y, frontier)
	
	while frontier.size() > 0:
		var index = randi() % frontier.size()
		var wall = frontier[index]
		frontier.remove_at(index)
		
		var cell_a = wall["from"]
		var cell_b = wall["to"]
		
		if visited[cell_b.x][cell_b.y]:
			continue
		
		carve_wall(cell_a, cell_b, wall["direction"])
		visited[cell_b.x][cell_b.y] = true
		add_frontier_walls(cell_b.x, cell_b.y, frontier)
	
	add_extra_connections()

func add_frontier_walls(x: int, y: int, frontier: Array) -> void:
	var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		if nx >= 0 and nx < grid_width and ny >= 0 and ny < grid_height:
			if not visited[nx][ny]:
				frontier.append({
					"from": Vector2i(x, y),
					"to": Vector2i(nx, ny),
					"direction": dir
				})

func carve_wall(a: Vector2i, b: Vector2i, direction: Vector2i) -> void:
	if direction.x == 1:
		horizontal_walls[a.x][a.y] = false
	elif direction.x == -1:
		horizontal_walls[b.x][b.y] = false
	elif direction.y == 1:
		vertical_walls[a.x][a.y] = false
	elif direction.y == -1:
		vertical_walls[b.x][b.y] = false

func add_extra_connections() -> void:
	for x in grid_width:
		for y in grid_height:
			if x < grid_width - 1 and horizontal_walls[x][y]:
				if randf() < extra_connection_chance:
					horizontal_walls[x][y] = false
			if y < grid_height - 1 and vertical_walls[x][y]:
				if randf() < extra_connection_chance:
					vertical_walls[x][y] = false

@export var cell_size: int = 1 # tiles per cell, not counting the shared wall

func get_tile_grid() -> Array:
	var tile_width = grid_width * (cell_size + 1) + 1
	var tile_height = grid_height * (cell_size + 1) + 1
	
	var tiles = []
	for tx in tile_width:
		tiles.append([])
		for ty in tile_height:
			tiles[tx].append(1)  # start everything as wall
	
	for cx in grid_width:
		for cy in grid_height:
			var origin_x = cx * (cell_size + 1) + 1
			var origin_y = cy * (cell_size + 1) + 1
			for dx in cell_size:
				for dy in cell_size:
					tiles[origin_x + dx][origin_y + dy] = 0 # carve the cell's own floor
			
			if not horizontal_walls[cx][cy] and cx < grid_width - 1:
				for dy in cell_size:
					tiles[origin_x + cell_size][origin_y + dy] = 0
			
			if not vertical_walls[cx][cy] and cy < grid_height - 1:
				for dx in cell_size:
					tiles[origin_x + dx][origin_y + cell_size] = 0
	
	return tiles


func print_maze() -> void:
	var tiles = get_tile_grid()
	var tile_width = tiles.size()
	var tile_height = tiles[0].size()
	for ty in tile_height:
		var row = "["
		for tx in tile_width:
			row += str(tiles[tx][ty]) + ","
		row = row.trim_suffix(",")
		row += "]"
		print(row)
