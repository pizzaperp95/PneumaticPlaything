extends Control

@export var on: bool = false

func _ready() -> void:
	$Green.visible = self.on

func turn_on() -> void:
	self.on = true
	$Green.visible = self.on

func turn_off() -> void:
	self.on = false
	$Green.visible = self.on

func toggle() -> void:
	self.on = !self.on
	$Green.visible = self.on

func set_state(value: bool) -> void:
	self.on = value
	$Green.visible = self.on
