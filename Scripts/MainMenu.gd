extends Control

func _ready():
	OS.request_permissions()
	randomize()
	$VersionLabel.text = "Pneumatic Plaything v%s" % ProjectSettings.get_setting("application/config/version")
	$Backgrounds.get_child(randi() % $Backgrounds.get_child_count()).visible = true
	$Buttons/EditorButton.grab_focus()
	
	Globalvariables.loadConfig()
	print(Globalvariables.FOV)
	print(Globalvariables.msaa)
	$SettingsScreen/DialogPanel/GraphicsPanel/HBoxContainer/settings/fov_slider.value = Globalvariables.FOV
	$SettingsScreen/DialogPanel/GraphicsPanel/HBoxContainer/settings/option_aa_msaa.selected = Globalvariables.msaa
	$SettingsScreen/DialogPanel/GraphicsPanel/HBoxContainer/settings/option_aa_ss.selected = Globalvariables.ssaa
	
	var moddir = DirAccess.open("user://Mods")
	if moddir == null: 
		print("Mod folder was not found. Creating.")
		var temp = DirAccess.open("user://")
		temp.make_dir("Mods")
		moddir = DirAccess.open("user://Mods")
	moddir.list_dir_begin()
	for file: String in moddir.get_files():
		if (!file.ends_with(".pck")): return
		ProjectSettings.load_resource_pack("user://Mods/%s" % file, true)
	
	var dir = DirAccess.open("res://LoadedModContent/ModManifest")
	if dir == null: 
		print("No mods were found.")
		return
	dir.list_dir_begin()
	var tempLoadedList = []
	for file: String in dir.get_files():
		var modManifest = load(dir.get_current_dir() + "/" + file.trim_suffix(".remap")).new()
		if (Stages.loaded_mods.get(modManifest.ModInfo["mod_name"]) != null): 
			if (tempLoadedList.find(modManifest.ModInfo["mod_name"]) == -1):
				$ModsScreen/DialogPanel/ModList.add_item(modManifest.ModInfo["mod_name"], null, true)
			return
		Stages.loaded_mods[modManifest.ModInfo["mod_name"]] = modManifest.ModInfo
		for stage in modManifest.ModInfo["implements_stages"]:
			Stages.stages_info[stage] = modManifest.ModInfo["implements_stages"][stage]
		$ModsScreen/DialogPanel/ModList.add_item(modManifest.ModInfo["mod_name"], null, true)
		tempLoadedList.append(modManifest.ModInfo["mod_name"])
		print("Loaded Mod \"%s\"" % modManifest.ModInfo["mod_name"])

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GUI/EditorScreen.tscn")

func _on_exit_button_pressed() -> void:
	Globalvariables.updateConfig()
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	$CreditsScreen.visible = true

func _on_controls_button_pressed() -> void:
	$ControlsScreen.visible = true

func _on_free_roam_button_pressed() -> void:
	$FreeRoamChooseScreen.visible = true

func _on_mods_button_pressed() -> void:
	$ModsScreen.visible = true

func _on_settings_button_pressed() -> void:
	$SettingsScreen.visible = true

func _on_input_eater_pressed() -> void:
	Globalvariables.updateConfig()
	$CreditsScreen.visible = false
	$ControlsScreen.visible = false
	$FreeRoamChooseScreen.visible = false
	$ModsScreen.visible = false
	$SettingsScreen.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if (!DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_mod_list_item_selected(index: int) -> void:
	var itext = $ModsScreen/DialogPanel/ModList.get_item_text(index)
	$ModsScreen/DialogPanel/ModNameText.text = Stages.loaded_mods[itext]["mod_name"]
	$ModsScreen/DialogPanel/ModAuthorText.text = "by %s" % Stages.loaded_mods[itext]["mod_creator"]
	$ModsScreen/DialogPanel/ModVersionText.text = "Mod version %s" % Stages.loaded_mods[itext]["mod_version"]
	$ModsScreen/DialogPanel/ModDescriptionText.text = Stages.loaded_mods[itext]["mod_description"]


func _on_open_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://Mods"))
	$PleaseRestart.show()


func _on_load_map_button_pressed() -> void:
	get_tree().change_scene_to_file(FreeRoamMaps.MapIndex[$FreeRoamChooseScreen/DialogPanel/MapSelector.get_item_text($FreeRoamChooseScreen/DialogPanel/MapSelector.selected)]["scene"])
