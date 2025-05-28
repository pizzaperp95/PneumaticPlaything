extends Control

@export var camera : String
@export var base_scene_path : String

func _ready() -> void:
	$Button.text = camera

func _on_button_pressed() -> void:
	get_node(base_scene_path + camera).current = true;
