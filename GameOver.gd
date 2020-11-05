extends Control


func _ready():
	pass


func _process(delta):
	
	if Input.is_action_pressed("interact"):
		get_tree().change_scene("res://Main.tscn")
