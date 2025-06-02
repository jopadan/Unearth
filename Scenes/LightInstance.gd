extends Node2D
onready var oSelection = Nodelist.list["oSelection"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oUi = Nodelist.list["oUi"]

var ownership = 5 # Not used by Dungeon Keeper, this is just to make it easy for the editor.
var thingType = Things.TYPE.EXTRA
var subtype = 2 # As written in Things.DATA_EXTRA

var locationX = null setget set_location_x
var locationY = null setget set_location_y
var locationZ = null setget set_location_z
var lightRange = null setget set_lightrange
var lightIntensity = null
var parentTile = null setget set_parentTile

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

func set_parentTile(setval):
	data18_19 = null
	parentTile = setval

func _enter_tree():
	if parentTile != null:
		add_to_group('attachedtotile_'+str(parentTile))
	#for i in 10:
	#	yield(get_tree(),'idle_frame')
	#print("hello? this is  subtype:", subtype, " thingType:" ,thingType, " position:", position, " locationX:", locationX," locationY:", locationY," locationZ:", locationZ, " visible: ", visible)

func set_location_x(setVal):
	if locationX != null and locationY != null:
		remove_from_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))
	locationX = setVal
	position.x = locationX * 32
	if locationX != null and locationY != null:
		add_to_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))

func set_location_y(setVal):
	if locationX != null and locationY != null:
		remove_from_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))
	locationY = setVal
	position.y = locationY * 32
	if locationX != null and locationY != null:
		add_to_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))

func set_location_z(setVal):
	locationZ = setVal

func set_lightrange(setval):
	lightRange = setval
	update()

func instance_was_selected(): update()
func instance_was_deselected(): update()
func _draw():
	if oSelection.cursorOnInstancesArray.has(self) or oInspector.inspectingInstance == self:
		draw_arc(Vector2(0,0), (lightRange * 32)+16, 0, PI*2, 64, Color(1,1,0.5,1), 4, false)

func _on_MouseDetection_mouse_entered():
	if oUi.mouseOnUi == true: return
	if oSelection.cursorOnInstancesArray.has(self) == false:
		oSelection.cursorOnInstancesArray.append(self)
	oSelection.clean_up_cursor_array()
	oThingDetails.update_details()
	update()

func _on_MouseDetection_mouse_exited():
	if oSelection.cursorOnInstancesArray.has(self):
		oSelection.cursorOnInstancesArray.erase(self)
	oSelection.clean_up_cursor_array()
	oThingDetails.update_details()
	update()

func _on_VisibilityNotifier2D_screen_entered():
	visible = true

func _on_VisibilityNotifier2D_screen_exited():
	visible = false
