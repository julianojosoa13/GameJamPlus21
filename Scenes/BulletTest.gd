extends Spatial

onready var raycast = $Camera/RayCast
onready var b_decal = preload("res://Scenes/BulletDecal.tscn")

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var b = b_decal.instance()
		raycast.get_collider().add_child(b)
		b.global_transform.origin = raycast.get_collision_point()
		b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
	if Input.is_action_pressed("ui_cancel"):
		$Camera.current = false
		$Camera2.current = true
