extends Node2D

const POPPER = preload("res://Scenes/Popper.tscn")

enum State {
	SPAWN,
	FREEZE,
	FIX,
	ROTATE,
	DRAIN
}

const EPSILON = 0.1 # because i hate floating point
const MIN_CELL = 1
const MAX_CELL = 12
const MIDDLE = 6
const GRID_SIZE = 11
const CELL_SIZE = 16
const WEIGHT_CUTOFF = 6
var state = State.SPAWN
var poppers = []
var lives = 6
var dead = false
var fix_timer = 0
var fix_time = 1.0/30.0
var rotated_this_turn = true
var time = 0
var freeze_time = 0
var pop_time = 0.5
var post_freeze_state = null
var score = 0
var round_score = 0
var move_time = 0.5
var move_time_accel = 0.25 / 80.0
var min_move_time = 0.15

func hurt(change_state=true):
	lives -= 1
	if lives == 5:
		$Heart6.animation = "empty"
	elif lives == 4:
		$Heart5.animation = "empty"
	elif lives == 3:
		$Heart4.animation = "empty"
	elif lives == 2:
		$Heart3.animation = "empty"
	elif lives == 1:
		$Heart2.animation = "empty"
	elif lives == 0:
		$Heart1.animation = "empty"
		dead = true
	if change_state:
		state = State.SPAWN
			
func init_grid():
	# The +2 padding just makes the math a little cleaner in other areas
	for i in range(GRID_SIZE+2):
		poppers.append([])
		for _j in range(GRID_SIZE+2):
			poppers[i].append(null)
	var block = POPPER.instance()
	poppers[4][6] = block
	poppers[6][6] = block
	poppers[8][6] = block

func add_points(points):
	score += points
	$Score.set_score(score)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	init_grid()
	$Score.set_score(score)
	$Glow.get_material().set_shader_param("screen_width", get_viewport().size.x)
	$Glow.get_material().set_shader_param("screen_height", get_viewport().size.y)

func to_pos(cell, rot):
	var pos = (cell * CELL_SIZE) + $Board.get_node("TextureRect").rect_position
	if rot == 0:
		pos.x += 8
	elif rot == 90:
		pos.y += 8
	elif rot == 180:
		pos.x += 8
		pos.y += 8
	elif rot == 270:
		pos.x += 8
		pos.y += 8
	return pos
	
func space_empty(cell):
	# have i mentioned that i hate floating point
	cell.x = int(cell.x)
	cell.y = int(cell.y)
	
	var empty = not (
		cell.x <= MIN_CELL - EPSILON or
		cell.x >= MAX_CELL or
		cell.y <= MIN_CELL - EPSILON or
		cell.y >= MAX_CELL or
		poppers[cell.x][cell.y] != null
	)
	
	return empty

func pop_cell(cell):
	if poppers[cell.x][cell.y] == null:
		print("ERROR: TRIED TO POP NULL CELL")
	else:
		poppers[cell.x][cell.y].kill()
		round_score += 1
		var sound = get_node("/root/Pop1")
		add_points(1)
		if round_score > 4:
			add_points(round_score)
			sound = get_node("/root/Pop2")
		if round_score > 8:
			add_points(round_score * 2)
			sound = get_node("/root/Pop3")
		if round_score > 16:
			add_points(round_score * round_score)
			sound = get_node("/root/Pop4")
		sound.play()
			
		poppers[cell.x][cell.y] = null

func get_neighbours(cell, colour, memo):
	var neighbours = []
	var below = cell + Vector2(0, 1)
	var right = cell + Vector2(1, 0)
	var left = cell - Vector2(1, 0)
	var bottom = cell - Vector2(0, 1)
	if (
		cell.x < MAX_CELL and
		cell.y < MAX_CELL and
		cell.x >= MIN_CELL and
		cell.y >= MIN_CELL and
		poppers[cell.x][cell.y] != null and
		colour == poppers[cell.x][cell.y].colour
		):
		memo.append(cell)
		neighbours.append(cell)
		if not below in memo:
			neighbours += get_neighbours(below, colour, memo)
		if not right in memo:
			neighbours += get_neighbours(right, colour, memo)
		if not left in memo:
			neighbours += get_neighbours(left, colour, memo)
		if not bottom in memo:
			neighbours += get_neighbours(bottom, colour, memo)
	return neighbours
	
func check_pops():
	var cells_to_pop = []
	
	var memo = []
	# Again, the padding just exists to make the math nicer
	for i in range(GRID_SIZE+2):
		memo.append([])
		for _j in range(GRID_SIZE+2):
			memo[i].append(false)
			
	for row in range(MIN_CELL, MAX_CELL+1):
		for col in range(MIN_CELL, MAX_CELL+1):
			if not memo[row][col] and poppers[row][col] != null:
				var c = poppers[row][col].colour
				var n = get_neighbours(Vector2(row, col), c, memo)
				for cell in n:
					memo[cell.x][cell.y] = true
					if len(n) >= 4:
						cells_to_pop.append(cell)
	
	for cell in cells_to_pop:
		pop_cell(cell)
	
	# return if we popped anything; if so we may need to fix the board state
	return len(cells_to_pop) > 0

func stick(obj):
	var cell = obj.cell
	if poppers[cell.x][cell.y] != null:
		# I'm *petty* sure but not totally sure this only happens when a
		# column is "full"
		obj.kill()
		hurt()
		state = State.SPAWN
		return
	else:
		poppers[cell.x][cell.y] = obj
	
	var popped = check_pops()
	if popped:
		post_freeze_state = State.FIX
		freeze_time = pop_time
		state = State.FREEZE
	else:
		state = State.ROTATE
	
