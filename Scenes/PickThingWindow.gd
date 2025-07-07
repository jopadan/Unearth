extends WindowDialog
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oThingTabs = Nodelist.list["oThingTabs"]
onready var oActionPointOptions = Nodelist.list["oActionPointOptions"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oGridFunctions = Nodelist.list["oGridFunctions"]
onready var oPropertiesWindow = Nodelist.list["oPropertiesWindow"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oUi = Nodelist.list["oUi"]

enum {
	GRIDCON_PATH
	ICON_PATH
}

enum { # I only used the official DK keeperfx categories as a guide rather than strict adherence. What strict adherence gets you is all the egg objects classified as Furniture, while Chicken sits alone in its own Food category.
	TAB_ACTION
	TAB_CREATURE
	TAB_GOLD
	TAB_TRAP
	TAB_SPELL
	TAB_SPECIAL
	TAB_BOX
	TAB_LAIR
	TAB_EFFECTGEN
	TAB_FURNITURE
	TAB_DECORATION
	TAB_MISC
}

onready var tabs = {
	TAB_CREATURE: [oThingTabs.get_node("TabFolder/Creature"),"res://edited_images/icon_creature.png"],
	TAB_SPELL: [oThingTabs.get_node("TabFolder/Spell"),"res://edited_images/icon_book.png"],
	TAB_TRAP: [oThingTabs.get_node("TabFolder/Trap"),"res://dk_images/traps_doors/anim0845/r1frame04.png"],
	TAB_BOX: [oThingTabs.get_node("TabFolder/Box"),"res://dk_images/traps_doors/anim0116/r1frame12.png"],
	TAB_SPECIAL: [oThingTabs.get_node("TabFolder/Special"),"res://dk_images/trapdoor_64/bonus_box_std.png"],
	TAB_GOLD: [oThingTabs.get_node("TabFolder/Gold"),"res://dk_images/symbols_64/creatr_stat_gold_std.png"], #"res://dk_images/valuables/gold_hoard1_fp/r1frame03.png" #"res://dk_images/valuables/gold_hoard2_fp/r1frame02.png" #"res://dk_images/valuables/gold_hoard4_fp/r1frame01.png"
	TAB_DECORATION: [oThingTabs.get_node("TabFolder/Decoration"),"res://dk_images/statues/anim0906/r1frame01.png"],
	TAB_ACTION: [oThingTabs.get_node("TabFolder/Action"),"res://dk_images/guisymbols_64/sym_fight.png"], #"res://Art/ActionPoint.png"
	TAB_EFFECTGEN: [oThingTabs.get_node("TabFolder/Effect"),"res://edited_images/icon_effect.png"],
	TAB_FURNITURE: [oThingTabs.get_node("TabFolder/Furniture"),"res://dk_images/furniture/workshop_machine_fp/r1frame01.png"], #"res://dk_images/furniture/training_machine_fp/r1frame09.png"
	TAB_LAIR: [oThingTabs.get_node("TabFolder/Lair"),"res://dk_images/room_64/lair_std.png"],
	TAB_MISC: [oThingTabs.get_node("TabFolder/Misc"),"res://dk_images/rpanel_64/tab_crtr_wandr_std.png"],
}

export var grid_item_size : Vector2
export var grid_window_scale : float setget update_scale
onready var oSelectedRect = $Clippy/SelectedRect
onready var oCenteredLabel = $Clippy/CenteredLabel
var scnGridItem = preload("res://Scenes/GenericGridItem.tscn")
var rectChangedTimer = Timer.new()
## The purpose of "Clippy" is to hide the blue cursor if you scroll it off the window.

func _ready():
	get_close_button().expand = true
	get_close_button().hide()
	connect("resized",oGridFunctions,"_on_GridWindow_resized", [self])
	connect("visibility_changed",oGridFunctions,"_on_GridWindow_visibility_changed",[self])
	connect("gui_input",oGridFunctions,"_on_GridWindow_gui_input",[self])
	connect("item_rect_changed",self,"rect_changed_start_timer")
	rectChangedTimer.connect("timeout", oUi, "_on_any_window_was_modified", [self])
	rectChangedTimer.one_shot = true
	add_child(rectChangedTimer)
	
	oThingTabs.tabSystem.connect("tab_changed",oGridFunctions,"_on_tab_changed",[self])
	
	grid_window_scale = 0.55
	grid_item_size = Vector2(96, 96)
	
	# Window's minimum size
	rect_min_size = Vector2(80,80)#Vector2((grid_item_size.x*grid_window_scale)+11, (grid_item_size.y*grid_window_scale)+11)
	
	oThingTabs.initialize([])

func initialize_thing_grid_items():
	yield(get_tree(),'idle_frame') # Needed for loading animation IDs from call_deferred in Things singleton
	var CODETIME_START = OS.get_ticks_msec()
	remove_all_grid_items()
	
	for thingCategory in [Things.TYPE.OBJECT, Things.TYPE.CREATURE, Things.TYPE.TRAP, Things.TYPE.DOOR, Things.TYPE.EFFECTGEN, Things.TYPE.EXTRA]:
		match thingCategory:
			Things.TYPE.OBJECT:
				for subtype in Things.DATA_OBJECT:
					if subtype != 0:
						var genre = Things.DATA_OBJECT[subtype][Things.GENRE]
						var putIntoTab
						match genre:
							"DECORATION": putIntoTab = TAB_DECORATION
							"EFFECT": putIntoTab = TAB_EFFECTGEN
							"FOOD": putIntoTab = TAB_FURNITURE
							"FURNITURE": putIntoTab = TAB_FURNITURE
							"LAIR_TOTEM": putIntoTab = TAB_LAIR
							"POWER": putIntoTab = TAB_MISC
							"SPECIALBOX": putIntoTab = TAB_SPECIAL
							"SPELLBOOK": putIntoTab = TAB_SPELL
							"TREASURE_HOARD": putIntoTab = TAB_GOLD
							"VALUABLE": putIntoTab = TAB_GOLD
							"WORKSHOPBOX": putIntoTab = TAB_BOX
							"HEROGATE": putIntoTab = TAB_ACTION
							_: putIntoTab = TAB_DECORATION
						
						# Check if this subtype needs to be recategorized
						if recategorization.has(subtype):
							if putIntoTab == recategorization[subtype][0]:
								putIntoTab = recategorization[subtype][1]
						
						add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_OBJECT, thingCategory, subtype)
			Things.TYPE.CREATURE:
				for subtype in Things.DATA_CREATURE:
					if subtype != 0:
						var putIntoTab = TAB_CREATURE
						add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_CREATURE, thingCategory, subtype)
			Things.TYPE.TRAP:
				for subtype in Things.DATA_TRAP:
					if subtype != 0:
						var putIntoTab = TAB_TRAP
						add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_TRAP, thingCategory, subtype)
			Things.TYPE.DOOR:
				for subtype in Things.DATA_DOOR:
					if subtype != 0:
						var putIntoTab = TAB_MISC
						add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_DOOR, thingCategory, subtype)
			Things.TYPE.EFFECTGEN:
				for subtype in Things.DATA_EFFECTGEN:
					if subtype != 0:
						var putIntoTab = TAB_EFFECTGEN
						add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_EFFECTGEN, thingCategory, subtype)
			Things.TYPE.EXTRA:
				for subtype in Things.DATA_EXTRA:
					if subtype != 0:
						var putIntoTab
						match subtype:
							1: putIntoTab = TAB_ACTION # Action Point
							2: putIntoTab = TAB_EFFECTGEN # Light
						add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_EXTRA, thingCategory, subtype)
	
	print('Initialized Things window: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

# Hardcoded recategorization for tabs
var recategorization = {
002 : [TAB_FURNITURE, TAB_DECORATION], #TORCH
004 : [TAB_FURNITURE, TAB_DECORATION], #TEMPLE_STATUE
007 : [TAB_FURNITURE, TAB_DECORATION], #TORCHUN
009 : [TAB_FURNITURE, TAB_MISC], #CHICKEN_GRW
010 : [TAB_FURNITURE, TAB_MISC], #CHICKEN_MAT
025 : [TAB_DECORATION, TAB_MISC], #ROOM_FLAG
028 : [TAB_FURNITURE, TAB_DECORATION], #CANDLESTCK
030 : [TAB_FURNITURE, TAB_DECORATION], #STATUE_HORNY
033 : [TAB_FURNITURE, TAB_DECORATION], #TEMPLE_SPANGLE
040 : [TAB_FURNITURE, TAB_MISC], #CHICKEN_STB
041 : [TAB_FURNITURE, TAB_MISC], #CHICKEN_WOB
042 : [TAB_FURNITURE, TAB_MISC], #CHICKEN_CRK
044 : [TAB_FURNITURE, TAB_MISC], #SPINNING_KEY
050 : [TAB_EFFECTGEN, TAB_MISC], #SPINNING_KEY2
051 : [TAB_EFFECTGEN, TAB_MISC], #ARMOUR
110 : [TAB_BOX, TAB_MISC], #WRKBOX_ITEM
112 : [TAB_EFFECTGEN, TAB_MISC], #DISEASE
128 : [TAB_EFFECTGEN, TAB_MISC], #SPINNCOIN
}

func add_to_category(tabNode, thingsData, thingtype, subtype):
	var getName = Things.fetch_name(thingtype, subtype)
	if "Dummy Trap" in getName: return
	
	var gridcontainer = get_grid_container_node(tabNode)
	
	var id = scnGridItem.instance()
	id.img_margin = 3
	id.connect('mouse_entered',oThingDetails,"_on_thing_portrait_mouse_entered",[id])
	id.set_meta("thingSubtype", subtype)
	id.set_meta("thingType", thingtype)
	
	# Appearance prioritization: Portrait > Texture > ThingDarkened.png
	var portraitTex = Things.fetch_portrait(thingtype, subtype)
	if portraitTex != null:
		id.img_normal = portraitTex
	else:
		var textureTex = Things.fetch_sprite(thingtype, subtype)
		if textureTex != null:
			id.img_normal = textureTex
		else:
			id.img_normal = preload('res://Art/ThingDarkened.png')
	
	add_item_to_grid(gridcontainer, id, getName)
	
	# Needed for when adding custom objects
	for i in 3:
		yield(get_tree(),'idle_frame')
		oGridFunctions._on_GridWindow_resized(self)


func _process(delta): # It's necessary to use _process to update selection, because ScrollContainer won't fire a signal while you're scrolling.
	update_selection_position()


func update_selection_position():
	if is_instance_valid(oSelectedRect.boundToItem) == true:
		oSelectedRect.rect_global_position = oSelectedRect.boundToItem.rect_global_position
		oSelectedRect.rect_size = oSelectedRect.boundToItem.rect_size

enum {
	CHANGE_TO_PORTRAIT,
	CHANGE_TO_SPRITE,
}

func _on_hovered_none(id):
	oCenteredLabel.get_node("Label").text = ""
	change_portrait_on_hover(id, CHANGE_TO_PORTRAIT)


func _on_hovered_over_item(id):
	var offset = Vector2(id.rect_size.x * 0.5, id.rect_size.y * 0.5)
	oCenteredLabel.rect_global_position = id.rect_global_position + offset
	oCenteredLabel.get_node("Label").text = id.get_meta("grid_item_text")
	change_portrait_on_hover(id, CHANGE_TO_SPRITE)


func change_portrait_on_hover(id, textureOrPortrait):
	var thingType = id.get_meta("thingType")
	var subtype = id.get_meta("thingSubtype")
	var tex
	match textureOrPortrait:
		CHANGE_TO_SPRITE: tex = Things.fetch_sprite(thingType, subtype)
		CHANGE_TO_PORTRAIT: tex = Things.fetch_portrait(thingType, subtype)
	if tex != null:
		id.img_normal = tex

func add_item_to_grid(tabID, id, set_text):
	tabID.add_child(id)
	
	var textArray = set_text.split(" ")
	var textLine1 = ""
	var textLine2 = ""
#	if set_text == "Hell Hound":
#		print(textArray.size())
	
	for i in textArray.size():
		if i < textArray.size()*0.5:
			textLine1 += textArray[i] + ' '
		else:
			textLine2 += textArray[i] + ' '
	
	set_text = textLine1 + '\n' + textLine2
	
	
	id.set_meta("grid_item_text", set_text)
	id.connect("mouse_entered", self, "_on_hovered_over_item", [id])
	id.connect("mouse_exited", self, "_on_hovered_none", [id])
	id.connect("pressed",self,"pressed",[id])
	id.rect_min_size = Vector2(grid_item_size.x * grid_window_scale, grid_item_size.y * grid_window_scale)
	
	if is_instance_valid(id) == true:
		add_workshop_item_sprite_overlay(id, id.get_meta("thingSubtype"))

func add_workshop_item_sprite_overlay(textureParent, subtype):
	if Things.DATA_OBJECT.has(subtype):
		var nameID = Things.DATA_OBJECT[subtype][Things.NAME_ID]
		if Things.LIST_OF_BOXES.has(nameID):
			var itemData = Things.LIST_OF_BOXES[nameID]
			var itemType = itemData[0]
			var itemSubtype = itemData[1]

			var workshopItemInTheBox = TextureRect.new()
			workshopItemInTheBox.texture = Things.fetch_sprite(itemType, itemSubtype)
			workshopItemInTheBox.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			workshopItemInTheBox.expand = true

			if textureParent is TextureButton:
				workshopItemInTheBox.anchor_left = 0.25
				workshopItemInTheBox.anchor_top = 0.25
				workshopItemInTheBox.anchor_right = 0.75
				workshopItemInTheBox.anchor_bottom = 0.75
			else:
				workshopItemInTheBox.anchor_left = 0.15
				workshopItemInTheBox.anchor_top = 0.15
				workshopItemInTheBox.anchor_right = 0.85
				workshopItemInTheBox.anchor_bottom = 0.85

			workshopItemInTheBox.rect_position = Vector2(2, -1)
			workshopItemInTheBox.modulate = Color(1, 1, 1, 0.5)
			workshopItemInTheBox.mouse_filter = Control.MOUSE_FILTER_IGNORE

			textureParent.add_child(workshopItemInTheBox)
			return true

	return false

func current_grid_container():
	return get_grid_container_node(oThingTabs.get_current_tab_control())


func pressed(id):
	#oSelection.paintSlab = setValue # Set whatever this needs to be
	oPickSlabWindow.set_selection(null)
	set_selection(id.get_meta("thingType"), id.get_meta("thingSubtype"))
	oPlacingSettings.set_placing_tab_and_update_it()
	oInspector.deselect()


func set_selection(setType, setSubtype):
	if setType == Things.TYPE.EXTRA and setSubtype == 1:
		oActionPointOptions.visible = true
	else:
		oActionPointOptions.visible = false
	
	if setType == null:
		oSelection.paintThingType = null
		oSelection.paintSubtype = null
		oSelectedRect.boundToItem = null
		oSelectedRect.visible = false
		return
	
	
	# Check EVERY tab, not just the currently selected TAB. This is needed for when right clicking on a thing in the field then switching to that tab.
	for tabIndex in oThingTabs.get_tab_count():
		var tabID = oThingTabs.get_tab_control(tabIndex)

		for id in get_grid_container_node(tabID).get_children():
			if id.get_meta("thingType") == setType and id.get_meta("thingSubtype") == setSubtype:
				
				oSelectedRect.visible = true
				oSelectedRect.boundToItem = id
				oSelection.paintThingType = setType
				oSelection.paintSubtype = setSubtype
				
				oThingTabs.set_current_tab(tabIndex)

func update_scale(setvalue):
	var oGridContainer = current_grid_container()
	if oGridContainer == null: return
	for id in oGridContainer.get_children():
		id.rect_min_size = Vector2(grid_item_size.x * setvalue, grid_item_size.y * setvalue)
	grid_window_scale = setvalue
	oGridFunctions._on_GridWindow_resized(self)

#func _on_ThingTabs_tab_changed(newTab):
#	update_scale(grid_window_scale)
#
#	# Make oSelectedRect visible if it's in the tab you switched to, otherwise make in invisible
#	oSelectedRect.visible = false
#	if is_instance_valid(oSelectedRect.boundToItem):
#		for id in current_grid_container().get_children():
#			if id.get_meta("thingSubtype") == oSelectedRect.boundToItem.get_meta("thingSubtype") and id.get_meta("thingType") == oSelectedRect.boundToItem.get_meta("thingType"):
#				oSelectedRect.visible = true
#
#	oGridFunctions._on_GridWindow_resized(self)

func remove_all_grid_items():
	for tabIndex in oThingTabs.get_tab_count():
		var tabID = oThingTabs.get_tab_control(tabIndex)
		
		for id in get_grid_container_node(tabID).get_children():
			id.queue_free()

func rect_changed_start_timer():
	rectChangedTimer.start(0.2)

func get_grid_container_node(tabID):
	var gc = tabID.get_node('ScrollContainer/GridContainer')
	if gc == null:
		gc = tabID.get_node('VBoxContainer/ScrollContainer/GridContainer')
	return gc
