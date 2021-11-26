extends VBoxContainer
onready var oThingListData = Nodelist.list["oThingListData"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oUi = Nodelist.list["oUi"]
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oSelectionStatusButton = Nodelist.list["oSelectionStatusButton"]
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]


var HIDE_UNKNOWN_DATA = true

var rememberInstance = null

func _ready():
	get_parent().set_tab_title(0, "Thing")

func _process(delta):
	if visible == false: return
	
	# Prioritize displaying "Selected" instance instead of hovered instance.
	var id
	if is_instance_valid(oInspector.inspectingInstance) == true:
		id = oInspector.inspectingInstance
	elif oSelection.cursorOnInstancesArray.empty() == false and is_instance_valid(oSelection.cursorOnInstancesArray[0]) == true:
		id = oSelection.cursorOnInstancesArray[0]
	else:
		if oUi.mouseOnUi == false:
			oThingListData.clear()
		rememberInstance = null
		return
	
	if rememberInstance == id:
		return
	else:
		rememberInstance = id
	
	oThingListData.clear()
	
	match id.filename.get_file():
		"ActionPointInstance.tscn": actionpoint_details(id)
		"LightInstance.tscn": light_details(id)
		"ThingInstance.tscn": thing_details(id)


func actionpoint_details(id):
	for i in 5:
		var description = null
		var value = null
		match i:
			0:
				description = "Type"
				value = "Action point"
			1:
				description = "Position"
				value = str(id.locationX)+',  '+str(id.locationY)
			2:
				description = "Point range"
				value = id.pointRange
			3:
				description = "Point #"
				value = id.pointNumber
			4:
				description = "Unknown 7"
				value = id.data7
				if HIDE_UNKNOWN_DATA == true: value = null
		
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
var data18 = null
var data19 = null

func light_details(id):
	for i in 15:
		var description = null
		var value = null
		match i:
			0:
				description = "Type"
				value = "Light"
			1:
				description = "Position"
				value = str(id.locationX)+',  '+str(id.locationY)+',  '+str(id.locationZ)
			2:
				description = "Light range" # 9-10
				value = id.lightRange
			3:
				description = "Intensity" # 9-10
				value = id.lightIntensity
			4:
				description = "Unknown 3"
				value = id.data3
				if HIDE_UNKNOWN_DATA == true: value = null
			5:
				description = "Unknown 4"
				value = id.data4
				if HIDE_UNKNOWN_DATA == true: value = null
			6:
				description = "Unknown 5"
				value = id.data5
				if HIDE_UNKNOWN_DATA == true: value = null
			7:
				description = "Unknown 6"
				value = id.data6
				if HIDE_UNKNOWN_DATA == true: value = null
			8:
				description = "Unknown 7"
				value = id.data7
				if HIDE_UNKNOWN_DATA == true: value = null
			9:
				description = "Unknown 8"
				value = id.data8
				if HIDE_UNKNOWN_DATA == true: value = null
			10:
				description = "Unknown 9"
				value = id.data9
				if HIDE_UNKNOWN_DATA == true: value = null
			11:
				description = "Unknown 16"
				value = id.data16
				if HIDE_UNKNOWN_DATA == true: value = null
			12:
				description = "Unknown 17"
				value = id.data17
				if HIDE_UNKNOWN_DATA == true: value = null
			13:
				description = "Unknown 18"
				value = id.data18
				if HIDE_UNKNOWN_DATA == true: value = null
			14:
				description = "Unknown 19"
				value = id.data19
				if HIDE_UNKNOWN_DATA == true: value = null
			
		if value != null:
			oThingListData.add_item(description, str(value))

