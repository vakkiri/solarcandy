extends Node2D

const MAX_COLOURS = 5
var first
var second
var third

func get_next():
	var out = first
	first = second
	second = third
	randomize()
	third = randi() % MAX_COLOURS
	update_colours()
	return out

var colours = {
	1: Color(77.0/255.0, 187.0/255.0, 227.0/255.0),		# purple
	0: Color(125.0/255.0, 91.0/255.0, 227.0/255.0),		# blue
	2: Color(245.0/255.0, 255.0/255.0, 232.0/255.0),	# white
	3: Color(250.0/255.0, 45.0/255.0, 113.0/255.0),		# red
	4: Color(235.0/255.0, 165.0/255.0, 75.0/255.0),		# orange
}
		
func update_colours():
	$First.color = colours[first]
	$Second.color = colours[second]
	$Third.color = colours[third]
	
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	first = randi() % MAX_COLOURS
	second = randi() % MAX_COLOURS
	third = randi() % MAX_COLOURS
	update_colours()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
