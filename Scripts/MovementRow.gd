extends Panel

@export var movement_bit : int = 0;
@export var movement_name : String = "Name"
@export var flow_path : String = "../../../../../../HelenHouseFlyout/FlowControls/"
@export var recording : bool = false
@export var current_index : int = 0;

var in_flow : float = 1.0
var out_flow : float = 1.0

var key_binding : InputEventKey = InputEventKey.new()
var binding : bool = false
var held_on_previous_frame : bool = false

signal movement_in(movement, rate)
signal movement_out(movement, rate)

func update_text() -> void:
	$Button.text = "%d - %s (%s)" % [movement_bit, movement_name, key_binding.as_text() if key_binding.keycode != 0 else "Unbound"]

func _update_in_flow(new_value: float) -> void:
	in_flow = new_value

func _update_out_flow(new_value: float) -> void:
	out_flow = new_value

func _ready() -> void:
	var animatronic = get_node("../../../../../../SubViewport/HelenHouse/3stHelen")
	if (flow_path != "None"):
		var if_node = get_node(flow_path + "InFlows/" + movement_name.replace(" ", "") + "Flow")
		var of_node = get_node(flow_path + "OutFlows/" + movement_name.replace(" ", "") + "Flow")
		if_node.value_updated.connect(self._update_in_flow)
		of_node.value_updated.connect(self._update_out_flow)
		in_flow = if_node.value
		out_flow = of_node.value
	movement_in.connect(animatronic._movement_in)
	movement_out.connect(animatronic._movement_out)
	movement_in.connect(self._movement_in)
	movement_out.connect(self._movement_out)
	update_text()

func _process(delta: float) -> void:
	if (binding): return
	if (Input.is_key_pressed(key_binding.keycode)):
		if (!held_on_previous_frame):
			movement_in.emit(movement_name, in_flow)
		held_on_previous_frame = true;
	else:
		if (held_on_previous_frame):
			movement_out.emit(movement_name, out_flow)
			held_on_previous_frame = false;

func _movement_in(movement, rate):
	$ActiveBG.visible = true

func _movement_out(movement, rate):
	$ActiveBG.visible = false

func _on_button_pressed() -> void:
	if (recording): return
	if (binding):
		update_text()
		binding = false
		return
	if (key_binding.keycode == 0):
		$Button.text = "Press a key to bind."
		binding = true
	else:
		key_binding.keycode = 0
		update_text()

func _input(event: InputEvent) -> void:
	if (event is InputEventKey && binding):
		if (event.keycode != KEY_ESCAPE):
			key_binding = event
		binding = false
		update_text()
		return
