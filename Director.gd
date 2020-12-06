extends Node

var crowds : Array
var catchers : Array
var player : Player

var currentPlayerCrowd : Array

var senderCrowd : Crowd
var recieverCrowd : Crowd

var _gameover : bool = false
var devmode : bool = false

var numRiles = 0
var riles_to_win = 5

var disputeLabel : Label


func _ready():
	
	
	
	pass
	
func _process(delta):
	if disputeLabel == null and player != null:
		disputeLabel = player.find_node("DisputeLabel", true, true) as Label
		disputeLabel.text = str("Disputes: ", numRiles, "/", riles_to_win)
		
		
func getGossip() :
	if !currentPlayerCrowd[0].riled:
		senderCrowd = currentPlayerCrowd[0]
		print(senderCrowd)
		return true
	else:
		return false
	
func sendGossip():
	recieverCrowd = currentPlayerCrowd[0]
	recieverCrowd.moveToCrowd(senderCrowd)
	senderCrowd.riled = true
	player._in_gossip_zone = 0
	print(recieverCrowd)
	print(recieverCrowd.position, " to ", recieverCrowd.moveTarget)
	senderCrowd = null
	recieverCrowd = null
	numRiles += 1
	disputeLabel.text = str("Disputes: ", numRiles, "/", riles_to_win)
	
func playerCaught():
	print("PLAYER CAUGHT")
	_gameover = true
	numRiles = 0
	get_tree().change_scene("res://GameOver.tscn")
	pass
	
func nearestCrowdTo(spot : Vector2, disguise : int) -> Crowd:
	var dist = 99999
	var closestCrowd : Crowd
	
	if disguise == 0:
		return null
	
	for i in crowds:
		if i is Crowd:
			if spot.distance_to(i.position) < dist and i._type == disguise:
				dist = spot.distance_to(i.position)
				closestCrowd = i
				
	return closestCrowd

func checkPlayerEscape():
	if numRiles >= riles_to_win:
		numRiles = 0
		get_tree().change_scene("res://Win.tscn")
