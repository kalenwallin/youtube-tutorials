extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const ProjectileScene = preload("res://Enemies/Hannes/Projectiles/Projectile.tscn")

export var ACCELERATION = 150
export var MAX_SPEED = 25
export var FRICTION = 400
export var WANDER_TARGET_RANGE = 32

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var Hstats = HannesStats
var state = CHASE

onready var sprite = $Sprite
onready var stats = $HannesStats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var cardinalTimer = $ShootCardinal
onready var ordinalTimer = $ShootOrdinal

var main
var projectiles = [0,0,0,0,0,0,0,0]

func _ready():
	if sprite.frame == 0:
		sprite.offset.x = 0
	elif sprite.frame == 1:
		sprite.offset.x = 1
	elif sprite.frame == 2:
		sprite.offset.x = 2
	elif sprite.frame == 3:
		sprite.offset.x = 2
	state = pick_random_state([IDLE, WANDER])
	Hstats.set_health(Hstats.max_health)
	ordinalTimer.start(1)
	main = get_tree().current_scene

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	animationTree.set("parameters/Hover/blend_position", direction)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	Hstats.health -= area.damage
	knockback = area.knockback_vector * 100
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_HannesStats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("HStart")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("HStop")

func _shoot_cardinal():
	var start_position = global_position
	for n in range(0,8,2):
		projectiles[n] = ProjectileScene.instance().init(n, start_position)
		main.add_child(projectiles[n])

func _shoot_ordinal():
	var start_position = global_position
	for n in range(1,8,2):
		projectiles[n] = ProjectileScene.instance().init(n, start_position)
		main.add_child(projectiles[n])

func _on_ShootOrdinal_timeout():
	_shoot_ordinal()
	cardinalTimer.start(2)

func _on_ShootCardinal_timeout():
	_shoot_cardinal()
	ordinalTimer.start(2)
