extends Control

var playing : bool = false
var recording : bool = false
var index : int = 0
var playback_rate : int = 1
var transport_enabled : bool = false
var erase_validated : bool = false
var cam_index : int = 0

var showtape_loaded : bool = false
var show_name : String

var current_stage : String

signal step(amount: int)
signal start_recording()
signal end_recording()
signal return_to_zero()
signal erase_all()

func reload_stage() -> void:
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
	for cosmetic_adjustment in $FlyoutPanel/Cosmetics/InvisibleMask/CosmeticsHandle.get_children():
		cosmetic_adjustment.queue_free()
	if ($SubViewport.get_child_count() > 0):
		$SubViewport.get_child(0).queue_free()
	cam_index = 0
	var stage = load(Stages.stages_info[current_stage]["scene"]).instantiate()
	$SubViewport.add_child(stage)
	
	var cam_offset = 4
	for i in range(1, Stages.stages_info[current_stage]["camera_count"]+1):
		var camera_button = load("res://Scenes/GUI/Controls/CameraButton.tscn").instantiate()
		camera_button.camera = "Angle " + str(i)
		camera_button.base_scene_path = "../../../" + Stages.stages_info[current_stage]["scene_ref_base"]
		camera_button.position.y = cam_offset
		cam_offset += 36
		$FlyoutPanel/Camera.add_child(camera_button)
	$FlyoutPanel/Camera.size.y = cam_offset
	
	var cosmetics_offset = 0
	var cosmetics_count = 0
	for cosmetic_subtable in Stages.stages_info[current_stage]["cosmetics"]:
		for cosmetic in cosmetic_subtable:
			var cosmetic_adjustment = load("res://Scenes/GUI/Controls/CosmeticAdjustment.tscn").instantiate()
			cosmetic_adjustment.vis_name = cosmetic
			cosmetic_adjustment.options = cosmetic_subtable[cosmetic]
			cosmetic_adjustment.scene_handle = "../../../../../" + Stages.stages_info[current_stage]["scene_ref_base"]
			cosmetic_adjustment.drop_index = Stages.stages_info[current_stage]["cosmetic_defaults"][cosmetics_count]
			cosmetic_adjustment.position.y = cosmetics_offset
			cosmetics_offset += 44
			cosmetics_count += 1
			$FlyoutPanel/Cosmetics/InvisibleMask/CosmeticsHandle.add_child(cosmetic_adjustment)
	$FlyoutPanel/Cosmetics/VScrollBar.max_value = cosmetics_count - 1
	
	var rows_offset = 0
	var flows_offset = 0
	var flow_count = 0
	for bit_number in Stages.stages_info[current_stage]["bit_mapping"]:
		var bot = Stages.stages_info[current_stage]["bit_mapping"][bit_number]["bot"]
		var movement = Stages.stages_info[current_stage]["bit_mapping"][bit_number]["movement"]
		
		var in_flow = Stages.stages_info[current_stage]["bit_mapping"][bit_number]["flow_in"]
		var out_flow = Stages.stages_info[current_stage]["bit_mapping"][bit_number]["flow_out"]
		if (in_flow is not String):
			var flow_control = load("res://Scenes/GUI/Controls/FlowControl.tscn").instantiate()
			flow_control.position.y = flows_offset
			flow_control.name = str(bit_number) + bot + movement + current_stage
			flow_control.vis_name = bot + " " + movement
			flow_control.in_value = in_flow
			flow_control.out_value = out_flow
			$FlyoutPanel/FlowControls/InvisibleMask/FlowHandle.add_child(flow_control)
			flows_offset += 44
			flow_count += 1
				
		var row = load("res://Scenes/GUI/Controls/MovementRow.tscn").instantiate()
		row.name = str(bit_number) + " Bit"
		row.position.y = rows_offset
		row.base_scene_path = "../../../../../" + Stages.stages_info[current_stage]["scene_ref_base"]
		row.animatronic = bot
		row.current_stage = current_stage
		if (in_flow is String): row.flow_path = "None"
		row.movement_bit = bit_number
		row.movement_name = movement
		$SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.add_child(row, true)
			
		var movement_button = load("res://Scenes/GUI/Controls/MovementButton.tscn").instantiate()
		movement_button.position.y = rows_offset
		movement_button.base_scene_path = "../../../../../" + Stages.stages_info[current_stage]["scene_ref_base"]
		movement_button.animatronic = bot
		movement_button.movement_bit = bit_number
		movement_button.current_stage = current_stage
		if (in_flow is String): movement_button.flow_path = "None"
		movement_button.movement_name = movement
		$FlyoutPanel/Movements/InvisibleMask/MovementHandle.add_child(movement_button)
		rows_offset += 44
	$SequencerPanel/TimelinePanel/VScrollBar.max_value = Stages.stages_info[current_stage]["bits"] - 1
	$FlyoutPanel/Movements/VScrollBar.max_value = Stages.stages_info[current_stage]["bits"] - 1
	$FlyoutPanel/FlowControls/VScrollBar.max_value = flow_count - 1
	$CameraPreview.visible = true

