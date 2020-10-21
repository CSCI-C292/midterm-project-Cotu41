extends Node2D


enum types {CROWD_NEUTRAL, CROWD_BLUE, CROWD_RED, CROWD_GREEN}

var _type = types.CROWD_NEUTRAL
var _size : int
var _pawn_members : Array
var _spread_dist : float = 4
func init_pawns(crowd_type):
	

	
	_type = crowd_type
	randomize()
	_size = randi() % 25 + 10  # random number of people between 10 and 25
	
	var collisionbox = get_child(0).get_child(0) as CollisionShape2D
	collisionbox.scale *= (_size/25.0) 
	
	
	print("Crowd Size: ", _size)
	print("Spread: ", _spread_dist*_size)
	var _pawnScene = preload("res://Pawn.tscn")
	
	
	for i in _size:
		var pawnscene = _pawnScene.instance()
		var pawn = pawnscene.get_child(0) as Pawn
		add_child(pawnscene)
		
		# archemedes was pretty smart
		# pick a randomm point in a radius around the crowd center to place pawn
		var t : float = 2 * PI * randf()
		var u : float = randf() + randf()
		var r : float
		
		if u > 1:
			r = 2 - u
		else:
			r = u
		
		pawnscene.position.x = r * cos(t) * (_spread_dist * _size)
		pawnscene.position.y = r * sin(t) * (_spread_dist * _size)
	

func _ready():
	init_pawns(types.CROWD_RED)
	pass






#I'm going to be refining this soon
#if you don't have space between one crowd and another it won't register the
#second crowd. It needs work
func _on_crowd_radius_area_entered(area):
	
	var owner = area.get_parent()
	if owner is Player:
		if _type == types.CROWD_BLUE:
			owner._in_gossip_zone = 2
		if _type == types.CROWD_RED:
			owner._in_gossip_zone = 1
		if _type == types.CROWD_GREEN:
			owner._in_gossip_zone = 3
		



func _on_crowd_radius_area_exited(area):
	var owner = area.get_parent()
	if owner is Player:
		owner._in_gossip_zone = 0
	pass # Replace with function body.
