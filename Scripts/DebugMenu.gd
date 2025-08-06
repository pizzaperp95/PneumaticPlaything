extends Control

func _ready() -> void:
	$VersionLabel.text = "Pneumatic Plaything v%s" % ProjectSettings.get_setting("application/config/version")
	$PlatformLabel.text = "%s %s %s" % [OS.get_name(), OS.get_version(), Engine.get_architecture_name()]

func _process(_delta: float) -> void:
	if (visible):
		$FPSLabel.text = "FPS: %.0f" % Engine.get_frames_per_second()
		var pos = get_node("../").position
		var angle = get_node("../Camera").rotation_degrees
		$PositionLabel.text = "X: %.2f, Y: %.2f, Z: %.2f" % [ pos.x, pos.y, pos.z ]
		$AngleLabel.text = "Pitch: %.2f, Yaw: %.2f" % [ angle.x, angle.y ]
