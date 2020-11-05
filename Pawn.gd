extends Node2D

class_name Pawn

export var blue_skin : Texture

export var red_skin : Texture

export var green_skin : Texture

export var talk_audio : Array
export var riled_audio : Array

var _current_audio : Array

var _mouth : AudioStreamPlayer
var _audio_index : int = 0
var _voice_pitch : float

var _emote_bubble : Sprite

#each emote lasts 3 seconds, the coundown stores the 'timer'.
var _emote_duration : float = 3
var _emote_countdown : float = 0

var _wobble_target : Vector2
var _wobble_duration : float = 0.2
var _wobble_countdown : float = 0

var _wobble_amount : int = 80
var _riled_wobble_amount : int = 160
var _riled_wobble_duration : int = 1


var _riled : bool = false




func _ready():
	self.get_child(0).texture = red_skin
	_emote_bubble = self.get_child(1) as Sprite
	_emote_bubble.visible = false
	_current_audio = talk_audio
	_audio_index = randi() % _current_audio.size()
	_voice_pitch = randf()+1
	_mouth = $mouth
	_mouth.set("pitch_scale", _voice_pitch) # each NPC has a little variation
	pass
	

func _emote():
	_emote_bubble.visible = true
	_emote_countdown += _emote_duration
	if(_audio_index >= _current_audio.size()):
		_audio_index = 0
	var sound = _current_audio[_audio_index] as AudioStreamSample
	_mouth.set("stream", sound)
	_mouth.play()
	_audio_index += 1
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

func rileUp():
	_riled = true
	_emote_bubble.visible = false
	_emote_bubble = self.get_child(2) as Sprite
	_current_audio = riled_audio


# makes the pawn subtly wobble around instead of standing like a statue
func _wobble(delta, amount):
	if _wobble_countdown <= 0:
		_wobble_target = self.position #go back towards relative origin
		_wobble_target.x += (randf() * amount) - (amount/2)
		_wobble_target.y += (randf() * amount) - (amount/2)
		_wobble_countdown = _wobble_duration
	else:
		_wobble_countdown -= delta
	
	var _wobbleSpeed = delta
	if _riled: _wobbleSpeed = 0.1
	self.position = self.position.move_toward(_wobble_target, _wobbleSpeed)
	
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
		
