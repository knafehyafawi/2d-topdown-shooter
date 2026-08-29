extends Node2D

@onready var tile_map_layer: TileMapLayer = $"../NavigationRegion2D/TileMapLayer"

@export var grid_width: int = 50
@export var grid_height: int = 50
@export var extra_connection_chance: float = 0.375
@export var cell_size: int = 8 # tiles per cell, not counting the shared wall
@export var corridor_width: int = 8
@export var wall_source_id: int = 0
@export var wall_atlas_coords: Vector2i = Vector2i(0, 0)

var visited: Array = []
var horizontal_walls: Array = []  # walls between (x,y) and (x+1,y)
var vertical_walls: Array = []    # walls between (x,y) and (x,y+1)
var last_tile_width: int = 0
var last_tile_height: int = 0
const TILE_PIXEL_SIZE: int = 16

func _ready() -> void:
	var start_time = Time.get_ticks_msec()
	var loading_screen = get_tree().get_first_node_in_group("loading_screen")
	
	generate()
	paint_maze()
	
	var nav_region = get_tree().get_first_node_in_group("nav_region")
	if nav_region:
		var nav_polygon = nav_region.navigation_polygon
		nav_polygon.clear_outlines()
		var arena_rect = PackedVector2Array([
			Vector2(0,0),
			Vector2(last_tile_width * TILE_PIXEL_SIZE, 0),
			Vector2(last_tile_width * TILE_PIXEL_SIZE, last_tile_height * TILE_PIXEL_SIZE),
			Vector2(0, last_tile_height * TILE_PIXEL_SIZE)
		])
		nav_polygon.add_outline(arena_rect)
		
		nav_region.bake_navigation_polygon()
		await nav_region.bake_finished
		await get_tree().physics_frame
		
		# debug
		print("Nav bake doned doned fr fr. Took: ", Time.get_ticks_msec() - start_time, " ms")
		print("Nav bake result polygon exists: ", nav_region.navigation_polygon != null, " | at time: ", Time.get_ticks_msec())
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var camera = player.get_node("Camera2D")
		camera.position_smoothing_enabled = false
		
		player.global_position = get_center_spawn_point()
		
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = last_tile_width * TILE_PIXEL_SIZE
		camera.limit_bottom = last_tile_height * TILE_PIXEL_SIZE
	
	print("Total load time (generation → camera setup): ", Time.get_ticks_msec() - start_time, " ms")
	
	#var test_enemy_scene = preload("res://Scenes/enemy.tscn")
	#var test_enemy = test_enemy_scene.instantiate()
	#get_parent().add_child.call_deferred(test_enemy)
	#test_enemy.global_position = get_center_spawn_point() + Vector2(1500, 1500)
	##print("Test enemy spawned at: ", test_enemy.global_position, " | player at: ", get_center_spawn_point())
	
	if loading_screen:
		loading_screen.visible = false
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		var countdown_label = hud.get_node("MarginContainer/CountdownLabel")
		countdown_label.visible = true
		for i in [3, 2, 1]:
			countdown_label.text = str(i)
			await get_tree().create_timer(1.0).timeout
		countdown_label.visible = false
	
	if player:
		player.can_act = true
		var camera = player.get_node("Camera2D")
		camera.position_smoothing_enabled = true
	
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	print("Spawner found: ", spawner)
	if spawner:
		var points = get_valid_spawn_points()
		print("Valid spawn points found: ", points.size())
		spawner.start_spawning(get_valid_spawn_points())

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

