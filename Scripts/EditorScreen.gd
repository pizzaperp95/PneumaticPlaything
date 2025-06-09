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
		"bits": 20, 
		"scene": "res://Scenes/Stages/HelenHouse.tscn", 
		"scene_ref_base": "SubViewport/HelenHouse/",
		"camera_count": 2,
		
		"ust_type": "Rockafire Explosion/3-Stage",
		
		"bit_mapping":
		{
			23: { "bot": "Helen", "movement": "Mouth", "flow_in": 3.0, "flow_out": 2.0 },
			24: { "bot": "Helen", "movement": "Left Ear", "flow_in": 3.5, "flow_out": 1.5 },
			25: { "bot": "Helen", "movement": "Right Ear", "flow_in": 3.5, "flow_out": 1.5 },
			26: { "bot": "Helen", "movement": "Left Eyelid", "flow_in": 1.5, "flow_out": 2.0 },
			27: { "bot": "Helen", "movement": "Right Eyelid", "flow_in": 1.5, "flow_out": 2.0 },
			28: { "bot": "Helen", "movement": "Eyes Left", "flow_in": 3.5, "flow_out": 1.5 },
			29: { "bot": "Helen", "movement": "Eyes Right", "flow_in": 3.5, "flow_out": 1.5 },
			30: { "bot": "Helen", "movement": "Head Left", "flow_in": 1.5, "flow_out": 1.5 },
			31: { "bot": "Helen", "movement": "Head Right", "flow_in": 1.5, "flow_out": 1.5 },
			32: { "bot": "Helen", "movement": "Head Up", "flow_in": 1.0, "flow_out": 1.0 },
			33: { "bot": "Helen", "movement": "Left Arm Up", "flow_in": 0.8, "flow_out": 0.6 },
			34: { "bot": "Helen", "movement": "Left Arm Twist", "flow_in": 0.8, "flow_out": 0.8 },
			35: { "bot": "Helen", "movement": "Left Elbow", "flow_in": 1.0, "flow_out": 1.0 },
			36: { "bot": "Helen", "movement": "Right Arm Up", "flow_in": 0.8, "flow_out": 0.6 },
			37: { "bot": "Helen", "movement": "Right Arm Twist", "flow_in": 0.8, "flow_out": 0.8 },
			38: { "bot": "Helen", "movement": "Right Elbow", "flow_in": 1.0, "flow_out": 1.0 },
			39: { "bot": "Helen", "movement": "Body Left", "flow_in": 0.7, "flow_out": 0.7 },
			40: { "bot": "Helen", "movement": "Body Right", "flow_in": 0.7, "flow_out": 0.7 },
			41: { "bot": "Helen", "movement": "Body Lean", "flow_in": 1.0, "flow_out": 0.8 },
			125: { "bot": "Spots", "movement": "Helen", "flow_in": "None", "flow_out": "None" },
		},
		
		"cosmetics": 
		{ 
			"Helen Hair":
			{
				"Black and White":
				{
					"Helen/Helen/Skeleton3D/BWHair": true,
					"Helen/Helen/Skeleton3D/YellowHair": false,
				},
				"Yellow":
				{
					"Helen/Helen/Skeleton3D/BWHair": false,
					"Helen/Helen/Skeleton3D/YellowHair": true,
				},
			},
			"Helen Dress":
			{
				"Tux":
				{
					"Helen/Helen/Skeleton3D/Collar": true,
					"Helen/Helen/Skeleton3D/Torso": true,
					"Helen/Helen/Skeleton3D/Skirt": true,
					"Helen/Helen/Skeleton3D/CheerDress": false,
				},
				"Cheerleader":
				{
					"Helen/Helen/Skeleton3D/Collar": false,
					"Helen/Helen/Skeleton3D/Torso": false,
					"Helen/Helen/Skeleton3D/Skirt": false,
					"Helen/Helen/Skeleton3D/CheerDress": true,
				}
			}
		}
	},
	"Chuck E's Corner": 
	{
		"bits": 16, 
		"scene": "res://Scenes/Stages/ChuckEsCorner.tscn", 
		"scene_ref_base": "SubViewport/ChuckEsCorner/",
		"camera_count": 3,
		
		"ust_type": "Cyberamics",
		
		"bit_mapping":
		{
			1: { "bot": "Chuck", "movement": "Mouth", "flow_in": 7.5, "flow_out": 6.0 },
			2: { "bot": "Chuck", "movement": "Head Left", "flow_in": 0.8, "flow_out": 1.0 },
			3: { "bot": "Chuck", "movement": "Head Right", "flow_in": 1.0, "flow_out": 1.0 },
			4: { "bot": "Chuck", "movement": "Head Up", "flow_in": 2.0, "flow_out": 1.0 },
			5: { "bot": "Chuck", "movement": "Eyes Left", "flow_in": 4.0, "flow_out": 3.0 },
			6: { "bot": "Chuck", "movement": "Eyes Right", "flow_in": 4.0, "flow_out": 3.0 },
			7: { "bot": "Chuck", "movement": "Eyelids", "flow_in": 7.5, "flow_out": 5.0 },
			8: { "bot": "Chuck", "movement": "Right Arm", "flow_in": 2.0, "flow_out": 1.0 },
			41: { "bot": "Warblettes", "movement": "Mouth", "flow_in": 4.0, "flow_out": 3.0 },
			44: { "bot": "Warblettes", "movement": "Body Rock", "flow_in": 1.0, "flow_out": 1.0 },
			50: { "bot": "Spots", "movement": "Chuck", "flow_in": "None", "flow_out": "None" },
			56: { "bot": "Spots", "movement": "Warblettes", "flow_in": "None", "flow_out": "None" },
			71: { "bot": "Floods", "movement": "Red", "flow_in": "None", "flow_out": "None" },
			72: { "bot": "Floods", "movement": "Green", "flow_in": "None", "flow_out": "None" },
			73: { "bot": "Floods", "movement": "Blue", "flow_in": "None", "flow_out": "None" },
			79: { "bot": "Color Spots", "movement": "Chuck", "flow_in": "None", "flow_out": "None" },
		},
		
		"cosmetics":
		{
			"Chuck E. Hat":
			{
				"Derby":
				{
					"Chuck/Chuck/Skeleton3D/Avenger Hat": false,
					"Chuck/Chuck/Skeleton3D/Cool Chuck Hat": false,
					"Chuck/Chuck/Skeleton3D/Derby": true,
				},
				"Cool Chuck":
				{
					"Chuck/Chuck/Skeleton3D/Avenger Hat": false,
					"Chuck/Chuck/Skeleton3D/Cool Chuck Hat": true,
					"Chuck/Chuck/Skeleton3D/Derby": false,
				},
				"Avenger":
				{
					"Chuck/Chuck/Skeleton3D/Avenger Hat": true,
					"Chuck/Chuck/Skeleton3D/Cool Chuck Hat": false,
					"Chuck/Chuck/Skeleton3D/Derby": false,
				},
				"None":
				{
					"Chuck/Chuck/Skeleton3D/Avenger Hat": false,
					"Chuck/Chuck/Skeleton3D/Cool Chuck Hat": false,
					"Chuck/Chuck/Skeleton3D/Derby": false,
				}
			},
			
			"Chuck E. Shirt":
			{
				"Red Vest":
				{
					"Chuck/Chuck/Skeleton3D/Avenger Shirt": false,
					"Chuck/Chuck/Skeleton3D/Cool Chuck Shirt": false,
					"Chuck/Chuck/Skeleton3D/Black Bowtie": true,
					"Chuck/Chuck/Skeleton3D/Buttons": true,
					"Chuck/Chuck/Skeleton3D/Vest Trim": true,
					"Chuck/Chuck/Skeleton3D/Yellow Checker Vest": false,
					"Chuck/Chuck/Skeleton3D/Rocker Vest": true,
				},
				"Yellow Checker Vest":
				{
					"Chuck/Chuck/Skeleton3D/Avenger Shirt": false,
					"Chuck/Chuck/Skeleton3D/Cool Chuck Shirt": false,
					"Chuck/Chuck/Skeleton3D/Black Bowtie": true,
					"Chuck/Chuck/Skeleton3D/Buttons": true,
					"Chuck/Chuck/Skeleton3D/Vest Trim": true,
					"Chuck/Chuck/Skeleton3D/Yellow Checker Vest": true,
					"Chuck/Chuck/Skeleton3D/Rocker Vest": false,
				},
				"Cool Chuck Shirt":
				{
					"Chuck/Chuck/Skeleton3D/Avenger Shirt": false,
					"Chuck/Chuck/Skeleton3D/Cool Chuck Shirt": true,
					"Chuck/Chuck/Skeleton3D/Black Bowtie": false,
					"Chuck/Chuck/Skeleton3D/Buttons": false,
					"Chuck/Chuck/Skeleton3D/Vest Trim": false,
					"Chuck/Chuck/Skeleton3D/Yellow Checker Vest": false,
					"Chuck/Chuck/Skeleton3D/Rocker Vest": false,
				},
				"Avenger Shirt":
				{
					"Chuck/Chuck/Skeleton3D/Avenger Shirt": true,
					"Chuck/Chuck/Skeleton3D/Cool Chuck Shirt": false,
					"Chuck/Chuck/Skeleton3D/Black Bowtie": false,
					"Chuck/Chuck/Skeleton3D/Buttons": false,
					"Chuck/Chuck/Skeleton3D/Vest Trim": false,
					"Chuck/Chuck/Skeleton3D/Yellow Checker Vest": false,
					"Chuck/Chuck/Skeleton3D/Rocker Vest": false,
				}
			},
			
			"Chuck E. Mask":
			{
				"PTT":
				{
					"Chuck/Chuck/Skeleton3D/PTT Ears": true,
					"Chuck/Chuck/Skeleton3D/PTT Ears Inside": true,
					"Chuck/Chuck/Skeleton3D/PTT Jaw": true,
					"Chuck/Chuck/Skeleton3D/PTT Muzzle": true,
					"Chuck/Chuck/Skeleton3D/Modern Ears": false,
					"Chuck/Chuck/Skeleton3D/Modern Ears Inside": false,
					"Chuck/Chuck/Skeleton3D/Modern Jaw": false,
					"Chuck/Chuck/Skeleton3D/Modern Muzzle": false,
				},
				"Modern":
				{
					"Chuck/Chuck/Skeleton3D/PTT Ears": false,
					"Chuck/Chuck/Skeleton3D/PTT Ears Inside": false,
					"Chuck/Chuck/Skeleton3D/PTT Jaw": false,
					"Chuck/Chuck/Skeleton3D/PTT Muzzle": false,
					"Chuck/Chuck/Skeleton3D/Modern Ears": true,
					"Chuck/Chuck/Skeleton3D/Modern Ears Inside": true,
					"Chuck/Chuck/Skeleton3D/Modern Jaw": true,
					"Chuck/Chuck/Skeleton3D/Modern Muzzle": true,
				},
			},
			
			"Chuck E. Eyelids":
			{
				"Blue":
				{
					"Chuck/Chuck/Skeleton3D/Blue Eyelids": true,
					"Chuck/Chuck/Skeleton3D/Grey Eyelids": false,
				},
				"Grey":
				{
					"Chuck/Chuck/Skeleton3D/Blue Eyelids": false,
					"Chuck/Chuck/Skeleton3D/Grey Eyelids": true,
				},
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
		for cosmetic_adjustment in $FlyoutPanel/Cosmetics/InvisibleMask/CosmeticsHandle.get_children():
			cosmetic_adjustment.queue_free()
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
	
	var cosmetics_offset = 0
	var cosmetics_count = -1
	for cosmetic in stages_info[current_stage]["cosmetics"]:
		var cosmetic_adjustment = load("res://Scenes/GUI/Controls/CosmeticAdjustment.tscn").instantiate()
		cosmetic_adjustment.vis_name = cosmetic
		cosmetic_adjustment.options = stages_info[current_stage]["cosmetics"][cosmetic]
		cosmetic_adjustment.scene_handle = "../../../../../" + stages_info[current_stage]["scene_ref_base"]
		cosmetic_adjustment.position.y = cosmetics_offset
		cosmetics_offset += 44
		cosmetics_count += 1
		$FlyoutPanel/Cosmetics/InvisibleMask/CosmeticsHandle.add_child(cosmetic_adjustment)
	$FlyoutPanel/Cosmetics/VScrollBar.max_value = cosmetics_count
	
	var rows_offset = 0
	var flows_offset = 0
	var flow_count = 0
	for bit_number in stages_info[current_stage]["bit_mapping"]:
		var bot = stages_info[current_stage]["bit_mapping"][bit_number]["bot"]
		var movement = stages_info[current_stage]["bit_mapping"][bit_number]["movement"]
		
		var in_flow = stages_info[current_stage]["bit_mapping"][bit_number]["flow_in"]
		var out_flow = stages_info[current_stage]["bit_mapping"][bit_number]["flow_out"]
		if (in_flow is not String):
			var flow_control = load("res://Scenes/GUI/Controls/FlowControl.tscn").instantiate()
			flow_control.position.y = flows_offset
			flow_control.name = bot + " " + movement
			flow_control.in_value = in_flow
			flow_control.out_value = out_flow
			$FlyoutPanel/FlowControls/InvisibleMask/FlowHandle.add_child(flow_control)
			flows_offset += 44
			flow_count += 1
				
		var row = load("res://Scenes/GUI/Controls/MovementRow.tscn").instantiate()
		row.name = str(bit_number) + " Bit"
		row.position.y = rows_offset
		row.base_scene_path = "../../../../../" + stages_info[current_stage]["scene_ref_base"]
		row.animatronic = bot
		if (in_flow is String): row.flow_path = "None"
		row.movement_bit = bit_number
		row.movement_name = movement
		$SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.add_child(row, true)
			
		var movement_button = load("res://Scenes/GUI/Controls/MovementButton.tscn").instantiate()
		movement_button.position.y = rows_offset
		movement_button.base_scene_path = "../../../../../" + stages_info[current_stage]["scene_ref_base"]
		movement_button.animatronic = bot
		if (in_flow is String): movement_button.flow_path = "None"
		movement_button.movement_name = movement
		$FlyoutPanel/Movements/InvisibleMask/MovementHandle.add_child(movement_button)
		rows_offset += 44
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
	if (header[1] != "2"):
		$IncorrectShowtapeDialog.dialog_text = "This showtape is not the correct version!"
		$IncorrectShowtapeDialog.show()
		return
	if (header[3] != stages_info[current_stage]["ust_type"]):
		$IncorrectShowtapeDialog.dialog_text = "This showtape is not compatible with the currently selected stage.\nShowtape stage type: " + header[3]
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
	var header = "UST,2,"+show_name.replace(",", "_").replace(";", "_")+","+stages_info[current_stage]["ust_type"]+";"
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
		temp_data[int(movement_row.name.split(" ")[0])] = movement_row.movements
		if (movement_row.movements.size() > longest_channel): longest_channel = movement_row.movements.size()
	for i in range(longest_channel+1):
		var frame_long_1 = 0
		var frame_long_2 = 0
		var frame_long_3 = 0
		var frame_long_4 = 0
		var frame_long_5 = 0
		var frame_long_6 = 0
		var frame_long_7 = 0
		var frame_long_8 = 0
		for j in temp_data:
			if (index_get_safe(i, temp_data[j])): 
				if (j <= 32):
					frame_long_1 += 1 << (j&32)-1
				elif (j <= 64):
					frame_long_2 += 1 << (j&32)-1
				elif (j <= 96):
					frame_long_3 += 1 << (j&32)-1
				elif (j <= 128):
					frame_long_4 += 1 << (j&32)-1
				elif (j <= 160):
					frame_long_5 += 1 << (j&32)-1
				elif (j <= 192):
					frame_long_6 += 1 << (j&32)-1
				elif (j <= 224):
					frame_long_7 += 1 << (j&32)-1
				elif (j <= 256):
					frame_long_8 += 1 << (j&32)-1
		write_out += (("%08X%08X%08X%08X%08X%08X%08X%08X,") % [frame_long_8, frame_long_7, frame_long_6, frame_long_5, frame_long_4, frame_long_3, frame_long_2, frame_long_1])
	return write_out

func plot_data(data: String):
	start_recording.emit()
	var evil_glass = []
	for movement_row in $SequencerPanel/TimelinePanel/InvisibleMask/MovementRowsContainer.get_children():
		evil_glass.append(movement_row.movement_bit)
	for frame_string in data.split(","):
		if (frame_string == ""): continue
		var frame_long_8 = frame_string.substr(0, 8).hex_to_int()
		var frame_long_7 = frame_string.substr(8, 8).hex_to_int()
		var frame_long_6 = frame_string.substr(16, 8).hex_to_int()
		var frame_long_5 = frame_string.substr(24, 8).hex_to_int()
		var frame_long_4 = frame_string.substr(32, 8).hex_to_int()
		var frame_long_3 = frame_string.substr(40, 8).hex_to_int()
		var frame_long_2 = frame_string.substr(48, 8).hex_to_int()
		var frame_long_1 = frame_string.substr(56, 8).hex_to_int()
		for i in stages_info[current_stage]["bit_mapping"]:
			var er = false
			var check_i = (i % 32) - 1
			var check_frame_segment = frame_long_1
			if (i <= 32):
				check_frame_segment = frame_long_1
			elif (i <= 64):
				check_frame_segment = frame_long_2
			elif (i <= 96):
				check_frame_segment = frame_long_3
			elif (i <= 128):
				check_frame_segment = frame_long_4
			elif (i <= 160):
				check_frame_segment = frame_long_5
			elif (i <= 192):
				check_frame_segment = frame_long_6
			elif (i <= 224):
				check_frame_segment = frame_long_7
			elif (i <= 256):
				check_frame_segment = frame_long_8
			if ((check_frame_segment & int(pow(2, check_i))) >> check_i == 1): 
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
