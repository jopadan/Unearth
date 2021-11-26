extends Node2D
onready var oSelection = Nodelist.list["oSelection"]
onready var oInspector = Nodelist.list["oInspector"]

var ownership = 5 # Not used by Dungeon Keeper, this is just to make it easy for the editor.
var thingType = Things.TYPE.EXTRA
var subtype = 2 # As written in Things.DATA_EXTRA

var locationX = null
var locationY = null
var locationZ = null
var lightRange = null setget set_lightrange
var lightIntensity = null

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


func _enter_tree():
	position.x = locationX * 32
	position.y = locationY * 32

func set_lightrange(setval):
	lightRange = setval
	update()

func instance_was_selected(): update()
func instance_was_deselected(): update()
func _draw():
	if oSelection.cursorOnInstancesArray.has(self) or oInspector.inspectingInstance == self:
		draw_arc(Vector2(0,0), (lightRange * 32)+16, 0, PI*2, 64, Color(1,1,0.5,1), 4, false)

func _on_MouseDetection_mouse_entered():
	if oSelection.cursorOnInstancesArray.has(self) == false:
		oSelection.cursorOnInstancesArray.append(self)
	oSelection.clean_up_cursor_array()
	update()

func _on_MouseDetection_mouse_exited():
	if oSelection.cursorOnInstancesArray.has(self):
		oSelection.cursorOnInstancesArray.erase(self)
	oSelection.clean_up_cursor_array()
	update()