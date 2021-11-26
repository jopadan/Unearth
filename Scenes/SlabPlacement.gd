extends Node
onready var oReadData = Nodelist.list["oReadData"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oSlabPalette = Nodelist.list["oSlabPalette"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
onready var oQuickMessage = Nodelist.list["oQuickMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oPlaceThingWithSlab = Nodelist.list["oPlaceThingWithSlab"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oDamagedWallLineEdit = Nodelist.list["oDamagedWallLineEdit"]
onready var oAutoWallArtButton = Nodelist.list["oAutoWallArtButton"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oOwnableNaturalTerrain = Nodelist.list["oOwnableNaturalTerrain"]
onready var oBridgesOnlyOnLiquidCheckbox = Nodelist.list["oBridgesOnlyOnLiquidCheckbox"]

enum dir {
	s = 0
	w = 1
	n = 2
	e = 3
	sw = 4
	nw = 5
	ne = 6
	se = 7
	all = 8
	center = 27
}

enum {
	OWNERSHIP_GRAPHIC_FLOOR
	OWNERSHIP_GRAPHIC_PORTAL
	OWNERSHIP_GRAPHIC_HEART
	OWNERSHIP_GRAPHIC_WALL
	OWNERSHIP_GRAPHIC_DOOR_1
	OWNERSHIP_GRAPHIC_DOOR_2
}

func _on_ConfirmAutoGen_confirmed():
	oQuickMessage.message("Auto-generated all slabs")
	auto_generate_rectangle(Vector2(0,0), Vector2(84,84))

func auto_generate_rectangle(rectStart, rectEnd):
	oEditor.mapHasBeenEdited = true
	# Include surrounding
	rectStart -= Vector2(1,1)
	rectEnd += Vector2(1,1)
	rectStart = Vector2(clamp(rectStart.x, 0, 84), clamp(rectStart.y, 0, 84))
	rectEnd = Vector2(clamp(rectEnd.x, 0, 84), clamp(rectEnd.y, 0, 84))
	
	var CODETIME_START = OS.get_ticks_msec()
	for ySlab in range(rectStart.y, rectEnd.y+1):
		for xSlab in range(rectStart.x, rectEnd.x+1):
			var slabID = oDataSlab.get_cell(xSlab, ySlab)
			var ownership = oDataOwnership.get_cell(xSlab, ySlab)
			
			slab_update_clm(xSlab, ySlab, slabID, ownership)
	
	print('Auto generated in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

	
	oOverheadGraphics.overhead2d_update_rect(rectStart, rectEnd)

func place_slab_shape(shapePositionArray, slabID, ownership):
	
	var removeFromShape = []
	
	var CODETIME_START = OS.get_ticks_msec()
	for pos in shapePositionArray:
		match slabID:
			Slabs.BRIDGE:
				if oBridgesOnlyOnLiquidCheckbox.pressed == true:
					if oDataSlab.get_cellv(pos) != Slabs.WATER and oDataSlab.get_cellv(pos) != Slabs.LAVA:
						removeFromShape.append(pos) # This prevents ownership from changing if placing a bridge on something that's not liquid
				if removeFromShape.has(pos) == false:
					oInstances.delete_all_objects_on_slab(pos.x,pos.y)
					oDataSlab.set_cellv(pos, slabID)
			Slabs.EARTH:
				oInstances.delete_all_objects_on_slab(pos.x,pos.y)
				var autoEarthID = auto_torch_earth(pos.x, pos.y)
				oDataSlab.set_cellv(pos, autoEarthID)
			Slabs.WALL_AUTOMATIC:
				oInstances.delete_all_objects_on_slab(pos.x,pos.y)
				var autoWallID = auto_wall(pos.x, pos.y)
				oDataSlab.set_cellv(pos, autoWallID)
			_:
				oInstances.delete_all_objects_on_slab(pos.x,pos.y)
				oDataSlab.set_cellv(pos, slabID)
	
	for i in removeFromShape:
		shapePositionArray.erase(i)
	
	oOverheadOwnership.ownership_update_shape(shapePositionArray, ownership)
	print('Rectangle placed in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

#func place_slab(xSlab, ySlab, slabID, ownership, updateSurrounding):
#
#	match slabID:
#		Slabs.BRIDGE:
#			if oBridgesOnlyOnLiquidCheckbox.pressed == true:
#				if oDataSlab.get_cell(xSlab, ySlab) != Slabs.WATER and oDataSlab.get_cell(xSlab, ySlab) != Slabs.LAVA:
#					return
#
#	oOverheadOwnership.ownership_update_shape([Vector2(xSlab,ySlab)], ownership)
#
#	oDataSlab.set_cell(xSlab, ySlab, slabID)
#
#	if slabID == Slabs.EARTH or Slabs.data[slabID][Slabs.IS_SOLID] == false:
#		for dir in [Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,0),Vector2(-1,1),Vector2(-1,-1),Vector2(1,-1),Vector2(1,1)]:
#			var surroundingSlabID = oDataSlab.get_cell(xSlab+dir.x, ySlab+dir.y)
#			if surroundingSlabID in [Slabs.EARTH, Slabs.EARTH_WITH_TORCH]:
#				auto_torch_earth(xSlab+dir.x, ySlab+dir.y)
#		if slabID == Slabs.EARTH:
#			slabID = auto_torch_earth(xSlab, ySlab)
#
#	# Update nearby SlabIDs if placing an automatic wall or a non-solid.
#	if slabID == Slabs.WALL_AUTOMATIC or Slabs.data[slabID][Slabs.IS_SOLID] == false:
#		for dir in [Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,0),Vector2(-1,1),Vector2(-1,-1),Vector2(1,-1),Vector2(1,1)]:
#			var surroundingSlabID = oDataSlab.get_cell(xSlab+dir.x, ySlab+dir.y)
#			if Slabs.auto_wall_updates_these.has(surroundingSlabID):
#				auto_wall(xSlab+dir.x, ySlab+dir.y)
#
#	slab_update_clm(xSlab, ySlab, slabID, ownership)
#
#	if updateSurrounding == true:
#		for dir in [Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,0),Vector2(-1,1),Vector2(-1,-1),Vector2(1,-1),Vector2(1,1)]:
#			var surroundingSlabID = oDataSlab.get_cell(xSlab+dir.x, ySlab+dir.y)
#			var surroundingOwnership = oDataOwnership.get_cell(xSlab+dir.x, ySlab+dir.y)
#
#			slab_update_clm(xSlab+dir.x, ySlab+dir.y, surroundingSlabID, surroundingOwnership)
#
#	oOverheadGraphics.overhead2d_update_rect(Vector2(xSlab,ySlab), Vector2(xSlab,ySlab)) # Uses clm, so this goes last

func auto_torch_earth(xSlab, ySlab):
	var newSlabID = Slabs.EARTH
	var calcTorchSide = calculate_torch_side(xSlab,ySlab)
	match calcTorchSide:
		1,3: # West, East
			if oDataSlab.get_cell(xSlab+1, ySlab) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab-1, ySlab) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.EARTH_WITH_TORCH
		0,2: # South, North
			if oDataSlab.get_cell(xSlab, ySlab+1) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab, ySlab-1) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.EARTH_WITH_TORCH
	
	oDataSlab.set_cell(xSlab, ySlab, newSlabID)
	return newSlabID

func auto_wall(xSlab, ySlab):
	var newSlabID = Slabs.ROCK
	
	match oAutoWallArtButton.text:
		"Grouped":
			if int(xSlab) % 15 < 15 or int(ySlab) % 15 < 15: newSlabID = Slabs.WALL_WITH_PAIR
			if int(xSlab) % 15 < 10 or int(ySlab) % 15 < 10: newSlabID = Slabs.WALL_WITH_WOMAN
			if int(xSlab) % 15 < 5 or int(ySlab) % 15 < 5: newSlabID = Slabs.WALL_WITH_TWINS
		"Random":
			newSlabID = Random.choose([Slabs.WALL_WITH_TWINS, Slabs.WALL_WITH_WOMAN, Slabs.WALL_WITH_PAIR])
	
	if Random.chance_int(int(oDamagedWallLineEdit.text)) == true:
		newSlabID = Slabs.WALL_DAMAGED
	
	# Checkerboard
	if (int(xSlab) % 2 == 0 and int(ySlab) % 2 == 0) or (int(xSlab) % 2 == 1 and int(ySlab) % 2 == 1):
		
		for dir in [Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,0)]:
			if oDataSlab.get_cell(xSlab+dir.x, ySlab+dir.y) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.WALL_WITH_BANNER
	
	# Torch wall takes priority
	var calcTorchSide = calculate_torch_side(xSlab,ySlab)
	match calcTorchSide:
		1,3: # West, East
			if oDataSlab.get_cell(xSlab+1, ySlab) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab-1, ySlab) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.WALL_WITH_TORCH
		0,2: # South, North
			if oDataSlab.get_cell(xSlab, ySlab+1) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab, ySlab-1) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.WALL_WITH_TORCH
	
	oDataSlab.set_cell(xSlab, ySlab, newSlabID)
	
	return newSlabID

func calculate_torch_side(xSlab, ySlab):
	var calcTorchSide = -1
	var sideNS = -1
	var sideEW = -1
	
	if int(xSlab) % 5 == 0:
		if int(xSlab) % 10 == 0: # Every 10th row is reversed
			if int(ySlab) % 2 == 0: # Every 2nd tile flips the other way
				sideNS = dir.s
			else:
				sideNS = dir.n
		else:
			if int(ySlab) % 2 == 0: # Every 2nd tile flips the other way
				sideNS = dir.n
			else:
				sideNS = dir.s
	
	if int(ySlab) % 5 == 0:
		if int(ySlab) % 10 == 0: # Every 10th row is reversed
			if int(xSlab) % 2 == 0: # Every 2nd tile flips the other way
				sideEW = dir.e
			else:
				sideEW = dir.w
		else:
			if int(xSlab) % 2 == 0: # Every 2nd tile flips the other way
				sideEW = dir.w
			else:
				sideEW = dir.e
	
	if sideNS != -1 and sideEW != -1:
		# Some torch postions (every 5x5 point) are dynamically chosen
		if oDataSlab.get_cell(xSlab+1, ySlab) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab-1, ySlab) == Slabs.CLAIMED_GROUND:
			calcTorchSide = sideEW
		if oDataSlab.get_cell(xSlab, ySlab+1) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab, ySlab-1) == Slabs.CLAIMED_GROUND:
			calcTorchSide = sideNS
	else:
		if sideEW != -1: calcTorchSide = sideEW
		if sideNS != -1: calcTorchSide = sideNS
	
	return calcTorchSide

