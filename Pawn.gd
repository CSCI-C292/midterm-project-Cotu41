extends Node2D

class_name Pawn

export var blue_skin : Texture

export var red_skin : Texture

export var green_skin : Texture


func _ready():
	self.get_child(0).texture = red_skin
	pass
