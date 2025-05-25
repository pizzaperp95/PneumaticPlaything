extends Control

var playing : bool = false
var recording : bool = false
var index : int = 0
var playback_rate : int = 1
var transport_enabled : bool = false

signal step(amount: int)
signal start_recording()
signal end_recording()
signal return_to_zero()

func update_time_label() -> void:
	var frames = index % 60
	var seconds = floori(index/60) % 60
	var minutes = floori(index/3600) % 60
	var hours = floori(index/216000)
	$SequencerPanel/TransportControls/TimeLabel.text = "%d:%02d:%02d:%02d" % [hours, minutes, seconds, frames] 
	#$SequencerPanel/TransportControls/TimeLabel.text = str(index)

func set_transport_enabled(enabled: bool):
	$SequencerPanel/TransportControls/Centered/StepBackwardsButton.disabled = !enabled
	$SequencerPanel/TransportControls/Centered/FastBackwardsButton.disabled = !enabled
	$SequencerPanel/TransportControls/Centered/PlayBackwardsButton.disabled = !enabled
	$SequencerPanel/TransportControls/Centered/PauseButton.disabled = !enabled
	$SequencerPanel/TransportControls/Centered/StopButton.disabled = !enabled
	$SequencerPanel/TransportControls/Centered/PlayButton.disabled = !enabled
	$SequencerPanel/TransportControls/Centered/FastForwardButton.disabled = !enabled
	$SequencerPanel/TransportControls/Centered/StepForwardButton.disabled = !enabled
	$SequencerPanel/TransportControls/RecordButton.disabled = !enabled
	transport_enabled = enabled

func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_size_changed) 
	set_transport_enabled(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_editor_screen"):
		$CameraPreview.visible = !$CameraPreview.visible;
		$CameraFullScreen.visible = !$CameraFullScreen.visible;
	if (transport_enabled):
		if event.is_action_pressed("sequencer_play_pause"):
			if (playing): _on_pause_button_pressed()
			else: _on_play_button_pressed()
		elif event.is_action_pressed("sequencer_play_reverse"):
			_on_play_backwards_button_pressed()
		elif event.is_action_pressed("sequencer_fast_reverse"):
			_on_fast_backwards_button_pressed()
		elif event.is_action_pressed("sequencer_fast_forward"):
			_on_fast_forward_button_pressed()
		elif event.is_action_pressed("sequencer_step_backward"):
			_on_step_backwards_button_pressed()
		elif event.is_action_pressed("sequencer_step_forward"):
			_on_step_forward_button_pressed()
		elif event.is_action_pressed("sequencer_home"):
			_on_stop_button_pressed()

func _physics_process(_delta: float) -> void:
	if (playing || recording):
		step.emit(playback_rate)
		index += playback_rate
		if (index <= 0): _on_stop_button_pressed()
		update_time_label()

func _on_size_changed() -> void:
	$SubViewport.size = $ColorRect.size

func _on_controls_button_pressed() -> void:
	$ControlsScreen.visible = true

func _on_credits_button_pressed() -> void:
	$CreditsScreen.visible = true

func _on_controls_input_eater_pressed() -> void:
	$ControlsScreen.visible = false

func _on_credits_input_eater_pressed() -> void:
	$CreditsScreen.visible = false

func _on_v_scroll_bar_value_changed(value: float) -> void:
	$SequencerPanel/TimelinePanel/InvisibleMask/RowsHandle.position.y = value * -44


func _on_play_button_pressed() -> void:
	playback_rate = 1
	playing = true

func _on_pause_button_pressed() -> void:
	playing = false

func _on_play_backwards_button_pressed() -> void:
	playback_rate = -1
	playing = true
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false 

func _on_fast_backwards_button_pressed() -> void:
	playback_rate = -2
	playing = true
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false

func _on_step_backwards_button_pressed() -> void:
	playing = false
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false
	if (index != 0): 
		step.emit(-1)
		index -= 1
	update_time_label()

func _on_fast_forward_button_pressed() -> void:
	playback_rate = 2
	playing = true
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false

func _on_step_forward_button_pressed() -> void:
	playing = false
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false
	step.emit(1)
	index += 1
	update_time_label()

func _on_record_button_toggled(toggled_on: bool) -> void:
	recording = toggled_on
	if (toggled_on): start_recording.emit()
	else: end_recording.emit()

func _on_stop_button_pressed() -> void:
	playing = false
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false
	index = 0
	return_to_zero.emit()
	update_time_label()
