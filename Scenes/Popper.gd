extends Node2D

const EXPLOSION = preload("res://Scenes/ExplodingPopper.tscn")
const MAX_COLOURS = 5
var move_time = 0.5
var move_timer = 0.0
var fast_move_time = 0.5/16
var stuck = false
var vertical_step = Vector2(0, 0.5)
var horizontal_step = Vector2(1, 0)
var cell = 0
var move_time_accel = 0.25 / 60
var min_move_time = 0.1

enum Colour {
	BLOCK, # BLOCK type is a dummy to represent the on-board blocks 
	PURPLE,
	BLUE,
	WHITE,
	RED,
	ORANGE
}

var colour = Colour.BLOCK
var _on_board = false
var orig_rotation = 0

func is_block():
	return colour == Colour.BLOCK
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.rotation_degrees = -get_parent().get_rotation()
	orig_rotation = get_parent().get_rotation()
	if is_block():
		visible = false
		stuck = true

func init():
	var rand = get_parent().get_parent().get_node("Spawner").get_next()
	if rand == 0:
		colour = Colour.PURPLE
		$AnimatedSprite.animation = "purple-idle"
	elif rand == 1:
		colour = Colour.BLUE
		$AnimatedSprite.animation = "blue-idle" 
	elif rand == 2:
		colour = Colour.WHITE
		$AnimatedSprite.animation = "white-idle"
	elif rand == 3:
		colour = Colour.RED
		$AnimatedSprite.animation = "red-idle"
	else:
		colour = Colour.ORANGE
		$AnimatedSprite.animation = "orange-idle"
	position = get_parent().get_parent().to_pos(cell, orig_rotation)
	visible = true
	stuck = false
	
func check_pops():
	pass
	
func stick():
	stuck = true
	get_parent().get_parent().stick(self)

func kill():
	var e = EXPLOSION.instance()
	e.position = position
	e.rotation_degrees = $AnimatedSprite.rotation_degrees
	if colour == Colour.WHITE:
		e.animation = "white"
	elif colour == Colour.RED:
		e.animation = "red"
	elif colour == Colour.BLUE:
		e.animation = "blue"
	elif colour == Colour.PURPLE:
		e.animation = "purple"
	get_parent().add_child(e)
	if is_block():
		print("ERROR: TRIED TO FREE A BLOCK")
	else:
		queue_free()

func can_move_left():
	var xstep = Vector2(1, 0).rotated(deg2rad(-get_parent().get_rotation()))
	return get_parent().get_parent().space_empty(cell - xstep)

func can_move_right():
	var xstep = Vector2(1, 0).rotated(deg2rad(-get_parent().get_rotation()))
	return get_parent().get_parent().space_empty(cell + xstep)

func in_score_area():
	if orig_rotation == 0:
		return cell.x == 6 and cell.y == 12
	elif orig_rotation == 90:
		return cell.x == 12 and cell.y == 6
	elif orig_rotation == 180:
		return cell.x == 6 and cell.y == 0.5
	elif orig_rotation == 270:
		return cell.x == 0.5 and cell.y == 6
	else:
		print("ERROR: INVALD ORIG ROTATION ", orig_rotation)
		return false
	
func hurt():
	get_parent().get_parent().hurt()
	kill()

func on_board():
	var _min = get_parent().get_parent().MIN_CELL
	var _max = get_parent().get_parent().MAX_CELL
	return (
		cell.x >= _min and
		cell.x < _max and
		cell.y >= _min + 0.5 and
		cell.y < _max
	)
			
func move(movement):
	cell += movement
	position = get_parent().get_parent().to_pos(cell, orig_rotation)
	round_position()

func round_position():
	# ahahaha i found a bunch of floating point error edge cases saturday night
	# I didn't have time to refactor this garbage game
	# so instead i did THIS
	# so glad you poked through my source to find this
	# this game is some of the worst code i've written in years
	if cell.x > 0.9 and cell.x < 1.1:
		cell.x = 1.0
	if cell.y > 0.9 and cell.y < 1.1:
		cell.y = 1.0
	if cell.x > 1.9 and cell.x < 2.1:
		cell.x = 2.0
	if cell.y > 1.9 and cell.y < 2.1:
		cell.y = 2.0
	if cell.x > 2.9 and cell.x < 3.1:
		cell.x = 3.0
	if cell.y > 2.9 and cell.y < 3.1:
		cell.y = 3.0
	if cell.x > 3.9 and cell.x < 4.1:
		cell.x = 4.0
	if cell.y > 3.9 and cell.y < 4.1:
		cell.y = 4.0
	if cell.x > 4.9 and cell.x < 5.1:
		cell.x = 5.0
	if cell.y > 4.9 and cell.y < 5.1:
		cell.y = 5.0
	if cell.x > 5.9 and cell.x < 6.1:
		cell.x = 6.0
	if cell.y > 5.9 and cell.y < 6.1:
		cell.y = 6.0
	if cell.x > 6.9 and cell.x < 7.1:
		cell.x = 7.0
	if cell.y > 6.9 and cell.y < 7.1:
		cell.y = 7.0
	if cell.x > 7.9 and cell.x < 8.1:
		cell.x = 8.0
	if cell.y > 7.9 and cell.y < 8.1:
		cell.y = 8.0
	if cell.x > 8.9 and cell.x < 9.1:
		cell.x = 9.0
	if cell.y > 8.9 and cell.y < 9.1:
		cell.y = 9.0
	if cell.x > 9.9 and cell.x < 10.1:
		cell.x = 10.0
	if cell.y > 9.9 and cell.y < 10.1:
		cell.y = 10.0
	if cell.x > 10.9 and cell.x < 11.1:
		cell.x = 11.0
	if cell.y > 10.9 and cell.y < 11.1:
		cell.y = 11.0
	if cell.x > 11.9 and cell.x < 12.1:
		cell.x = 12.0
	if cell.y > 11.9 and cell.y < 12.1:
		cell.y = 12.0
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ystep = vertical_step.rotated(deg2rad(-get_parent().get_rotation()))
	var xstep = horizontal_step.rotated(deg2rad(-get_parent().get_rotation()))
	if move_time > min_move_time:
		move_time -= move_time_accel * delta
	else:
		move_time = min_move_time
	if on_board():
		_on_board = true
	if not stuck and not is_block():
		move_timer -= delta
		if move_timer <= 0:
			if Input.is_action_pressed("ui_down"):
				move_timer += fast_move_time
			else:
				move_timer += move_time
			move(ystep)
			if _on_board:
				if not get_parent().get_parent().space_empty(cell):
					if in_score_area():
						hurt()
					else:
						move(-ystep)
						get_node("/root/DropSound").play()
						stick()
		
		if _on_board and not stuck:
			if Input.is_action_just_pressed("ui_left"):
				if can_move_left():
					move(-xstep)
					get_node("/root/MoveSound").play()
			if Input.is_action_just_pressed("ui_right"):
				if can_move_right():
					move(xstep)
					get_node("/root/MoveSound").play()
			if Input.is_action_just_pressed("ui_down"):
				move_timer = 0
		
		
		
			
