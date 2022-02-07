extends Control


# Declare member variables here. Examples:
onready var bar = $HPBar

# Called when hannes' health changes
func set_health(value):
	bar.value = value

# Called when the node enters the scene tree for the first time.
func _ready():
	bar.value = HannesStats.health
	# warning-ignore:return_value_discarded
	HannesStats.connect("health_changed", self, "set_health")

