class_name Player extends CharacterBody3D

@export var current_map: String

var SPEED_BASE: float = 4
var SPEED_CROUCHED: float = 2
var SPEED_RUNNING: float = 7
var SPEED_CROUCH_RUN: float = 3

var speed: float = SPEED_BASE # m/s
var acceleration: float = 100 # m/s^2

var jump_height: float = 1 # m
var camera_sens: float = 3

var interact: bool = true

var jumping: bool = false
var crouched: bool = false
var running: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var camera: Camera3D = $Camera

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if (interact):
		if event is InputEventMouseMotion:
			look_dir = event.relative * 0.001
			if mouse_captured: _rotate_camera()
	if event.is_action_pressed(&"fullscreen"): 
		if (!DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif event.is_action_pressed(&"freeroam_open_menu"): 
		if (!interact):
			interact = true
			capture_mouse()
			$InGameMenu.visible = false
		else:
			interact = false
			release_mouse()
			$InGameMenu.visible = true
			$InGameMenu/Buttons/ReturnButton.grab_focus()
		pass
	elif event.is_action_pressed(&"freeroam_debug_menu"):
		$DebugMenu.visible = !$DebugMenu.visible

func _physics_process(delta: float) -> void:
	if (interact):
		if Input.is_action_just_pressed(&"freeroam_jump"): jumping = true
		elif Input.is_action_just_pressed(&"freeroam_crouch"): 
			$CShape.shape.height = 1.0
			$Camera.position.y = 1.0
			if (running): speed = SPEED_CROUCH_RUN
			else: speed = SPEED_CROUCHED
			crouched = true
		elif Input.is_action_just_released(&"freeroam_crouch"): 
			$CShape.shape.height = 1.8
			$Camera.position.y = 1.7
			if (running): speed = SPEED_RUNNING
			else: speed = SPEED_BASE
			crouched = false
		elif Input.is_action_just_pressed(&"freeroam_run"): 
			if (crouched): speed = SPEED_CROUCH_RUN
			else: speed = SPEED_RUNNING
			running = true
		elif Input.is_action_just_released(&"freeroam_run"): 
			if (crouched): speed = SPEED_CROUCHED
			else: speed = SPEED_BASE
			running = false
		elif Input.is_action_just_pressed(&"freeroam_toggle_flashlight"): 
			$Camera/Flashlight.visible = !$Camera/Flashlight.visible
			
		if mouse_captured: _handle_joypad_camera_rotation(delta)
		velocity = _walk(delta) + _gravity(delta) + _jump(delta)
		move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector(&"freeroam_look_left", &"freeroam_look_right", &"freeroam_look_up", &"freeroam_look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector(&"freeroam_move_left", &"freeroam_move_right", &"freeroam_move_forward", &"freeroam_move_backward")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel
