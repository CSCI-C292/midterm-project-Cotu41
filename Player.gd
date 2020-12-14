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

# These aren't used with player movement via the keys, just shoving.
var velocity : Vector2
# Since we're using basic 2D physics vectors, we can add to them from
# 	multiple sources- meaning it stays nicely decoupled.
var acceleration : Vector2

# coefficient for how much our velocity/acceleration naturally decreases
export var _floor_friction : float =  6

# coefficient which factors into the crowd shoving.
# allows denser crowds (where the player is closer to the center) to shove
#	more firmly. Sparser crowds (which are harder to avoid) do not shove as
#	hard, which means it will be less annoying if the player bumps into them.
const _crowd_density_coef : float = 128000.0 

export var _player_speed : float =  15 #speed normally
export var _player_crowd_speed : float = 6.0 #speed while inside crowd

var _gossipIcon : UIColorBox
var _disguiseIcon : UIColorBox
var _inputCooldownDuration = 0.5
var _gossipCooldown = 0

var _collider : Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	_skins = [neutral_skin, red_skin, blue_skin, green_skin]
	self.get_child(0).texture = neutral_skin
	
	_gossipIcon = find_node("GossipIcon", true, true) as UIColorBox
	_disguiseIcon = find_node("DisguiseIcon", true, true) as UIColorBox
	_collider = $PlayerCollider
	
	Director.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Set z-ordering
	self.z_index = global_position.y
	
	var temp_speed : float = _player_speed
	
	
	
	#crowd dynamics
	if _in_gossip_zone > 0:
		temp_speed = _player_crowd_speed
		
	
		
	#apply/change our physics vectors
	_update_physics(delta)
	
	#normalized movement vector
	var move_vector : Vector2 = Vector2(0, 0)
	# User Input - MOVEMENT
	if Input.is_action_pressed("move_up"):
		move_vector.y += -1
	if Input.is_action_pressed("move_down"):
		move_vector.y += 1
	if Input.is_action_pressed("move_left"):
		move_vector.x += -1
	if Input.is_action_pressed("move_right"):
		move_vector.x += 1
	
	move_vector = move_vector.normalized()
	velocity += move_vector*temp_speed # apply movement, scale by speed
		
	#gossip interaction
	if Input.is_action_pressed("interact") and _in_gossip_zone != 0 and _gossipCooldown <= 0:
		if _gossip == 0 and _disguise == _in_gossip_zone:
			if Director.getGossip():
				_gossip = _in_gossip_zone
			
		elif _gossip != 0 and _disguise == _in_gossip_zone:
			if _gossip != _in_gossip_zone:
				Director.sendGossip()
				_gossip = 0
		#set our player's current gossip to the crowd they just got it from
		_gossipIcon.setSkin(_gossip)
		_gossipCooldown = _inputCooldownDuration
	
	#coatroom interaction
	if Input.is_action_pressed("interact") and _in_disguise_zone != 0:
		#set the player's new disguise after interacting with a coatroom
		_disguise = _in_disguise_zone
		_disguiseIcon.setSkin(_disguise)
		self.get_child(0).texture = _skins[_disguise]
	
	if _gossipCooldown > 0:
		_gossipCooldown -= delta
	
	pass

func _update_physics(delta : float):
	position.y += velocity.y*delta
	if position.y < -20:
		position.y = -20
	elif position.y > 1255:
		position.y = 1255
	
	
	position.x += velocity.x*delta
	if position.x < 20:
		position.x = 20
	elif position.x > 1400:
		position.x = 1400
		
	velocity += acceleration*delta
	
	
	var oppVel := Vector2(velocity.x*-1*_floor_friction, velocity.y*-1*_floor_friction)
	
	velocity += oppVel*delta
	
	if _in_gossip_zone == 0 or _disguise == _in_gossip_zone:
		var oppAcc := Vector2(acceleration.x*-1*_floor_friction, acceleration.y*-1*_floor_friction)
		acceleration += oppAcc*delta
		print(acceleration, " v ", oppAcc)

#simple function for adding in "force" (force just being acc. since no mass)
func shove(acceleration : Vector2):
	self.acceleration += acceleration


func _on_PlayerCollider_area_entered(area):
	return
	var owner = area.get_parent() as Node2D
	if owner.name.begins_with("@Crowd") or owner.name.begins_with("Crowd" ):
		if _disguise != owner.name.split_floats("-", false)[1]:
			print(-1*(self.position.distance_to(owner.position))*self.position.direction_to(owner.position)*8)
			



func _on_door_area_area_shape_entered(area_id, area, area_shape, self_shape):
	Director.checkPlayerEscape()
	pass # Replace with function body.
