extends Node3D

var animation_player

var last_anim_name = ""

func _ready():
	animation_player = $AnimationPlayer

func _movement_in(movement, rate):
	if (movement != last_anim_name):
		animation_player.speed_scale = rate
		animation_player.play(movement)
		last_anim_name = movement

func _movement_out(_movement, _rate):
	pass # lol pranked
