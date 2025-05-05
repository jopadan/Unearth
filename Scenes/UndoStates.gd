extends Node

onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oThreadedSaveUndo = Nodelist.list["oThreadedSaveUndo"]
onready var oLoadingBar = Nodelist.list["oLoadingBar"]
onready var oNewMapWindow = Nodelist.list["oNewMapWindow"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]


var undo_history = []
var max_undo_states = 256
var performing_undo = false

var undo_save_queued = false

func _input(event):
	if event.is_action_pressed("undo"):
		perform_undo()


func clear_history():
	#oMessage.quick("Undo history cleared")
	undo_history.clear()
	oMenu.update_undo_availability()
	
	call_deferred("attempt_to_save_new_undo_state")


func attempt_to_save_new_undo_state(): # called by oEditor
	undo_save_queued = true


func _process(delta):
	if undo_save_queued == true:
		set_process(false)
		while true:
			if Input.is_mouse_button_pressed(BUTTON_LEFT) or \
				oLoadingBar.visible == true or \
				oNewMapWindow.currently_creating_new_map == true or \
				performing_undo == true:
					yield(get_tree(), "idle_frame")
			else:
				break
		oThreadedSaveUndo.semaphore.post()
		
		undo_save_queued = false
		set_process(true)


func on_undo_state_saved(new_state):
	if undo_history.size() >= 1 and are_states_equal(new_state, undo_history[0]):
		#oMessage.quick("Didn't add undo state as it is the same as the previous undo-state")
		return
	if undo_history.size() >= max_undo_states:
		undo_history.pop_back()
	undo_history.push_front(new_state)
	oMenu.update_undo_availability()
	
	#oMessage.quick("Undo history size: " + str(undo_history.size()) + " (test)")


func perform_undo():
	if oMapSettingsWindow.visible == true: return
	print("perform_undo")
	if performing_undo == true or undo_history.size() <= 1:
		return
	var previous_state = undo_history[1]
	if typeof(previous_state) != TYPE_DICTIONARY:
		print("Error: previous_state is not a dictionary")
		oMessage.big("Undo state error", "previous_state is not a dictionary")
		return
	
	var CODETIME_START = OS.get_ticks_msec()
	performing_undo = true
	
	oCurrentMap.clear_map()
	
	for EXT in previous_state:
		var buffer = previous_state[EXT]
		if buffer == null or !(buffer is StreamPeerBuffer):
			print("Undo state error: buffer '%s' is not a valid StreamPeerBuffer" % EXT)
			oMessage.big("Undo state error", "Buffer '%s' is not a valid StreamPeerBuffer" % EXT)
			continue
		var undotimeExt = OS.get_ticks_msec()
		oBuffers.read_buffer_for_extension(buffer, EXT)
		print(str(EXT) + ' Undotime: ' + str(OS.get_ticks_msec() - undotimeExt) + 'ms')

	oOpenMap.continue_load(oCurrentMap.path)
	undo_history.pop_front()
	oMenu.update_undo_availability()
	#oMessage.quick("Undo performed")

	if oEditor.mapHasBeenEdited == false:
		oEditor.mapHasBeenEdited = oEditor.SET_EDITED_WITHOUT_SAVING_STATE
	elif undo_history.size() <= 1:
		oEditor.mapHasBeenEdited = false
	
	print('perform_undo: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	var IDLE_FRAME_CODETIME_START = OS.get_ticks_msec()
	
	print('Idle frame (after undo): ' + str(OS.get_ticks_msec() - IDLE_FRAME_CODETIME_START) + 'ms')
	
	performing_undo = false



func are_states_equal(state1, state2): # (0ms or 1ms)
	for EXT in state1.keys():
		var buffer1 = state1[EXT]
		var buffer2 = state2.get(EXT)
		if buffer1 is StreamPeerBuffer and buffer2 is StreamPeerBuffer:
			if buffer1.data_array != buffer2.data_array:
				return false
		
		if buffer1 == null and buffer2 != null:
			return false
		if buffer1 != null and buffer2 == null:
			return false
	return true
