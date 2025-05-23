extends Node3D

var animation_player

func _ready():
	animation_player = $AnimationPlayer

func _movement_in(movement, rate):
	animation_player.speed_scale = rate
	animation_player.play(movement)

func _movement_out(movement, rate):
	animation_player.speed_scale = rate
	animation_player.play_backwards(movement)
