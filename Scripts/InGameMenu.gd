extends Control


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_exit_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GUI/MainMenu.tscn")


func _on_flow_controls_button_pressed() -> void:
	pass # Replace with function body.


func _on_cosmetics_button_pressed() -> void:
	pass # Replace with function body.


func _on_load_show_button_pressed() -> void:
	pass # Replace with function body.


func _on_return_button_pressed() -> void:
	get_node("../").interact = true
	get_node("../").capture_mouse()
	visible = false
