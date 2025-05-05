extends Node

onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oDataLua = Nodelist.list["oDataLua"]
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oMenuButtonFile = Nodelist.list["oMenuButtonFile"]

var queueExit = false

func _input(event):
	if event.is_action_pressed("save"):
		oMenu.pressed_save_keyboard_shortcut()

func save_map(filePath): # auto opens other files
	var map = filePath.get_basename()
	var SAVETIME_START = OS.get_ticks_msec()
	delete_existing_files(map)
	
	oDataClm.update_all_utilized() # Doesn't need to be in "Undo"
	
	var writeFailure = false
	for EXT in oBuffers.FILE_TYPES:
		if not oBuffers.should_process_file_type(EXT):
			continue # skip saving this filetype
		
		var saveToFilePath = map + '.' + EXT.to_lower()
		var err = oBuffers.write(saveToFilePath, EXT.to_upper())
		if err != OK:
			writeFailure = true
		
		var getModifiedTime = File.new().get_modified_time(saveToFilePath)
		oCurrentMap.currentFilePaths[EXT] = [saveToFilePath, getModifiedTime]
	
	if writeFailure == true:
		oMessage.big("Error", "Saving failed. Try saving to a different directory.")
	else:
		print('Total time to save: ' + str(OS.get_ticks_msec() - SAVETIME_START) + 'ms')
		
		if oDataScript.data == "" and oDataLua.data == "":
			oMessage.big("Warning", "Your map has no script. Use the Script Generator in Map Settings to give your map basic functionality.")
		
		oMessage.quick('Saved map')
		oCurrentMap.set_path_and_title(filePath)
		oEditor.mapHasBeenEdited = false
		oScriptEditor.set_script_as_edited(false)
		oDataClm.store_default_data() # This makes it so the map Column Editor's default columns are now reflected as "what's saved"
		oMapSettingsWindow.visible = false
		
		# This goes last. Queued from when doing "save before quitting" and "save as" before quitting.
		if queueExit == true:
			get_tree().quit()

func delete_existing_files(map):
	var fileTypesToDelete = []
	
	if OS.get_name() == "X11":
		# Important for Linux to delete all files otherwise duplicates can be created. (Lowercase files can be saved without replacing the uppercase files)
		fileTypesToDelete = oBuffers.FILE_TYPES
	else:
		# If switching formats, then it's important to delete files of the other format (TNG and TNGFX shouldn't exist at the same time)
		if oCurrentFormat.selected == Constants.ClassicFormat:
			# Do not delete LOF because Classic format can be used with LOF multiplayer levels
			fileTypesToDelete = ["TNGFX", "APTFX", "LGTFX"]
		elif oCurrentFormat.selected == Constants.KfxFormat:
			fileTypesToDelete = ["LIF", "TNG", "APT", "LGT"]
	
	var baseDirectory = map.get_base_dir()
	var MAP_NAME = map.get_basename().get_file().to_upper()
	
	var dir = Directory.new()
	if dir.open(baseDirectory) == OK:
		dir.list_dir_begin(true, false)
		var fileName = dir.get_next()
		while fileName != "":
			if MAP_NAME in fileName.to_upper():
				# Only delete the accompanying file types that I'm about to write
				if fileTypesToDelete.has(fileName.get_extension().to_upper()):
					if dir.file_exists(fileName) == true: # Ensure any files being removed are definitely files and never directories
						print("Deleted: " + fileName)
						dir.remove(fileName)
			fileName = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func clicked_save_on_menu():
	save_map(oCurrentMap.path)
