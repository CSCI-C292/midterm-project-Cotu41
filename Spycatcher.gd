extends Node2D

export var detection_radius : float = 500
export var crowd_detect_radius: float = 250
export var grab_radius : float = 10
export var patrol_point_closeness : float = 10
export var patrol_points : Array
export var move_speed : float = 100
export var chase_speed : float = 500
export var investigation_duration : int = 5

var lastSeen : Vector2

var _patrol_index : int = 0

var _in_chase : bool = false


var _detect_tick_interval : float = 1
var _detect_tick_countdown : float = 0

func _ready():
	pass

func _process(delta):
	self.z_index = self.global_position.y
	
	if Director._gameover:
		pass
	
	
	if !_in_chase:
		_patrol(delta)
	else:
		_chase(delta)
	
	if _detect_tick_countdown <= 0:
		_check_for_player(delta)
		_detect_tick_countdown = _detect_tick_interval
	else:
		_detect_tick_countdown -= delta
	
	pass

func _patrol(delta):
	
	if self.position.distance_to(patrol_points[_patrol_index]) <= patrol_point_closeness:
#		if _patrol_index == patrol_points.size() - 1:
#			_patrol_index = 0
#		else:
#			_patrol_index += 1
		_patrol_index = randi()%patrol_points.size()
	else:
		position = position.move_toward(patrol_points[_patrol_index], delta*move_speed)
	
	
func _chase(delta):
	
	if position.distance_to(Director.player.position) < grab_radius:
		Director.playerCaught()
		_in_chase = false
		return
		#GAME OVER
	
	if position.distance_to(lastSeen) >= grab_radius:
		position = position.move_toward(lastSeen, delta*chase_speed)
	else:
		_check_for_player(delta)
	
	
	
func _check_for_player(delta):
	var dist = position.distance_to(Director.player.position)
	if dist <= crowd_detect_radius:
		_in_chase = true
		lastSeen = Director.player.position
		_chase(delta)
	elif Director.player._in_gossip_zone != Director.player._disguise:
		if dist <= detection_radius:
			_in_chase = true
			lastSeen = Director.player.position
			_chase(delta)
	else:
		_in_chase = false
	pass

