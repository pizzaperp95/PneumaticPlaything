extends Control

var playing : bool = false
var recording : bool = false
var index : int = 0
var playback_rate : int = 1
var transport_enabled : bool = false
var erase_validated : bool = false
var cam_index : int = 0
var fullscreen : bool = false

var showtape_loaded : bool = false
var show_name : String

var current_stage : String

var stages_info = {
	"Helen House": 
	{
		"bits": 32, 
		"scene": "res://Scenes/Stages/HelenHouse.tscn", 
		"scene_ref_base": "SubViewport/HelenHouse/",
		"camera_count": 2,
		
		"ust_character": "Mitzi/Helen", 
		"ust_stage": "Rockafire Explosion/3-Stage (Single Character)",
		
		"bit_mapping":
		{
			"Helen":
			{
				"Mouth": [3.0, 2.0],
				"Left Ear": [3.5, 1.5],
				"Right Ear": [3.5, 1.5],
				"Left Eyelid": [1.5, 2.0],
				"Right Eyelid": [1.5, 2.0],
				"Eyes Left": [3.5, 1.5],
				"Eyes Right": [3.5, 1.5],
				"Head Left": [1.5, 1.5],
				"Head Right": [1.5, 1.5],
				"Head Up": [1.0, 1.0],
				"Left Arm Up": [0.8, 0.6],
				"Left Arm Twist": [0.8, 0.8],
				"Left Elbow": [1.0, 1.0],
				"Right Arm Up": [0.8, 0.6],
				"Right Arm Twist": [0.8, 0.8],
				"Right Elbow": [1.0, 1.0],
				"Body Left": [0.7, 0.7],
				"Body Right": [0.7, 0.7],
				"Body Lean": [1.0, 0.8],
			},
			"None":
			{
				"Unused 20": ["None"],
				"Unused 21": ["None"],
				"Unused 22": ["None"],
				"Unused 23": ["None"],
				"Unused 24": ["None"],
				"Unused 25": ["None"],
				"Unused 26": ["None"],
				"Unused 27": ["None"],
				"Unused 28": ["None"],
				"Unused 29": ["None"],
				"Unused 30": ["None"],
				"Unused 31": ["None"],
				"Unused 32": ["None"],
			}
		}
	},
	"Chuck E's Corner": 
	{
		"bits": 8, 
		"scene": "res://Scenes/Stages/ChuckEsCorner.tscn", 
		"scene_ref_base": "SubViewport/ChuckEsCorner/",
		"camera_count": 3,
		
		"ust_character": "Chuck E.", 
		"ust_stage": "Cyberamics (Single Character)",
		
		"bit_mapping":
		{
			"Chuck":
			{
				"Mouth": [7.5, 6.0],
				"Head Left": [0.8, 1.0],
				"Head Right": [1.0, 1.0],
				"Head Up": [2.0, 1.0],
				"Eyes Left": [4.0, 3.0],
				"Eyes Right": [4.0, 3.0],
				"Eyelids": [7.5, 5.0],
				"Right Arm": [2.0, 1.0],
			}
		}
	}
}

signal step(amount: int)
signal start_recording()
signal end_recording()
signal return_to_zero()
signal erase_all()

