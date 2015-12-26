extends Spatial


const SPEED = 5
const GRAVITY = -9.8

var camera
var lastMousePos
var currentMousePos = Vector2(0, 0)

var destinationRotation = Vector2(0, 0)
var currentRotation = Vector2(0, 0)

var velocity = Vector3(0, 0, 0)

func _ready():
	camera = get_node("cam_pitch")
	set_process_input(true)
	set_process(true)

func _process(delta):
	var diffRotation = (destinationRotation - currentRotation)*15*delta
	currentRotation += diffRotation
	set_rotation(Vector3(0, currentRotation.x, 0))
	camera.set_rotation(Vector3(currentRotation.y, 0, 0))

func _input(event):
	if event.type==InputEvent.MOUSE_MOTION:
		# Handle player rotation
		lastMousePos = currentMousePos
		currentMousePos = event.pos

		var diffMousePos = currentMousePos - lastMousePos
		destinationRotation -= diffMousePos/500
	elif event.is_action_released("ui_cancel"):
		get_tree().quit()

func _enter_tree():
	pass#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
