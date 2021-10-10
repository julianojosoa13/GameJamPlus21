extends KinematicBody
export  var speed = 2
const ACCEL_DEFAULT = 10

var nbr_fantome = 0
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5
var life = 5
#var poursuivants = 0

var ouvert = false
var can_shoot = true

enum {
	CONTROLLABLE = 0,
	CINEMATIQUE = 1,
	DEAD = 2,
	RESPAWN = 3,
	CAPTURING = 4
}

onready var b_decal_jaune = preload("res://Scenes/BulletDecal_jaune.tscn")
onready var b_decal_bleu = preload("res://Scenes/BulletDecal_bleu.tscn")
onready var b_decal_rouge = preload("res://Scenes/BulletDecal_rouge.tscn")
onready var b_decal_vert = preload("res://Scenes/BulletDecal_vert.tscn")
onready var raycast = $paint/RayCast

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
var couleur

onready var head = $Head
onready var campivot = $Head/Camera
onready var mesh = $Armature/Skeleton/character

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initial_pos = translation
	initial_direction = global_transform.origin
	nbr_fantome = 0
	$Bouteille.max_value = $paint/Particles.lifetime
	$Bouteille.min_value = $paint/Particles.lifetime / 2
	$Bouteille.value = $paint/Particles.lifetime
	
	#mesh no longer inherits rotation of parent, allowing it to rotate freely
#	mesh.set_as_toplevel(true)
	
func _input(event):
	#get mouse input for camera rotation
	match state :
		CONTROLLABLE:
			if event is InputEventMouseMotion:
				rotate_y(deg2rad(-event.relative.x * mouse_sense))
				head.rotate_x(deg2rad(event.relative.y * mouse_sense))
				head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(35))
				$paint.rotate_x(deg2rad(event.relative.y * mouse_sense))
				$paint.rotation.x = clamp(head.rotation.x, deg2rad(-30), deg2rad(20))
			if Input.is_action_just_pressed("fire"):
				
				var objet = raycast.get_collider()
				
				if $paint/Particles.emitting == false:
					couleur = get_rand_array([BLEU, VERT,JAUNE, ROUGE])
					match couleur:
						BLEU:
							$paint/AnimationPlayer.play("bleue")
							$Label/ColorUI.play("bleue")
							if objet != null and objet.is_in_group("sol"):
								var b = b_decal_bleu.instance()
								objet.add_child(b)
								b.global_transform.origin = raycast.get_collision_point()
								b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
								b.translation.y = b.translation.y + (rand_range(0,0.34))
						JAUNE:
							$paint/AnimationPlayer.play("jaune")
							$Label/ColorUI.play("jaune")
							if objet != null and objet.is_in_group("sol"):
								var b = b_decal_jaune.instance()
								objet.add_child(b)
								b.global_transform.origin = raycast.get_collision_point()
								b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
								b.translation.y = b.translation.y + (rand_range(0,0.34))
						ROUGE:
							$paint/AnimationPlayer.play("rouge")
							$Label/ColorUI.play("rouge")
							if objet != null and objet.is_in_group("sol"):
								var b = b_decal_rouge.instance()
								objet.add_child(b)
								b.global_transform.origin = raycast.get_collision_point()

								b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
								b.translation.y = b.translation.y + (rand_range(0,0.34))
						VERT:	
							$Label/ColorUI.play("vert")
							$paint/AnimationPlayer.play("vert")
							if objet != null and objet.is_in_group("sol"):
								var b = b_decal_vert.instance()
								objet.add_child(b)
								b.global_transform.origin = raycast.get_collision_point()
								b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
								b.translation.y = b.translation.y + (rand_range(0,0.34))
					$CinematicCamera.current = true
					$Head/Camera.current = false
					$paint/Particles.emitting = true
					
					$Timer.start($paint/Particles.lifetime)
#					if $Timer.paused == false:
#						$Timer.paused = true
					
						
			if Input.is_action_pressed("fire"):
				if $paint/Particles.emitting == true:
					
					var objet = raycast.get_collider()
#					if objet != null:
#						print(objet.get_groups())
					if objet != null and objet.is_in_group("sol"):

						match couleur:
							BLEU:
								var b = b_decal_bleu.instance()
								objet.add_child(b)
								b.global_transform.origin = raycast.get_collision_point()

								b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
								b.translation.y = b.translation.y + (rand_range(0,0.34))
							JAUNE:
								var b = b_decal_jaune.instance()
								objet.add_child(b)
								b.global_transform.origin = raycast.get_collision_point()

								b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
								b.translation.y = b.translation.y + (rand_range(0,0.34))
							ROUGE:
								var b = b_decal_rouge.instance()
								objet.add_child(b)
								b.global_transform.origin = raycast.get_collision_point()

								b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
								b.translation.y = b.translation.y + (rand_range(0,0.34))
							VERT:
								var b = b_decal_vert.instance()
								objet.add_child(b)
								b.global_transform.origin = raycast.get_collision_point()

								b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
								b.translation.y = b.translation.y + (rand_range(0,0.34))
					if objet != null and objet.is_in_group("tay"):
						objet.queue_free()
			if Input.is_action_just_released("fire"):
				$Timer.stop()
				$CinematicCamera.current = false
				$Head/Camera.current = true
				$paint/Particles.emitting = false

func get_rand_array(liste):
	randomize()
	return liste[randi() % liste.size()]

func respawn():
	translation= initial_pos
	var lookdir = atan2(-initial_direction.x, -initial_direction.z)
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
				
	if $paint/Particles.emitting == true and $Timer.time_left > 0:
		$Bouteille.value = $Timer.time_left
#		print(str($paint/Particles.lifetime) + " - " +  str($Timer.time_left))
		

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
			velocity = Vector3.ZERO
			$CinematicCamera.current = true
			$Head/Camera.current = false
			if Input.is_action_just_pressed("ui_accept"):
#				print("respawning!!!!!!!")
				life = 5
				$HeartUI.hearts = life
				$HurtBox/CollisionShape.disabled = false
				respawn()
			
		
	
	move_and_slide(velocity, Vector3.UP)
			




func _on_HurtBox_body_entered(body):
	if (body.is_in_group("enemy") and state != DEAD):
		life -= 1
		if (life <= 0):
			$HeartUI.hearts = life
			state = DEAD
			body.state = 0
			$AnimationPlayer.play("Death")
			$HurtBox/CollisionShape.disabled = true
		else :
			$HeartUI.hearts = life
			respawn()
		
