extends Node2D

class_name Player

var _gossip : int = 0
var _in_gossip_zone : int = 0

var _disguise : int = 0
var _in_disguise_zone : int = 0

export var neutral_skin : Texture

export var blue_skin : Texture

export var red_skin : Texture

export var green_skin : Texture

var _skins : Array

var shoveFactor : float = 0
var shoveAngle : float = 0

export var _player_speed : float =  300.0 #speed normally
export var _player_crowd_speed : float = 150.0 #speed while inside crowd

var _gossipIcon : UIColorBox
var _disguiseIcon : UIColorBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_skins = [neutral_skin, red_skin, blue_skin, green_skin]
	self.get_child(0).texture = neutral_skin
	
	_gossipIcon = find_node("GossipIcon", true, true) as UIColorBox
	_disguiseIcon = find_node("DisguiseIcon", true, true) as UIColorBox
	
	var collider = find_node("PlayerCollider", true, true) as Area2D
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	self.z_index = global_position.y

	var temp_speed : float = _player_speed
	
	#crowd dynamics
	if _in_gossip_zone > 0:
		temp_speed = _player_crowd_speed
		
	
	if Input.is_action_pressed("move_up"):
		position.y -= temp_speed*delta
	if Input.is_action_pressed("move_down"):
		position.y += temp_speed*delta
	if Input.is_action_pressed("move_left"):
		position.x -= temp_speed*delta
	if Input.is_action_pressed("move_right"):
		position.x += temp_speed*delta
		
	#gossip interaction
	if Input.is_action_pressed("interact") and _in_gossip_zone != 0:
		if _gossip == 0 and _disguise == _in_gossip_zone:
			_gossip = _in_gossip_zone
		print("LINE 52(Player)\tGOSSIP: ", _gossip)
		#set our player's current gossip to the crowd they just got it from
		_gossipIcon.setSkin(_gossip)
	
	#coatroom interaction
	if Input.is_action_pressed("interact") and _in_disguise_zone != 0:
		#set the player's new disguise after interacting with a coatroom
		_disguise = _in_disguise_zone
		_disguiseIcon.setSkin(_disguise)
		self.get_child(0).texture = _skins[_disguise]
	
	pass




func _on_PlayerCollider_area_entered(area):
	
	var owner = area.get_parent() as Node2D
	print(owner.name)
	if owner.name.begins_with("@Crowd") or owner.name.begins_with("Crowd" ):
		print(owner.name)
		print("ID: ", owner.name.split_floats("-", false)[1], " vs ", _disguise)
		if _disguise != owner.name.split_floats("-", false)[1]:
			print("PUSH OUT")
			shoveFactor = 800 # over double the player speed
			shoveAngle = owner.global_position.angle_to(global_position)
	
	pass # Replace with function body.
