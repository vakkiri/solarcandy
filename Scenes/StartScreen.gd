extends Node2D


var blink_timer = 0
var blink_time = 0.75


# Called when the node enters the scene tree for the first time.
func _ready():
	$Glow.get_material().set_shader_param("screen_width", get_viewport().size.x)
	$Glow.get_material().set_shader_param("screen_height", get_viewport().size.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("ui_accept"):
		get_tree().change_scene("res://Scenes/Game.tscn")
	
	blink_timer -= delta
	if blink_timer <= 0.0:
		blink_timer += blink_time
		$PressStart.visible = !$PressStart.visible
	
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
