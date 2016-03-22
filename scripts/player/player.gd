extends Spatial

var cam_base
var cam_pitch

var cam_pos
var cam_look

func _ready():
	globals.register_player(self)
	
	cam_base = get_node("cam_base")
	cam_pitch = cam_base.get_node("cam_pitch")
	
	cam_pos = cam_pitch.get_node("cam/cam_pod/cam_pos")
	cam_look = cam_pitch.get_node("cam/cam_pod/cam_look")
	
	globals.camera.activate_player_camera()
	reset_camera_system_rotation(Vector2(0, 0))

func get_camera_system():
	return {"pos": cam_pos, "look": cam_look}

func reset_camera_system_rotation(rot):
	cam_base.reset_rotation(rot)

func _exit_tree():
	globals.camera.remove_camera_system(self)
