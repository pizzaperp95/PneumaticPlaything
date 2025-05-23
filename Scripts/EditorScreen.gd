extends Control

signal movement_in(movement, rate)
signal movement_out(movement, rate)

func _ready() -> void:
	var animatronic = $"SubViewport/HelenHouse/3stHelen"
	movement_in.connect(animatronic._movement_in)
	movement_out.connect(animatronic._movement_out)
	movement_in.connect(self._movement_in)
	movement_out.connect(self._movement_out)
	get_tree().get_root().size_changed.connect(_on_size_changed) 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_editor_screen"):
		$CameraPreview.visible = !$CameraPreview.visible;
		$CameraFullScreen.visible = !$CameraFullScreen.visible;

func _on_movements_flyout_button_toggled(toggled_on: bool) -> void:
	$Movements.visible = toggled_on

func _on_flows_flyout_button_toggled(toggled_on: bool) -> void:
	$FlowControls.visible = toggled_on

func _movement_in(movement, rate):
	get_node("Movements/IndicatorLights/" + movement).turn_on();

func _movement_out(movement, rate):
	get_node("Movements/IndicatorLights/" + movement).turn_off();

func _on_size_changed() -> void:
	$SubViewport.size = $ColorRect.size


func _on_mouth_button_down() -> void:
	movement_in.emit("Mouth", $FlowControls/InFlows/MouthFlow.value)

func _on_mouth_button_up() -> void:
	movement_out.emit("Mouth", $FlowControls/OutFlows/MouthFlow.value)


func _on_left_ear_button_down() -> void:
	movement_in.emit("Left Ear", $FlowControls/InFlows/LeftEarFlow.value)

func _on_left_ear_button_up() -> void:
	movement_out.emit("Left Ear", $FlowControls/OutFlows/LeftEarFlow.value)


func _on_right_ear_button_down() -> void:
	movement_in.emit("Right Ear", $FlowControls/InFlows/RightEarFlow.value)

func _on_right_ear_button_up() -> void:
	movement_out.emit("Right Ear", $FlowControls/OutFlows/RightEarFlow.value)


func _on_left_eyelid_button_down() -> void:
	movement_in.emit("Left Eyelid", $FlowControls/InFlows/LeftEyelidFlow.value)

func _on_left_eyelid_button_up() -> void:
	movement_out.emit("Left Eyelid", $FlowControls/OutFlows/LeftEyelidFlow.value)


func _on_right_eyelid_button_down() -> void:
	movement_in.emit("Right Eyelid", $FlowControls/InFlows/RightEyelidFlow.value)

func _on_right_eyelid_button_up() -> void:
	movement_out.emit("Right Eyelid", $FlowControls/OutFlows/RightEyelidFlow.value)


func _on_eyes_left_button_down() -> void:
	movement_in.emit("Eyes Left", $FlowControls/InFlows/EyesLeftFlow.value)

func _on_eyes_left_button_up() -> void:
	movement_out.emit("Eyes Left", $FlowControls/OutFlows/EyesLeftFlow.value)


func _on_eyes_right_button_down() -> void:
	movement_in.emit("Eyes Right", $FlowControls/InFlows/EyesRightFlow.value)

func _on_eyes_right_button_up() -> void:
	movement_out.emit("Eyes Right", $FlowControls/OutFlows/EyesRightFlow.value)


func _on_head_left_button_down() -> void:
	movement_in.emit("Head Left", $FlowControls/InFlows/HeadLeftFlow.value)

func _on_head_left_button_up() -> void:
	movement_out.emit("Head Left", $FlowControls/OutFlows/HeadLeftFlow.value)


func _on_head_right_button_down() -> void:
	movement_in.emit("Head Right", $FlowControls/InFlows/HeadRightFlow.value)

func _on_head_right_button_up() -> void:
	movement_out.emit("Head Right", $FlowControls/OutFlows/HeadRightFlow.value)


func _on_head_up_button_down() -> void:
	movement_in.emit("Head Up", $FlowControls/InFlows/HeadUpFlow.value)

func _on_head_up_button_up() -> void:
	movement_out.emit("Head Up", $FlowControls/OutFlows/HeadUpFlow.value)


func _on_left_arm_up_button_down() -> void:
	movement_in.emit("Left Arm Up", $FlowControls/InFlows/LeftArmUpFlow.value)

func _on_left_arm_up_button_up() -> void:
	movement_out.emit("Left Arm Up", $FlowControls/OutFlows/LeftArmUpFlow.value)


func _on_left_arm_twist_button_down() -> void:
	movement_in.emit("Left Arm Twist", $FlowControls/InFlows/LeftArmTwistFlow.value)

func _on_left_arm_twist_button_up() -> void:
	movement_out.emit("Left Arm Twist", $FlowControls/OutFlows/LeftArmTwistFlow.value)


func _on_left_elbow_button_down() -> void:
	movement_in.emit("Left Elbow", $FlowControls/InFlows/LeftElbowFlow.value)

func _on_left_elbow_button_up() -> void:
	movement_out.emit("Left Elbow", $FlowControls/OutFlows/LeftElbowFlow.value)


func _on_right_arm_up_button_down() -> void:
	movement_in.emit("Right Arm Up", $FlowControls/InFlows/RightArmUpFlow.value)

func _on_right_arm_up_button_up() -> void:
	movement_out.emit("Right Arm Up", $FlowControls/OutFlows/RightArmUpFlow.value)


func _on_right_arm_twist_button_down() -> void:
	movement_in.emit("Right Arm Twist", $FlowControls/InFlows/RightArmTwistFlow.value)

func _on_right_arm_twist_button_up() -> void:
	movement_out.emit("Right Arm Twist", $FlowControls/OutFlows/RightArmTwistFlow.value)


func _on_right_elbow_button_down() -> void:
	movement_in.emit("Right Elbow", $FlowControls/InFlows/RightElbowFlow.value)

func _on_right_elbow_button_up() -> void:
	movement_out.emit("Right Elbow", $FlowControls/OutFlows/RightElbowFlow.value)


func _on_body_left_button_down() -> void:
	movement_in.emit("Body Left", $FlowControls/InFlows/BodyLeftFlow.value)

func _on_body_left_button_up() -> void:
	movement_out.emit("Body Left", $FlowControls/OutFlows/BodyLeftFlow.value)


func _on_body_right_button_down() -> void:
	movement_in.emit("Body Right", $FlowControls/InFlows/BodyRightFlow.value)

func _on_body_right_button_up() -> void:
	movement_out.emit("Body Right", $FlowControls/OutFlows/BodyRightFlow.value)


func _on_body_lean_button_down() -> void:
	movement_in.emit("Body Lean", $FlowControls/InFlows/BodyLeanFlow.value)

func _on_body_lean_button_up() -> void:
	movement_out.emit("Body Lean", $FlowControls/OutFlows/BodyLeanFlow.value)