func reload_stage(stage_previously_loaded: bool) -> void:
	if (stage_previously_loaded):
		$SequencerPanel/TimelinePanel/VScrollBar.value = 0
		$FlyoutPanel/Movements/VScrollBar.value = 0
		$FlyoutPanel/FlowControls/VScrollBar.value = 0
		$CameraPreview.visible = false
		for row in $SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_children():
			row.queue_free()
		for flow in $FlyoutPanel/FlowControls/InvisibleMask/FlowHandle.get_children():
			flow.queue_free()
		for movement in $FlyoutPanel/Movements/InvisibleMask/MovementHandle.get_children():
			movement.queue_free()
		for camera in $FlyoutPanel/Camera.get_children():
			camera.queue_free()
		$SubViewport.get_child(0).queue_free()
		cam_index = 0
	var stage = load(stages_info[current_stage]["scene"]).instantiate()
	$SubViewport.add_child(stage)
	var cam_offset = 4
	for i in range(1, stages_info[current_stage]["camera_count"]+1):
		var camera_button = load("res://Scenes/GUI/Controls/CameraButton.tscn").instantiate()
		camera_button.camera = "Angle " + str(i)
		camera_button.base_scene_path = "../../../" + stages_info[current_stage]["scene_ref_base"]
		camera_button.position.y = cam_offset
		cam_offset += 36
		$FlyoutPanel/Camera.add_child(camera_button)
	$FlyoutPanel/Camera.size.y = cam_offset
	var rows_offset = 0
	var flows_offset = 0
	var bit_idx = 1
	var flow_count = 0
	for bot in stages_info[current_stage]["bit_mapping"]:
		for movement in stages_info[current_stage]["bit_mapping"][bot]:
			
			var movement_flows = stages_info[current_stage]["bit_mapping"][bot][movement]
			if (movement_flows[0] is not String):
				var flow_control = load("res://Scenes/GUI/Controls/FlowControl.tscn").instantiate()
				flow_control.position.y = flows_offset
				flow_control.name = bot + " " + movement
				flow_control.in_value = movement_flows[0]
				flow_control.out_value = movement_flows[1]
				$FlyoutPanel/FlowControls/InvisibleMask/FlowHandle.add_child(flow_control)
				flows_offset += 44
				flow_count += 1
				
			var row = load("res://Scenes/GUI/Controls/MovementRow.tscn").instantiate()
			row.position.y = rows_offset
			row.base_scene_path = "../../../../../" + stages_info[current_stage]["scene_ref_base"]
			row.animatronic = bot
			if (movement_flows[0] is String): row.flow_path = "None"
			row.movement_bit = bit_idx
			row.movement_name = movement
			$SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.add_child(row)
			
			var movement_button = load("res://Scenes/GUI/Controls/MovementButton.tscn").instantiate()
			movement_button.position.y = rows_offset
			movement_button.base_scene_path = "../../../../../" + stages_info[current_stage]["scene_ref_base"]
			movement_button.animatronic = bot
			if (movement_flows[0] is String): movement_button.flow_path = "None"
			movement_button.movement_name = movement
			$FlyoutPanel/Movements/InvisibleMask/MovementHandle.add_child(movement_button)
			
			rows_offset += 44
			bit_idx += 1
	$SequencerPanel/TimelinePanel/VScrollBar.max_value = stages_info[current_stage]["bits"] - 1
	$FlyoutPanel/Movements/VScrollBar.max_value = stages_info[current_stage]["bits"] - 1
	$FlyoutPanel/FlowControls/VScrollBar.max_value = flow_count - 1
	$CameraPreview.visible = true

func _on_stage_change_overwrite_confirmation_dialog_confirmed() -> void:
	erase_all.emit()
	current_stage = $MenuBar/StageSelector.get_item_text($MenuBar/StageSelector.selected)
	reload_stage(true)

func update_time_label() -> void:
	var frames = index % 60
	var seconds = floori(index/60) % 60
	var minutes = floori(index/3600) % 60
	var hours = floori(index/216000)
	$SequencerPanel/TransportControls/TimeLabel.text = "%d:%02d:%02d:%02d" % [hours, minutes, seconds, frames] 

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
	erase_all.connect(_erase_all)
	$MenuBar/MenuButton.get_popup().id_pressed.connect(_showtape_menu_button_pressed)
	OS.request_permissions()
	current_stage = $MenuBar/StageSelector.get_item_text($MenuBar/StageSelector.selected)
	reload_stage(false)

