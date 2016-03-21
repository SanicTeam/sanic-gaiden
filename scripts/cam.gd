# This script controls the position and rotation of the 3D camera.
extends Spatial

const UP = Vector3(0, 1, 0)

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
	
	if cam_system_look != null:
		cam.look_at(cam_system_look.get_global_transform(), UP)

func set_camera_system(cam_pos, look_pos = null):
	cam_system = cam_pos
	cam_system_look = look_pos

func remove_camera_system(cam_pos):
	if cam_system == cam_pos:
		cam_system = null
		cam_system_look = null
