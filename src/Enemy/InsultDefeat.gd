extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument:String): #Note, this signal/function is being kicked off while the Dialogic scene is still running. Notable for avoiding conflict with the pause-for-dialogue implementation.
	print(argument)
	if argument == "combat_won":
		queue_free()