func _on_stage_selector_item_selected(_index: int) -> void:
	if (showtape_loaded): $StageChangeOverwriteConfirmationDialog.show()
	else:
		current_stage = $MenuBar/StageSelector.get_item_text($MenuBar/StageSelector.selected)
		reload_stage(true)

func _showtape_menu_button_pressed(id: int) -> void:
	match (id):
		0: #new
			if (showtape_loaded): $NewOverwriteConfirmationDialog.show()
			else: $ShowtapeNewScreen.visible = true
		1: #load
			if (showtape_loaded): $LoadOverwriteConfirmationDialog.show()
			else: $ShowtapeLoadScreen.visible = true
		2: #save
			if (showtape_loaded): $ShowtapeSaveScreen.visible = true
			else: $NoShowtapeLoadedDialog.show()


func _on_showtape_new_audio_browse_button_pressed() -> void:
	$OpenAudioFileDialog.show()

func _on_open_audio_file_dialog_file_selected(path: String) -> void:
	$ShowtapeNewScreen/DialogPanel/AudioFilePath.text = path

func _on_showtape_new_cancel_button_pressed() -> void:
	$ShowtapeNewScreen/DialogPanel/AudioFilePath.text = ""
	$ShowtapeNewScreen/DialogPanel/ShowNameTextBox.text = ""
	$ShowtapeNewScreen.visible = false

func _on_showtape_new_create_button_pressed() -> void:
	if (!FileAccess.file_exists($ShowtapeNewScreen/DialogPanel/AudioFilePath.text.strip_edges())):
		$FileDoesntExistDialog.show()
		return
	if ($ShowtapeNewScreen/DialogPanel/ShowNameTextBox.text.strip_edges() == ""):
		$EmptyStringDialog.show()
		return
	show_name = $ShowtapeNewScreen/DialogPanel/ShowNameTextBox.text.strip_edges()
	$AudioStreamPlayer.stream = load_audio($ShowtapeNewScreen/DialogPanel/AudioFilePath.text.strip_edges())
	set_transport_enabled(true)
	showtape_loaded = true
	$MenuBar/EditingLabel.text = "Editing: " + show_name
	$ShowtapeNewScreen/DialogPanel/AudioFilePath.text = ""
	$ShowtapeNewScreen/DialogPanel/ShowNameTextBox.text = ""
	$ShowtapeNewScreen.visible = false

func _on_new_overwrite_confirmation_dialog_confirmed() -> void:
	erase_all.emit()
	$ShowtapeNewScreen.visible = true

func _on_open_showtape_file_dialog_file_selected(path: String) -> void:
	$ShowtapeLoadScreen/DialogPanel/InFilePath.text = path

func _on_showtape_load_in_browse_button_pressed() -> void:
	$OpenShowtapeFileDialog.show()

func _on_showtape_load_cancel_button_pressed() -> void:
	$ShowtapeLoadScreen/DialogPanel/InFilePath.text = ""
	$ShowtapeLoadScreen.visible = false

func _on_showtape_load_open_button_pressed() -> void:
	if (!FileAccess.file_exists($ShowtapeLoadScreen/DialogPanel/InFilePath.text.strip_edges())):
		$FileDoesntExistDialog.show()
		return
	var file = FileAccess.open($ShowtapeLoadScreen/DialogPanel/InFilePath.text.strip_edges(), FileAccess.READ)
	var content = file.get_as_text()
	var header = content.split(";")[0].split(",")
	if ((int(header[3]) != stages_info[current_stage]["bits"]) || (header[4] != stages_info[current_stage]["ust_stage"])|| (header[5] != stages_info[current_stage]["ust_character"])):
		$IncorrectShowtapeDialog.dialog_text = "This showtape is not compatible with the currently selected stage.\nShowtape stage type: %s\nShowtape character(s): %s" % [header[4], header[5]]
		$IncorrectShowtapeDialog.show()
		return
	show_name = header[2]
	plot_data(content.split(";")[1])
	$AudioStreamPlayer.stream = load_audio_from_buffer(Marshalls.base64_to_raw(content.split(";")[2]))
	set_transport_enabled(true)
	showtape_loaded = true
	$MenuBar/EditingLabel.text = "Editing: " + show_name
	$ShowtapeLoadScreen/DialogPanel/InFilePath.text = ""
	$ShowtapeLoadScreen.visible = false

