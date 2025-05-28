extends WindowDialog
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oReloaderPathLabel = Nodelist.list["oReloaderPathLabel"]
onready var oReloaderPathPackLabel = Nodelist.list["oReloaderPathPackLabel"]

onready var oExportTmapaDatDialog = Nodelist.list["oExportTmapaDatDialog"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oChooseTmapaFileDialog = Nodelist.list["oChooseTmapaFileDialog"]
onready var oRNC = Nodelist.list["oRNC"]
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oExportTmapaButton = Nodelist.list["oExportTmapaButton"]
onready var oMapProperties = Nodelist.list["oMapProperties"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oEditor = Nodelist.list["oEditor"]


var filelistfile = File.new()
var fileListFilePath = ""
var editingImg = Image.new()
var fileTimes = []
var partsList = []
var modifiedCheck = File.new()
var getPackFolder = ""

func _ready():
	editingImg.create(8*32, 68*32, false, Image.FORMAT_RGB8)
	oExportTmapaButton.disabled = true
	oExportTmapaButton.set_tooltip("A filelist pack must be loaded first in order to export")
	oReloaderPathLabel.text = ""
	oReloaderPathPackLabel.text = ""

func reloader_loop():
	if fileListFilePath != "":
		execute()
	yield(get_tree().create_timer(0.25), "timeout")
	reloader_loop()


func _on_TextureEditingHelpButton_pressed():
	var helptxt = ""
	helptxt += "After you load a tileset, a bunch of .PNG files will be saved to your hard drive. Edit these files in your favourite image editor.\n"
	helptxt += "Unearth will actively reload the textures in real-time as you edit and save those .PNGs. So any edits you make will be shown in real-time in Unearth. This applies to the 3D view too, so press Spacebar while in the 3D view to stop the camera from moving.\n"
	oMessage.big("Help",helptxt)


func initialize_filelist():
	partsList.clear()
	
	if filelistfile.open(fileListFilePath, File.READ) != OK: return
	
	var flContent = filelistfile.get_as_text()
	filelistfile.close()
	
	partsList = Array(flContent.split('\n', false))
	partsList.pop_front() # remove the first line: textures_pack_000	8	68	32	32
	
	for i in partsList.size():
		partsList[i] = Array(partsList[i].split('\t', false))
		#print(partsList[i].size())
	
	# Initialize fileTimes
	if fileTimes.size() < partsList.size():
		fileTimes.resize(partsList.size()) # This is bigger than it needs to be but that doesn't matter
		for i in fileTimes.size():
			fileTimes[i] = -1
	
	# Change current map's Tileset setting if it's a different one
	var fn = get_tmapa_filename()
	if oDataLevelStyle.data != int(fn):
		oDataLevelStyle.data = int(fn)
		oTMapLoader.apply_texture_pack()
		oEditor.mapHasBeenEdited = true
		oMessage.quick("Changed map's Tileset to show what you're currently editing")


func execute():
	print("execute")
	var CODETIME_START = OS.get_ticks_msec()
	
	var anyChangesWereMade = false
	var imgLoader = Image.new()
	var baseDir = fileListFilePath.get_base_dir()
	var partsModified = []
	
	
	for i in partsList.size():
		var path = baseDir.plus_file(partsList[i][0])
		if modifiedCheck.get_modified_time(path) != fileTimes[i]:
			partsModified.append(i)
	
	
	for i in partsModified:
		var path = baseDir.plus_file(partsList[i][0])
		fileTimes[i] = modifiedCheck.get_modified_time(path) # Must be in a separate loop to the if check for modified time
		
		#print("A FILE WAS CHANGED")
		
		var x = int(partsList[i][1])
		var y = int(partsList[i][2])
		var w = int(partsList[i][3])
		var h = int(partsList[i][4])
		imgLoader.load(path)
		imgLoader.convert(Image.FORMAT_RGB8)
		
		var destY = i/8
		var destX = i-(destY*8)
		
		var destination = Vector2(destX*32,destY*32)
		editingImg.lock()
		imgLoader.lock()
		for pixelY in imgLoader.get_height(): # This is different than using the w and h variables
			for pixelX in imgLoader.get_width():
				var col = imgLoader.get_pixel(pixelX,pixelY)
				if oReadPalette.dictionary.has(col) == false:
					imgLoader.set_pixel(pixelX,pixelY, Color(255,0,255))
		
		editingImg.blit_rect(imgLoader,Rect2(x,y,w,h), destination)
		imgLoader.unlock()
		editingImg.unlock()
		anyChangesWereMade = true
	
	if anyChangesWereMade == true:
		print("anyChangesWereMade")
		var baseName = get_tmapa_filename()
		var tmapNumber = int(baseName.to_int())
		oTMapLoader.load_image_into_cache(editingImg, tmapNumber, baseName)
		oTMapLoader.apply_texture_pack()
	
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

#	var imgTex = ImageTexture.new()
#	imgTex.create_from_image(img,0)
#	$"../TextureRect".texture = imgTex



#func _on_LoadFilelistButton_pressed():
#	Utils.popup_centered(oChooseFileListFileDialog)
#	oChooseFileListFileDialog.current_dir = Settings.unearth_path.plus_file("textures").plus_file("")
#	oChooseFileListFileDialog.current_path = Settings.unearth_path.plus_file("textures").plus_file("")
#	oChooseFileListFileDialog.current_file = "filelist_tmapa000.txt"


func _on_ModifyTexturesButton_pressed():
	match OS.get_name():
		"Windows": OS.shell_open(getPackFolder.replace("/", "\\"))
		"X11": OS.shell_open(getPackFolder)

func _on_ExportTmapaButton_pressed():
	Utils.popup_centered(oExportTmapaDatDialog)
	oExportTmapaDatDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportTmapaDatDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportTmapaDatDialog.current_file = get_tmapa_filename()+".dat"

func _on_CreateFilelistButton_pressed():
	Utils.popup_centered(oChooseTmapaFileDialog)
	oChooseTmapaFileDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oChooseTmapaFileDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oChooseTmapaFileDialog.current_file = "tmapa000.dat"

#	yield(get_tree(),'idle_frame')
#	print(oChooseFileListFileDialog.get_vbox().get_child(2).get_child(0))
#	var tree = oChooseFileListFileDialog.get_vbox().get_child(2).get_child(0)
#	tree.visible = false
#	for i in 100:
#		tree.visible = false
#		yield(get_tree(),'idle_frame')
#	var treeSelected = tree.get_selected()
#	var get_selected_column = tree.get_selected_column()
#	var get_edited = tree.get_edited()
#	tree.scroll_to_item(treeSelected)


func get_tmapa_filename():
	return fileListFilePath.right(fileListFilePath.length()-12).to_lower().trim_suffix(".txt")


func _on_ExportTmapaDatDialog_file_selected(path):
	var buffer = StreamPeerBuffer.new()
	#print(oTMapLoader.paletteData)
	var CODETIME_START = OS.get_ticks_msec()
	
	editingImg.lock()

	for y in 68*32:
		for x in 8*32:
			var col = editingImg.get_pixel(x,y)
			var R = floor(col.r8/4.0)*4
			var G = floor(col.g8/4.0)*4
			var B = floor(col.b8/4.0)*4
			
			var roundedCol = Color8(R,G,B)
			
			var paletteIndex = 255 # Purple should show easier as an issue to debug
			if oReadPalette.dictionary.has(roundedCol) == true:
				paletteIndex = oReadPalette.dictionary[roundedCol]
#			else:
#				print(str(roundedCol.r) + ', '+str(roundedCol.g) + ', '+str(roundedCol.b) + ', '+str(roundedCol.a))
			
			buffer.put_8(paletteIndex)
	editingImg.unlock()
	
	var file = File.new()
	file.open(path,File.WRITE)
	file.store_buffer(buffer.data_array)
	file.close()
	
	oMessage.quick("Exported : " + path)
	
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')



var user_cancelled = false


func _on_ChooseTmapaFileDialog_file_selected(path):
	var sourceImg = oTMapLoader.convert_tmapa_to_image(path)
	if sourceImg == null: return
	var CODETIME_START = OS.get_ticks_msec()
	
	var outputDir = Settings.unearth_path.plus_file("textures")
	
	var filelistFile = File.new()
	if filelistFile.open(Settings.unearthdata.plus_file("exportfilelist.txt"), File.READ) != OK:
		return
	
	# Split the Filelist into usable arrays
	
	var flContent = filelistFile.get_as_text()
	var numberString = path.get_file().get_basename().trim_prefix('tmapa')
	flContent = flContent.replace("subdir", "pack" + numberString)
	flContent = flContent.replace("textures_pack_number", "textures_pack_" + numberString)
	filelistFile.close()
	
	var lineArray = Array(flContent.split('\n', false))
	lineArray.pop_front() # For the array remove the first line: textures_pack_number	8	68	32	32
	
	for i in lineArray.size():
		lineArray[i] = Array(lineArray[i].split('\t', false))
	
	# The strings can be out of order, so create a dictionary that looks like this - "subdir/earth_standard.png" : []
	# Calculate the maxWidth and maxHeight by figuring out the largest destination positions that are in the list for each string
	var imageDictionary = {}
	for i in lineArray.size():
		var localPath = lineArray[i][0]
		var posX = int(lineArray[i][1])+32
		var posY = int(lineArray[i][2])+32
		
		if imageDictionary.has(localPath) == false:
			imageDictionary[localPath] = [0, 0]
		
		imageDictionary[localPath][0] = max(posX, imageDictionary[localPath][0])
		imageDictionary[localPath][1] = max(posY, imageDictionary[localPath][1])
	
	
	# Replace the width and height array with an Image.
	for i in imageDictionary:
		var createNewImage = Image.new()
		var w = imageDictionary[i][0]
		var h = imageDictionary[i][1]
		createNewImage.create(w,h,false,Image.FORMAT_RGB8)
		imageDictionary[i] = createNewImage
	
	# Make images
	for i in lineArray.size():
		var sourceTileY = i / 8
		var sourceTileX = i - (sourceTileY * 8)
		
		var localPath = lineArray[i][0]
		var destX = lineArray[i][1]
		var destY = lineArray[i][2]
#		var width = lineArray[i][3]
#		var height = lineArray[i][4]
		var createNewImage = imageDictionary[localPath]
		createNewImage.lock()
		createNewImage.blit_rect(sourceImg, Rect2(sourceTileX*32,sourceTileY*32, 32,32), Vector2(destX, destY))
		createNewImage.unlock()
	
	# Save PNGs (separate loop so we're iterating once on each file, rather than every single filelist line)
	
	var checkForExistingFolderOnce = 0
	
	var dir = Directory.new()
	for localPath in imageDictionary:
		
		var savePath = outputDir.plus_file(localPath)
		var packFolder = savePath.get_base_dir()
		
		
		if dir.dir_exists(packFolder) == false:
			dir.make_dir_recursive(packFolder)
		else:
			if checkForExistingFolderOnce == 0:
				var confirmDialog = ConfirmationDialog.new()
				confirmDialog.dialog_text = "The folder of .PNGs already exists, they will be overwritten: \n" + packFolder + "\n\n If overwriting the files here causes you data loss then Cancel and go backup the folder."
				confirmDialog.window_title = "Confirm File Replacement"
				confirmDialog.popup_exclusive = true
				confirmDialog.connect("confirmed", self, "_on_confirmation_confirmed")
				confirmDialog.connect("popup_hide", self, "_on_confirmation_hide")
				add_child(confirmDialog)
				confirmDialog.popup_centered()
				yield(confirmDialog, "visibility_changed")
				yield(get_tree(),'idle_frame')
				if user_cancelled == true:
					return
		
		checkForExistingFolderOnce = 1
		
		var createNewImage = imageDictionary[localPath]
		createNewImage.save_png(savePath)
		oMessage.quick("Exported : textures/" + localPath)
		
		getPackFolder = packFolder
	
	oReloaderPathPackLabel.text = getPackFolder
	
	save_new_filelist_txt_file(flContent, numberString, outputDir) # This goes after the "make_dir_recursive" commands
	print('Exported Filelist in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func _on_confirmation_confirmed():
	user_cancelled = false

func _on_confirmation_hide():
	if not user_cancelled:
		user_cancelled = true


func save_new_filelist_txt_file(flContent, numberString, outputDir):
	var file = File.new()
	var path = outputDir.plus_file("filelist_tmapa"+numberString+".txt")
	file.open(path, File.WRITE)
	file.store_string(flContent)
	file.close()
	
	fileListFilePath = path
	oReloaderPathLabel.text = path
	
	oExportTmapaButton.disabled = false
	oExportTmapaButton.set_tooltip("")
	
	initialize_filelist()
	
	reloader_loop()



#	for y in 68:
#		for x in 8:
#
#			pass
#editingImg.lock()
#	var imgLoader = Image.new()
#	var CODETIME_START = OS.get_ticks_msec()
#	for i in lineArray.size():
#		#if i == 40:
#			#print(lineArray[i])
#			var path = lineArray[i][0]
#			var x = lineArray[i][1]
#			var y = lineArray[i][2]
#			var width = lineArray[i][3]
#			var height = lineArray[i][4]
#			imgLoader.load(baseDir.plus_file(path))
#
#			var destY = i/8
#			var destX = i-(destY*8)
#
#			var destination = Vector2(destX*32,destY*32)
#
#			editingImg.blit_rect(imgLoader,Rect2(x,y,width,height), destination)
#			#for z in lineArray[i]:
#			#	print(z)
#	editingImg.unlock()


