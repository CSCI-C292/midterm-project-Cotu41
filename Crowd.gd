extends Node2D


enum types {CROWD_NEUTRAL = 0, CROWD_RED = 1, CROWD_BLUE = 2, CROWD_GREEN = 3}

var _type = types.CROWD_NEUTRAL
var _size : int
var _pawn_members : Array
var _spread_dist : float = 4

var _emote_countdown : float = 6 * randf() #every zero to six seconds

export var crowd_type : int

func init_pawns(crowd_type):
	

	
	_type = crowd_type
	self.name = str("Crowd-", _type)
	randomize()
	_size = randi() % 25 + 10  # random number of people between 10 and 25
	
	var collisionbox = get_child(0).get_child(0) as CollisionShape2D
	collisionbox.scale *= (_size/25.0) 
	
	
	print("Crowd Size: ", _size)
	print("Spread: ", _spread_dist*_size)
	var _pawnScene = preload("res://Pawn.tscn")
	
	
	for i in _size:
		var pawnscene = _pawnScene.instance()
		add_child(pawnscene)
		
		var pawn = pawnscene as Pawn
		
		# give our new pawn its correct color
		if pawn is Pawn:
			_pawn_members.append(pawn) # add our pawn to our array
			pawn.setSkin(crowd_type)
		
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
	init_pawns(crowd_type)
	pass

func _process(delta):
	if _emote_countdown < 0:
		# EMOTE
		_member_emote()
		_emote_countdown = 6 * randf()
	else:
		_emote_countdown -= delta
		

func _member_emote():
	
	# pick random member
	var rMember = _pawn_members[randi() % _size] as Pawn
	rMember._emote()
	pass


func _on_crowd_radius_area_entered(area):
	var owner = area.get_parent()
	if owner is Player:
		owner._in_gossip_zone += _type
		


func _on_crowd_radius_area_exited(area):
	var owner = area.get_parent()
	if owner is Player:
		owner._in_gossip_zone -= _type
	
