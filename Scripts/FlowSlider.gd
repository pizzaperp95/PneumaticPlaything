extends Control

@export var value : float = 1.0

func _ready() -> void:
	$Panel/Slider.value = self.value

func _on_slider_value_changed(value: float) -> void:
	self.value = $Panel/Slider.value
	$Panel/ValueLabel.text = str(self.value)
