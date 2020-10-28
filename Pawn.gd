extends Node2D

class_name Pawn

export var blue_skin : Texture

export var red_skin : Texture

export var green_skin : Texture

var _emote_bubble : Sprite

#each emote lasts 3 seconds, the coundown stores the 'timer'.
var _emote_duration : float = 3
var _emote_countdown : float = 0

var _wobble_target : Vector2
var _wobble_duration : float = 2
var _wobble_countdown : float = 0

func _ready():
	self.get_child(0).texture = red_skin
	_emote_bubble = self.get_child(1) as Sprite
	_emote_bubble.visible = false
	pass
	

func _emote():
	_emote_bubble.visible = true
	_emote_countdown += _emote_duration
	pass

func _process(delta):
	
	# easy little solution (more like hack) to manage our z-ordering.
	z_index = self.global_position.y
	
	
	_wobble(delta, 80)
	if _emote_countdown > 0: #if there's an emote running...
		_emote_countdown -= delta
		if _emote_countdown <= 0:
			_emote_bubble.visible = false #so we don't try every tick
		
	pass

# makes the pawn subtly wobble around instead of standing like a statue
func _wobble(delta, amount):
	if _wobble_countdown <= 0:
		_wobble_target = self.position #go back towards relative origin
		_wobble_target.x += (randf() * amount) - (amount/2)
		_wobble_target.y += (randf() * amount) - (amount/2)
		_wobble_countdown = _wobble_duration
	else:
		_wobble_countdown -= delta
	
	self.position = self.position.move_toward(_wobble_target, delta)
	
	pass


func setSkin(skinIndex : int):
	if skinIndex == 1:
		self.get_child(0).texture = red_skin
	elif skinIndex == 2:
		self.get_child(0).texture = blue_skin
	elif skinIndex == 3:
		self.get_child(0).texture = green_skin
	else:
		pass
		
