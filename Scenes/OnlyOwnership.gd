extends PanelContainer
onready var oSelection = Nodelist.list["oSelection"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oSlabTabs = Nodelist.list["oSlabTabs"]

var scnOwnerButton = preload("res://Scenes/OnlyOwnershipButton.tscn")
onready var oSelectedRect = get_node("../../../../Clippy/SelectedRect")

func update_grid_items():
	var oGridContainer = current_grid_container()

	for i in oGridContainer.get_children():
		i.free()

	var owner_order
	if oCurrentFormat.selected == Constants.ClassicFormat:
		owner_order = [0,1,2,3,4,5]
	else:
		owner_order = [0,1,2,3,6,7,8,4,5]

#	# Add children
	for i in owner_order:
		var id = scnOwnerButton.instance()
		id.connect("pressed", self, "_on_OwnerButtonPressed", [id])
		
		id.connect("mouse_entered", oPickSlabWindow, "_on_hovered_over_item", [id])
		id.connect("mouse_exited", oPickSlabWindow, "_on_hovered_none")
		
		id.set_meta("ownershipID",i)
		id.set_meta("grid_item_text",Constants.ownershipNames[i])
		
		#var col = Constants.ownerRoomCol[i]
		if i == oSelection.paintOwnership:
			id.pressed = true
		
		#var textLabel = id.get_node("Label")
		
		var keeperColourIconPic = id.get_node("TextureRect")
		match i:
			0: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_red_std.png")
			1: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_blue_std.png")
			2: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_green_std.png")
			3: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_yellow_std.png")
			4: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_white_std.png")
			5: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_any_dis.png")
			6: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_purple_std.png")
			7: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_black_std.png")
			8: keeperColourIconPic.texture = preload("res://edited_images/plyrsym_32/symbol_player_orange_std.png")
		
		oGridContainer.add_child(id)
	
	# Refresh tab by switching away then back
	if oSlabTabs.get_current_tab_control().name == "OnlyOwnership":
		var ontab = oSlabTabs.current_tab
		oSlabTabs.current_tab = ontab-1
		yield(get_tree(),'idle_frame')
		oSlabTabs.current_tab = ontab


func _on_OwnerButtonPressed(id):
	oSelectedRect.boundToItem = id
	oSelectedRect.visible = true
	oSelection.newOwnership(id.get_meta("ownershipID"))


func select_appropriate_button():
	if visible == false: return # Needed because this function can be called when tab isn't visible
	# Select grid item in window
	for id in current_grid_container().get_children():
		if id is Button:
			if id.get_meta("ownershipID") == oSelection.paintOwnership:
				oSelectedRect.boundToItem = id
				oSelectedRect.visible = true
				id.pressed = true
				# highlight i here


func current_grid_container():
	return $"ScrollContainer/GridContainer"


func _on_OnlyOwnership_visibility_changed():
	if visible == true:
		select_appropriate_button()
