extends KinematicBody
onready var oCamera3D = Nodelist.list["oCamera3D"]
onready var oGame3D = Nodelist.list["oGame3D"]
onready var oRayCastBlockMap = Nodelist.list["oRayCastBlockMap"]
onready var oHead = Nodelist.list["oHead"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oPropertiesWindow = Nodelist.list["oPropertiesWindow"]
onready var oUi = Nodelist.list["oUi"]

var mouseSensitivity = 0.1
var direction = Vector3()
var velocity = Vector3()
var acceleration = 10
var speed = 0.5
var speed_multiplier = 1
var movement = Vector3()

#var scnProjectile = preload("res://Scenes/Projectile.tscn")

onready var oCamera2D = $'../../Game2D/Camera2D'


func _input(event):
	if oEditor.currentView != oEditor.VIEW_3D: return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * mouseSensitivity
		oHead.rotation_degrees.x = clamp(oHead.rotation_degrees.x - event.relative.y * mouseSensitivity, -90, 90)
	
	speed_multiplier = 1
	if Input.is_key_pressed(KEY_SHIFT):
		speed_multiplier = 10
	
	if Input.is_action_just_pressed("change_3d_mouse_mode"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			oUi.switch_to_3D_overhead()
		else:
			oUi.switch_to_1st_person()
	
	if Input.is_action_just_pressed("mouse_left"):
		pass
	
	direction = Vector3()
	if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
		translation.y -= 3
	if Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
		translation.y += 3
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.z = -1
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.z = 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x = -1
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x = 1
	direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, rotation.y)

func _physics_process(delta):
	if oEditor.currentView != oEditor.VIEW_3D: return
	
	velocity = velocity.linear_interpolate(direction * speed * speed_multiplier, acceleration * delta)
	movement = velocity
	#movement = move_and_slide(movement, Vector3.UP)
	movement = move_and_collide(movement)
