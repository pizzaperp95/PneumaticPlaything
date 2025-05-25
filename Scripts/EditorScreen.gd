extends Control

var playing : bool = false
var recording : bool = false
var index : int = 0
var playback_rate : int = 1

signal step_forward()
signal step_backward()
signal start_recording()
signal end_recording()
signal return_to_zero()

func update_time_label() -> void:
	var frames = index % 60
	var seconds = floori(index/60) % 60
	var minutes = floori(index/360) % 60
	var hours = floori(index/7200)
	$SequencerPanel/TransportControls/TimeLabel.text = "%d:%02d:%02d:%02d" % [hours, minutes, seconds, frames] 
	#$SequencerPanel/TransportControls/TimeLabel.text = str(index)

func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_size_changed) 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_editor_screen"):
		$CameraPreview.visible = !$CameraPreview.visible;
		$CameraFullScreen.visible = !$CameraFullScreen.visible;

func _physics_process(_delta: float) -> void:
	if (playing || recording):
		step_forward.emit()
		index += 1
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
	recording = false
	end_recording.emit()

func _on_pause_button_pressed() -> void:
	playing = false
	recording = false
	end_recording.emit()

func _on_play_backwards_button_pressed() -> void:
	playback_rate = -1
	playing = true
	recording = false
	end_recording.emit()

func _on_fast_backwards_button_pressed() -> void:
	playback_rate = -2
	playing = true
	recording = false
	end_recording.emit()

func _on_step_backwards_button_pressed() -> void:
	playing = false
	recording = false
	end_recording.emit()
	step_backward.emit()
	if (index != 0): index -= 1
	update_time_label()

func _on_fast_forward_button_pressed() -> void:
	playback_rate = 2
	playing = true
	recording = false
	end_recording.emit()

func _on_step_forward_button_pressed() -> void:
	playing = false
	recording = false
	end_recording.emit()
	step_forward.emit()
	index += 1
	update_time_label()

func _on_record_button_pressed() -> void:
	playback_rate = 1
	playing = false
	recording = true
	start_recording.emit()

func _on_stop_button_pressed() -> void:
	playing = false
	recording = false
	index = 0
	end_recording.emit()
	return_to_zero.emit()
	update_time_label()
