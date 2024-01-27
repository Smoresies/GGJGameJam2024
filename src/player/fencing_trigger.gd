extends Node2D

@export var _player = Node2D

signal triggered_fencing()
	
func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	emit_signal("triggered_fencing")
