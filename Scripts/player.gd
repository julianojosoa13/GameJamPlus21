extends KinematicBody
export  var speed = 2
const ACCEL_DEFAULT = 10

var nbr_fantome = 0
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5
var life = 3
#var poursuivants = 0

var ouvert = false
var captured = false

enum {
	CONTROLLABLE = 0,
	CINEMATIQUE = 1,
	DEAD = 2,
	RESPAWN = 3,
	CAPTURING = 4
}

enum {
	BLEU = 0,
	VERT = 1,
	ROUGE = 2,
	JAUNE = 3
}

var initial_pos = Vector3.ZERO
var cam_accel = 40
var mouse_sense = 0.1
var snap

var angular_velocity = 30
var state = CONTROLLABLE

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()
var initial_direction = Vector3.ZERO

onready var head = $Head
onready var campivot = $Head/Camera
onready var mesh = $Armature/Skeleton/character

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initial_pos = translation
	initial_direction = global_transform.origin
	$CinematicCamera/TextureRect.visible = false
	nbr_fantome = 0
	captured = true
	
	#mesh no longer inherits rotation of parent, allowing it to rotate freely
#	mesh.set_as_toplevel(true)
	
func _input(event):
	#get mouse input for camera rotation
	match state :
		CONTROLLABLE:
			if event is InputEventMouseMotion:
				rotate_y(deg2rad(-event.relative.x * mouse_sense))
				head.rotate_x(deg2rad(event.relative.y * mouse_sense))
				head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(50))
				$paint.rotate_x(deg2rad(event.relative.y * mouse_sense))
				$paint.rotation.x = clamp(head.rotation.x, deg2rad(-30), deg2rad(10))
			if Input.is_action_pressed("fire"):
				$CinematicCamera.current = true
				$Head/Camera.current = false
				$paint/Particles.emitting = true
#				$Armature/Skeleton/character.visible = false
#				state = CAPTURING
#				$CinematicCamera/TextureRect.visible = true	
			if Input.is_action_just_released("fire"):
				var couleur = get_rand_array([BLEU, VERT,JAUNE, ROUGE])
				match couleur:
					BLEU:
						$paint/AnimationPlayer.play("bleue")
					JAUNE:
						$paint/AnimationPlayer.play("jaune")
					ROUGE:
						$paint/AnimationPlayer.play("rouge")
					VERT:
						$paint/AnimationPlayer.play("vert")
				$CinematicCamera.current = false
				$Head/Camera.current = true
				$paint/Particles.emitting = false

func get_rand_array(liste):
	randomize()
	return liste[randi() % liste.size()]

func respawn():
	translation= initial_pos
	var lookdir = atan2(-initial_direction.x, -initial_direction.z)
	rotation.y = lookdir
	var liste_objets = $Detecteur.get_overlapping_bodies()
	for objet in liste_objets:
		if (objet.is_in_group("enemy")):
			objet.translation = objet.initial_pos
	$AnimationPlayer.play("Idle")
	$Armature/Skeleton/character.visible = false
	yield(get_tree().create_timer(.5), "timeout")
	$Armature/Skeleton/character.visible = true
	yield(get_tree().create_timer(.2), "timeout")
	$Armature/Skeleton/character.visible = false
	yield(get_tree().create_timer(.2), "timeout")
	$Armature/Skeleton/character.visible = true
	yield(get_tree().create_timer(.2), "timeout")
	$Armature/Skeleton/character.visible = false
	yield(get_tree().create_timer(.2), "timeout")
	$Armature/Skeleton/character.visible = true
	yield(get_tree().create_timer(.2), "timeout")
	$Armature/Skeleton/character.visible = false
	yield(get_tree().create_timer(.2), "timeout")
	$Armature/Skeleton/character.visible = true
	yield(get_tree().create_timer(.2), "timeout")
	state = CONTROLLABLE
	$Head/Camera.current = true
	$CinematicCamera.current = false
	$AnimationPlayer.play("Respawn")
	
func _process(_delta):
	match state:
		CONTROLLABLE:
			var nbr_fantome_aggressif = 0
			
			if direction != Vector3.ZERO:
		#		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)
				$AnimationPlayer.play("Run")
			else:
				$AnimationPlayer.play("Idle")

func _physics_process(delta):
	match state:
		CONTROLLABLE:
			direction = Vector3.ZERO
			var h_rot = global_transform.basis.get_euler().y
			var f_input = - Input.get_action_strength("move_backward") + Input.get_action_strength("move_forward")
			var h_input = - Input.get_action_strength("move_right") + Input.get_action_strength("move_left")
			direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
			velocity = velocity.linear_interpolate(direction * speed, accel * delta)
		DEAD:
			get_parent().get_child(0).environment.dof_blur_far_distance = 0.2
			velocity = Vector3.ZERO
			$DangerMark/AnimationPlayer.play("sauve")
			$CinematicCamera.current = true
			$Head/Camera.current = false
		
	
	move_and_slide(velocity, Vector3.UP)
			




func _on_HurtBox_body_entered(body):
	if (body.is_in_group("enemy") and state != DEAD):
		$CinematicCamera/TextureRect.visible = false
		life -= 1
		if (life <= 0):
			state = DEAD
			body.state = 0
			$CanvasLayer/ColorRect4/ProgressBar.value -= 0
			$CanvasLayer/GameOVER.visible = true
			$AnimationPlayer.play("Death")
		else :
			$CanvasLayer/ColorRect4/ProgressBar.value -= 33
			respawn()
		
