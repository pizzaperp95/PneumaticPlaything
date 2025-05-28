extends Node3D

var animation_player : AnimationPlayer
var animation_tree : AnimationTree
var blend_tree : AnimationNodeBlendTree

var movement_states : Dictionary

func _ready():
	animation_player = $AnimationPlayer
	
	animation_tree = AnimationTree.new()
	animation_tree.anim_player = animation_player.get_path()
	add_child(animation_tree)
	
	animation_tree.tree_root = AnimationNodeBlendTree.new()
	animation_tree.active = true
	blend_tree = animation_tree.tree_root as AnimationNodeBlendTree
	
	animation_player.speed_scale = 0
	
	var animations = animation_player.get_animation_list()
	
	for animation in animations:
		movement_states[animation] = [false, 0.0, 0.0, 0.0]
	
	var prev_name = "Anim_" + animations[0]
	var old_time_name = "Time_" + animations[0]
	var old_seek_name = "Seek_" + animations[0]
	
	var prev_anim_node := AnimationNodeAnimation.new()
	prev_anim_node.animation = animations[0]
	blend_tree.add_node(prev_name, prev_anim_node)
	
	var old_time_node := AnimationNodeTimeScale.new()
	blend_tree.add_node(old_time_name,old_time_node)
		
	var _old_seek_node := AnimationNodeTimeSeek.new()
	blend_tree.add_node(old_seek_name,_old_seek_node)
		
	blend_tree.connect_node(old_time_name,0,prev_name)
	blend_tree.connect_node(old_seek_name,0,old_time_name)
	prev_name = old_seek_name
	
	for i in range(1, animations.size()):
		var anim_name = "Anim_" + animations[i]
		var add_name = "Add_" + animations[i]
		var time_name = "Time_" + animations[i]
		var seek_name = "Seek_" + animations[i]

		var new_anim_node := AnimationNodeAnimation.new()
		new_anim_node.animation = animations[i]
		blend_tree.add_node(anim_name, new_anim_node)
		
		var time_node := AnimationNodeTimeScale.new()
		blend_tree.add_node(time_name,time_node)
		
		var seek_node := AnimationNodeTimeSeek.new()
		blend_tree.add_node(seek_name,seek_node)

		var add_node := AnimationNodeAdd2.new()
		blend_tree.add_node(add_name, add_node)
		
		blend_tree.connect_node(time_name, 0, anim_name)
		blend_tree.connect_node(seek_name, 0, time_name)
		blend_tree.connect_node(add_name, 0, prev_name)
		blend_tree.connect_node(add_name, 1, seek_name)
		prev_name = add_name
	
	blend_tree.connect_node("output", 0, prev_name)
	
	for i in range(0, animations.size()):
		animation_tree.set("parameters/Add_" + str(animations[i]) + "/add_amount", 1.0)
		animation_tree.set("parameters/Seek_" + str(animations[i]) + "/seek_request", 0)
		animation_tree.set("parameters/Time_" + str(animations[i]) + "/scale", 0)

func _physics_process(delta: float) -> void:
	for key in movement_states:
		var anim_path = "parameters/Seek_" + key + "/seek_request"
		var state = movement_states[key]
		if (state[0]):
			state[1] = clamp(float(state[1]) + (delta * state[2]), 0, 1)
		else:
			state[1] = clamp(float(state[1]) - (delta * state[3]), 0, 1)
		animation_tree.set(anim_path, state[1])

func _movement_in(movement, rate):
	movement_states[movement][0] = true
	movement_states[movement][2] = rate

func _movement_out(movement, rate):
	movement_states[movement][0] = false
	movement_states[movement][3] = rate