func slab_update_clm(xSlab, ySlab, slabID, ownership):
	
	var surrounding = get_surrounding_slabs(xSlab, ySlab)
	
	# WIB (wibble)
	update_wibble(xSlab, ySlab, slabID, surrounding)
	# WLB (Water Lava Block)
	if slabID != Slabs.BRIDGE:
		oDataLiquid.set_cell(xSlab, ySlab, Slabs.data[slabID][Slabs.LIQUID_TYPE])
	
	match Slabs.data[slabID][Slabs.BITMASK_TYPE]:
		Slabs.BITMASK_WALL: place_fortified_wall(xSlab, ySlab, slabID, ownership, surrounding)
		Slabs.BITMASK_NONE: place_simple(xSlab, ySlab, slabID, ownership, surrounding)
		Slabs.BITMASK_GOLD: place_gold(xSlab, ySlab, slabID, ownership, surrounding)
		Slabs.BITMASK_OTHER: place_other(xSlab, ySlab, slabID, ownership, surrounding)
		Slabs.BITMASK_GENERAL: place_general(xSlab, ySlab, slabID, ownership, surrounding)
		Slabs.BITMASK_CLAIMED: place_claimed_area(xSlab, ySlab, slabID, ownership, surrounding)

func place_fortified_wall(xSlab, ySlab, slabID, ownership, surrounding):
	if slabID == Slabs.WALL_AUTOMATIC:
		slabID = auto_wall(xSlab, ySlab) # Set slabID to a real one
	
	var slabVariation = slabID * 28
	
	var bitmask = get_wall_bitmask(xSlab, ySlab, surrounding, ownership)
	var asset3x3group = make_slab(slabID*28, bitmask)
	
	# Wall corners
	# 0 1 2
	# 3 4 5
	# 6 7 8
	var wallS = Slabs.data[ surrounding[dir.s] ][Slabs.BITMASK_TYPE]
	var wallW = Slabs.data[ surrounding[dir.w] ][Slabs.BITMASK_TYPE]
	var wallN = Slabs.data[ surrounding[dir.n] ][Slabs.BITMASK_TYPE]
	var wallE = Slabs.data[ surrounding[dir.e] ][Slabs.BITMASK_TYPE]
	if wallN == Slabs.BITMASK_WALL and wallE == Slabs.BITMASK_WALL and Slabs.data[ surrounding[dir.ne] ][Slabs.IS_SOLID] == false:
		asset3x3group[2] = ((slabVariation + dir.all) * 9) + 2
	if wallN == Slabs.BITMASK_WALL and wallW == Slabs.BITMASK_WALL and Slabs.data[ surrounding[dir.nw] ][Slabs.IS_SOLID] == false:
		asset3x3group[0] = ((slabVariation + dir.all) * 9) + 0
	if wallS == Slabs.BITMASK_WALL and wallE == Slabs.BITMASK_WALL and Slabs.data[ surrounding[dir.se] ][Slabs.IS_SOLID] == false:
		asset3x3group[8] = ((slabVariation + dir.all) * 9) + 8
	if wallS == Slabs.BITMASK_WALL and wallW == Slabs.BITMASK_WALL and Slabs.data[ surrounding[dir.sw] ][Slabs.IS_SOLID] == false:
		asset3x3group[6] = ((slabVariation + dir.all) * 9) + 6
	
	asset3x3group = modify_for_liquid(asset3x3group, surrounding, bitmask, slabID)
	asset3x3group = modify_room_face(asset3x3group, surrounding, slabID)
	
	var clmIndexArray = asset_position_to_column_index(asset3x3group)
	clmIndexArray = set_ownership_graphic(clmIndexArray, ownership, OWNERSHIP_GRAPHIC_WALL, bitmask, slabID)
	
	if slabID == Slabs.WALL_WITH_TORCH:
		
		clmIndexArray = adjust_torch_cubes(clmIndexArray, calculate_torch_side(xSlab, ySlab))
	
	clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_WALL, slabID)
	clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_WALL_NEARBY_WATER, slabID)
	clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_WALL_NEARBY_LAVA, slabID)
	
	set_columns(xSlab, ySlab, clmIndexArray)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab,slabID, ownership, slabVariation, bitmask, surrounding)

