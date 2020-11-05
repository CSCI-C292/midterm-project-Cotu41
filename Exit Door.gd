extends Node2D


func _ready():
	pass


func _on_door_area_area_entered(area):
	if area.get_parent() is Player:
		Director.checkPlayerEscape()
	pass # Replace with function body.
