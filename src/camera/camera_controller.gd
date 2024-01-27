extends Node2D

@export var LEFT_BOUND = 400
@export var RIGHT_BOUND = 600
@export var PAN_SPEED = 300 # the speed at which the camera moves horizontally
@export var PLAYER = Node2D

func _ready():
	pass

func _process(_delta):
	
	# keep the player within the specified area of the screen
	var relative_pos = PLAYER.position.x - position.x
	if relative_pos < LEFT_BOUND:
		position.x += relative_pos - LEFT_BOUND
	elif relative_pos > RIGHT_BOUND:
		position.x += relative_pos - RIGHT_BOUND
