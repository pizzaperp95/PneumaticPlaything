extends Control

@export var vis_name: String
@export var scene_handle: String
@export var options: Dictionary

func _ready() -> void:
	$Panel/Label.text = vis_name
	for option in options:
		$Panel/OptionButton.add_item(option)
	$Panel/OptionButton.select(0)
	for adjusted in options[$Panel/OptionButton.get_item_text(0)]:
		get_node(scene_handle+adjusted).visible = options[$Panel/OptionButton.get_item_text(0)][adjusted]


func _on_option_button_item_selected(index: int) -> void:
	for adjusted in options[$Panel/OptionButton.get_item_text(index)]:
		get_node(scene_handle+adjusted).visible = options[$Panel/OptionButton.get_item_text(index)][adjusted]
