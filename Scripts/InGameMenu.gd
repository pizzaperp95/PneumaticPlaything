extends Control

func _ready() -> void:
	var cosmetics_offset = 0
	var cosmetics_count = 0
	for cosmetic_subtable in FreeRoamMaps.MapIndex[get_node("../").current_map]["stage"]["cosmetics"]:
		for cosmetic in cosmetic_subtable:
			var cosmetic_adjustment = load("res://Scenes/GUI/Controls/CosmeticAdjustment.tscn").instantiate()
			cosmetic_adjustment.vis_name = cosmetic
			cosmetic_adjustment.options = cosmetic_subtable[cosmetic]
			cosmetic_adjustment.scene_handle = "../../../../../../../"
			cosmetic_adjustment.drop_index = FreeRoamMaps.MapIndex[get_node("../").current_map]["stage"]["cosmetic_defaults"][cosmetics_count]
			cosmetic_adjustment.position.y = cosmetics_offset
			cosmetic_adjustment.anchor_right = 1.0
			cosmetics_offset += 44
			cosmetics_count += 1
			$CosmeticsScreen/DialogPanel/InvisibleMask/CosmeticsHandle.add_child(cosmetic_adjustment)
	$CosmeticsScreen/DialogPanel/VScrollBar.max_value = cosmetics_count - 1

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
	
