extends Control

var in_flows = []
var out_flows = []
var prev_frame_held = []
var animatables_handles = []

var transport_enabled = false
var playing = false
var index = 0

var loaded_frames = []
var show_is_loaded = false
var show_name

var stage

func _ready() -> void:
	stage = FreeRoamMaps.MapIndex[get_node("../").current_map]["stage"]
	
	var cosmetics_offset = 0
	var cosmetics_count = 0
	for cosmetic_subtable in stage["cosmetics"]:
		for cosmetic in cosmetic_subtable:
			var cosmetic_adjustment = load("res://Scenes/GUI/Controls/CosmeticAdjustment.tscn").instantiate()
			cosmetic_adjustment.vis_name = cosmetic
			cosmetic_adjustment.options = cosmetic_subtable[cosmetic]
			cosmetic_adjustment.scene_handle = "../../../../../../../"
			cosmetic_adjustment.drop_index = stage["cosmetic_defaults"][cosmetics_count]
			cosmetic_adjustment.position.y = cosmetics_offset
			cosmetic_adjustment.anchor_right = 1.0
			cosmetics_offset += 44
			cosmetics_count += 1
			$CosmeticsScreen/DialogPanel/InvisibleMask/CosmeticsHandle.add_child(cosmetic_adjustment)
	$CosmeticsScreen/DialogPanel/VScrollBar.max_value = cosmetics_count - 1
	
	var movement_count = 0
	var flows_offset = 0
	var flow_count = 0
	for bit_number in stage["bit_mapping"]:
		var bot = stage["bit_mapping"][bit_number]["bot"]
		var movement = stage["bit_mapping"][bit_number]["movement"]
		
		var in_flow = stage["bit_mapping"][bit_number]["flow_in"]
		var out_flow = stage["bit_mapping"][bit_number]["flow_out"]
		
		animatables_handles.push_back(get_node("../../" + bot))
		in_flows.push_back(in_flow)
		out_flows.push_back(out_flow)
		prev_frame_held.push_back(false)
		
		if (in_flow is not String):
			var flow_control = load("res://Scenes/GUI/Controls/FlowControl.tscn").instantiate()
			flow_control.position.y = flows_offset
			flow_control.name = str(bit_number) + bot + movement + get_node("../").current_map
			flow_control.vis_name = bot + " " + movement
			flow_control.in_value = in_flow
			flow_control.out_value = out_flow
			flow_control.anchor_right = 1.0
			flow_control.internal_id = movement_count
			$FlowControlsScreen/DialogPanel/InvisibleMask/FlowHandle.add_child(flow_control)
			flow_control.in_value_updated.connect(self._update_in_flow)
			flow_control.out_value_updated.connect(self._update_out_flow)
			flows_offset += 44
			flow_count += 1
		movement_count += 1
	
	$FlowControlsScreen/DialogPanel/VScrollBar.max_value = flow_count - 1

func _update_in_flow(new_value: float, internalid: int) -> void:
	in_flows[internalid] = new_value

func _update_out_flow(new_value: float, internalid: int) -> void:
	out_flows[internalid] = new_value

func _on_exit_button_pressed() -> void:
	$ExitDesktopOverwriteConfirmationDialog.show()

func _on_exit_menu_button_pressed() -> void:
	$ExitMenuOverwriteConfirmationDialog.show()

func _on_flow_controls_button_pressed() -> void:
	$BG.visible = false
	$FlowControlsScreen.visible = true

func _on_cosmetics_button_pressed() -> void:
	$BG.visible = false
	$CosmeticsScreen.visible = true

func _on_load_show_button_pressed() -> void:
	$BG.visible = false
	$LoadShowScreen.visible = true

func _on_return_button_pressed() -> void:
	get_node("../").interact = true
	get_node("../").capture_mouse()
	visible = false

func _on_input_eater_pressed() -> void:
	$BG.visible = true
	$CosmeticsScreen.visible = false
	$FlowControlsScreen.visible = false
	$LoadShowScreen.visible = false

func _on_cosmetics_v_scroll_bar_value_changed(value: float) -> void:
	$CosmeticsScreen/DialogPanel/InvisibleMask/CosmeticsHandle.position.y = value * -44

func _on_flow_v_scroll_bar_value_changed(value: float) -> void:
	$FlowControlsScreen/DialogPanel/InvisibleMask/FlowHandle.position.y = value * -44

func _on_cancel_button_pressed() -> void:
	$BG.visible = true
	$LoadShowScreen.visible = false
	$LoadShowScreen/DialogPanel/InFilePath.text = ""

