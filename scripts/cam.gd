# This script controls the position and rotation of the 3D camera.
extends Spatial

const UP = Vector3(0, 1, 0)
const RIGHT = Vector3(0, 0, 1)

var cam

var cam_system = null
var cam_system_look = null

func _ready():
	cam = get_node("Camera")
	set_process(true)

func _process(delta):
	# If there's a camera system set, snap the camera to it.
	if cam_system != null:
		set_global_transform(cam_system.get_global_transform())
		set_rotation(Vector3(0, 0, 0))
	
	if cam_system_look != null:
		cam.look_at(cam_system_look.get_global_transform().origin, UP)

func set_camera_system(cam_pos, look_pos):
	cam_system = cam_pos
	cam_system_look = look_pos

func get_camera_system():
	return {'pos': cam_system, 'look': cam_system_look}

func remove_camera_system(cam_pos):
	if cam_system == cam_pos:
		cam_system = null
		cam_system_look = null

func get_global_look():
	return cam_system_look.get_global_transform().origin - cam_system.get_global_transform().origin

func get_global_yaw():
	if cam_system == null:
		return 0
	
	var right = get_global_look().cross(UP).normalized()
	var forward = right.cross(UP)
	
	return acos(RIGHT.dot(forward))*sign(forward.x)

func get_global_pitch():
	if cam_system == null:
		return 0
	
	return get_global_look().normalized().rotated(UP, -get_global_yaw()).x
