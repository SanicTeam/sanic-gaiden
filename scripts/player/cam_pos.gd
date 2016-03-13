extends Position3D


var globals

func _ready():
	globals = get_tree().get_root().get_node("globals")
	globals.set_camera_system(self)
	
func _exit_tree():
	globals.set_camera_system(null)
