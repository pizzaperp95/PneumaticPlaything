extends Control

@export var vis_name: String
@export var scene_handle: String
@export var options: Dictionary
@export var drop_index: int = 0

func _ready() -> void:
	$Panel/Label.text = vis_name
	for option in options:
		$Panel/OptionButton.add_item(option)
	$Panel/OptionButton.select(drop_index)
	for adjusted in options[$Panel/OptionButton.get_item_text(drop_index)]:
		get_node(scene_handle+adjusted).visible = options[$Panel/OptionButton.get_item_text(drop_index)][adjusted]


func _on_option_button_item_selected(index: int) -> void:
	for adjusted in options[$Panel/OptionButton.get_item_text(index)]:
		get_node(scene_handle+adjusted).visible = options[$Panel/OptionButton.get_item_text(index)][adjusted]
