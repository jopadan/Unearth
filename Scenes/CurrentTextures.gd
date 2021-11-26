extends Node
# 1. Read tmapa files from DK /data/ directory. Must always be done in case there are changes.
# Keep a list of date modified dates along with png filenames in Settings.
# 2. Scan /unearthdata/ for png files, making sure they match the dates in array of the original files
# 3. Load png files into cachedTextures, load cachedTextures into shaders.
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oQuickMessage = Nodelist.list["oQuickMessage"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oGame = Nodelist.list["oGame"]
onready var oRNC = Nodelist.list["oRNC"]
const IMAGE_FORMAT = Image.FORMAT_RGB8
const textureWidth = 256
const textureHeight = 2176
enum {
	LOADING_NOT_STARTED
	LOADING_IN_PROGRESS
	LOADING_SUCCESS
}
var CODETIME_START

var paletteData = []
var REMEMBER_TMAPA_PATHS = {}
var cachedTextures = [] # Dynamically created based on what's in REMEMBER_TMAPA_PATHS
var texturesLoadedState = LOADING_NOT_STARTED


func _notification(what: int):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		if texturesLoadedState != LOADING_IN_PROGRESS: # Don't do anything if it's already doing something
			# If anything differs, then reload
			if REMEMBER_TMAPA_PATHS.hash() != scan_dk_data_directory().hash():
				start()
	#		else:
	#			print('Nothing differs')


func _on_ReloadTextureMapsButton_pressed():
	if texturesLoadedState != LOADING_IN_PROGRESS: # Don't do anything if it's already doing something
		oQuickMessage.message("Reloading texture maps")
		REMEMBER_TMAPA_PATHS.clear()
		start()


func LOAD_TMAPA_PATHS_FROM_SETTINGS(dictionaryFromSettings):
	REMEMBER_TMAPA_PATHS = dictionaryFromSettings


func start():
	texturesLoadedState = LOADING_IN_PROGRESS
	paletteData = oReadPalette.readPalette(Settings.unearthdata.plus_file("palette.dat"))
	
	var newTmapaPaths = scan_dk_data_directory()
	# Check if what's in TMAPA_PATHS (loaded from Settings) differs from what's in NEW_TMAPA_PATHS
	
	if REMEMBER_TMAPA_PATHS.hash() == newTmapaPaths.hash(): # This compares dictionaries, checking if date modified is different or if there's a different number of file entries
		#print("No changes.")
		pass
	else:
		# They differ in either file count or date
		
		# Remove any old entries
		for path in REMEMBER_TMAPA_PATHS.keys(): # Doing .keys() should allow erasing while iterating I think
			if newTmapaPaths.has(path) == false:
				REMEMBER_TMAPA_PATHS.erase(path)
		
		# Look for any changes
		for path in newTmapaPaths:
			if REMEMBER_TMAPA_PATHS.has(path) == true:
				if newTmapaPaths[path] != REMEMBER_TMAPA_PATHS[path]: # Check if date differs
					create_png_cache_file(path)
			else:
				create_png_cache_file(path)
			yield(get_tree(), "idle_frame")
	
	var err = loadCachedTextures(newTmapaPaths)
	match err:
		OK:
			#print(cachedTextures)
			Settings.set_setting("REMEMBER_TMAPA_PATHS", newTmapaPaths) # Do this last
			#oQuickMessage.message("Texture cache loaded")
			texturesLoadedState = LOADING_SUCCESS
			# This is important to do here if updating textures while a map is already open
			if oDataSlab.get_cell(0,0) != TileMap.INVALID_CELL:
				set_default_texture_pack(oDataLevelStyle.data)
		FAILED:
			oQuickMessage.message("Cache failed loading")
			newTmapaPaths.clear()
			REMEMBER_TMAPA_PATHS.clear()
			texturesLoadedState = LOADING_NOT_STARTED
			start() # Redo


func scan_dk_data_directory():
	var path = oGame.DK_DATA_DIRECTORY
	var dictionary = {}
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() == false:
				if fileName.to_upper().begins_with("TMAPA") == true: # Get file regardless of case (case insensitive)
					if fileName.to_upper().begins_with("TMAPANIM") == false:
						var getModifiedTime = File.new().get_modified_time(path.plus_file(fileName))
						dictionary[path.plus_file(fileName)] = getModifiedTime
			fileName = dir.get_next()
	return dictionary


func create_png_cache_file(tmapaDkOriginalPath):
	if oRNC.checkForRncCompression(tmapaDkOriginalPath) == true:
		oRNC.decompress(tmapaDkOriginalPath,tmapaDkOriginalPath)
	
	var file = File.new()
	if file.open(tmapaDkOriginalPath, File.READ) == OK:
		CODETIME_START = OS.get_ticks_msec()
		
		var img = Image.new()
		img.create(textureWidth, textureHeight, false, IMAGE_FORMAT)
		file.seek(0)
		img.lock()
		for y in textureHeight:
			for x in textureWidth:
				var paletteIndex = file.get_8()
				img.set_pixel(x,y,paletteData[paletteIndex])
		img.unlock()
		
		#img.load("1024x1024.png")
		#img.load("originalmapa.png")
		
		
		var imgTex = ImageTexture.new()
		imgTex.create_from_image(img, Texture.FLAG_MIPMAPS + Texture.FLAG_ANISOTROPIC_FILTER)
		var constructFilename = tmapaDkOriginalPath.get_file().get_basename().to_lower()
		constructFilename += ".png"
		ResourceSaver.save(Settings.unearthdata.plus_file(constructFilename), imgTex)
		
		oQuickMessage.message("Caching texture maps : unearthdata".plus_file(constructFilename))
		print('Created cache file in: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	else:
		print("Failed to open file.")
	file.close()


func loadCachedTextures(newTmapaPaths):
	cachedTextures.clear()
	
	CODETIME_START = OS.get_ticks_msec()
	
	var keys = newTmapaPaths.keys()
	
	for i in keys.size():
		var fn = keys[i].get_file().get_basename().to_lower()
		var cachePath = Settings.unearthdata.plus_file(fn + ".png")
		
		if File.new().file_exists(cachePath) == true:
			var tmapaNumber = int(fn.to_lower().trim_prefix("tmapa")) # Get the specific position to create within the array
			
			# Fill all array positions, in case a tmapa00#.dat file is deleted
			while cachedTextures.size() <= tmapaNumber:
				cachedTextures.append(null)
			
			# Need to call load() on an Image class if I want the save and load to work correctly (otherwise it saves too fast and doesn't load or something)
			var img = Image.new()
			img.load(cachePath)
			
			var twoTexArr = convertImgToTwoTextureArrays(img)
			cachedTextures[tmapaNumber] = twoTexArr
			#print('Loaded cache file: ' + cachePath)
		else:
			print('Cache file not found: ' + cachePath)
			cachedTextures.clear()
			return FAILED
	print('Loaded cached .png textures: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	return OK


func set_default_texture_pack(value):
	if cachedTextures[value][0] == null or cachedTextures[value][1] == null:
		oQuickMessage.message("Error: Cached textures could not be loaded. Try reloading texture maps.")
		return
	# 2D
	if oOverheadGraphics.arrayOfColorRects.size() > 0:
		oOverheadGraphics.arrayOfColorRects[0].get_material().set_shader_param("dkTextureMap_Split_A", cachedTextures[value][0])
		oOverheadGraphics.arrayOfColorRects[0].get_material().set_shader_param("dkTextureMap_Split_B", cachedTextures[value][1])
	# 3D
	if oGenerateTerrain.materialArray.size() > 0:
		oGenerateTerrain.materialArray[0].set_shader_param("dkTextureMap_Split_A", cachedTextures[value][0])
		oGenerateTerrain.materialArray[0].set_shader_param("dkTextureMap_Split_B", cachedTextures[value][1])
	
	assign_textures_to_slab_window(value)


func assign_textures_to_slab_window(value): # Called by SlabStyleWindow
	for nodeID in get_tree().get_nodes_in_group("SlabDisplay"):
		nodeID.get_material().set_shader_param("dkTextureMap_Split_A", cachedTextures[value][0])
		nodeID.get_material().set_shader_param("dkTextureMap_Split_B", cachedTextures[value][1])


# SLICE COUNT being too high is the reason TextureArray doesn't work on old PC. (NOT IMAGE SIZE, NOT MIPMAPS EITHER)
# RES files might actually take longer to generate a TextureArray from than PNG, not sure.
func convertImgToTwoTextureArrays(img):
	if img.get_format() != IMAGE_FORMAT:
		img.convert(IMAGE_FORMAT)
	
	var twoTextureArrays = [
		TextureArray.new(),
		TextureArray.new(),
	]
	var xSlices = 8
	var ySlices = 34
	var sliceWidth = 32 #img.get_width() / xSlices;
	var sliceHeight = 32 #img.get_height() / ySlices;
	twoTextureArrays[0].create(sliceWidth, sliceHeight, xSlices*ySlices, IMAGE_FORMAT, TextureLayered.FLAG_MIPMAPS)
	twoTextureArrays[1].create(sliceWidth, sliceHeight, xSlices*ySlices, IMAGE_FORMAT, TextureLayered.FLAG_MIPMAPS)
	
	for i in 2:
		var yOffset = 0
		if i == 1:
			yOffset = 34
		
		for y in ySlices:
			for x in xSlices:
				var slice = img.get_rect(Rect2(x*sliceWidth, (y+yOffset)*sliceHeight, sliceWidth, sliceHeight))
				slice.generate_mipmaps() #Important otherwise it's black when zoomed out
				twoTextureArrays[i].set_layer_data(slice, (y*xSlices)+x)
	
	return twoTextureArrays