func place_general(xSlab, ySlab, slabID, ownership, surrounding):
	if slabID == Slabs.EARTH:
		slabID = auto_torch_earth(xSlab, ySlab) # Set slabID to a real one
	
	var slabVariation = slabID*28
	var bitmask = get_general_bitmask(slabID, surrounding)
	var asset3x3group = make_slab(slabID*28, bitmask)
	asset3x3group = modify_for_liquid(asset3x3group, surrounding, bitmask, slabID)
	var clmIndexArray = asset_position_to_column_index(asset3x3group)
	
	if slabID == Slabs.EARTH:
		clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_EARTH, slabID)
		clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_EARTH_NEARBY_WATER, slabID)
	elif slabID == Slabs.PATH: clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_DIRTPATH, slabID)
	elif slabID == Slabs.DUNGEON_HEART: clmIndexArray = set_ownership_graphic(clmIndexArray, ownership, OWNERSHIP_GRAPHIC_HEART, bitmask, slabID)
	elif slabID == Slabs.PORTAL: clmIndexArray = set_ownership_graphic(clmIndexArray, ownership, OWNERSHIP_GRAPHIC_PORTAL, bitmask, slabID)
	elif slabID == Slabs.LIBRARY: clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_LIBRARY, slabID)
	elif slabID == Slabs.EARTH_WITH_TORCH:
		clmIndexArray = adjust_torch_cubes(clmIndexArray, calculate_torch_side(xSlab, ySlab))
		
	set_columns(xSlab, ySlab, clmIndexArray)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab,slabID, ownership, slabVariation, bitmask, surrounding)

func place_gold(xSlab, ySlab, slabID, ownership, surrounding):
	var slabVariation = slabID*28
	var bitmask = get_gold_bitmask(surrounding)
	var asset3x3group = make_slab(slabVariation, bitmask)
	asset3x3group = modify_for_liquid(asset3x3group, surrounding, bitmask, slabID)
	var clmIndexArray = asset_position_to_column_index(asset3x3group)
	clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_GOLD, slabID)
	clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_GOLD_NEARBY_LAVA, slabID)
	clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_GOLD_NEARBY_WATER, slabID)
	
	set_columns(xSlab, ySlab, clmIndexArray)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab, slabID, ownership, slabVariation, bitmask, surrounding)

func place_claimed_area(xSlab, ySlab, slabID, ownership, surrounding):
	var slabVariation = slabID*28
	var bitmask = get_claimed_area_bitmask(xSlab, ySlab, slabID, surrounding, ownership)
	var asset3x3group = make_slab(slabVariation, bitmask)
	asset3x3group = modify_for_liquid(asset3x3group, surrounding, bitmask, slabID)
	var clmIndexArray = asset_position_to_column_index(asset3x3group)
	clmIndexArray = set_ownership_graphic(clmIndexArray, ownership, OWNERSHIP_GRAPHIC_FLOOR, bitmask, slabID)
	clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_CLAIMED_AREA, slabID)
	
	set_columns(xSlab, ySlab, clmIndexArray)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab,slabID, ownership, slabVariation, bitmask, surrounding)

func place_simple(xSlab, ySlab, slabID, ownership, surrounding):
	var slabVariation = slabID*28
	var bitmask = 0
	var asset3x3group = make_slab(slabVariation, bitmask)
	var clmIndexArray = asset_position_to_column_index(asset3x3group)
	
	if slabID == Slabs.LAVA:
		clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_LAVA, slabID)
	
	set_columns(xSlab, ySlab, clmIndexArray)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab,slabID, ownership, slabVariation, bitmask, null)

func place_other(xSlab, ySlab, slabID, ownership, surrounding): # These slabs only have 8 variations each, compared to the others which have 28 each.
	
	# Make sure door is facing the correct direction by changing its Slab based on surrounding slabs.
	if slabID in [Slabs.WOODEN_DOOR_1, Slabs.WOODEN_DOOR_2, Slabs.BRACED_DOOR_1, Slabs.BRACED_DOOR_2, Slabs.IRON_DOOR_1, Slabs.IRON_DOOR_2, Slabs.MAGIC_DOOR_1, Slabs.MAGIC_DOOR_2]:
		if Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == true and Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == true:
			match slabID:
				Slabs.WOODEN_DOOR_1: slabID = Slabs.WOODEN_DOOR_2
				Slabs.BRACED_DOOR_1: slabID = Slabs.BRACED_DOOR_2
				Slabs.IRON_DOOR_1: slabID = Slabs.IRON_DOOR_2
				Slabs.MAGIC_DOOR_1: slabID = Slabs.MAGIC_DOOR_2
			oDataSlab.set_cell(xSlab, ySlab, slabID)
		elif Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == true and Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == true:
			match slabID:
				Slabs.WOODEN_DOOR_2: slabID = Slabs.WOODEN_DOOR_1
				Slabs.BRACED_DOOR_2: slabID = Slabs.BRACED_DOOR_1
				Slabs.IRON_DOOR_2: slabID = Slabs.IRON_DOOR_1
				Slabs.MAGIC_DOOR_2: slabID = Slabs.MAGIC_DOOR_1
			oDataSlab.set_cell(xSlab, ySlab, slabID)
	
	var slabVariation = (42 * 28) + (8 * (slabID - 42))
	var bitmask = 1
	var asset3x3group = make_slab(slabVariation, bitmask)
	var clmIndexArray = asset_position_to_column_index(asset3x3group)
	
	match slabID:
		Slabs.WOODEN_DOOR_1, Slabs.BRACED_DOOR_1, Slabs.IRON_DOOR_1, Slabs.MAGIC_DOOR_1:
			clmIndexArray = set_ownership_graphic(clmIndexArray, ownership, OWNERSHIP_GRAPHIC_DOOR_1, 0, slabID)
		Slabs.WOODEN_DOOR_2, Slabs.BRACED_DOOR_2, Slabs.IRON_DOOR_2, Slabs.MAGIC_DOOR_2:
			clmIndexArray = set_ownership_graphic(clmIndexArray, ownership, OWNERSHIP_GRAPHIC_DOOR_2, 0, slabID)
		Slabs.GEMS:
			clmIndexArray = randomize_columns(clmIndexArray, oSlabPalette.RNG_CLM_GEMS, slabID)
	
	set_columns(xSlab, ySlab, clmIndexArray)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab,slabID, ownership, slabVariation, bitmask, null)

