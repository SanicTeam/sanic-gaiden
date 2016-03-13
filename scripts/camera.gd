# This script takes care of rotating the camera system and following the player.

extends Spatial


const MAX_CAM_PITCH = deg2rad(21)
const MIN_CAM_PITCH = deg2rad(-78)

var cam_pitch
var cam_pod
var sanic
var lastMousePos
var currentMousePos = Vector2(0, 0)

var destinationRotation = Vector2(0, 0)
var currentRotation = Vector2(0, 0)

var velocity = Vector3(0, 0, 0)

func _ready():
	cam_pitch = get_node("cam_pitch")
	cam_pod = cam_pitch.get_node("cam/cam_pod")
	sanic = get_parent().get_node("sanic")
	set_process_input(true)
	set_process(true)

func _process(delta):
	var diffRotation = (destinationRotation - currentRotation)*15*delta
	currentRotation += diffRotation
	set_rotation(Vector3(0, currentRotation.x, 0))
	cam_pitch.set_rotation(Vector3(currentRotation.y, 0, 0))
	
	# Make the camera movement more stiff when it's closer to the player
	var lerp_multiplier = 16 - cam_pod.get_camera_compress()*2
	# Ease into the destination translation
	set_translation(get_translation().linear_interpolate(sanic.get_translation(), lerp_multiplier*delta))

func _input(event):
	if event.type==InputEvent.MOUSE_MOTION:
		# Handle camera rotation
		lastMousePos = currentMousePos
		currentMousePos = event.pos

		var diffMousePos = currentMousePos - lastMousePos
		destinationRotation -= diffMousePos/500
		destinationRotation.y = min(MAX_CAM_PITCH, max(MIN_CAM_PITCH, destinationRotation.y))
	elif event.is_action_released("ui_cancel"):
		get_tree().quit()

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
