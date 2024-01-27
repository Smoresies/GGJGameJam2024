extends Node2D

@export var _player = Node2D

signal triggered_fencing()
	
func _on_area_2d_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	emit_signal("triggered_fencing")
