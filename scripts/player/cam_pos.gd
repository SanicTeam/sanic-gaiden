extends Position3D

var globals
var cam_look

func _ready():
	globals = get_tree().get_root().get_node("globals")
	cam_look = get_parent().get_node("cam_look")
	
	globals.camera.set_camera_system(self, cam_look)

func _exit_tree():
	globals.camera.remove_camera_system(self)
