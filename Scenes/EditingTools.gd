extends HBoxContainer

enum {
	PENCIL
	RECTANGLE
}

var TOOL_SELECTED = PENCIL

func _on_ToolRectangle_toggled(button_pressed):
	TOOL_SELECTED = RECTANGLE

func _on_ToolPencil_toggled(button_pressed):
	TOOL_SELECTED = PENCIL

func switched_to_slab_mode():
	visible = true

func switched_to_thing_mode():
	$ToolPencil.pressed = true
	visible = false
