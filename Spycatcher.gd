extends Node2D

export var detection_radius : float = 500
export var crowd_detect_radius: float = 250
export var grab_radius : float = 10
export var patrol_point_closeness : float = 10
export var patrol_points : Array
export var move_speed : float = 100
export var chase_speed : float = 500
export var investigation_duration : int = 5

export(Array, Texture) var suspicious_emotes
export(Array, Texture) var angry_emotes
export(Array, Texture) var alert_emotes


var lastSeen : Vector2
var disguise_lastSeen : int = 0
var suspicionLevel : float = 0
var investigation_countdown : float = 0


# each doublecheck_duration seconds, check out a crowd of the same color as
# 	you last spotted the player- only if you've spotted them at some point.
export var doublecheck_duration : int = 15
var doublecheck_countdown : float = 0


var _patrol_index : int = 0
var _interest_points : Array
var _in_chase : bool = false
var _time_since_chase : float


var _detect_tick_interval : float = 1
var _detect_tick_countdown : float = 0

export var emote_duration : int = 2
var _emote_countdown : float = -1
var _current_emote_type : int = -1

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
		
	_drawEmote(delta)
	
	pass

func _patrol(delta):
	
	# Check interest points.
	# Reach each one
	# If player is seen, clear interest points and
	# 	re-evaluate where you're investigating
	# Strike interest points off as you reach them
	# When you're out, return to your static patrol points.
	
	#Double check
	if doublecheck_countdown <= 0:
		_doublecheck()
		doublecheck_countdown += doublecheck_duration
	else:
		doublecheck_countdown -= delta
	
	
	
	# check interest points
	if not _interest_points.empty():
		
		# suspicion level goes up whenever a catcher makes contact with the
		# player, and goes down at a rate of 1.0/second when outside a chase.
		# This nicely means if the player is constantly escaping the catcher,
		# they'll be (rightfully) angry for longer- and will eventually cool
		# down back into normal suspicion/curiousity
		if suspicionLevel > 5:
			_emote(1)
		else:
			_emote(0)
		if position.distance_to(_interest_points.front()) <= patrol_point_closeness:
			_interest_points.remove(_interest_points.find(_interest_points.front()))
			
			_check_for_player(delta)
			# I'm aware this should leave more and more null values at early
			# 	indxs, but I don't have to continually resize and it's solved
			# 	whenever we reset the array. Such as here:
			if _interest_points.count(null) == _interest_points.size():
				_interest_points.clear()
		else:
			position = position.move_toward(_interest_points.front(), 
			delta*move_speed) # move toward interest point
	else: # no interest points? Ok, let's just do our normal job...
		# For patrol points, we're just using a normal indexing method for
		#	iteration- since we don't need to change the array ever.
		if _patrol_index >= patrol_points.size():
			_patrol_index = 0 # disallow ArrayOutOfBounds
		
		if self.position.distance_to(patrol_points[_patrol_index]) <= patrol_point_closeness: # check distance to current patrol target
			_patrol_index += 1 # iterate patrol route
		else:  
			# move toward current patrol target when not close to it
			position = position.move_toward(patrol_points[_patrol_index],
			delta*move_speed)

# Hey, I remember he was disguised as disguise_lastSeen...
# Let's see if he's over here...
# (this discourages the player from haphazardly running around/getting spotted
func _doublecheck():
	
	var interestingCrowd = Director.nearestCrowdTo(position, disguise_lastSeen)
	if interestingCrowd != null:
		_interest_points.append(interestingCrowd.position)
	pass
	
func _chase(delta):
	_interest_points.clear()
	if position.distance_to(Director.player.position) < grab_radius:
		Director.playerCaught()
		_in_chase = false
		return
		#GAME OVER
	
	if position.distance_to(lastSeen) >= grab_radius:
		position = position.move_toward(lastSeen, delta*chase_speed)
	else:
		_check_for_player(delta)
	
# Integer represents type of emote
# 0 is suspicious
# 1 is angry
# 2 is alert
func _emote(emoteType : int):
	
	# the emote type ints are ordered from small to large in order of
	# importance. An ongoing alert emote will trump a suspicious, or angry
	# emote. This also means that if we're already doing a certain emote,
	# we won't flip to a new one of the same type.

	if _current_emote_type >= emoteType: return
	
	
	
	
	_current_emote_type = emoteType
	print("eStart: ", emoteType, " CD@t: ", _emote_countdown, 
	"\tCURR: ", _current_emote_type)
	
	var emote_selection : Array
	match emoteType:
		0:
			emote_selection = suspicious_emotes
			
		1:
			emote_selection = angry_emotes
			
		2:
			emote_selection = alert_emotes
	
	if emote_selection == null or emote_selection.empty(): return
	
	emote_selection.shuffle() #shuffle the emotes and choose the first
	$emote_bubble.texture = emote_selection[0] #this gives us a random selection
	_emote_countdown = emote_duration
	
	
	
func _drawEmote(delta):
	if _emote_countdown > 0:
		if not $emote_bubble.visible: $emote_bubble.visible = true
		_emote_countdown -= delta
	else:
		$emote_bubble.visible = false
		_current_emote_type = -1
	
func _check_for_player(delta):
	var dist = position.distance_to(Director.player.position)
	if dist <= crowd_detect_radius:
		_emote(2)
		_in_chase = true
		lastSeen = Director.player.position
		disguise_lastSeen = Director.player._disguise
		suspicionLevel += 1
		_chase(delta)
	elif Director.player._in_gossip_zone != Director.player._disguise:
		if dist <= detection_radius:
			_emote(2)
			_in_chase = true
			lastSeen = Director.player.position
			disguise_lastSeen = Director.player._disguise
			suspicionLevel += 1
			_chase(delta)
	else:
		if lastSeen != null and _in_chase:
			
			_interest_points.append(lastSeen)
			
			# Check out the nearest crowd for that shifty spy-lookin' dude
			var nearestCrowd = Director.nearestCrowdTo(lastSeen, 
													   disguise_lastSeen)
			if nearestCrowd != null:
				_interest_points.append(nearestCrowd.position)
		if suspicionLevel > 0:
			suspicionLevel -= delta
		_in_chase = false
		
	pass

