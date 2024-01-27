extends Area2D

@export_category("Timeline")
@export var TIMELINE_NAME = "tl_Test"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_body_entered(body):
	#I have no clue how to check for if the body is the player, but that check would go here.
	#No clue how to disable the player's controls/pause the game during dialogue, but that should happen. Prolly handle via signal in Player Controller?
	Dialogic.start(TIMELINE_NAME)
	$CollisionShape2D.set_deferred("disabled", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
