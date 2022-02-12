extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/ProjectileDeathEffect.tscn")

enum {
	NORTH, #0
	NORTHEAST, #1
	EAST, #2
	SOUTHEAST, #3
	SOUTH, #4
	SOUTHWEST, #5
	WEST, #6
	NORTHWEST #7
}

export var SPEED = 50
export var STATE = NORTH

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var movementController = $MovementController
onready var animationPlayer = $AnimationPlayer

func init(direction, hannesPosition):
	STATE = direction
	global_position = hannesPosition
	return self

func _ready():
	pass

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, delta)
	knockback = move_and_slide(knockback)
	
	match STATE:
		NORTH:
			sprite.animation = 'N'
			velocity = velocity.move_toward(Vector2(0, -1), delta)
			
		NORTHEAST:
			sprite.animation = 'NE'
			velocity = velocity.move_toward(Vector2(1, -1), delta)
			
		EAST:
			sprite.animation = 'E'
			velocity = velocity.move_toward(Vector2(1, 0), delta)
			
		SOUTHEAST:
			sprite.animation = 'SE'
			velocity = velocity.move_toward(Vector2(1, 1), delta)
			
		SOUTH:
			sprite.animation = 'S'
			velocity = velocity.move_toward(Vector2(0, 1), delta)
			
		SOUTHWEST:
			sprite.animation = 'SW'
			velocity = velocity.move_toward(Vector2(-1, 1), delta)
			
		WEST:
			sprite.animation = 'W'
			velocity = velocity.move_toward(Vector2(-1, 0), delta)
			
		NORTHWEST:
			sprite.animation = 'NW'
			velocity = velocity.move_toward(Vector2(-1, -1), delta)
			
	velocity = velocity.normalized() * SPEED
	velocity = move_and_slide(velocity)
	if get_slide_count():
		stats.health = 0

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 150
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_Hitbox_area_entered(_area):
	stats.health = 0

func _on_SoftCollision_area_entered(_area):
	pass
	#stats.health = 0
