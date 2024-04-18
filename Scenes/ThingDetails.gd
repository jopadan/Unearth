extends VBoxContainer
onready var oThingListData = Nodelist.list["oThingListData"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oUi = Nodelist.list["oUi"]
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oSelectionStatusButton = Nodelist.list["oSelectionStatusButton"]
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]


#var rememberInstance = null

func _ready():
	oPropertiesTabs.set_tab_title(0, "Inspect")

func update_details():
	oThingListData.clear()
	var id = get_selected_or_hovered_instance()
	if is_instance_valid(id):
		match id.filename.get_file():
			"ActionPointInstance.tscn": actionpoint_details(id)
			"LightInstance.tscn": light_details(id)
			"ThingInstance.tscn": thing_details(id)

func get_selected_or_hovered_instance():
	# Prioritize displaying the currently selected instance instead of the instance under the cursor.
	if is_instance_valid(oInspector.inspectingInstance):
		return oInspector.inspectingInstance
	if oSelection.cursorOnInstancesArray.size() > 0:
		var topInst = oSelection.cursorOnInstancesArray[0]
		if is_instance_valid(topInst):
			return topInst
	return null

func actionpoint_details(id):
	for i in 4:
		var description = null
		var value = null
		match i:
			0:
				description = "Type"
				value = "Action point"
			1:
				description = "Position"
				value = str(id.locationX)+' '+str(id.locationY)
			2:
				description = "Point range"
				value = id.pointRange
			3:
				description = "Point #"
				value = id.pointNumber
		
		if value != null:
			oThingListData.add_item(description, str(value))

var data3 = null
var data4 = null
var data5 = null
var data6 = null
var data7 = null
var data8 = null
var data9 = null
var data16 = null
var data17 = null
var data18_19 = null

func light_details(id):
	for i in 5:
		var description = null
		var value = null
		match i:
			0:
				description = "Type"
				value = "Light"
			1:
				description = "Position"
				value = str(id.locationX)+' '+str(id.locationY)+' '+str(id.locationZ)
			2:
				description = "Light range" # 9-10
				value = id.lightRange
			3:
				description = "Intensity" # 9-10
				value = id.lightIntensity
			4:
				description = "Attached to" # 18-19
				if id.parentTile != null:
					var parentY = int(id.parentTile/M.ySize)
					var parentX = id.parentTile - (parentY*M.xSize)
					var hoveredCell = oDataSlab.get_cell(parentX,parentY)
					if Slabs.data.has(hoveredCell):
						value = Slabs.data[hoveredCell][Slabs.NAME]
					else:
						value = ""
					if parentX == 0 and parentY == 0: value = "" # Don't show the text "Impenetrable Rock" for keys
					value += ' (' + str(parentX) + ','+str(parentY) + ')'
				if id.parentTile == 65535:
					value = "Manually placed"
			
		if value != null:
			oThingListData.add_item(description, str(value))


func thing_details(id):
	for i in 16:
		var description = null
		var value = null
		match i:
			0:
				description = "ID"
				value = retrieve_thing_name(id.thingType, id.subtype)
			1:
				description = "Type"
				value = retrieve_subtype_value(id.thingType, id.subtype)
			2:
				description = "Position"
				value = str(id.locationX)+' '+str(id.locationY)+' '+str(id.locationZ)
			3:
				description = "Ownership"
				value = Constants.ownershipNames[id.ownership]
			4:
				description = "Effect range" # 9-10
				value = id.effectRange
			5:
				description = "Attached to" # 11-12
				if id.parentTile != null:
					var parentY = int(id.parentTile/M.ySize)
					var parentX = id.parentTile - (parentY*M.xSize)
					var hoveredCell = oDataSlab.get_cell(parentX,parentY)
					if Slabs.data.has(hoveredCell):
						value = Slabs.data[hoveredCell][Slabs.NAME]
					else:
						value = ""
					if parentX == 0 and parentY == 0: value = "" # Don't show the text "Impenetrable Rock" for keys
					value += ' (' + str(parentX) + ','+str(parentY) + ')'
				if id.parentTile == 65535:
					value = "Manually placed"
			6:
				description = "Door orientation" # 13
				match id.doorOrientation:
					0: value = "E/W"
					1: value = "N/S"
			7:
				description = "Level" # 14
				value = id.creatureLevel
			8:
				description = "Gate #" # 14
				value = id.herogateNumber
			9:
				description = "Custom box" # 14
				value = id.boxNumber
			10:
				description = "Door locked" # 14
				value = id.doorLocked
			# FX extended fields
			11:
				description = "Health %"
				value = id.creatureInitialHealth
				if oCurrentFormat.selected == 0: value = null # Classic format
			12:
				description = "Gold held"
				value = id.creatureGold
				if oCurrentFormat.selected == 0: value = null # Classic format
			13:
				description = "Name" # Creature name
				value = id.creatureName
				if oCurrentFormat.selected == 0: value = null # Classic format
			14:
				description = "Gold value"
				value = id.goldValue
				if oCurrentFormat.selected == 0: value = null # Classic format
			15:
				description = "Orientation"
				value = id.orientation
				if oCurrentFormat.selected == 0: value = null # Classic format
			
		if value != null:
			oThingListData.add_item(description, str(value))


