extends Node


@export var grid_width: int = 20
@export var grid_height: int = 15
@export var extra_connection_chance: float = 0.12

var visited: Array = []
var  horizontal_walls: Array = [] # walls between (x,y) and (x+1,y)
var vertical_walls: Array = [] # walls between (x,y) and (x,y+1)

func _ready() -> void:
	pass

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
			horizontal_walls[x].append(true)
			vertical_walls[x].append(true)
	
	var start_x = randi() % grid_width
	var start_y = randi() % grid_height
	visited[start_x][start_y] = true
	
	var frontier: Array = []
	add_frontier_walls(start_x, start_y, frontier)
	
	while frontier.size() > 0:
		var index = randi() % frontier.size()
		var wall = randi() % frontier[index]
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
	var directions = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		if nx >=0 and nx < grid_width and ny >=0 and ny < grid_height:
			if not visited[nx][ny]:
				frontier.append({
					"from": Vector2i(x,y),
					"to": Vector2i(nx,ny),
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


func print_maze() -> void:
	var output = ""
	for y in grid_height:
		var row_top = ""
		var row_mid = ""
		for x in grid_width:
			row_top += "#"
			row_top += ("#" if vertical_walls[x][y] else " ")
			row_mid += " "
			row_mid += ("#" if horizontal_walls[x][y] else " ")
		output += row_top + "#\n"
		output += row_mid + "\n"
	for x in grid_width:
		output += "##"
	output += "#\n"
	print(output)