func _on_open_button_pressed() -> void:
	if (!FileAccess.file_exists($LoadShowScreen/DialogPanel/InFilePath.text.strip_edges())):
		$FileDoesntExistDialog.show()
		return
	$LoadShowScreen/DialogPanel/PleaseWaitText.visible = true
	var file = FileAccess.open($LoadShowScreen/DialogPanel/InFilePath.text.strip_edges(), FileAccess.READ)
	var content = file.get_as_text()
	var header = content.split(";")[0].split(",")
	if (header[1] != "2"):
		$IncorrectShowtapeDialog.dialog_text = "This showtape is not the correct version!"
		$IncorrectShowtapeDialog.show()
		$LoadShowScreen/DialogPanel/PleaseWaitText.visible = false
		return
	if (header[3] != stage["ust_type"]):
		$IncorrectShowtapeDialog.dialog_text = "This showtape is not compatible with the currently selected stage.\nShowtape stage type: %s\n Current stage type: %s" % [ header[3], stage["ust_type"] ]
		$IncorrectShowtapeDialog.show()
		$LoadShowScreen/DialogPanel/PleaseWaitText.visible = false
		return
	show_name = header[2]
	loaded_frames = []
	load_data(content.split(";")[1])
	$AudioStreamPlayer.stream = load_audio_from_buffer(Marshalls.base64_to_raw(content.split(";")[2]))
	set_transport_enabled(true)
	show_is_loaded = true
	$TransportControls/ShowLabel.text = "Playing: " + show_name
	$LoadShowScreen/DialogPanel/InFilePath.text = ""
	$LoadShowScreen/DialogPanel/PleaseWaitText.visible = false
	$LoadShowScreen.visible = false
	$BG.visible = true

func _on_in_browse_button_pressed() -> void:
	$OpenShowtapeFileDialog.show()

func _on_exit_desktop_overwrite_confirmation_dialog_confirmed() -> void:
	get_tree().quit()

func _on_exit_menu_overwrite_confirmation_dialog_confirmed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GUI/MainMenu.tscn")

func _on_open_showtape_file_dialog_file_selected(path: String) -> void:
	$LoadShowScreen/DialogPanel/InFilePath.text = path

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

func load_data(data) -> void:
	for frame_string in data.split(","):
		if (frame_string == ""): continue
		var check_frame_split = frame_string.split()
		check_frame_split.reverse()
		var unpacked_frame = []
		for i in stage["bit_mapping"]:
			if ((check_frame_split[(i - 1) / 4].hex_to_int() & int(pow(2, ((i - 1) % 4)))) == int(pow(2, ((i - 1) % 4)))): 
				unpacked_frame.push_back(true)
			else: unpacked_frame.push_back(false)
		loaded_frames.push_back(unpacked_frame)

func set_transport_enabled(enabled) -> void:
	$TransportControls/PauseButton.disabled = !enabled
	$TransportControls/PlayButton.disabled = !enabled
	$TransportControls/StopButton.disabled = !enabled
	transport_enabled = true

func update_time_label() -> void:
	var frames = index % 60
	var seconds = floori(index/60.0) % 60
	var minutes = floori(index/3600.0) % 60
	var hours = floori(index/216000.0)
	$TransportControls/TimeLabel.text = "%d:%02d:%02d:%02d" % [hours, minutes, seconds, frames] 

func _on_stop_button_pressed() -> void:
	playing = false
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.seek(0)
	index = 0
	update_time_label()

func _on_pause_button_pressed() -> void:
	$AudioStreamPlayer.stop()
	playing = false

func _on_play_button_pressed() -> void:
	$AudioStreamPlayer.play(float(index)/60.0)
	playing = true

func _physics_process(_delta: float) -> void:
	if (playing):
		if (index >= loaded_frames.size()): 
			_on_stop_button_pressed() 
			return
		var j = 0
		for i in stage["bit_mapping"]:
			if (loaded_frames[index][j]):
				if (!prev_frame_held[j]):
					animatables_handles[j]._movement_in(stage["bit_mapping"][i]["movement"], in_flows[j])
				prev_frame_held[j] = true
			else:
				if (prev_frame_held[j]):
					animatables_handles[j]._movement_out(stage["bit_mapping"][i]["movement"], in_flows[j])
				prev_frame_held[j] = false
			j+=1
		index += 1
		if (index % 60 == 0): index = int($AudioStreamPlayer.get_playback_position() * 60)
		if (index <= 0): _on_stop_button_pressed()
		update_time_label()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("freeroam_open_curtains"):
		for curtain in FreeRoamMaps.MapIndex[get_node("../").current_map]["curtains"]:
			for curtain_movement in FreeRoamMaps.MapIndex[get_node("../").current_map]["curtains"][curtain]:
				get_node("../../" + curtain + "/AnimationPlayer").speed_scale = 0.2
				get_node("../../" + curtain + "/AnimationPlayer").play(curtain_movement)
	if (transport_enabled):
		if event.is_action_pressed("freeroam_transport_play_pause"):
			if (playing): _on_pause_button_pressed()
			else: _on_play_button_pressed()
		elif event.is_action_pressed("freeroam_transport_stop"):
			_on_stop_button_pressed()
		
