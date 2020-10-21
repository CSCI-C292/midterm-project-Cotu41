extends Node2D

class_name Player

var _gossip : int = 0
var _in_gossip_zone : int = 0

export var _player_speed : float =  300.0
var _no_gossip_icon : TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	_no_gossip_icon = find_node("NoGossipIcon", true, true) 
	_no_gossip_icon.visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("move_up"):
		position.y -= _player_speed*delta
	if Input.is_action_pressed("move_down"):
		position.y += _player_speed*delta
	if Input.is_action_pressed("move_left"):
		position.x -= _player_speed*delta
	if Input.is_action_pressed("move_right"):
		position.x += _player_speed*delta
		
	if Input.is_action_pressed("interact") and _gossip == 0 and _in_gossip_zone != 0:
		_gossip = _in_gossip_zone
		print(_gossip)
		#set our player's current gossip to the crowd they just got it from
		_no_gossip_icon.visible = false #later, here we will also change color
	
	pass