func thing_details(id):
	for i in 22:
		var description = null
		var value = null
		match i:
			0:
				description = "Name"
				value = retrieve_thing_name(id.thingType, id.subtype)
			1:
				description = "Type"
				value = retrieve_subtype_value(id.thingType, id.subtype)
			2:
				description = "Position"
				value = str(id.locationX)+',  '+str(id.locationY)+',  '+str(id.locationZ)
			3:
				description = "Ownership"
				value = Constants.ownershipNames[id.ownership]
			4:
				description = "Effect range" # 9-10
				value = id.effectRange
			5:
				description = "Unknown 9"
				value = id.data9
				if HIDE_UNKNOWN_DATA == true: value = null
			6:
				description = "Unknown 10"
				value = id.data10
				if HIDE_UNKNOWN_DATA == true: value = null
			7:
				description = "Attached to" # 11-12
				if id.sensitiveTile != null:
					var sensY = int(id.sensitiveTile/85)
					var sensX = id.sensitiveTile - (sensY*85)
					value = str(sensX) + ',  '+str(sensY)
				if id.sensitiveTile == 65535:
					value = "None"
			8:
				description = "Unknown 11"
				value = id.data11
				if HIDE_UNKNOWN_DATA == true: value = null
			9:
				description = "Unknown 12"
				value = id.data12
				if HIDE_UNKNOWN_DATA == true: value = null
			10:
				description = "Door orientation" # 13
				match id.doorOrientation:
					0: value = "E/W"
					1: value = "N/S"
			11:
				description = "Unknown 13"
				value = id.data13
				if HIDE_UNKNOWN_DATA == true: value = null
			12:
				description = "Level" # 14
				value = id.creatureLevel
			13:
				description = "Gate number" # 14
				value = id.herogateNumber
			14:
				description = "Door locked" # 14
				match id.doorLocked:
					0: value = "False"
					1: value = "True"
			15:
				description = "Unknown 14"
				value = id.data14
				if HIDE_UNKNOWN_DATA == true: value = null
			16:
				description = "Unknown 15"
				value = id.data15
				if HIDE_UNKNOWN_DATA == true: value = null
			17:
				description = "Unknown 16"
				value = id.data16
				if HIDE_UNKNOWN_DATA == true: value = null
			18:
				description = "Unknown 17"
				value = id.data17
				if HIDE_UNKNOWN_DATA == true: value = null
			19:
				description = "Unknown 18"
				value = id.data18
				if HIDE_UNKNOWN_DATA == true: value = null
			20:
				description = "Unknown 19"
				value = id.data19
				if HIDE_UNKNOWN_DATA == true: value = null
			21:
				description = "Unknown 20"
				value = id.data20
				if HIDE_UNKNOWN_DATA == true: value = null
		if value != null:
			oThingListData.add_item(description, str(value))

func _on_DeleteSelectedButton_pressed():
	oSelection.delete_instance(oInspector.inspectingInstance)
	oThingListData.clear()


func _on_SelectionStatusButton_pressed():
	oSelectionStatusButton.text = "Selected"
	oInspector.deselect()

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
		Things.TYPE.EFFECT:
			if Things.DATA_EFFECT.has(s_type):
				return Things.DATA_EFFECT[s_type][Things.NAME]
		Things.TYPE.TRAP:
			if Things.DATA_TRAP.has(s_type):
				return Things.DATA_TRAP[s_type][Things.NAME]
		Things.TYPE.DOOR:
			if Things.DATA_DOOR.has(s_type):
				return Things.DATA_DOOR[s_type][Things.NAME]
		Things.TYPE.EXTRA:
			if Things.DATA_EXTRA.has(s_type):
				return Things.DATA_EXTRA[s_type][Things.NAME]
	return "Unrecognized Thing ID"

func retrieve_subtype_value(t_type, s_type):
	match t_type:
		Things.TYPE.NONE: return "None" + " : " + str(s_type)
		Things.TYPE.OBJECT: return "Object" + " : " + str(s_type)
		Things.TYPE.CREATURE: return "Creature" + " : " + str(s_type)
		Things.TYPE.EFFECT: return "Effect" + " : " + str(s_type)
		Things.TYPE.TRAP: return "Trap" + " : " + str(s_type)
		Things.TYPE.DOOR: return "Door" + " : " + str(s_type)
		Things.TYPE.EXTRA: return null
#			match s_type:
#				1: return "Action point : " + str(s_type)
#				2: return "Light : " + str(s_type)
	return "Unrecognized Thing ID"

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
func _on_PropertiesTabs_tab_changed(tab):
	if tab == 0:
		if is_instance_valid(oInspector.inspectingInstance) == false:
			oThingListData.clear()