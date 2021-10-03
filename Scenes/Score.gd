extends Node2D


const DIGIT = preload("res://Scenes/Digit.tscn")

var spacing = 20
var digits = []

func set_score(score):
	while not digits.empty():
		digits.back().queue_free()
		digits.pop_back()
		
	score = str(score)
	var offset = 0
	for digit in score:
		var d = DIGIT.instance()
		d.position = Vector2(offset, 0)
		d.set_digit(ord(digit) - ord('0'))
		offset += spacing
		digits.append(d)
		add_child(d)
	position = Vector2(21, -184)
	position.x -= spacing * (len(score) / 2.0)
	if len(score) % 2 != 0:
		position.x += 5
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