func randomize_columns(clmIndexArray, RNG_CLM, slabID):
	var rngSelect = oSlabPalette.randomColumns[RNG_CLM]
	
	match slabID:
		Slabs.PATH:
			var stoneRatio = 0.15
			for i in 9:
				if rngSelect.has(clmIndexArray[i]):
					if stoneRatio < randf():
						clmIndexArray[i] = rngSelect[Random.randi_range(0,2)] # Smooth path
					else:
						clmIndexArray[i] = rngSelect[Random.randi_range(3,4)] # Stony path
		_:
			for i in 9:
				if rngSelect.has(clmIndexArray[i]): # If the column exists within the random column array, then replace it with a random one.
					clmIndexArray[i] = rngSelect[randi() % rngSelect.size()]
	return clmIndexArray

func set_ownership_graphic(clmIndexArray, ownership, OWNERSHIP_GRAPHIC_TYPE, bitmask, slabID):
	if ownership == 0: return clmIndexArray # Already red
	# index_entry_replace_one_cube() arguments: array, cubePosition, setCubeID
	match OWNERSHIP_GRAPHIC_TYPE:
		OWNERSHIP_GRAPHIC_FLOOR:
			clmIndexArray[4] = oDataClm.index_entry_replace_one_cube(clmIndexArray[4], 0, Cube.ownedCube[Cube.FLOOR_MARKER][ownership])
		OWNERSHIP_GRAPHIC_PORTAL:
			if bitmask == 0:
				clmIndexArray[4] = oDataClm.index_entry_replace_one_cube(clmIndexArray[4], 6, Cube.ownedCube[Cube.PORTAL_MARKER][ownership])
		OWNERSHIP_GRAPHIC_HEART:
			match bitmask:
				03: # sw bitmask
					clmIndexArray[2] = oDataClm.index_entry_replace_one_cube(clmIndexArray[2], 7, Cube.ownedCube[Cube.HEART_MARKER][ownership])
				06: # nw bitmask
					clmIndexArray[8] = oDataClm.index_entry_replace_one_cube(clmIndexArray[8], 7, Cube.ownedCube[Cube.HEART_MARKER][ownership])
				12: # ne bitmask
					clmIndexArray[6] = oDataClm.index_entry_replace_one_cube(clmIndexArray[6], 7, Cube.ownedCube[Cube.HEART_MARKER][ownership])
				09: # se bitmask
					clmIndexArray[0] = oDataClm.index_entry_replace_one_cube(clmIndexArray[0], 7, Cube.ownedCube[Cube.HEART_MARKER][ownership])
		OWNERSHIP_GRAPHIC_WALL:
			for i in 9:
				# 0 1 2
				# 3 4 5
				# 6 7 8
				# Red Banner Left: 0, 2, 6
				# Red Banner Middle: 1, 3, 5, 7
				# Red Banner Right: 2, 6, 8
				# Barracks: 1, 3, 5, 7
				match i:
					4: # Wall marker
						clmIndexArray[i] = oDataClm.index_entry_replace_one_cube(clmIndexArray[i], 4, Cube.ownedCube[Cube.WALL_MARKER][ownership])
					1, 3, 5, 7: # Barracks, Red Banner Middle
						if oDataClm.cubes[clmIndexArray[i]][4] == 161: # Red Banner Middle
							clmIndexArray[i] = oDataClm.index_entry_replace_one_cube(clmIndexArray[i], 4, Cube.ownedCube[Cube.BANNER_MIDDLE][ownership])
						elif oDataClm.cubes[clmIndexArray[i]][3] == 393: # Barracks flag
							clmIndexArray[i] = oDataClm.index_entry_replace_one_cube(clmIndexArray[i], 3, Cube.ownedCube[Cube.BARRACKS_FLAG][ownership])
					0, 2, 6, 8: # Red Banner Left, Red Banner Right
						var cube4 = oDataClm.cubes[clmIndexArray[i]][4]
						if cube4 == 160: # Red Banner Left
							clmIndexArray[i] = oDataClm.index_entry_replace_one_cube(clmIndexArray[i], 4, Cube.ownedCube[Cube.BANNER_LEFT][ownership])
						elif cube4 == 162: # Red Banner Right
							clmIndexArray[i] = oDataClm.index_entry_replace_one_cube(clmIndexArray[i], 4, Cube.ownedCube[Cube.BANNER_RIGHT][ownership])
		OWNERSHIP_GRAPHIC_DOOR_1:
			# Floor marker
			#clmIndexArray[4] = oDataClm.index_entry_replace_one_cube(clmIndexArray[4], 0, Cube.ownedCube[Cube.FLOOR_MARKER][ownership])
			# Red Banner Left, Red Banner Middle, Red Banner Right
			clmIndexArray[1] = oDataClm.index_entry_replace_one_cube(clmIndexArray[1], 4, Cube.ownedCube[Cube.BANNER_LEFT][ownership])
			#clmIndexArray[4] = oDataClm.index_entry_replace_one_cube(clmIndexArray[4], 4, Cube.ownedCube[Cube.BANNER_MIDDLE][ownership])
			clmIndexArray[7] = oDataClm.index_entry_replace_one_cube(clmIndexArray[7], 4, Cube.ownedCube[Cube.BANNER_RIGHT][ownership])
			
			# Change BOTH Red Banner Middle AND Floor marker in same column
			var cubeArray = oDataClm.cubes[clmIndexArray[4]].duplicate(true)
			cubeArray[0] = Cube.ownedCube[Cube.FLOOR_MARKER][ownership]
			cubeArray[4] = Cube.ownedCube[Cube.BANNER_MIDDLE][ownership]
			clmIndexArray[4] = oDataClm.index_entry(cubeArray, oDataClm.floorTexture[clmIndexArray[4]])
			
		OWNERSHIP_GRAPHIC_DOOR_2:
			# Floor marker
			#clmIndexArray[4] = oDataClm.index_entry_replace_one_cube(clmIndexArray[4], 0, Cube.ownedCube[Cube.FLOOR_MARKER][ownership])
			# Red Banner Left, Red Banner Middle, Red Banner Right
			clmIndexArray[3] = oDataClm.index_entry_replace_one_cube(clmIndexArray[3], 4, Cube.ownedCube[Cube.BANNER_LEFT][ownership])
			#clmIndexArray[4] = oDataClm.index_entry_replace_one_cube(clmIndexArray[4], 4, Cube.ownedCube[Cube.BANNER_MIDDLE][ownership])
			clmIndexArray[5] = oDataClm.index_entry_replace_one_cube(clmIndexArray[5], 4, Cube.ownedCube[Cube.BANNER_RIGHT][ownership])
			
			var cubeArray = oDataClm.cubes[clmIndexArray[4]].duplicate(true)
			cubeArray[0] = Cube.ownedCube[Cube.FLOOR_MARKER][ownership]
			cubeArray[4] = Cube.ownedCube[Cube.BANNER_MIDDLE][ownership]
			clmIndexArray[4] = oDataClm.index_entry(cubeArray, oDataClm.floorTexture[clmIndexArray[4]])
			
	return clmIndexArray

func asset_position_to_column_index(array):
	for i in 9:
		var slabVariation = array[i] / 9
		var newSubtile = array[i] - (slabVariation*9)
		array[i] = oSlabPalette.slabPal[slabVariation][newSubtile] # slab variation - subtile of that variation
	return array

func set_columns(xSlab, ySlab, array):
	for i in 9:
		var ySubtile = i/3
		var xSubtile = i - (ySubtile*3)
		oDataClmPos.set_cell((xSlab*3)+xSubtile, (ySlab*3)+ySubtile, array[i])

