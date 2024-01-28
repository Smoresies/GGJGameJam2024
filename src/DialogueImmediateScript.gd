extends Node


@export_category("Timeline")
@export var TIMELINE_NAME = "tl_Test"

# Called when the node enters the scene tree for the first time.
func _ready():
	#No clue how to disable the player's controls/pause the game during dialogue, but that should happen. Prolly handle via signal in Player Controller?
	Dialogic.start(TIMELINE_NAME)