func _on_DeleteSelectedButton_pressed():
	oSelection.manually_delete_one_instance(oInspector.inspectingInstance)
	update_details()


func _on_SelectionStatusButton_pressed():
	oSelectionStatusButton.text = "Selected"
	oInspector.deselect()
	update_details()

func _on_SelectionStatusButton_mouse_entered():
	oSelectionStatusButton.text = "Deselect"
func _on_SelectionStatusButton_mouse_exited():
	oSelectionStatusButton.text = "Selected"

func retrieve_thing_name(t_type, s_type): # called by ThingInstance too
	match t_type:
		Things.TYPE.OBJECT:
			if Things.DATA_OBJECT.has(s_type):
				return Things.DATA_OBJECT[s_type][Things.NAME]
		Things.TYPE.CREATURE:
			if Things.DATA_CREATURE.has(s_type):
				return Things.DATA_CREATURE[s_type][Things.NAME]
		Things.TYPE.EFFECTGEN:
			if Things.DATA_EFFECTGEN.has(s_type):
				return Things.DATA_EFFECTGEN[s_type][Things.NAME]
		Things.TYPE.TRAP:
			if Things.DATA_TRAP.has(s_type):
				return Things.DATA_TRAP[s_type][Things.NAME]
		Things.TYPE.DOOR:
			if Things.DATA_DOOR.has(s_type):
				return Things.DATA_DOOR[s_type][Things.NAME]
		Things.TYPE.EXTRA:
			if Things.DATA_EXTRA.has(s_type):
				return Things.DATA_EXTRA[s_type][Things.NAME]
	return "Unknown"

func retrieve_subtype_value(t_type, s_type):
	match t_type:
		Things.TYPE.NONE: return "None" + " : " + str(s_type)
		Things.TYPE.OBJECT: return "Object" + " : " + str(s_type)
		Things.TYPE.CREATURE: return "Creature" + " : " + str(s_type)
		Things.TYPE.EFFECTGEN: return "EffectGen" + " : " + str(s_type)
		Things.TYPE.TRAP: return "Trap" + " : " + str(s_type)
		Things.TYPE.DOOR: return "Door" + " : " + str(s_type)
		Things.TYPE.EXTRA: return null
#			match s_type:
#				1: return "Action point : " + str(s_type)
#				2: return "Light : " + str(s_type)
	return "Unknown"

func _on_thing_portrait_mouse_entered(nodeId):
	# Don't display data if something is selected
	if is_instance_valid(oInspector.inspectingInstance) == true:
		return
	
	oThingListData.clear()
	var portraitSubtype = nodeId.get_meta("thingSubtype")
	var portraitThingType = nodeId.get_meta("thingType")
	
	
	var value = null
	
	# Name
	value = retrieve_thing_name(portraitThingType, portraitSubtype)
	if value != null:
		oThingListData.add_item(str(value),"")
	
	value = null
	if portraitThingType != Things.TYPE.EXTRA:
		value = retrieve_subtype_value(portraitThingType, portraitSubtype)
		if value != null:
			oThingListData.add_item(str(value),"")


# Fixes an obscure issue where it would continue to show what you've highlighted in the Thing Window inside of the Properties' Thing column.
#func _on_PropertiesTabs_tab_changed(tab):
#	if tab == 0:
#		if is_instance_valid(oInspector.inspectingInstance) == false:
#			oThingListData.clear()
