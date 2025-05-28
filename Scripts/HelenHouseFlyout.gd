extends Control

signal movement_in(movement, rate)
signal movement_out(movement, rate)



func _ready() -> void:
	#var animatronic = get_node("../SubViewport/HelenHouse/Helen")
	#movement_in.connect(animatronic._movement_in)
	#movement_out.connect(animatronic._movement_out)
	movement_in.connect(self._movement_in)
	movement_out.connect(self._movement_out)

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("cycle_camera_angle")):
		cam_index += 1
		get_node("../SubViewport/HelenHouse/Camera " + str((cam_index % 2)+1)).current = true

func _movement_in(movement, _rate):
	get_node("Movements/IndicatorLights/" + movement).turn_on();

func _movement_out(movement, _rate):
	get_node("Movements/IndicatorLights/" + movement).turn_off();

func _on_angle_1_button_pressed() -> void:
	get_node("../SubViewport/HelenHouse/Camera 1").current = true

func _on_angle_2_button_pressed() -> void:
	get_node("../SubViewport/HelenHouse/Camera 2").current = true
