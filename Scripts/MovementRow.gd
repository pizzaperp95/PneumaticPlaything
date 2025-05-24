extends Panel

@export var movement_bit : int = 0;
@export var movement_name : String = "Name"
@export var flow_path : String = "../../../../../../HelenHouseFlyout/FlowControls/"
@export var recording : bool = false

var key_binding : InputEventKey = InputEventKey.new()
var binding : bool = false

signal movement_in(movement, rate)
signal movement_out(movement, rate)

func update_text() -> void:
	$Button.text = "%d - %s (%s)" % [movement_bit, movement_name, key_binding.as_text() if key_binding.keycode != 0 else "Unbound"]

func _ready() -> void:
	var animatronic = get_node("../../../../../../SubViewport/HelenHouse/3stHelen")
	movement_in.connect(animatronic._movement_in)
	movement_out.connect(animatronic._movement_out)
	movement_in.connect(self._movement_in)
	movement_out.connect(self._movement_out)
	update_text()

func _movement_in(movement, rate):
	pass

func _movement_out(movement, rate):
	pass

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
