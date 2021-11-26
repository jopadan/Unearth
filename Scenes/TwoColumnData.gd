extends GridContainer

const thinLineEditTheme = preload("res://Theme/ThinLineEdit.tres")
onready var oInspector = Nodelist.list["oInspector"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oUi = Nodelist.list["oUi"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]


const columnLeftSize = 120
const columnRightSize = 150

func _ready():
	columns = 2

func add_item(leftText, rightText):
	# Left column item
	var nameDesc = Label.new()
	nameDesc.align = HALIGN_LEFT
	nameDesc.text = leftText
	nameDesc.autowrap = true
	nameDesc.rect_min_size.x = columnLeftSize # minimum text width based on the word: "Floor texture"
	nameDesc.valign = VALIGN_TOP
	nameDesc.size_flags_vertical = Control.SIZE_FILL # To handle the other side's autowrap text
	
	add_child(nameDesc)
	
	# Right column item
	var nameValue
	match leftText:
		"Door locked":
			nameValue = OptionButton.new()
			nameValue.add_item("False")
			nameValue.add_item("True")
			
			nameValue.connect("item_selected",self,"_on_optionbutton_item_selected", [leftText])
			for i in nameValue.get_item_count():
				if nameValue.get_item_text(nameValue.get_item_index(i)) == rightText:
					nameValue.selected = i
		"Ownership":
			nameValue = OptionButton.new()
			nameValue.focus_mode = 0 # I don't know whether I need this
			nameValue.get_popup().focus_mode = 0
			nameValue.add_item("Red")
			nameValue.add_item("Blue")
			nameValue.add_item("Green")
			nameValue.add_item("Yellow")
			nameValue.add_item("White")
			nameValue.add_item("None")
			
#			print(nameValue.get_popup().mouse_filter)
			
			nameValue.connect("item_selected",self,"_on_optionbutton_item_selected", [leftText])
			nameValue.connect("toggled",self,"_on_optionbutton_toggled", [nameValue])
			# Select the correct option
			for i in nameValue.get_item_count():
				if nameValue.get_item_text(nameValue.get_item_index(i)) == rightText:
					nameValue.selected = i
		
		"Level","Effect range","Light range","Intensity","Gate number","Point range","Point #":
			nameValue = LineEdit.new()
			nameValue.expand_to_text_length = true
			nameValue.theme = thinLineEditTheme
			nameValue.connect("focus_exited",self,"_on_lineedit_focus_exited", [nameValue,leftText])
			nameValue.connect("text_entered",self,"_on_lineedit_text_entered", [nameValue])
		_:
			nameValue = Label.new()
			nameValue.autowrap = true
			nameValue.rect_min_size.x = columnRightSize
			if name == "ColumnListData": nameValue.rect_min_size.x = columnRightSize-50
			# This is for when highlighting something in the Thing Window
			if rightText == "":
				nameValue.rect_min_size.x = 0
				nameDesc.autowrap = false
	
	nameValue.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_END # To handle the other side's autowrap text
	nameValue.align = HALIGN_LEFT
	nameValue.text = rightText
	add_child(nameValue)

func _on_optionbutton_toggled(state,nameValue):
	oUi.optionButtonIsOpened = state

func _on_optionbutton_item_selected(indexSelected, leftText): # When pressing Enter on LineEdit, lose focus
	oEditor.mapHasBeenEdited = true
	
	var inst = oInspector.inspectingInstance
	
	match leftText:
		"Ownership":
			oSelection.paintOwnership = indexSelected
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.ownership = oSelection.paintOwnership
				"PlacingListData":
					oPlacingSettings.ownership = oSelection.paintOwnership
		"Door locked":
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.doorLocked = indexSelected
						inst.toggle_spinning_key()
				"PlacingListData":
					oPlacingSettings.doorLocked = indexSelected

#func _on_lineedit_focus_entered(lineEditId): # When pressing Enter on LineEdit, lose focus
#	for i in 1:
#		yield(get_tree(),'idle_frame')
#
#	lineEditId.select_all()

func _on_lineedit_text_entered(new_text, lineEditId): # When pressing Enter on LineEdit, lose focus
	oEditor.mapHasBeenEdited = true
	lineEditId.release_focus()

func _on_lineedit_focus_exited(lineEditId, leftText): # This signal will go off first even if you click the "Deselect" button.
	oEditor.mapHasBeenEdited = true
	var valueNumber = lineEditId.text
	var inst = oInspector.inspectingInstance
	
	match leftText:
		"Level":
			valueNumber = int(valueNumber)
			valueNumber = clamp(valueNumber, 1, 10)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.creatureLevel = valueNumber
				"PlacingListData":
					oPlacingSettings.creatureLevel = valueNumber
		"Point #":
			valueNumber = int(valueNumber)
			valueNumber = clamp(valueNumber, 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.pointNumber = valueNumber
				"PlacingListData":
					oPlacingSettings.pointNumber = valueNumber
		"Gate number":
			valueNumber = int(valueNumber)
			valueNumber = clamp(valueNumber, 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.herogateNumber = valueNumber
				"PlacingListData":
					oPlacingSettings.herogateNumber = valueNumber
		"Intensity":
			valueNumber = int(valueNumber)
			valueNumber = clamp(valueNumber, 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.lightIntensity = valueNumber
				"PlacingListData":
					oPlacingSettings.lightIntensity = valueNumber
		"Effect range":
			valueNumber = float(valueNumber)
			valueNumber = clamp(valueNumber, 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.effectRange = valueNumber
				"PlacingListData":
					oPlacingSettings.effectRange = valueNumber
		"Light range":
			valueNumber = float(valueNumber)
			valueNumber = clamp(valueNumber, 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.lightRange = valueNumber
				"PlacingListData":
					oPlacingSettings.lightRange = valueNumber
		"Point range":
			valueNumber = float(valueNumber)
			valueNumber = clamp(valueNumber, 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.pointRange = valueNumber
				"PlacingListData":
					oPlacingSettings.pointRange = valueNumber
	
	lineEditId.text = String(valueNumber)

func clear():
	delete_children(self)

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n) #important to do this otherwise the margins get messed up
		n.queue_free()


