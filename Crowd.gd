extends Node2D

class_name Crowd


enum types {CROWD_NEUTRAL = 0, CROWD_RED = 1, CROWD_BLUE = 2, CROWD_GREEN = 3}

var _type = types.CROWD_NEUTRAL
var _size : int
var _pawn_members : Array
var _spread_dist : float = 4
var riled : bool = false
var moveTarget : Vector2
var moving : bool = false
var radius : Area2D
export var move_speed : float = 150 #arbitrary

var _emote_countdown : float = 6 * randf() #every zero to six seconds
var _tempGossip : int = 0
export var crowd_type : int

var unwanted_guest_present : bool = false

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
	

func moveToCrowd(other : Crowd):
	moveTarget = other.position
	moving = true
	riled = true
	other.riled = true
	for i in _pawn_members:
		if i is Pawn:
			i.rileUp()
	for i in other._pawn_members:
		if i is Pawn:
			i.rileUp()
	

func _ready():
	init_pawns(crowd_type)
	Director.crowds.append(self)
	radius = $crowd_radius
	pass

func _process(delta):
	
	if unwanted_guest_present:
		var player : Player = Director.player
		player.shove(-1*(1600*8/player.position.distance_to(self.position))*player.position.direction_to(self.position))
	
	if _emote_countdown < 0:
		# EMOTE
		_member_emote()
		_emote_countdown = 6 * randf()
	else:
		_emote_countdown -= delta
		
	if moving == true:
		if position == moveTarget:
			moving = false
		else:
			var normDir = position.direction_to(moveTarget)
			position = position.move_toward(moveTarget, move_speed*delta)

func _member_emote():
	
	# pick random member
	var rMember = _pawn_members[randi() % _size] as Pawn
	rMember._emote()
	pass


func _on_crowd_radius_area_entered(area):
	var owner = area.get_parent()
	if owner is Player:

		Director.currentPlayerCrowd.append(self)
		if owner._disguise != _type:
			unwanted_guest_present = true
			
		else:
			_tempGossip = owner._in_gossip_zone
			owner._in_gossip_zone = _type
		


func _on_crowd_radius_area_exited(area):
	var owner = area.get_parent()
	if owner is Player:
		unwanted_guest_present = false
		Director.currentPlayerCrowd.remove(
			Director.currentPlayerCrowd.find(self))
		print(Director.currentPlayerCrowd)
		if Director.currentPlayerCrowd.empty():
			owner._in_gossip_zone = 0
		else:
			for crowd in Director.currentPlayerCrowd:
				if area.overlaps_area(crowd.radius):
					owner._in_gossip_zone = crowd._type
				else:
					owner._in_gossip_zone = 0
		
		
	
