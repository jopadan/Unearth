extends Node2D
onready var oQuickMessage = Nodelist.list["oQuickMessage"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oWarning = Nodelist.list["oWarning"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]

var thingScn = preload("res://Scenes/ThingInstance.tscn")
var actionPointScn = preload("res://Scenes/ActionPointInstance.tscn")
var lightScn = preload("res://Scenes/LightInstance.tscn")


func place_new_light(newThingType, newSubtype, newPosition, newOwnership):
	var id = lightScn.instance()
	id.locationX = newPosition.x
	id.locationY = newPosition.y
	id.locationZ = newPosition.z
	id.lightRange = oPlacingSettings.lightRange
	id.lightIntensity = oPlacingSettings.lightIntensity
	id.data3 = 0
	id.data4 = 0
	id.data5 = 0
	id.data6 = 0
	id.data7 = 0
	id.data8 = 0
	id.data9 = 0
	id.data16 = 0
	id.data17 = 0
	id.data18 = 255
	id.data19 = 255
	add_child(id)

func place_new_action_point(newThingType, newSubtype, newPosition, newOwnership):
	var id = actionPointScn.instance()
	id.locationX = newPosition.x
	id.locationY = newPosition.y
	id.pointRange = oPlacingSettings.pointRange
	id.pointNumber = get_free_action_point_number()
	id.data7 = 0
	add_child(id)

func place_new_thing(newThingType, newSubtype, newPosition, newOwnership): # Placed by hand
	var CODETIME_START = OS.get_ticks_msec()
	var slabID = oDataSlab.get_cell(newPosition.x/3,newPosition.y/3)
	var id = thingScn.instance()
	
	id.data9 = 0
	id.data10 = 0
	id.data11 = 0
	id.data12 = 0
	id.data13 = 0
	id.data14 = 0
	id.data15 = 0
	id.data16 = 0
	id.data17 = 0
	id.data18 = 0
	id.data19 = 0
	id.data20 = 0
	
	id.locationX = newPosition.x
	id.locationY = newPosition.y
	id.locationZ = newPosition.z
	id.thingType = newThingType
	id.subtype = newSubtype
	id.ownership = newOwnership
	
	match id.thingType:
		Things.TYPE.OBJECT:
			
			if id.subtype == 49: # Hero Gate
				id.herogateNumber = get_free_hero_gate_number() #originalInstance.herogateNumber
				#Set all attached to tile: None, except for these: Torch, Heart, Unlit Torch, all Eggs and Chicken, Spinning Key, Spinning Key 2, all Lairs (don't forget Orc Lair!), Spinning Coin, and Effects.
			elif id.subtype in [2,7]: # Torch and Unlit Torch
				id.locationZ = 2.875
				
				if Slabs.data[oDataSlab.get_cell(floor((newPosition.x+1)/3),floor(newPosition.y/3))][Slabs.IS_SOLID] == true : id.locationX += 0.25
				if Slabs.data[oDataSlab.get_cell(floor((newPosition.x-1)/3),floor(newPosition.y/3))][Slabs.IS_SOLID] == true : id.locationX -= 0.25
				if Slabs.data[oDataSlab.get_cell(floor(newPosition.x/3),floor((newPosition.y+1)/3))][Slabs.IS_SOLID] == true : id.locationY += 0.25
				if Slabs.data[oDataSlab.get_cell(floor(newPosition.x/3),floor((newPosition.y-1)/3))][Slabs.IS_SOLID] == true : id.locationY -= 0.25
			
			# Whether the object is "Attached to tile" or not.
			if id.subtype in [2, 5, 7, 9,10,40,41,42, 50, 57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85, 126, 128]:
				id.sensitiveTile = (floor(newPosition.y/3) * 85) + floor(newPosition.x/3)
			else:
				id.sensitiveTile = 65535 # "None"
			
		Things.TYPE.CREATURE:
			id.creatureLevel = oPlacingSettings.creatureLevel
		Things.TYPE.EFFECT:
			id.effectRange = oPlacingSettings.effectRange
			id.sensitiveTile = (floor(newPosition.y/3) * 85) + floor(newPosition.x/3)
		Things.TYPE.TRAP:
			pass
		Things.TYPE.DOOR:
			id.doorLocked = oPlacingSettings.doorLocked
			if newSubtype == 0: id.subtype = 1 #Depending on whether it was placed via autoslab or a hand placed Thing object.
			match slabID:
				Slabs.WOODEN_DOOR_1:
					id.subtype = 1
					id.doorOrientation = 1
				Slabs.WOODEN_DOOR_2:
					id.subtype = 1
					id.doorOrientation = 0
				Slabs.BRACED_DOOR_1:
					id.subtype = 2
					id.doorOrientation = 1
				Slabs.BRACED_DOOR_2:
					id.subtype = 2
					id.doorOrientation = 0
				Slabs.IRON_DOOR_1:
					id.subtype = 3
					id.doorOrientation = 1
				Slabs.IRON_DOOR_2:
					id.subtype = 3
					id.doorOrientation = 0
				Slabs.MAGIC_DOOR_1:
					id.subtype = 4
					id.doorOrientation = 1
				Slabs.MAGIC_DOOR_2:
					id.subtype = 4
					id.doorOrientation = 0
	
	add_child(id)
	print('Thing placed in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	# Warnings
	if id.thingType == Things.TYPE.OBJECT:
		if id.subtype == 10:
			if slabID != Slabs.HATCHERY:
				oWarning.give_warning("Chicken won't appear unless placed inside a Hatchery. Place an Egg instead.")
		if id.subtype in [52,53,54,55,56]:
			if slabID != Slabs.TREASURE_ROOM:
				oWarning.give_warning("Treasury Gold won't appear unless placed inside a Treasure Room.")

func spawn(xSlab, ySlab, slabID, ownership, subtile, tngObj): # Spawns from tng file
	var id = thingScn.instance()
	id.data9 = 0
	id.data10 = 0
	id.data11 = 0
	id.data12 = 0
	id.data13 = 0
	id.data14 = 0
	id.data15 = 0
	id.data16 = 0
	id.data17 = 0
	id.data18 = 0
	id.data19 = 0
	id.data20 = 0
	
	var subtileY = subtile/3
	var subtileX = subtile-(subtileY*3)
	id.locationX = ((xSlab*3) + subtileX) + tngObj[3]
	id.locationY = ((ySlab*3) + subtileY) + tngObj[4]
	id.locationZ = tngObj[5]
	id.sensitiveTile = (ySlab * 85) + xSlab
	id.thingType = tngObj[6]
	id.subtype = tngObj[7]
	id.ownership = ownership
	
	if id.thingType == Things.TYPE.EFFECT:
		id.effectRange = tngObj[8]
	
	if slabID == Slabs.GUARD_POST:
		if tngObj[7] == 115: # Guard Flag (Red)
			match ownership:
				0: pass # Red
				1: id.subtype = 116 # Blue
				2: id.subtype = 117 # Green
				3: id.subtype = 118 # Yellow
				4: id.queue_free() # White
				5: id.subtype = 119 # None
	elif slabID == Slabs.DUNGEON_HEART:
		if tngObj[7] == 111: # Heart Flame (Red)
			match ownership:
				0: pass # Red
				1: id.subtype = 120 # Blue
				2: id.subtype = 121 # Green
				3: id.subtype = 122 # Yellow
				4: id.queue_free() # White
				5: id.queue_free() # None
	
	add_child(id)
	
#	if slabID == Slabs.WALL_WITH_TORCH or slabID == Slabs.EARTH_WITH_TORCH:
#
#		var scene = preload('res://scenes/TorchPartnerArrow.tscn')
#		var partnerArrow = scene.instance()
#		#partnerArrow.position = Vector2(xSlab*96, ySlab*96)
#
#		var oSlabPlacement = Nodelist.list["oSlabPlacement"]
#		match Nodelist.list["oSlabPlacement"].calculate_torch_side(xSlab, ySlab):
#			0: partnerArrow.texture = preload("res://Art/torchdir0.png")
#			1: partnerArrow.texture = preload("res://Art/torchdir1.png")
#			2: partnerArrow.texture = preload("res://Art/torchdir2.png")
#			3: partnerArrow.texture = preload("res://Art/torchdir3.png")
#		id.add_child(partnerArrow)

func delete_all_objects_on_slab(xSlab, ySlab):
	for id in get_tree().get_nodes_in_group("Instance"):
		if id.locationX >= xSlab*3 and id.locationX < (xSlab+1) * 3 and id.locationY >= ySlab*3 and id.locationY < (ySlab+1) * 3:
			id.queue_free()

func get_node_of_group_on_subtile(nodegroup, xSubtile, ySubtile):
	for id in get_tree().get_nodes_in_group(nodegroup):
		if id.is_queued_for_deletion() == false:
			if id.locationX >= floor(xSubtile) and id.locationX < floor(xSubtile)+1 and id.locationY >= floor(ySubtile) and id.locationY < floor(ySubtile)+1:
				return id
	return null

#func delete_objects_on_subtile(xSubtile,ySubtile):
#	for id in get_tree().get_nodes_in_group("Thing"):
#		if id.locationX >= floor(xSubtile) and id.locationX < ceil(xSubtile) and id.locationY >= floor(ySubtile) and id.locationY < ceil(ySubtile):
#			id.queue_free()

#func delete_objects_on_subtile(checkPos):
#	checkPos += Vector2(0.5,0.5)
#	var space = get_world_2d().direct_space_state
#	for i in space.intersect_point(global_transform.translated(checkPos).get_origin(), 32, [], 0x7FFFFFFF, true, true):
#		if i["collider"].get_parent().is_in_group("Thing"):
#			i.queue_free()

func delete_attached_objects_on_slab(xSlab, ySlab):
	
	# Figure out how to make this faster
	# Objects like torches are placed off the slab, their sensitiveTile needs to be checked.
	
	var groupName = 'attachedtotile_'+str((ySlab*85)+xSlab)
	if groupName == "attachedtotile_0": return # This fixes an edge case issue with Spinning Keys being destroyed if you click the top left corner
	for id in get_tree().get_nodes_in_group(groupName):
		#id.position = Vector2(-32767,-32767)
		#id.remove_child()
		id.queue_free()

#			if oDkSlabThings.tngObject[idx][8] != 0:
#				var id = oDkSlabThings.tngObject[idx][7]
#				print(Things.DATA_OBJECT[id][Things.NAME] + ". Unknown value: " + str(oDkSlabThings.tngObject[idx][8]))

func get_free_hero_gate_number():
	var listOfHeroGateNumbers = []
	for id in get_tree().get_nodes_in_group("Thing"):
		if id.thingType == Things.TYPE.OBJECT and id.subtype == 49:
			listOfHeroGateNumbers.append(id.herogateNumber)
	
	var newNumber = 1
	while true:
		if newNumber in listOfHeroGateNumbers:
			newNumber += 1
		else:
			return newNumber

func get_free_action_point_number():
	var listOfpointNumbers = []
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		listOfpointNumbers.append(id.pointNumber)
	
	var newNumber = 1
	while true:
		if newNumber in listOfpointNumbers:
			newNumber += 1
		else:
			return newNumber


#var ts = Constants.TILE_SIZE
		#delete_within_range(ts*3, Vector2(cursorTile.x*ts,cursorTile.y*ts)+Vector2(ts/2,ts/2))

#func delete_within_range(withinRange, sourcePosition):
#	var rect = RectangleShape2D.new()
#	rect.extents = Vector2(withinRange/2, withinRange/2)
#
#	var query = Physics2DShapeQueryParameters.new()
#	query.set_shape(rect)
#	query.transform = oInstances.global_transform.translated(sourcePosition)
#	query.collide_with_areas = true
#
#	var space = oInstances.get_world_2d().direct_space_state
#	for i in space.intersect_shape(query,9999999):
#		var thingId = i["collider"].get_parent()
#		if thingId.is_in_group("Thing"):
#			thingId.queue_free()



#func torch_within_range(withinRange, sourcePosition):
#	var rect = RectangleShape2D.new()
#	rect.extents = Vector2(withinRange/2, withinRange/2)
#
#	var query = Physics2DShapeQueryParameters.new()
#	query.set_shape(rect)
#	query.transform = oInstances.global_transform.translated(sourcePosition)
#	query.collide_with_areas = true
#
#	var space = oInstances.get_world_2d().direct_space_state
#	for i in space.intersect_shape(query,99999999):
#		var thingId = i["collider"].get_parent()
#		if thingId.is_in_group("Thing"):
#			if thingId.subtype == 2 and thingId.thingType == Things.TYPE.OBJECT:
#				return true
#	return false