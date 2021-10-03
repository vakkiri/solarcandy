extends Node2D

var board_rotation = 0
var visual_rotation = 0
var phase = 0
var rot_speed = 3.14 / 2.0
var flip_speed = 135
var weight = 0

func rotate_left():
	board_rotation -= 90
	if board_rotation < 0:
		board_rotation += 360
	weight *= -1
	
func rotate_right():
	print(weight)
	board_rotation += 90
	if board_rotation >= 360:
		board_rotation -= 360
	weight *= -1
	print(weight)

func get_rotation():
	return board_rotation
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var weight_rot
	if weight > 0:
		weight_rot = min(4, weight)
	else:
		weight_rot = max(-4, weight)
	var target_weight = board_rotation + weight_rot
	
	if visual_rotation != target_weight:
		var diff = target_weight - visual_rotation
		if diff > 90:
			visual_rotation += 360
		elif diff < -90:
			visual_rotation -= 360
		diff = target_weight - visual_rotation
		if diff <= 5 and diff >= -5:
			visual_rotation = target_weight
		elif visual_rotation < target_weight:
			visual_rotation += flip_speed * delta
		else:
			visual_rotation -= flip_speed * delta
	phase += rot_speed * delta
	rotation_degrees = visual_rotation + (sin(phase) * 1.0)
