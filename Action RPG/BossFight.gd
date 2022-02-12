extends Node2D

onready var winTimer = $WinTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Hannes_tree_exited():
	winTimer.start(0.5)

func _on_WinTimer_timeout():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Win.tscn")
