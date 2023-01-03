extends VBoxContainer
onready var oToolPencil = Nodelist.list["oToolPencil"]
onready var oBrushSizeContainer = Nodelist.list["oBrushSizeContainer"]

var BRUSH_SIZE = 1

enum {
	PENCIL
	RECTANGLE
	PAINTBUCKET
}

var TOOL_SELECTED = PENCIL

func _on_ToolPencil_toggled(button_pressed):
	TOOL_SELECTED = PENCIL
	oBrushSizeContainer.visible = true

func _on_ToolRectangle_toggled(button_pressed):
	TOOL_SELECTED = RECTANGLE
	oBrushSizeContainer.visible = false

func _on_ToolPaintBucket_toggled(button_pressed):
	TOOL_SELECTED = PAINTBUCKET
	oBrushSizeContainer.visible = false



func switched_to_slab_mode():
	visible = true

func switched_to_thing_mode():
	oToolPencil.pressed = true
	visible = false


func _on_EditBrushSizeValue_value_changed(value):
	BRUSH_SIZE = value
