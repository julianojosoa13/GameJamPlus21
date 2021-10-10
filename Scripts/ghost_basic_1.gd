extends KinematicBody

enum {
	IDLE = 0,
	WANDER = 1,
	CHASE = 2,
	REPOSITIONING = 3,
	SPOTTED = 4
}

export var deceleration = 2
export var vitesse = 2
export var acceleration = 2

var aggressif = false
var player = null
var velocity = Vector3.ZERO
var distance_limite =  20
var state = 0
var wander_direction = Vector3.ZERO


var initial_pos = Vector3.ZERO

onready var b_decal_noire = preload("res://Scenes/BulletDecal_noire.tscn")

func _ready():
	initial_pos = translation
	state = WANDER
	$Timer.start(1)

func _process(delta):		
	if(initial_pos.distance_to(translation) > (distance_limite + 1)):
		player = null
		state = REPOSITIONING
	
	match state :
		SPOTTED:
			$AnimationPlayer.stop()
			velocity = Vector3.ZERO
		CHASE :
			chase_state(delta)
		WANDER:
			wander_state(delta)
		IDLE :
			velocity = velocity.move_toward(Vector3.ZERO, delta * deceleration)	
			if ($Timer.time_left == 0):
				state = get_rand_array([IDLE,WANDER])
				$Timer.start(rand_range(1,3))		
		REPOSITIONING:
			var direction = (- translation + initial_pos).normalized()
			direction.y = 0
			velocity = velocity.move_toward(direction * vitesse, acceleration * delta )
			var lookdir = atan2(-velocity.x, -velocity.z)
			rotation.y = lookdir
			if (translation == initial_pos):
				state = IDLE
				
	velocity = move_and_slide(velocity)
	
	
	if state != SPOTTED:
		seek_player()
				
func turn(player):
#	var global_pos = global_transform.origin
#	var player_pos = player.global_transform.origin
#	var rotation_speed = 0.5
#	var wtransform = global_transform.looking_at(Vector3(player_pos.x,global_pos.y,player_pos.z),Vector3(0,1,0))
#	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rotation_speed)
#
#	global_transform = Transform(Basis(wrotation), global_transform.origin)
#

	pass
	
func chase_state(delta):
	if player != null:
		var direction = (player.translation - translation).normalized()
		direction.y = 0
		velocity = velocity.move_toward(direction * vitesse, acceleration * delta )
		turn(player)
	else:
		state = get_rand_array([IDLE,WANDER])

func wander_state(delta):
	var direction = (wander_direction- translation).normalized()
	direction.y = 0
	velocity = velocity.move_toward(direction * vitesse, acceleration * delta )
	var lookdir = atan2(-velocity.x, -velocity.z)
	rotation.y = lookdir
	if ($Timer.time_left == 0):
		state = get_rand_array([IDLE,WANDER])
#		print(state)
		$Timer.start(rand_range(1,3))
	if (translation.distance_to(wander_direction) <= vitesse):
		state = get_rand_array([IDLE,WANDER])
		$Timer.start(rand_range(1,3))
	
func seek_player():
	if player != null:
		state = CHASE

func get_rand_array(liste):
	randomize()
	return liste[randi() % liste.size()]


func _on_Area_body_entered(body):
	if (body.is_in_group("player")):
		player = body
		aggressif = true
			

func _on_PlayerChase_body_exited(body):
	if (body.is_in_group("player")) and player != null:
		player = null	
	aggressif = false


func _on_Timer_timeout():
	wander_direction = initial_pos + Vector3(rand_range(-distance_limite,distance_limite), 0, rand_range(-distance_limite,distance_limite))


func _on_RaycastTimer_timeout():
	var objet = $RayCast.get_collider()
	if objet != null and objet.is_in_group("sol"):
		var b = b_decal_noire.instance()
		objet.add_child(b)
		b.global_transform.origin = $RayCast.get_collision_point()
		
		b.look_at($RayCast.get_collision_point() + $RayCast.get_collision_normal(), Vector3.UP)
		b.translation.y = b.translation.y + 0.4
		get_parent().nombre_crotte += 1
	$RayCast/RaycastTimer.start(rand_range(5,10))
