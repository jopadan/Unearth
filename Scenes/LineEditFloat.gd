extends LineEdit

func _ready():
	connect("focus_exited", self, "_on_focus_exited")

func _on_focus_exited():
	text = String(int(text))
	#text = text.pad_decimals(2)
