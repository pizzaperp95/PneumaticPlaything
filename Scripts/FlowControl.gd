extends Control

@export var in_value : float = 1.0
@export var out_value : float = 1.0
@export var vis_name : String = ""
@export var internal_id: int

signal in_value_updated(new_value: float, internalid: int)
signal out_value_updated(new_value: float, internalid: int)

func _ready() -> void:
	$Panel/Label.text = self.vis_name
	$Panel/InStepper.value = self.in_value
	$Panel/OutStepper.value = self.out_value

func _on_in_stepper_value_changed(value: float) -> void:
	self.in_value = value
	in_value_updated.emit(value, internal_id)

func _on_out_stepper_value_changed(value: float) -> void:
	self.out_value = value
	out_value_updated.emit(value, internal_id)
