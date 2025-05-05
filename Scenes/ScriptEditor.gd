extends Control
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oScriptEmptyStatus = Nodelist.list["oScriptEmptyStatus"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oUi = Nodelist.list["oUi"]
onready var oMapSettingsTabs = Nodelist.list["oMapSettingsTabs"]
onready var oBuffers = Nodelist.list["oBuffers"]

var scriptHasBeenEditedInUnearth = false

var SCRIPT_EDITOR_FONT_SIZE = 20 setget set_SCRIPT_EDITOR_FONT_SIZE, get_SCRIPT_EDITOR_FONT_SIZE

func set_SCRIPT_EDITOR_FONT_SIZE(setVal):
	SCRIPT_EDITOR_FONT_SIZE = setVal
	var current_font = oScriptTextEdit.get_font("font").duplicate()
	current_font.size = SCRIPT_EDITOR_FONT_SIZE
	oScriptTextEdit.add_font_override("font", current_font)

func get_SCRIPT_EDITOR_FONT_SIZE():
	return SCRIPT_EDITOR_FONT_SIZE

func initialize_for_new_map():
	update_texteditor()
	set_script_as_edited(false)
	oScriptTextEdit.clear_undo_history() # Important so the 1st undo state is the loaded script

func _on_ScriptTextEdit_text_changed():
	set_script_as_edited(true)
	set_script_data(oScriptTextEdit.text)
	update_empty_script_status()
	
	var updateHelpers = false
	var line = oScriptTextEdit.get_line(oScriptTextEdit.cursor_get_line())
	for i in oScriptHelpers.commandsWithPositions.size():
		if oScriptHelpers.commandsWithPositions[i][0] in line.to_upper():
			updateHelpers = true
	if updateHelpers == true:
		oScriptHelpers.start() # in the case of updating a line (with coords) in the built-in Script Editor


func set_script_as_edited(edited):
	scriptHasBeenEditedInUnearth = edited
	match edited:
		true:
			oMapSettingsTabs.set_tab_title(2, "Edit Script *")
			oEditor.mapHasBeenEdited = true
		false:
			oMapSettingsTabs.set_tab_title(2, "Edit Script")


func set_script_data(value):
	value = value.replace(char(0x200B), "") # Remove Zero Width Spaces
	oDataScript.data = value


func update_empty_script_status():
	if oScriptTextEdit.text == "":
		oScriptEmptyStatus.visible = true
	else:
		oScriptEmptyStatus.visible = false


func load_generated_text(setWithString):
	set_script_as_edited(true)
	set_script_data(setWithString)
	update_texteditor()

func update_texteditor():
	# This is for when pressing Undo
	var scroll = oScriptTextEdit.scroll_vertical
	var lineNumber = oScriptTextEdit.cursor_get_line()
	var columnNumber = oScriptTextEdit.cursor_get_column()
	
	oScriptTextEdit.text = oDataScript.data # This resets a bunch of stuff in TextEdit like cursor line.
	
	oScriptTextEdit.cursor_set_line(lineNumber)
	oScriptTextEdit.scroll_vertical = scroll
	oScriptTextEdit.cursor_set_column(columnNumber)
	
	update_empty_script_status()
	oScriptHelpers.start() # in the case of editing text file outside of Unearth


func _notification(what: int):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		check_if_txt_file_has_been_modified() # Check for TXT file changes
		check_if_lua_file_has_been_modified() # Check for LUA file changes


func check_if_txt_file_has_been_modified():
	var file_type = "TXT"
	if oCurrentMap.currentFilePaths.has(file_type):
		var file_info = oCurrentMap.currentFilePaths[file_type]
		var file_path = file_info[oCurrentMap.PATHSTRING]
		var stored_modified_time = file_info[oCurrentMap.MODIFIED_DATE]
		var current_modified_time = File.new().get_modified_time(file_path)

		if stored_modified_time != current_modified_time:
			oMessage.quick("Script reloaded from file.")
			file_info[oCurrentMap.MODIFIED_DATE] = current_modified_time
			
			# Reload the TXT buffer
			oBuffers.read(file_path, file_type)
			
			# Update the main script editor
			update_texteditor()
			set_script_as_edited(false)


func check_if_lua_file_has_been_modified():
	var file_type = "LUA"
	if oCurrentMap.currentFilePaths.has(file_type):
		var file_info = oCurrentMap.currentFilePaths[file_type]
		var file_path = file_info[oCurrentMap.PATHSTRING]
		var stored_modified_time = file_info[oCurrentMap.MODIFIED_DATE]
		var current_modified_time = File.new().get_modified_time(file_path)

		if stored_modified_time != current_modified_time:
			oMessage.quick("Lua script reloaded from file.")
			file_info[oCurrentMap.MODIFIED_DATE] = current_modified_time
			
			# Reload the LUA buffer
			oBuffers.read(file_path, file_type)


func _on_ScriptTextEdit_visibility_changed():
	if visible == false:
		# When you close the window, update script helpers. This is important to update here in case you remove any lines (helper related) in the script editor
		oScriptHelpers.start()










#	if oCurrentMap.currentFilePaths.has("TXT"):
#		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]

#func place_text(insertString):
#	insertString =
	
	#oScriptTextEdit.cursor_set_line(lineNumber, txt)
#	var lineNumber = oScriptTextEdit.cursor_get_line()
#	var existingLineString = oScriptTextEdit.get_line(lineNumber)
#
#	if oScriptTextEdit.get_line(lineNumber).length() > 0: #If line contains stuff
#		oScriptTextEdit.set_line(lineNumber, existingLineString + '\n')
#		oScriptTextEdit.set_line(lineNumber+1, insertString)
#
#		oScriptTextEdit.cursor_set_line(oScriptTextEdit.cursor_get_line()+1)
#	else:
#		oScriptTextEdit.set_line(lineNumber, insertString)
#	oScriptTextEdit.update()


#func reload_script_into_window(): # Called from oDataScript
#	oScriptTextEdit.text = oDataScript.data
	
#	if oCurrentMap.currentFilePaths.has("TXT"):
#		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
#	else:
#		oScriptNameLabel.text = "No script file loaded"
	
#	hide_script_side()
	
#	if oDataScript.data == "":
#		hide_script_side()
#	else:
#		show_script_side()

#func hide_script_side():
#	oScriptContainer.visible = false
	# Make scroll bar area fill the entire window
	#oGeneratorContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#yield(get_tree(),'idle_frame')
	#rect_size.x = 0

#func show_script_side():
#	oScriptContainer.visible = true
#	# Reduce scroll bar area so ScriptContainer has space
#	oGeneratorContainer.size_flags_horizontal = Control.SIZE_FILL
#	yield(get_tree(),'idle_frame')
#	if rect_size.x < 960:
#		rect_size.x = 1280




func _on_ScriptHelpButton_pressed():
	oMessage.big("Help","Changes made to the script in this window are only committed to file upon saving the map. Changes made to the script externally using a text editor such as Notepad are instantly reloaded into Unearth, replacing any work done in this window. \nUse Google to learn more about Dungeon Keeper Script Commands.")

func _input(event):
	if event is InputEventMouseButton and (event.is_pressed()):
		if Rect2( oScriptTextEdit.rect_global_position, oScriptTextEdit.rect_size ).has_point(oScriptTextEdit.get_global_mouse_position()) == false:
			oScriptTextEdit.release_focus()
