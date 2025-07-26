extends Control

@export var x_offset : int = 0

func _ready() -> void:
	self.size.x += x_offset
