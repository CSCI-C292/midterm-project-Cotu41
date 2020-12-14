extends Control

var tex : TextureRect
var endAlpha : float


func _ready():
	tex = $Panel/TextureRect 
	endAlpha = tex.modulate.a
	tex.modulate.a = 0
	pass


func _process(delta):
	if tex.modulate.a < endAlpha:
		tex.modulate.a = tex.modulate.a + delta
	elif tex.modulate.a > endAlpha:
		tex.modulate.a = endAlpha
		
	if Input.is_action_pressed("interact"):
		get_tree().change_scene("res://Main.tscn")
