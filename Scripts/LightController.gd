extends Node3D

func _movement_in(movement, _rate):
	get_node(movement).visible = true

func _movement_out(movement, _rate):
	get_node(movement).visible = false
