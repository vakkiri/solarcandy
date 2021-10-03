extends Node2D


var blink_timer = 0
var blink_time = 0.75


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		blink_timer -= delta
		if blink_timer <= 0.0:
			blink_timer += blink_time
			$TextureRect3.visible = !$TextureRect3.visible
		
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
