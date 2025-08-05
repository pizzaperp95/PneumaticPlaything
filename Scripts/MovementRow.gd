extends Panel

@export var movement_bit : int = 0
@export var movement_name : String = "Name"
@export var flow_path : String = "../../../../../FlyoutPanel/FlowControls/InvisibleMask/FlowHandle/"
@export var base_scene_path : String
@export var current_stage : String
@export var animatronic : String
@export var movements : Array[bool]
@export var etching: bool = false
@export var forced_etchable: bool = false

var in_flow : float = 1.0
var out_flow : float = 1.0

var key_binding : InputEventKey = InputEventKey.new()
var current_index : int = 0
var binding : bool = false
var held_on_previous_frame : bool = false
var playback_held_on_previous_frame : bool = false
var recording : bool = false
var playing : bool = true
var current_block_indicator

signal movement_in(movement, rate)
signal movement_out(movement, rate)

func set_at_current() -> void:
	if (current_index > self.movements.size()-1): self.movements.append(true)
	else: self.movements.set(current_index, true)
	if (check_at_index(current_index-1)): current_block_indicator.get_node("ColorRect").size.x += 2
	else:
		current_block_indicator = load("res://Scenes/GUI/Controls/MovementFrameIndicatorOn.tscn").instantiate()
		current_block_indicator.position.x = current_index * 2
		$MovementsBG/InvisibleMask/MovementsHandle.add_child(current_block_indicator)

func unset_at_current() -> void:
	if (current_index > self.movements.size()-1): self.movements.append(false)
	else: self.movements.set(current_index, false)
	if (!check_at_index(current_index-1)): current_block_indicator.get_node("ColorRect").size.x += 2
	else:
		current_block_indicator = load("res://Scenes/GUI/Controls/MovementFrameIndicatorOff.tscn").instantiate()
		current_block_indicator.position.x = current_index * 2
		$MovementsBG/InvisibleMask/MovementsHandle.add_child(current_block_indicator)

func check_at_current() -> bool:
	if (current_index > self.movements.size()-1): return false
	var out = self.movements.get(current_index)
	if (out == null): return false
	return out

func check_at_index(cindex: int) -> bool:
	if (cindex > self.movements.size()-1): return false
	if (cindex < 0): return false
	var out = self.movements.get(cindex)
	if (out == null): return false
	return out

func check_if_erasing() -> bool:
	if (forced_etchable): return true
	return (!$LockButton.button_pressed) && key_binding.keycode != 0

func _step(amount: int):
	if (recording && check_if_erasing()): 
		if (etching): set_at_current()
		else: unset_at_current()
	if (playing):
		if (check_at_current()):
			if (!playback_held_on_previous_frame):
				movement_in.emit(movement_name, in_flow)
			playback_held_on_previous_frame = true;
		else:
			if (playback_held_on_previous_frame):
				movement_out.emit(movement_name, out_flow)
				playback_held_on_previous_frame = false;
	current_index += amount
	$MovementsBG/InvisibleMask/MovementsHandle.position.x += -2*amount

func _return_to_zero():
	current_index = 0
	$MovementsBG/InvisibleMask/MovementsHandle.position.x = 120
	movement_out.emit(movement_name, out_flow)

func _erase_all() -> void:
	_return_to_zero()
	_on_clear_button_pressed()

func _start_recording():
	recording = true

func _end_recording():
	recording = false

func _start_playback():
	playing = true

func _end_playback():
	playing = false

func update_text() -> void:
	if (animatronic == "None"): $Button.text = "%d - Unused (%s)" % [movement_bit, key_binding.as_text() if key_binding.keycode != 0 else "Unbound"]
	else: $Button.text = "%d - %s %s (%s)" % [movement_bit, animatronic, movement_name, key_binding.as_text() if key_binding.keycode != 0 else "Unbound"]

func _update_in_flow(new_value: float, _internalid: int) -> void:
	in_flow = new_value

func _update_out_flow(new_value: float, _internalid: int) -> void:
	out_flow = new_value

func _ready() -> void:
	if (flow_path != "None"):
		var flow_control = get_node(flow_path + str(movement_bit) + animatronic + movement_name + current_stage)
		flow_control.in_value_updated.connect(self._update_in_flow)
		flow_control.out_value_updated.connect(self._update_out_flow)
		in_flow = flow_control.in_value
		out_flow = flow_control.out_value
	if (animatronic != "None"):
		var animatronic_node = get_node(base_scene_path + animatronic)
		movement_in.connect(animatronic_node._movement_in)
		movement_out.connect(animatronic_node._movement_out)
	movement_in.connect(self._movement_in)
	movement_out.connect(self._movement_out)
	var editor = get_node("../../../../../")
	editor.step.connect(_step)
	editor.start_recording.connect(_start_recording)
	editor.end_recording.connect(_end_recording)
	editor.return_to_zero.connect(_return_to_zero)
	editor.erase_all.connect(_erase_all)
	current_block_indicator = load("res://Scenes/GUI/Controls/MovementFrameIndicatorOff.tscn").instantiate()
	update_text()

func _process(_delta: float) -> void:
	if (binding || key_binding.keycode == 0): return
	if (Input.is_key_pressed(key_binding.keycode)):
		if (!held_on_previous_frame):
			movement_in.emit(movement_name, in_flow)
		held_on_previous_frame = true;
	else:
		if (held_on_previous_frame):
			movement_out.emit(movement_name, out_flow)
			held_on_previous_frame = false;

func _movement_in(_movement, _rate):
	$ActiveBG.visible = true
	if (recording): etching = true

func _movement_out(_movement, _rate):
	$ActiveBG.visible = false
	etching = false

func _on_button_pressed() -> void:
	if (binding):
		update_text()
		binding = false
		return
	if (key_binding.keycode == 0):
		$Button.text = "Press a key to bind."
		binding = true
	else:
		key_binding.keycode = KEY_NONE
		update_text()

func _input(event: InputEvent) -> void:
	if (event is InputEventKey && binding):
		if (event.keycode != KEY_ESCAPE):
			key_binding = event
		binding = false
		update_text()
		return

func _on_clear_button_pressed() -> void:
	if ($LockButton.button_pressed): return
	movements = []
	for indicator in $MovementsBG/InvisibleMask/MovementsHandle.get_children():
		indicator.queue_free()
	current_block_indicator = load("res://Scenes/GUI/Controls/MovementFrameIndicatorOff.tscn").instantiate()