func get_gold_bitmask(surrounding):
	var bitmask = 0
	if Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == false: bitmask += 1
	if Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == false: bitmask += 2
	if Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == false: bitmask += 4
	if Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == false: bitmask += 8
	return bitmask

func get_wall_bitmask(xSlab, ySlab, surrounding, ownership):
	var ownerS = oDataOwnership.get_cell(xSlab, ySlab+1)
	var ownerW = oDataOwnership.get_cell(xSlab-1, ySlab)
	var ownerN = oDataOwnership.get_cell(xSlab, ySlab-1)
	var ownerE = oDataOwnership.get_cell(xSlab+1, ySlab)
	if ownerS == 5: ownerS = ownership # If next to a Player 5 wall, treat it as earth, don't put up a wall against it.
	if ownerW == 5: ownerW = ownership
	if ownerN == 5: ownerN = ownership
	if ownerE == 5: ownerE = ownership
	var bitmask = 0
	if Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == false or ownerS != ownership: bitmask += 1
	if Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == false or ownerW != ownership: bitmask += 2
	if Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == false or ownerN != ownership: bitmask += 4
	if Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == false or ownerE != ownership: bitmask += 8
	return bitmask

func get_claimed_area_bitmask(xSlab, ySlab, slabID, surrounding, ownership):
	var bitmask = 0
	if (slabID != surrounding[dir.s] and Slabs.doors.has(surrounding[dir.s]) == false) or oDataOwnership.get_cell(xSlab, ySlab+1) != ownership: bitmask += 1
	if (slabID != surrounding[dir.w] and Slabs.doors.has(surrounding[dir.w]) == false) or oDataOwnership.get_cell(xSlab-1, ySlab) != ownership: bitmask += 2
	if (slabID != surrounding[dir.n] and Slabs.doors.has(surrounding[dir.n]) == false) or oDataOwnership.get_cell(xSlab, ySlab-1) != ownership: bitmask += 4
	if (slabID != surrounding[dir.e] and Slabs.doors.has(surrounding[dir.e]) == false) or oDataOwnership.get_cell(xSlab+1, ySlab) != ownership: bitmask += 8
	return bitmask

func get_general_bitmask(slabID, surrounding):
	var bitmask = 0
	if slabID != surrounding[dir.s]: bitmask += 1
	if slabID != surrounding[dir.w]: bitmask += 2
	if slabID != surrounding[dir.n]: bitmask += 4
	if slabID != surrounding[dir.e]: bitmask += 8
	# Middle slab
	if bitmask == 0:
		if Slabs.rooms_with_middle_slab.has(slabID):
			if slabID != surrounding[dir.se] or slabID != surrounding[dir.sw] or slabID != surrounding[dir.ne] or slabID != surrounding[dir.nw]:
				bitmask = 15
				if slabID == Slabs.TEMPLE: # Temple is just odd
					bitmask = 1000
	return bitmask

func get_surrounding_slabs(xSlab, ySlab):
	var surrounding = []
	surrounding.resize(8)
	surrounding[dir.n] = oDataSlab.get_cell(xSlab, ySlab-1)
	surrounding[dir.s] = oDataSlab.get_cell(xSlab, ySlab+1)
	surrounding[dir.e] = oDataSlab.get_cell(xSlab+1, ySlab)
	surrounding[dir.w] = oDataSlab.get_cell(xSlab-1, ySlab)
	surrounding[dir.ne] = oDataSlab.get_cell(xSlab+1, ySlab-1)
	surrounding[dir.nw] = oDataSlab.get_cell(xSlab-1, ySlab-1)
	surrounding[dir.se] = oDataSlab.get_cell(xSlab+1, ySlab+1)
	surrounding[dir.sw] = oDataSlab.get_cell(xSlab-1, ySlab+1)
	return surrounding

func adjust_torch_cubes(clmIndexArray, torchSideToKeep):
	var side = 0
	for i in [7,3,1,5]: # S W N E
		if torchSideToKeep != side:
			# Wall Torch Cube: 119
			# Earth Torch Cube: 24
			if oDataClm.cubes[clmIndexArray[i]][3] == 119 or oDataClm.cubes[clmIndexArray[i]][3] == 24:
				# Paint with "normal wall" cube.
				var replaceUsingCubeBelow = oDataClm.cubes[clmIndexArray[i]][2]
				clmIndexArray[i] = oDataClm.index_entry_replace_one_cube(clmIndexArray[i], 3, replaceUsingCubeBelow)
		side += 1
	return clmIndexArray

func modify_room_face(asset3x3group, surrounding, slabID):
	var modify0 = 0; var modify1 = 0; var modify2 = 0; var modify3 = 0; var modify4 = 0; var modify5 = 0; var modify6 = 0; var modify7 = 0; var modify8 = 0
	if Slabs.rooms.has(surrounding[dir.s]):
		var roomFace = surrounding[dir.s] + 1
		var offset = ((roomFace-slabID)*28)*9
		if surrounding[dir.se] == surrounding[dir.s] and surrounding[dir.sw] == surrounding[dir.s]:
			offset += 9*9
		modify6 = offset
		modify7 = offset
		modify8 = offset
	
	if Slabs.rooms.has(surrounding[dir.w]):
		var roomFace = surrounding[dir.w] + 1
		var offset = ((roomFace-slabID)*28)*9
		if surrounding[dir.sw] == surrounding[dir.w] and surrounding[dir.nw] == surrounding[dir.w]:
			offset += 9*9
		modify0 = offset
		modify3 = offset
		modify6 = offset
	if Slabs.rooms.has(surrounding[dir.n]):
		var roomFace = surrounding[dir.n] + 1
		var offset = ((roomFace-slabID)*28)*9
		if surrounding[dir.ne] == surrounding[dir.n] and surrounding[dir.nw] == surrounding[dir.n]:
			offset += 9*9
		modify0 = offset
		modify1 = offset
		modify2 = offset
	if Slabs.rooms.has(surrounding[dir.e]):
		var roomFace = surrounding[dir.e] + 1
		var offset = ((roomFace-slabID)*28)*9
		if surrounding[dir.se] == surrounding[dir.e] and surrounding[dir.ne] == surrounding[dir.e]:
			offset += 9*9
		modify2 = offset
		modify5 = offset
		modify8 = offset
	
	asset3x3group[0] += modify0
	asset3x3group[1] += modify1
	asset3x3group[2] += modify2
	asset3x3group[3] += modify3
	asset3x3group[4] += modify4
	asset3x3group[5] += modify5
	asset3x3group[6] += modify6
	asset3x3group[7] += modify7
	asset3x3group[8] += modify8
	
	return asset3x3group

