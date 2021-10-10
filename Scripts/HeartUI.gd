extends Control

var hearts = 5 setget set_hearts
var max_hearts = 5 setget set_max_hearts

onready var HeartFull = $HeartFull
onready var HeartEmpty = $HeartEmpty


func set_hearts(value):
	hearts = clamp(value, -1, max_hearts)
	if HeartFull != null:
		HeartFull.rect_size.x = hearts * 15
	
func set_max_hearts(value):
	max(value, 1)
	


func _ready():
	self.max_hearts = 5
	self.hearts = get_parent().life