func _on_stage_change_overwrite_confirmation_dialog_confirmed() -> void:
	erase_all.emit()
	current_stage = $MenuBar/StageSelector.get_item_text($MenuBar/StageSelector.selected)
	reload_stage()

func update_time_label() -> void:
	var frames = index % 60
	var seconds = floori(index/60.0) % 60
	var minutes = floori(index/3600.0) % 60
	var hours = floori(index/216000.0)
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
	for mod in Stages.loaded_mods:
		for moddedStage in Stages.loaded_mods[mod]["implements_stages"]:
			$MenuBar/StageSelector.add_item(moddedStage)
	current_stage = $MenuBar/StageSelector.get_item_text($MenuBar/StageSelector.selected)
	reload_stage()

func _on_stage_selector_item_selected(_index: int) -> void:
	if (showtape_loaded): $StageChangeOverwriteConfirmationDialog.show()
	else:
		current_stage = $MenuBar/StageSelector.get_item_text($MenuBar/StageSelector.selected)
		reload_stage()

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
		3: # exit menu
			if (showtape_loaded): $ExitMenuOverwriteConfirmationDialog.show()
			else: get_tree().change_scene_to_file("res://Scenes/GUI/MainMenu.tscn")
		4: # exit desktop
			if (showtape_loaded): $ExitDesktopOverwriteConfirmationDialog.show()
			else: get_tree().quit()


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
	if (header[1] != "2"):
		$IncorrectShowtapeDialog.dialog_text = "This showtape is not the correct version!"
		$IncorrectShowtapeDialog.show()
		return
	if (header[3] != Stages.stages_info[current_stage]["ust_type"]):
		$IncorrectShowtapeDialog.dialog_text = "This showtape is not compatible with the currently selected stage.\nShowtape stage type: %s\n Current stage type: %s" % [ header[3], Stages.stages_info[current_stage]["ust_type"] ]
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
	if ($ShowtapeSaveScreen/DialogPanel/OutFilePath.text == ""):
		$NoFileSpecified.show()
		return
	var header = "UST,2,"+show_name.replace(",", "_").replace(";", "_")+","+Stages.stages_info[current_stage]["ust_type"]+";"
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
	if event.is_action_pressed("editor_toggle_full_camera"):
		$CameraPreview.visible = !$CameraPreview.visible;
		$CameraFullScreen.visible = !$CameraFullScreen.visible;
	if event.is_action_pressed("fullscreen"):
		if (!DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if (event.is_action_pressed("editor_cycle_camera_angle")):
		cam_index += 1
		get_node(Stages.stages_info[current_stage]["scene_ref_base"] + "Angle " + str((cam_index % Stages.stages_info[current_stage]["camera_count"])+1)).current = true
	if (transport_enabled):
		if event.is_action_pressed("editor_sequencer_play_pause"):
			if (playing): _on_pause_button_pressed()
			else: _on_play_button_pressed()
		elif event.is_action_pressed("editor_sequencer_play_reverse"):
			_on_play_backwards_button_pressed()
		elif event.is_action_pressed("editor_sequencer_fast_reverse"):
			_on_fast_backwards_button_pressed()
		elif event.is_action_pressed("editor_sequencer_fast_forward"):
			_on_fast_forward_button_pressed()
		elif event.is_action_pressed("editor_sequencer_step_backward"):
			_on_step_backwards_button_pressed()
		elif event.is_action_pressed("editor_sequencer_step_forward"):
			_on_step_forward_button_pressed()
		elif event.is_action_pressed("editor_sequencer_home"):
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
	$ShowtapeNewScreen.visible = false
	$ShowtapeLoadScreen.visible = false
	$ShowtapeSaveScreen.visible = false

func _on_v_scroll_bar_value_changed(value: float) -> void:
	$SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.position.y = value * -44

func _on_flow_v_scroll_bar_value_changed(value: float) -> void:
	$FlyoutPanel/FlowControls/InvisibleMask/FlowHandle.position.y = value * -44

func _on_movement_v_scroll_bar_value_changed(value: float) -> void:
	$FlyoutPanel/Movements/InvisibleMask/MovementHandle.position.y = value * -44

func _on_cosmetics_v_scroll_bar_value_changed(value: float) -> void:
	$FlyoutPanel/Cosmetics/InvisibleMask/CosmeticsHandle.position.y = value * -44

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
	if (playing): 
		# starting recording while playing causes issues
		_on_stop_button_pressed()
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
	var temp_data = {}
	var longest_channel = 0
	for movement_row in $SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_children():
		temp_data[movement_row.movement_bit] = movement_row.movements
		if (movement_row.movements.size() > longest_channel): longest_channel = movement_row.movements.size()
	for i in range(longest_channel+1):
		var total_frame_index = 1
		var fstring = ""
		for j in range(64):
			var f_quartet = 0
			for k in range(4):
				if (index_get_safe(i, index_s_get_safe(total_frame_index, temp_data))):
					f_quartet += int(pow(2, k))
				total_frame_index += 1
			fstring = ("%01X" % f_quartet) + fstring
		write_out += fstring + ","
	return write_out

func plot_data(data: String):
	start_recording.emit()
	var evil_glass = []
	for movement_row in $SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_children():
		evil_glass.append(movement_row.movement_bit)
	for frame_string in data.split(","):
		if (frame_string == ""): continue
		var check_frame_split = frame_string.split()
		check_frame_split.reverse()
		for i in Stages.stages_info[current_stage]["bit_mapping"]:
			var er = false
			if ((check_frame_split[(i - 1) / 4].hex_to_int() & int(pow(2, ((i - 1) % 4)))) == int(pow(2, ((i - 1) % 4)))): 
				er = true
			$SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_child(evil_glass.find(i)).forced_etchable = true
			$SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_child(evil_glass.find(i)).etching = er
		step.emit(1)
	for movement_row in $SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_children():
		movement_row.forced_etchable = false
		movement_row.etching = false
	end_recording.emit()
	return_to_zero.emit()

func index_get_safe(cindex: int, data: Array[bool]) -> bool:
	if (cindex > data.size()-1): return false
	if (cindex < 0): return false
	var out = data.get(cindex)
	if (out == null): return false
	return out

func index_s_get_safe(cindex: int, data: Dictionary) -> Array[bool]:
	if (cindex > data.size()-1): return [ false ]
	if (cindex < 0): return [ false ]
	var out = data.get(cindex)
	if (out == null): return [ false ]
	return out


func _on_exit_menu_overwrite_confirmation_dialog_confirmed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GUI/MainMenu.tscn")


func _on_exit_desktop_overwrite_confirmation_dialog_2_confirmed() -> void:
	get_tree().quit()


func _on_instructions_label_pressed() -> void:
	$InstructionsLabel.visible = false