func modify_for_liquid(asset3x3group, surrounding, bitmask, slabID):
	var modify0 = 0; var modify1 = 0; var modify2 = 0; var modify3 = 0; var modify4 = 0; var modify5 = 0; var modify6 = 0; var modify7 = 0; var modify8 = 0
	if surrounding[dir.s] == Slabs.LAVA:
		modify6 = 9*9
		modify7 = 9*9
		modify8 = 9*9
	elif surrounding[dir.s] == Slabs.WATER:
		modify6 = 18*9
		modify7 = 18*9
		modify8 = 18*9
	
	if surrounding[dir.w] == Slabs.LAVA:
		modify0 = 9*9
		modify3 = 9*9
		modify6 = 9*9
	elif surrounding[dir.w] == Slabs.WATER:
		modify0 = 18*9
		modify3 = 18*9
		modify6 = 18*9
	
	if surrounding[dir.n] == Slabs.LAVA:
		modify0 = 9*9
		modify1 = 9*9
		modify2 = 9*9
	elif surrounding[dir.n] == Slabs.WATER:
		modify0 = 18*9
		modify1 = 18*9
		modify2 = 18*9
	
	if surrounding[dir.e] == Slabs.LAVA:
		modify2 = 9*9
		modify5 = 9*9
		modify8 = 9*9
	elif surrounding[dir.e] == Slabs.WATER:
		modify2 = 18*9
		modify5 = 18*9
		modify8 = 18*9
	
	asset3x3group[0] += modify0
	asset3x3group[1] += modify1
	asset3x3group[2] += modify2
	asset3x3group[3] += modify3
	asset3x3group[4] += modify4
	asset3x3group[5] += modify5
	asset3x3group[6] += modify6
	asset3x3group[7] += modify7
	asset3x3group[8] += modify8
	
	# When gold, impenetrable or earth is placed in lava/water, as a solo piece, randomly remove 1-3 corners
	if bitmask == 15 and (slabID == Slabs.ROCK or slabID == Slabs.EARTH or slabID == Slabs.GOLD):
		var cornerList = [0,2,6,8]
		cornerList.shuffle()
		if modify0 == 9*9:
			for i in Random.randi_range(1,3):
				var choose = cornerList[i]
				asset3x3group[choose] = Slabs.LAVA * 28 * 9
		elif modify0 == 9*18:
			for i in Random.randi_range(1,3):
				var choose = cornerList[i]
				asset3x3group[choose] = Slabs.WATER * 28 * 9
	return asset3x3group

func make_slab(slabVariation, bitmask):
	var constructedSlab = bitmaskToSlab[bitmask].duplicate()
	for subtile in 9:
		constructedSlab[subtile] = ((slabVariation+constructedSlab[subtile]) * 9) + subtile
	return constructedSlab

var bitmaskToSlab = {
	00:slab_center,
	01:slab_s,
	02:slab_w,
	04:slab_n,
	08:slab_e,
	03:slab_sw,
	06:slab_nw,
	12:slab_ne,
	09:slab_se,
	15:slab_all,
	05:slab_sn,
	10:slab_ew,
	07:slab_swn,
	11:slab_swe,
	13:slab_sen,
	14:slab_wne,
	1000:slab_temple_odd,
}

const slab_center = [
	dir.center, # subtile 0
	dir.center, # subtile 1
	dir.center, # subtile 2
	dir.center, # subtile 3
	dir.center, # subtile 4
	dir.center, # subtile 5
	dir.center, # subtile 6
	dir.center, # subtile 7
	dir.center, # subtile 8
]
const slab_s = [
	dir.s, # subtile 0
	dir.s, # subtile 1
	dir.s, # subtile 2
	dir.s, # subtile 3
	dir.s, # subtile 4
	dir.s, # subtile 5
	dir.s, # subtile 6
	dir.s, # subtile 7
	dir.s, # subtile 8
]
const slab_w = [
	dir.w, # subtile 0
	dir.w, # subtile 1
	dir.w, # subtile 2
	dir.w, # subtile 3
	dir.w, # subtile 4
	dir.w, # subtile 5
	dir.w, # subtile 6
	dir.w, # subtile 7
	dir.w, # subtile 8
]
const slab_n = [
	dir.n, # subtile 0
	dir.n, # subtile 1
	dir.n, # subtile 2
	dir.n, # subtile 3
	dir.n, # subtile 4
	dir.n, # subtile 5
	dir.n, # subtile 6
	dir.n, # subtile 7
	dir.n, # subtile 8
]
const slab_e = [
	dir.e, # subtile 0
	dir.e, # subtile 1
	dir.e, # subtile 2
	dir.e, # subtile 3
	dir.e, # subtile 4
	dir.e, # subtile 5
	dir.e, # subtile 6
	dir.e, # subtile 7
	dir.e, # subtile 8
]
const slab_sw = [
	dir.sw, # subtile 0
	dir.sw, # subtile 1
	dir.sw, # subtile 2
	dir.sw, # subtile 3
	dir.sw, # subtile 4
	dir.sw, # subtile 5
	dir.sw, # subtile 6
	dir.sw, # subtile 7
	dir.sw, # subtile 8
]
const slab_nw = [
	dir.nw, # subtile 0
	dir.nw, # subtile 1
	dir.nw, # subtile 2
	dir.nw, # subtile 3
	dir.nw, # subtile 4
	dir.nw, # subtile 5
	dir.nw, # subtile 6
	dir.nw, # subtile 7
	dir.nw, # subtile 8
]
const slab_ne = [
	dir.ne, # subtile 0
	dir.ne, # subtile 1
	dir.ne, # subtile 2
	dir.ne, # subtile 3
	dir.ne, # subtile 4
	dir.ne, # subtile 5
	dir.ne, # subtile 6
	dir.ne, # subtile 7
	dir.ne, # subtile 8
]
const slab_se = [
	dir.se, # subtile 0
	dir.se, # subtile 1
	dir.se, # subtile 2
	dir.se, # subtile 3
	dir.se, # subtile 4
	dir.se, # subtile 5
	dir.se, # subtile 6
	dir.se, # subtile 7
	dir.se, # subtile 8
]
const slab_all = [
	dir.all, # subtile 0
	dir.all, # subtile 1
	dir.all, # subtile 2
	dir.all, # subtile 3
	dir.all, # subtile 4
	dir.all, # subtile 5
	dir.all, # subtile 6
	dir.all, # subtile 7
	dir.all, # subtile 8
]
const slab_sn = [
	dir.n, # subtile 0
	dir.n, # subtile 1
	dir.n, # subtile 2
	dir.s, # subtile 3
	dir.all, # subtile 4
	dir.s, # subtile 5
	dir.s, # subtile 6
	dir.s, # subtile 7
	dir.s, # subtile 8
]

const slab_ew = [
	dir.w, # subtile 0
	dir.w, # subtile 1
	dir.e, # subtile 2
	dir.w, # subtile 3
	dir.all, # subtile 4
	dir.e, # subtile 5
	dir.w, # subtile 6
	dir.w, # subtile 7
	dir.e, # subtile 8
]

const slab_sen = [
	dir.ne, # subtile 0
	dir.ne, # subtile 1
	dir.ne, # subtile 2
	dir.se, # subtile 3
	dir.all, # subtile 4
	dir.all, # subtile 5
	dir.se, # subtile 6
	dir.se, # subtile 7
	dir.se, # subtile 8
]

const slab_swe = [
	dir.sw, # subtile 0
	dir.sw, # subtile 1
	dir.se, # subtile 2
	dir.sw, # subtile 3
	dir.all, # subtile 4
	dir.se, # subtile 5
	dir.sw, # subtile 6
	dir.all, # subtile 7
	dir.se, # subtile 8
]