func _on_load_overwrite_confirmation_dialog_confirmed() -> void:
	erase_all.emit()
	$ShowtapeLoadScreen.visible = true


func _on_showtape_save_out_browse_button_pressed() -> void:
	$SaveShowtapeFileDialog.show()

func _on_showtape_save_create_button_pressed() -> void:
	var header = "UST,1,"+show_name.replace(",", "_").replace(";", "_")+","+str(stages_info[current_stage][1])+","+stages_info[current_stage][6]+","+stages_info[current_stage][5]+";"
	var data_out_string = save_data()
	var file = FileAccess.open($ShowtapeSaveScreen/DialogPanel/OutFilePath.text, FileAccess.WRITE)
	file.store_string(header+data_out_string+";"+Marshalls.raw_to_base64($AudioStreamPlayer.stream.data))
	file.close()
	$ShowtapeSaveScreen/DialogPanel/OutFilePath.text = ""
	$ShowtapeSaveScreen.visible = false

func _on_showtape_save_cancel_button_pressed() -> void:
	$ShowtapeSaveScreen/DialogPanel/OutFilePath.text = ""
	$ShowtapeSaveScreen.visible = false

func _on_save_showtape_file_dialog_file_selected(path: String) -> void:
	$ShowtapeSaveScreen/DialogPanel/OutFilePath.text = path

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_editor_screen"):
		$CameraPreview.visible = !$CameraPreview.visible;
		$CameraFullScreen.visible = !$CameraFullScreen.visible;
	if event.is_action_pressed("fullscreen"):
		if (!fullscreen):
			fullscreen = true
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			fullscreen = false
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if (event.is_action_pressed("cycle_camera_angle")):
		cam_index += 1
		get_node(stages_info[current_stage]["scene_ref_base"] + "Angle " + str((cam_index % stages_info[current_stage]["camera_count"])+1)).current = true
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
	if (playing):
		step.emit(playback_rate)
		index += playback_rate
		if (index <= 0): _on_stop_button_pressed()
		update_time_label()

func load_audio(path: String) -> AudioStream:
	var sound
	match (path.split(".")[-1]):
		"mp3":
			sound = AudioStreamMP3.load_from_file(path)
		"wav":
			sound = AudioStreamWAV.load_from_file(path)
		"ogg":
			sound = AudioStreamOggVorbis.load_from_file(path)
	return sound

func load_audio_from_buffer(data: PackedByteArray) -> AudioStream:
	var sound
	match (data[0]):
		73:
			sound = AudioStreamMP3.load_from_buffer(data)
		82:
			sound = AudioStreamWAV.load_from_buffer(data)
		79:
			sound = AudioStreamOggVorbis.load_from_buffer(data)
	return sound

func _on_size_changed() -> void:
	$SubViewport.size = $ColorRect.size

func _on_controls_button_pressed() -> void:
	$ControlsScreen.visible = true

func _on_credits_button_pressed() -> void:
	$CreditsScreen.visible = true

func _on_input_eater_pressed() -> void:
	$ControlsScreen.visible = false
	$CreditsScreen.visible = false
	$ShowtapeNewScreen.visible = false
	$ShowtapeLoadScreen.visible = false
	$ShowtapeSaveScreen.visible = false

func _on_v_scroll_bar_value_changed(value: float) -> void:
	$SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.position.y = value * -44

func _on_flow_v_scroll_bar_value_changed(value: float) -> void:
	$FlyoutPanel/FlowControls/InvisibleMask/FlowHandle.position.y = value * -44

