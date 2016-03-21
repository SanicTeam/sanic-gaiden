extends Spatial

var globals
var animations

var cam_pos
var cam_dest

var previous_cam_system

func _ready():
	globals = get_tree().get_root().get_node("globals")
	animations = get_node("door_model/AnimationPlayer")
	
	cam_pos = get_node("cam_pos")
	cam_dest = get_node("cam_dest")
	
	animations.set_current_animation("Double Opening")
	
	set_process(true)

func _process(delta):
	cam_pos.set_translation(cam_pos.get_translation().linear_interpolate(cam_dest.get_translation(), 4*delta))
	cam_pos.set_rotation(cam_pos.get_rotation().linear_interpolate(cam_dest.get_rotation(), 4*delta))

func _on_Area_body_enter_shape( body_id, body, body_shape, area_shape ):
	if body extends preload("res://scripts/player/sanic.gd"):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop_all()
			animations.play("Double Opening", -1)
			animations.seek(pos)
		elif area_shape == 1: # Loading zone
			globals.set_scene("res://levels/level2.scn")
		elif area_shape == 2: # Camera zone
			print("Camera zone enter")
			previous_cam_system = globals.camera.cam_system
			cam_pos.set_global_transform(previous_cam_system.get_global_transform())
			globals.camera.set_camera_system(cam_pos)

func _on_Area_body_exit_shape( body_id, body, body_shape, area_shape ):
	if body extends preload("res://scripts/player/sanic.gd"):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop_all()
			animations.play("Double Opening", -1, -1)
			animations.seek(pos)
		elif area_shape == 2: # Camera zone
			globals.camera.set_camera_system(previous_cam_system)
