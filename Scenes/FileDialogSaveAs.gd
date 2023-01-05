extends FileDialog
onready var oGame = Nodelist.list["oGame"]
onready var oUi = Nodelist.list["oUi"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]

var saveInstruction = Label.new()
var lineEdit
var lineEditPreviousText = "sadfdfgfdhgfds" # this should be something that won't be initially written in linedit

func _ready():
	var optionButton = get_vbox().get_child(3).get_child(2)
	optionButton.visible = false
	lineEdit = get_line_edit()
	get_vbox().add_child(saveInstruction)
	get_vbox().move_child(saveInstruction,3)

func _on_FileDialogSaveAs_about_to_show():
	var path = oGame.SAVE_AS_DIRECTORY
	if oGame.SAVE_AS_DIRECTORY == "": # Default path
		var personalFolder = oGame.DK_LEVELS_DIRECTORY.plus_file("personal")
		if Directory.new().dir_exists(personalFolder):
			path = personalFolder # KeeperFX has personal folder
		else:
			path = oGame.DK_LEVELS_DIRECTORY # Old DK does not have personal folder
	current_path = path
	current_dir = path
	
	yield(get_tree(),'idle_frame')
	var currentMapNumber = oCurrentMap.path.get_file().to_upper().trim_prefix("MAP")
	lineEdit.text = "map" + str(currentMapNumber)
	lineEdit.caret_position = lineEdit.text.length()
	lineEdit.grab_focus()

func _process(delta):
	if visible == false: return
	
	# This is better than a signal because it covers more cases, such as when clicking on a file in the dialog
	if lineEditPreviousText != lineEdit.text:
		linedit_was_changed()
		lineEditPreviousText = lineEdit.text
	
	saveInstruction.set("custom_colors/font_color", Color(1,0.5,0.5,1))
	saveInstruction.text = "Map not playable from this directory."
	var dir = current_dir.to_upper()
	if oGame.running_keeperfx() == true:
		if dir.ends_with("/LEVELS"):
			saveInstruction.text = "Must save in a sub directory."
		if dir.ends_with("/CAMPGNS"):
			saveInstruction.text = "Must save in a sub directory."
		if dir.get_base_dir().ends_with("/LEVELS") or dir.get_base_dir().ends_with("/CAMPGNS"):
			saveInstruction.text = "Map playable from this directory."
			saveInstruction.set("custom_colors/font_color", Color(0.5,1.0,0.5,1))
	else:
		# Original DK
		if dir.ends_with("/LEVELS"):
			saveInstruction.text = "Map playable from this directory."
			saveInstruction.set("custom_colors/font_color", Color(0.5,1.0,0.5,1))


func linedit_was_changed():
	
	var rememberCaretPos = lineEdit.caret_position
	
	# remove the letters "m-a-p" when checking whether the string has letters. removing the prefix isn't good enough here.
	if Utils.string_has_letters(lineEdit.text.replace("m","").replace("a","").replace("p","").trim_suffix(".slb")) == true:
		oMessage.quick("Use only digits in map name")
	
	if lineEdit.text.length() < 8:
		rememberCaretPos += 2
	
	# If you begin typing while the caret is on "map", skip to the beginning of the digits
	if lineEdit.text.length() > 8:
		if rememberCaretPos <= 3:
			rememberCaretPos = 4
	
	
	
	var numberString = Utils.strip_letters_from_string(lineEdit.text)
	
	lineEdit.text = 'map'+numberString
	
	while lineEdit.text.length() > 8:
		var eraseTxt = lineEdit.text
		if rememberCaretPos > 8:
			eraseTxt.erase(3, 1)
		else:
			eraseTxt.erase(8, 1)
		lineEdit.text = eraseTxt
	
	while lineEdit.text.length() < 8:
		lineEdit.text = lineEdit.text.insert(3,"0")
	
	if int(lineEdit.text) > 32767:
		lineEdit.text = "map32767"
		oMessage.quick("Map number can be no larger than 32767")
	
	lineEdit.caret_position = rememberCaretPos


func _on_FileDialogSaveAs_visibility_changed():
	if is_instance_valid(oUi) == false: return
	if visible == true:
		oUi.hide_tools()
	else:
		oUi.show_tools()
