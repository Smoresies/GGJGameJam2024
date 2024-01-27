extends Node2D

@export var ROTATION_SPEED = 6

var _ccw = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func spawn(pos, vel):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(ROTATION_SPEED * delta)