func get_tile_grid() -> Array:
	var tile_width = grid_width * (cell_size + 1) + 1
	var tile_height = grid_height * (cell_size + 1) + 1
	
	var tiles = []
	for tx in tile_width:
		tiles.append([])
		for ty in tile_height:
			tiles[tx].append(1)
	
	for cx in grid_width:
		for cy in grid_height:
			var origin_x = cx * (cell_size + 1) + 1
			var origin_y = cy * (cell_size + 1) + 1
			for dx in cell_size:
				for dy in cell_size:
					tiles[origin_x + dx][origin_y + dy] = 0
			
			if not horizontal_walls[cx][cy] and cx < grid_width - 1:
				var mid = origin_y + int(cell_size / 2.0)
				for w in corridor_width:
					var offset = w - int(corridor_width / 2.0)
					var y_pos = mid + offset
					if y_pos >= origin_y and y_pos < origin_y + cell_size:
						tiles[origin_x + cell_size][y_pos] = 0
			
			if not vertical_walls[cx][cy] and cy < grid_height - 1:
				var mid_x = origin_x + int(cell_size / 2.0)
				for w in corridor_width:
					var offset = w - int(corridor_width / 2.0)
					var x_pos = mid_x + offset
					if x_pos >= origin_x and x_pos < origin_x + cell_size:
						tiles[x_pos][origin_y + cell_size] = 0
	
	cleanup_isolated_walls(tiles, tile_width, tile_height)
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

func paint_maze() -> void:
	tile_map_layer.clear()
	var tiles = get_tile_grid()
	last_tile_width = tiles.size()
	last_tile_height = tiles[0].size()
	for x in last_tile_width:
		for y in last_tile_height:
			if tiles[x][y] == 1:
				tile_map_layer.set_cell(Vector2i(x, y), wall_source_id, wall_atlas_coords)

func get_arena_pixel_size() -> Vector2:
	return Vector2(last_tile_width * TILE_PIXEL_SIZE, last_tile_height * TILE_PIXEL_SIZE)

func cleanup_isolated_walls(tiles: Array, tile_width: int, tile_height: int) -> void:
	for x in range(1, tile_width - 1):
		for y in range(1, tile_height - 1):
			if tiles[x][y] == 1:
				var open_neighbors = 0
				if tiles[x-1][y] == 0:
					open_neighbors += 1
				if tiles[x+1][y] == 0:
					open_neighbors += 1
				if tiles[x][y-1] == 0:
					open_neighbors += 1
				if tiles[x][y+1] == 0:
					open_neighbors += 1
				if open_neighbors >= 4:
					tiles[x][y] = 0

func get_center_spawn_point() -> Vector2:
	var tiles = get_tile_grid()
	@warning_ignore("integer_division")
	var center_x = last_tile_width / 2
	@warning_ignore("integer_division")
	var center_y = last_tile_height / 2
	
	if tiles[center_x][center_y] == 0:
		return Vector2(center_x * TILE_PIXEL_SIZE + TILE_PIXEL_SIZE / 2.0, center_y * TILE_PIXEL_SIZE + TILE_PIXEL_SIZE / 2.0)
	
	# spiral outward from center until an open tile is found
	for radius in range(1, max(last_tile_width, last_tile_height)):
		for dx in range(-radius, radius + 1):
			for dy in range(-radius, radius + 1):
				var tx = center_x + dx
				var ty = center_y + dy
				if tx >= 0 and tx < last_tile_width and ty >= 0 and ty < last_tile_height:
					if tiles[tx][ty] == 0:
						return Vector2(tx * TILE_PIXEL_SIZE + TILE_PIXEL_SIZE / 2.0, ty * TILE_PIXEL_SIZE + TILE_PIXEL_SIZE / 2.0)
	
	return Vector2(TILE_PIXEL_SIZE * 2, TILE_PIXEL_SIZE * 2)  # fallback, should never actually hit this

func get_valid_spawn_points() -> Array:
	var points = []
	for cx in grid_width:
		for cy in grid_height:
			var origin_x = cx * (cell_size + 1) + 1
			var origin_y = cy * (cell_size + 1) + 1
			var center_x = origin_x + cell_size / 2.0
			var center_y = origin_y + cell_size / 2.0
			points.append(Vector2(center_x * TILE_PIXEL_SIZE, center_y * TILE_PIXEL_SIZE))
	return points