const slab_swn = [
	dir.nw, # subtile 0
	dir.nw, # subtile 1
	dir.nw, # subtile 2
	dir.all, # subtile 3
	dir.all, # subtile 4
	dir.sw, # subtile 5
	dir.sw, # subtile 6
	dir.sw, # subtile 7
	dir.sw, # subtile 8
]

const slab_wne = [
	dir.nw, # subtile 0
	dir.all, # subtile 1
	dir.ne, # subtile 2
	dir.nw, # subtile 3
	dir.all, # subtile 4
	dir.ne, # subtile 5
	dir.nw, # subtile 6
	dir.nw, # subtile 7
	dir.ne, # subtile 8
]

const slab_temple_odd = [
	dir.s, # subtile 0
	dir.s, # subtile 1
	dir.s, # subtile 2
	dir.e, # subtile 3
	dir.all, # subtile 4
	dir.w, # subtile 5
	dir.n, # subtile 6
	dir.n, # subtile 7
	dir.n, # subtile 8
]

func update_wibble(xSlab, ySlab, slabID, surrounding):
	var myWibble = Slabs.data[slabID][Slabs.WIBBLE_TYPE]
	
	var xWib = xSlab * 3
	var yWib = ySlab * 3
	
	oDataWibble.set_cell(xWib+1, yWib+1, myWibble)
	oDataWibble.set_cell(xWib+2, yWib+1, myWibble)
	oDataWibble.set_cell(xWib+1, yWib+2, myWibble)
	oDataWibble.set_cell(xWib+2, yWib+2, myWibble)
	
	if myWibble == 1:
		oDataWibble.set_cell(xWib+0, yWib+0, myWibble)
		oDataWibble.set_cell(xWib+1, yWib+3, myWibble)
		oDataWibble.set_cell(xWib+2, yWib+3, myWibble)
		oDataWibble.set_cell(xWib+3, yWib+3, myWibble)
		oDataWibble.set_cell(xWib+3, yWib+2, myWibble)
		oDataWibble.set_cell(xWib+3, yWib+1, myWibble)
		oDataWibble.set_cell(xWib+3, yWib+0, myWibble)
		oDataWibble.set_cell(xWib+0, yWib+3, myWibble)
		oDataWibble.set_cell(xWib+1, yWib+0, myWibble)
		oDataWibble.set_cell(xWib+2, yWib+0, myWibble)
		oDataWibble.set_cell(xWib+0, yWib+1, myWibble)
		oDataWibble.set_cell(xWib+0, yWib+2, myWibble)
	
	if myWibble != 1:
		var nCheck = Slabs.data[ surrounding[dir.n] ][Slabs.WIBBLE_TYPE]
		var wCheck = Slabs.data[ surrounding[dir.w] ][Slabs.WIBBLE_TYPE]
		if nCheck == myWibble:
			oDataWibble.set_cell(xWib+1, yWib+0, myWibble)
			oDataWibble.set_cell(xWib+2, yWib+0, myWibble)
		if wCheck == myWibble:
			oDataWibble.set_cell(xWib+0, yWib+1, myWibble)
			oDataWibble.set_cell(xWib+0, yWib+2, myWibble)
		if nCheck == myWibble and wCheck == myWibble and Slabs.data[ surrounding[dir.nw] ][Slabs.WIBBLE_TYPE] == myWibble:
			oDataWibble.set_cell(xWib+0, yWib+0, myWibble)
	
#	if myWibble == 0:
#		oDataWibble.set_cell(xWib+1, yWib+1, myWibble)
	#if myWibble <= 1:
#	for i in 16:
#		var ySubtile = i/4
#		var xSubtile = i - (ySubtile*4)
#		#print(xWib+xSubtile)
#		oDataWibble.set_cell(xWib+xSubtile, yWib+ySubtile, myWibble)
	
#	if myWibble == 2:
#		oDataWibble.set_cell(xWib+1, yWib+0, 1)
#		oDataWibble.set_cell(xWib+2, yWib+0, 1)
#		if Slabs.data[ surrounding[dir.n] ][Slabs.WIBBLE_TYPE] != 2:
#			oDataWibble.set_cell(xWib+1, yWib+0, 1)
#			oDataWibble.set_cell(xWib+2, yWib+0, 1)
#		if Slabs.data[ surrounding[dir.w] ][Slabs.WIBBLE_TYPE] != 2:
#			oDataWibble.set_cell(xWib+0, yWib+1, 1)
#			oDataWibble.set_cell(xWib+0, yWib+2, 1)
#		if Slabs.data[ surrounding[dir.nw] ][Slabs.WIBBLE_TYPE] != 2:
#			oDataWibble.set_cell(xWib+0, yWib+0, 1)
	
#	else: # myWibble == 2
#		for i in 9:
#			var ySubtile = i/3
#			var xSubtile = i - (ySubtile*3)
#			var existingValue = oDataClmPos.get_cell(xWib+xSubtile, yWib+ySubtile)
#			if existingValue != 1:
#				oDataWibble.set_cell(xWib+xSubtile, yWib+ySubtile, myWibble)
	
	#if oDataWibble.get_cell(xWib+xSubtile, yWib+ySubtile) == 2:

#	if sCheck == myWibble:
#		oDataWibble.set_cell(xWib+1, yWib+2, myWibble)
#		oDataWibble.set_cell(xWib+2, yWib+2, myWibble)
#	if eCheck == myWibble:
#		oDataWibble.set_cell(xWib+0, yWib+1, myWibble)
#		oDataWibble.set_cell(xWib+0, yWib+2, myWibble)
#		if nCheck == myWibble: # east AND north
#			oDataWibble.set_cell(xWib+3, yWib+0, myWibble)
#		if sCheck == myWibble: # east AND south
#			oDataWibble.set_cell(xWib+3, yWib+3, myWibble)
#	if wCheck == myWibble:
#		oDataWibble.set_cell(xWib+2, yWib+1, myWibble)
#		oDataWibble.set_cell(xWib+2, yWib+2, myWibble)
#		if sCheck == myWibble: # west AND south
#			oDataWibble.set_cell(xWib+0, yWib+3, myWibble)
#		if nCheck == myWibble: # west AND north
#			oDataWibble.set_cell(xWib+0, yWib+0, myWibble)

	
	
	



#func set_columns(xSlab, ySlab, array):
#	for ySubtile in 3:
#		for xSubtile in 3:
#			var i = (ySubtile*3)+xSubtile
#
#			var slabVariation = array[i] / 9
#			var newSubtile = array[i] - (slabVariation*9)
#			var value = oSlabPalette.slabPal[slabVariation][newSubtile] # slab variation - subtile of that variation
#
#			oDataClmPos.set_cell((xSlab*3)+xSubtile, (ySlab*3)+ySubtile, value)


	# Temple is really bizarre
#	if slabID == Slabs.TEMPLE:
#		if bitmask != 1+2 and bitmask != 1+8 and bitmask != 4+2 and bitmask != 4+8:
#			var countSurr = 0
#			if surrounding[dir.ne] != slabID: countSurr += 1
#			if surrounding[dir.nw] != slabID: countSurr += 1
#			if surrounding[dir.se] != slabID: countSurr += 1
#			if surrounding[dir.sw] != slabID: countSurr += 1
#			if countSurr > 2:
#				bitmask = 15


