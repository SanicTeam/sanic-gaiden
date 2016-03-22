extends Position3D

var cam_look

func _ready():
	cam_look = get_parent().get_node("cam_look")
	
	globals.camera.set_camera_system(self, cam_look)

func _exit_tree():
	globals.camera.remove_camera_system(self)
