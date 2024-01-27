extends Node

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn(pos, vel):
	var random_number = rng.randi_range(0, 1)
	if random_number < 2:
		for N in get_children():
			if not N.visible:
				N.spawn(pos, vel, rng.randi_range(0, 1) * 2 - 1, rng.randf_range(0, 1))
				N.show()
				return
		get_children()[0].spawn(pos, vel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