func spawn():
	var p = POPPER.instance()
	if $Board.get_rotation() == 0:
		p.cell = Vector2(6, 0)
	elif $Board.get_rotation() == 90:
		p.cell = Vector2(0, 6)
	elif $Board.get_rotation() == 180:
		p.cell = Vector2(6, 12)
	elif $Board.get_rotation() == 270:
		p.cell= Vector2(12, 6)
	$Board.add_child(p)
	p.init()
	state = State.FREEZE
	# Turns "start" and a new spawn, and we try to rotate once per turn
	rotated_this_turn = false
	# reset the combo score at start of round
	round_score = 0
		
func fix(delta):
	var moved = false
	fix_timer -= delta
	if fix_timer <= 0:
		fix_timer += fix_time
		# defaults for rotation == 0
		var start = Vector2(MIN_CELL, MIN_CELL)
		var row_step = Vector2(1, 0)
		var col_step = Vector2(0, 1)
		if $Board.get_rotation() == 90:
			start = Vector2(MIN_CELL, MAX_CELL-1)
			row_step = Vector2(0, -1)
			col_step = Vector2(1, 0)
		elif $Board.get_rotation() == 270:
			start = Vector2(MAX_CELL-1, MIN_CELL)
			row_step = Vector2(0, 1)
			col_step = Vector2(-1, 0)
		elif $Board.get_rotation() == 180:
			start = Vector2(MAX_CELL-1, MAX_CELL-1)
			row_step = Vector2(-1, 0)
			col_step = Vector2(0, -1)
		for i in range(GRID_SIZE):
			var needs_move = false
			for j in range(GRID_SIZE-1, -1, -1):
				var pos = start + row_step * i + col_step * j
				if poppers[pos.x][pos.y] == null:
					needs_move = true
				# The "block" poppers count as a space for others to land on
				elif poppers[pos.x][pos.y].is_block():
					needs_move = false
				if needs_move and poppers[pos.x][pos.y] != null:
					var below = pos + col_step
					poppers[pos.x][pos.y].move(col_step)
					poppers[below.x][below.y] = poppers[pos.x][pos.y]
					poppers[pos.x][pos.y] = null
					moved = true
		if not moved:
			# After fixing the board we may be able to pop more
			var popped = check_pops()
			if popped:
				state = State.FIX
			else:
				state = State.ROTATE
	
func check_rotate():
	# We only want to rotate once per turn
	if not rotated_this_turn:
		var weight = 0
		
		for row in range(MIN_CELL, MAX_CELL+1):
			for col in range(MIN_CELL, MAX_CELL+1):
				if poppers[row][col] != null and not poppers[row][col].is_block():
					var pos = poppers[row][col].cell
					if $Board.get_rotation() == 0:
						if pos.x > MIDDLE + EPSILON:
							weight += 1
						elif pos.x < MIDDLE - EPSILON:
							weight -= 1
					elif $Board.get_rotation() == 90:
						if pos.y < MIDDLE + EPSILON:
							weight += 1
						elif pos.y > MIDDLE - EPSILON:
							weight -= 1
					elif $Board.get_rotation() == 180:
						if pos.x < MIDDLE + EPSILON:
							weight += 1
						elif pos.x > MIDDLE - EPSILON:
							weight -= 1
					elif $Board.get_rotation() == 270:
						if pos.y > MIDDLE + EPSILON:
							weight += 1
						elif pos.y < MIDDLE - EPSILON:
							weight -= 1
		$Board.weight = weight	
		if weight <= -WEIGHT_CUTOFF:
			$Board.rotate_left()
		elif weight >= WEIGHT_CUTOFF:
			$Board.rotate_right()
		rotated_this_turn = true
		state = State.FIX
	else:
		state = State.DRAIN
		
func drain():
	var rotation = $Board.get_rotation()
	var start_pos
	var up
	var popped = false
	if rotation == 0:
		start_pos = Vector2(6, 11)
		up = Vector2(0, -1)
	elif rotation == 90:
		start_pos = Vector2(11, 6)
		up = Vector2(-1, 0)
	elif rotation == 180:
		start_pos = Vector2(6, 1.0)
		up = Vector2(0, 1.0)
	elif rotation == 270:
		start_pos = Vector2(1.0, 6)
		up = Vector2(1.0, 0)
	while poppers[start_pos.x][start_pos.y] != null:
		if not popped:
			poppers[start_pos.x][start_pos.y].position -= up * CELL_SIZE
			poppers[start_pos.x][start_pos.y].kill()
			popped = true
			hurt(false)
		var before = start_pos + up
		poppers[start_pos.x][start_pos.y] = poppers[before.x][before.y]
		start_pos = before
	if not popped:
		post_freeze_state = State.SPAWN
		freeze_time = 0
	else:
		post_freeze_state = State.DRAIN
		freeze_time = pop_time
	state = State.FREEZE
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if move_time > min_move_time:
		move_time -= move_time_accel * delta
	else:
		move_time = min_move_time
	$Background.get_material().set_shader_param("time", time)
	if not dead:
		if state == State.DRAIN:
			drain()
		elif state == State.FREEZE:
			if freeze_time > 0.0:
				freeze_time -= delta
			elif post_freeze_state != null:
				state = post_freeze_state
				post_freeze_state = null
		elif state == State.SPAWN:
			spawn()
		elif state == State.FIX:
			fix(delta)
		elif state == State.ROTATE:
			check_rotate()
	else:
		freeze_time -= delta
		if freeze_time <= 0:
			for child in $Board.get_children():
				if child.is_in_group("popper"):
					child.kill()
					break
			freeze_time += 0.3
		$GameOver.visible = true
