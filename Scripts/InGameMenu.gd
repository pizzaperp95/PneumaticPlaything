extends Control

var in_flows = []
var out_flows = []

var loaded_show = []

func _ready() -> void:
	var stage = FreeRoamMaps.MapIndex[get_node("../").current_map]["stage"]
	
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
	
	var rows_offset = 0
	var flows_offset = 0
	var flow_count = 0
	for bit_number in stage["bit_mapping"]:
		var bot = stage["bit_mapping"][bit_number]["bot"]
		var movement = stage["bit_mapping"][bit_number]["movement"]
		
		var in_flow = stage["bit_mapping"][bit_number]["flow_in"]
		var out_flow = stage["bit_mapping"][bit_number]["flow_out"]
		
		in_flows.push_back(in_flow)
		out_flows.push_back(out_flow)
		
		if (in_flow is not String):
			var flow_control = load("res://Scenes/GUI/Controls/FlowControl.tscn").instantiate()
			flow_control.position.y = flows_offset
			flow_control.name = str(bit_number) + bot + movement + get_node("../").current_map
			flow_control.vis_name = bot + " " + movement
			flow_control.in_value = in_flow
			flow_control.out_value = out_flow
			flow_control.anchor_right = 1.0
			$FlowControlsScreen/DialogPanel/InvisibleMask/FlowHandle.add_child(flow_control)
			flows_offset += 44
			flow_count += 1
	
	$FlowControlsScreen/DialogPanel/VScrollBar.max_value = flow_count - 1

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_exit_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GUI/MainMenu.tscn")

func _on_flow_controls_button_pressed() -> void:
	$BG.visible = false
	$FlowControlsScreen.visible = true

func _on_cosmetics_button_pressed() -> void:
	$BG.visible = false
	$CosmeticsScreen.visible = true

func _on_load_show_button_pressed() -> void:
	$BG.visible = false

func _on_return_button_pressed() -> void:
	get_node("../").interact = true
	get_node("../").capture_mouse()
	visible = false

func _on_input_eater_pressed() -> void:
	$BG.visible = true
	$CosmeticsScreen.visible = false
	$FlowControlsScreen.visible = false

func _on_cosmetics_v_scroll_bar_value_changed(value: float) -> void:
	$CosmeticsScreen/DialogPanel/InvisibleMask/CosmeticsHandle.position.y = value * -44

func _on_flow_v_scroll_bar_value_changed(value: float) -> void:
	$FlowControlsScreen/DialogPanel/InvisibleMask/FlowHandle.position.y = value * -44
