extends Panel

@export var thisTab = 0 # The tab that must be active in the settings screen for the panel to appear.

func _ready() -> void:
	$HBoxContainer/settings/option_aa_msaa.selected = get_viewport().msaa_3d
	$HBoxContainer/settings/option_aa_ss.selected = get_viewport().screen_space_aa
	$HBoxContainer/settings/fov_slider.value = Globalvariables.FOV

func _on_tab_bar_tab_changed(tab: int) -> void:
	if (thisTab == tab):
		self.show()
	else:
		self.hide()

func updateconfig():
	Globalvariables.updateConfig()

func _on_fov_slider_value_changed(value: float) -> void:
	Globalvariables.FOV = value
	$HBoxContainer/settings/fov_slider/Label3.text = str(int(value))


func _on_option_aa_ss_item_selected(index: int) -> void:
	get_viewport().screen_space_aa = int(index == 1) as Viewport.ScreenSpaceAA


func _on_option_aa_msaa_item_selected(index: int) -> void:
	if index == 0: # Disabled
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif index == 1: # 2×
		get_viewport().msaa_3d = Viewport.MSAA_2X
	elif index == 2: # 4×
		get_viewport().msaa_3d = Viewport.MSAA_4X
	elif index == 3: # 8×
		get_viewport().msaa_3d = Viewport.MSAA_8X
	
