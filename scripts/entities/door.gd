# The gateway to new worlds.
extends Spatial

var animations

var cam_dest
var cam_look_dest

func _ready():
	animations = get_node("door_model/AnimationPlayer")
	
	cam_dest = get_node("cam_dest")
	cam_look_dest = get_node("cam_look_dest")
	
	animations.set_current_animation("Double Opening")

func _on_Area_body_enter_shape( body_id, body, body_shape, area_shape ):
	if globals.is_character(body):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop_all()
			animations.play("Double Opening", -1)
			animations.seek(pos)
		elif area_shape == 1: # Loading zone
			globals.set_scene("test_level1")
		elif area_shape == 2: # Camera zone
			take_camera()

func _on_Area_body_exit_shape( body_id, body, body_shape, area_shape ):
	if globals.is_character(body):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop_all()
			animations.play("Double Opening", -1, -1)
			animations.seek(pos)
		elif area_shape == 2: # Camera zone
			release_camera()

func take_camera():
	globals.camera.set_camera_system(cam_dest, cam_look_dest, 0.08)

func release_camera():
	globals.camera.activate_player_camera()
