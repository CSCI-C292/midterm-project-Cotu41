extends TextureRect

class_name UIColorBox

export var none : Texture
export var red : Texture
export var blue : Texture
export var green : Texture

var _texs : Array


func _ready():
	self.texture = none
	_texs = [none, red, blue, green]
	pass
	
# Just pass in the numbers we've been using for each color/nation
# neutral = 0, red = 1, blue = 2, green = 3
func setSkin(skinIndex : int):
	self.texture = _texs[skinIndex]
