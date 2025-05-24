extends Control

func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_size_changed) 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_editor_screen"):
		$CameraPreview.visible = !$CameraPreview.visible;
		$CameraFullScreen.visible = !$CameraFullScreen.visible;

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
