extends Control

@export var in_value : float = 1.0
@export var out_value : float = 1.0

signal in_value_updated(new_value: float)
signal out_value_updated(new_value: float)

func _ready() -> void:
	$Panel/Label.text = self.name
	$Panel/InSlider.value = self.in_value
	$Panel/InStepper.value = self.in_value
	$Panel/OutSlider.value = self.out_value
	$Panel/OutStepper.value = self.out_value

func _on_in_slider_value_changed(value: float) -> void:
	self.in_value = $Panel/InSlider.value
	$Panel/InStepper.value = value
	in_value_updated.emit(value)

func _on_in_stepper_value_changed(value: float) -> void:
	self.in_value = $Panel/InStepper.value
	$Panel/InSlider.value = value
	in_value_updated.emit(value)

func _on_out_slider_value_changed(value: float) -> void:
	self.out_value = $Panel/OutSlider.value
	$Panel/OutStepper.value = value
	out_value_updated.emit(value)

func _on_out_stepper_value_changed(value: float) -> void:
	self.out_value = $Panel/OutStepper.value
	$Panel/OutSlider.value = value
	out_value_updated.emit(value)
