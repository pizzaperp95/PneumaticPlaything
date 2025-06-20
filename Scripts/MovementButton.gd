extends Control

signal movement_in(movement, rate)
signal movement_out(movement, rate)

@export var animatronic : String
@export var movement_bit : int
@export var current_stage : String
@export var base_scene_path : String
@export var flow_path : String = "../../../../../FlyoutPanel/FlowControls/InvisibleMask/FlowHandle/"
@export var movement_name : String

var in_flow : float = 1.0
var out_flow : float = 1.0

func _ready() -> void:
	$Panel/Button.text = animatronic + " " + movement_name
	if (animatronic != "None"):
		var animatronic_node = get_node(base_scene_path + animatronic)
		movement_in.connect(animatronic_node._movement_in)
		movement_out.connect(animatronic_node._movement_out)
	if (flow_path != "None"):
		var flow_control = get_node(flow_path + str(movement_bit) + animatronic + movement_name + current_stage)
		flow_control.in_value_updated.connect(self._update_in_flow)
		flow_control.out_value_updated.connect(self._update_out_flow)
		in_flow = flow_control.in_value
		out_flow = flow_control.out_value

func _update_in_flow(new_value: float) -> void:
	in_flow = new_value

func _update_out_flow(new_value: float) -> void:
	out_flow = new_value

func _on_button_button_down() -> void:
	movement_in.emit(movement_name, in_flow)
	$Panel/IndicatorPanel/Green.visible = true

func _on_button_button_up() -> void:
	movement_out.emit(movement_name, out_flow)
	$Panel/IndicatorPanel/Green.visible = false
