# This script controls the position of the 3D camera.
extends Spatial


var cam_system = null

func _ready():
	set_process(true)

func _process(delta):
	# If there's a camera system set, snap the camera to it.
	if cam_system != null:
		set_global_transform(cam_system.get_global_transform())

func set_camera_system(node):
	cam_system = node

func remove_camera_system(node):
	if cam_system == node:
		cam_system = null
