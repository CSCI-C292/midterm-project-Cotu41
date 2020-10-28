extends Node2D

export var blue_skin : Texture

export var red_skin : Texture

export var green_skin : Texture

export var _type : int = 0

func _ready():
	var sprite = get_child(0) as Sprite
	if _type == 1:
		sprite.texture = red_skin
	elif _type == 2:
		sprite.texture = blue_skin
	elif _type == 3:
		sprite.texture = green_skin
		
	pass


func _on_CoatroomHitbox_area_entered(area):
	var owner = area.get_parent()
	if owner is Player:
		owner._in_disguise_zone += _type


func _on_CoatroomHitbox_area_exited(area):
	var owner = area.get_parent()
	if owner is Player:
		owner._in_disguise_zone -= _type

