extends Control

var tex : TextureRect
var tex2 : TextureRect
var endAlpha : float


func _ready():
	tex = $Panel/sendanotheragent
	tex2 = $Panel/caught
	endAlpha = tex.modulate.a
	tex.modulate.a = 0
	tex2.modulate.a = 0
	pass


func _process(delta):
	if tex.modulate.a < endAlpha:
		tex.modulate.a = tex.modulate.a + delta
		tex2.modulate.a = tex.modulate.a + delta
	elif tex.modulate.a > endAlpha:
		tex.modulate.a = endAlpha
		tex2.modulate.a = endAlpha
		
	if Input.is_action_pressed("interact"):
		get_tree().change_scene("res://Main.tscn")
