extends Node2D

onready var death_timer = $DeathTimer
onready var stats = $"../Stats"

func _ready():
	start_death_timer(5) # how long the projectile flies for

func get_death_time_left():
	return death_timer.time_left

func start_death_timer(duration):
	death_timer.start(duration)

func _on_DeathTimer_timeout():
	stats.health = 0

func _on_Timer_timeout():
	pass