func _on_movement_v_scroll_bar_value_changed(value: float) -> void:
	$FlyoutPanel/Movements/InvisibleMask/MovementHandle.position.y = value * -44

func _erase_all() -> void:
	playing = false
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.seek(0)
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false
	index = 0
	update_time_label()
	show_name = ""
	$AudioStreamPlayer.stream = null
	set_transport_enabled(false)
	showtape_loaded = false
	$MenuBar/EditingLabel.text = "No showtape loaded."

func _on_movements_flyout_button_toggled(toggled_on: bool) -> void:
	$FlyoutPanel/Movements.visible = toggled_on

func _on_flows_flyout_button_toggled(toggled_on: bool) -> void:
	$FlyoutPanel/FlowControls.visible = toggled_on

func _on_camera_flyout_button_toggled(toggled_on: bool) -> void:
	$FlyoutPanel/Camera.visible = toggled_on

func _on_cosmetics_flyout_button_toggled(toggled_on: bool) -> void:
	$FlyoutPanel/Cosmetics.visible = toggled_on

func _on_stage_flyout_button_toggled(toggled_on: bool) -> void:
	$FlyoutPanel/Stage.visible = toggled_on


func _on_play_button_pressed() -> void:
	playback_rate = 1
	$AudioStreamPlayer.pitch_scale = 1
	$AudioStreamPlayer.play(float(index)/60.0)
	playing = true

func _on_pause_button_pressed() -> void:
	$AudioStreamPlayer.stop()
	playing = false

func _on_play_backwards_button_pressed() -> void:
	playback_rate = -1
	$AudioStreamPlayer.stop() # cant play backwards :(
	playing = true
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false 

func _on_fast_backwards_button_pressed() -> void:
	playback_rate = -2
	$AudioStreamPlayer.stop() # cant play backwards :(
	playing = true
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false

func _on_step_backwards_button_pressed() -> void:
	playing = false
	$AudioStreamPlayer.stop()
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false
	if (index != 0): 
		step.emit(-1)
		index -= 1
	update_time_label()

func _on_fast_forward_button_pressed() -> void:
	playback_rate = 2
	$AudioStreamPlayer.pitch_scale = 2
	$AudioStreamPlayer.play(float(index)/60.0)
	playing = true
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false

func _on_step_forward_button_pressed() -> void:
	playing = false
	$AudioStreamPlayer.stop()
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
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.seek(0)
	$SequencerPanel/TransportControls/RecordButton.button_pressed = false
	index = 0
	return_to_zero.emit()
	update_time_label()

func save_data() -> String:
	var write_out : String = ""
	var temp_data = []
	var longest_channel = 0
	for movement_row in $SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_children():
		temp_data.append(movement_row.movements)
		if (movement_row.movements.size() > longest_channel): longest_channel = movement_row.movements.size()
	for i in range(longest_channel+1):
		var frame_byte = 0
		for j in range(stages_info[current_stage]["bits"]):
			if (index_get_safe(i, temp_data[j])): frame_byte += 1 << j;
		write_out += ("%0"+str(stages_info[current_stage]["bits"]/4)+"X,") % frame_byte
	return write_out

func plot_data(data: String):
	start_recording.emit()
	for frame_string in data.split(","):
		if (frame_string == ""): continue
		var frame_byte = frame_string.hex_to_int()
		for i in range(stages_info[current_stage]["bits"]):
			var er = false
			if ((frame_byte & int(pow(2, i))) >> i == 1): 
				er = true
			$SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_child(i).etching = er
		step.emit(1)
	for movement_row in $SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_children():
		movement_row.etching = false
	end_recording.emit()
	return_to_zero.emit()

func index_get_safe(cindex: int, data: Array[bool]) -> bool:
	if (cindex > data.size()-1): return false
	if (cindex < 0): return false
	var out = data.get(cindex)
	if (out == null): return false
	return out