#func adjust_torch_cubes(clmIndexArray, torchSide):
#	var torchSidesToRemove = []
#	for i in 9:
#		match i:
#			1,3,5,7: 
#				if oDataClm.cubes[clmIndexArray[i]][3] == 119: # Torch cube
#					torchSidesToRemove.append(i)
#	if torchSidesToRemove.empty() == true: return clmIndexArray
#
#	# Pick one side to keep, by removing it from the array in which they'll be removed
#	torchSidesToRemove.remove(randi() % torchSidesToRemove.size())
#	# Paint over the rest with "normal wall" cube.
#	for i in torchSidesToRemove:
#		var replaceUsingCubeBelow = oDataClm.cubes[clmIndexArray[i]][2]
#		clmIndexArray[i] = oDataClm.index_entry_replace_one_cube(clmIndexArray[i], 3, replaceUsingCubeBelow)
#
#	return clmIndexArray


#					var TORCH_DISTANCE = float(oTorchDistanceLineEdit.text)
#					if torch_within_distance(TORCH_DISTANCE, xSlab, ySlab) == false:
#						slabID = Slabs.WALL_WITH_TORCH

#func torch_within_distance(torchDist, xSlab,ySlab):
#	var ts = Constants.TILE_SIZE
#	var sourcePos = Vector2(xSlab*ts, ySlab*ts) + Vector2(ts/2, ts/2)
#
#	var realDistance = torchDist * ts
#
#	for id in get_tree().get_nodes_in_group("Thing"):
#		if id.subtype == 2 and id.thingType == Things.TYPE.OBJECT:
#
#			# Get the tile that the Torch is "attached to".
#			var sensY = int(id.sensitiveTile/85)
#			var sensX = id.sensitiveTile - (sensY*85)
#			var attachedToTilePos = Vector2(sensX*ts,sensY*ts) + Vector2(ts/2, ts/2)
#
#
#			if attachedToTilePos.distance_to(sourcePos) <= realDistance and Vector2(sensX,sensY) != Vector2(xSlab,ySlab):
#				return true
#	return false

#func torch_flags(xSlab,ySlab):
#	var tflag = 0
#	if int(xSlab) % 5 == 0:
#		if oDataSlab.get_cell(xSlab, ySlab+1) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab, ySlab-1) == Slabs.CLAIMED_GROUND:
#			tflag += 1
#	if int(ySlab) % 5 == 0:
#		if oDataSlab.get_cell(xSlab+1, ySlab) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab-1, ySlab) == Slabs.CLAIMED_GROUND:
#			tflag += 1
#	return tflag


#	get_test_slb_data()

#func get_test_slb_data():
#	var file = File.new()
#	file.open("F:/Games/Dungeon Keeper/campgns/keeporig/map00014.slb", File.READ)
#	#file.open("F:/Games/Dungeon Keeper/ADiKtEd/levels/map00001.slb", File.READ)
#	oReadData.read_slb(file)

#func _unhandled_input(event):
#	if Input.is_key_pressed(KEY_T):
#		print('Pressed T to auto generate DAT/CLM')
#		auto_generate()
#		oShaderUniform.map_overhead_2d_textures()
#
#	if Input.is_key_pressed(KEY_U):
#		oDataClm.update_all_utilized()


#func randomize_dirtpath(clmIndexArray, RNG_CLM):
#	var rngSelect = oSlabPalette.randomColumns[RNG_CLM]
#	if rngSelect.has(clmIndexArray[i]):
#	var stoneRatio = 0.10
#	for i in 9:
#		if stoneRatio < randf():
#			clmIndexArray[i] = rngSelect[Random.randi_range(0,2)] # Smooth path
#		else:
#			clmIndexArray[i] = rngSelect[Random.randi_range(3,4)] # Stony path
#	return clmIndexArray


	# Every second tile will prioritize the opposite direction
#	if int(xSlab) % 2 == 0:
#		if Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == false: return dir.n
#		if Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == false: return dir.s
#	else:
#		if Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == false: return dir.s
#		if Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == false: return dir.n
#
#	if int(ySlab) % 2 == 0:
#		if Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == false: return dir.e
#		if Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == false: return dir.w
#	else:
#		if Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == false: return dir.w
#		if Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == false: return dir.e
#	return -1


	# Every second tile will prioritize the opposite direction
#	var tflag = torch_flags(xSlab, ySlab)
#
#	if tflag == 1:
#		if Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == false:
#			return dir.n
#		elif Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == false:
#			return dir.s
#
#		if Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == false:
#			return dir.w
#		elif Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == false:
#			return dir.e
	
#	var faceX = 0
#	var faceY = 0
#
#	if int(xSlab) % 2 == 0:
#		if Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == false:
#			faceY = dir.n
#		elif Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == false:
#			faceY = dir.s
#	else:
#		if Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == false:
#			faceY = dir.s
#		elif Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == false:
#			faceY = dir.n
#
#	if int(ySlab) % 2 == 0:
#		if Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == false:
#			faceX = dir.e
#		elif Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == false:
#			faceX = dir.w
#	else:
#		if Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == false:
#			faceX = dir.w
#		elif Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == false:
#			faceX = dir.e
#
#	if int(xSlab) % 5 == 0: # This is tricky to explain but it ensures that there's less slabs facing north only.
#		if faceY != 0: return faceY
#		elif faceX != 0: return faceX
#	else:
#		if faceX != 0: return faceX
#		elif faceY != 0: return faceY
	


#const subtilePos = [Vector2(0,0),Vector2(1,0),Vector2(2,0),Vector2(0,1),Vector2(1,1),Vector2(2,1),Vector2(0,2),Vector2(1,2),Vector2(2,2)]
#	for i in 9:
#		oDataClmPos.set_cellv(Vector2((xSlab*3)+subtilePos[i].x, (ySlab*3)+subtilePos[i].y), array[i])


#func set_columns(array, xSlab, ySlab):
#	for ySubtile in 3:
#		for xSubtile in 3:
#			var i = (ySubtile*3)+xSubtile
#			oDataClmPos.set_cell( (xSlab*3)+xSubtile, (ySlab*3)+ySubtile, array[i])



			
#			if slabID == Slabs.WALL_AUTOMATIC:
#				listOfAutowallsToUpdate.append(Vector2(xSlab,ySlab))
#			else:
	
	# This must be done afterwards for the autowall to work correctly, not sure why.
	# Automatic walls can be set inside "Image to Map", and they need to be "Placed" but ONLY after surrounding cells have been set
	
#	for i in listOfAutowallsToUpdate:
#		var xSlab = i.x
#		var ySlab = i.y
#		# Update nearby SlabIDs if placing an automatic wall or a non-solid.
#		for dir in [Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,0),Vector2(-1,1),Vector2(-1,-1),Vector2(1,-1),Vector2(1,1)]:
#			var surroundingSlabID = oDataSlab.get_cell(xSlab+dir.x, ySlab+dir.y)
#			if Slabs.auto_wall_updates_these.has(surroundingSlabID):
#				var slabID = auto_wall(xSlab+dir.x, ySlab+dir.y)
#				var ownership = oDataOwnership.get_cell(xSlab, ySlab)
#				slab_update_clm(xSlab, ySlab, slabID, ownership)