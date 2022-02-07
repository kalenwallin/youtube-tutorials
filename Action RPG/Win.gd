extends Node2D

var prev_scene;

# Called when the node enters the scene tree for the first time.
func _ready():
	 pass

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Tutorial.tscn")
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
