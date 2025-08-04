extends Node3D

var on = false
var velocity = 0.0
var rate_out = 0.0

func _physics_process(_delta: float) -> void:
	$RotationHandle.rotate_object_local(Vector3(0, 1, 0), lerpf(0, 0.1, velocity))
	if (on): velocity = minf(velocity*1.05, 1.0)
	else: velocity = maxf(velocity-(rate_out/1000), 0.0)
	if (!on && velocity == 0.0): $RotationHandle/Light.visible = false

func _movement_in(_movement, rate):
	$RotationHandle/Light.visible = true
	velocity += rate/1000
	on = true

func _movement_out(_movement, rate):
	on = false
	rate_out = rate
