extends Node

var FOV = 80
var config = ConfigFile.new()
var msaa = 1
var ssaa = 1

func _ready() -> void:
	msaa = get_viewport().msaa_3d
	ssaa = get_viewport().screen_space_aa

func updateConfig():
	msaa = get_viewport().msaa_3d
	ssaa = get_viewport().screen_space_aa
	config.set_value("GRAPHICS", "fov", FOV)
	config.set_value("GRAPHICS", "msaa", msaa)
	config.set_value("GRAPHICS", "ssaa", ssaa)
	config.save("user://settings.cfg")

func loadConfig():
	var err = config.load("user://settings.cfg")
	print("loading config...")
	if err != OK:
		print("Couldn't load config!")
		return

	FOV = config.get_value("GRAPHICS", "fov")
	msaa = config.get_value("GRAPHICS", "msaa")
	ssaa = config.get_value("GRAPHICS", "ssaa")
	print("config loaded.")
	
	# set msaa
	var index = msaa
	if index == 0: # Disabled
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif index == 1: # 2×
		get_viewport().msaa_3d = Viewport.MSAA_2X
	elif index == 2: # 4×
		get_viewport().msaa_3d = Viewport.MSAA_4X
	elif index == 3: # 8×
		get_viewport().msaa_3d = Viewport.MSAA_8X

	# set ssaa
	get_viewport().screen_space_aa = int(index == 1) as Viewport.ScreenSpaceAA 
