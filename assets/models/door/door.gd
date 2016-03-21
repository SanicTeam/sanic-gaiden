# The gateway to new worlds.
extends Spatial

var globals
var animations

var cam_pos
var cam_dest
var cam_look_pos
var cam_look_dest

var previous_cam_system

func _ready():
	globals = get_tree().get_root().get_node("globals")
	animations = get_node("door_model/AnimationPlayer")
	
	cam_pos = get_node("cam_pos")
	cam_dest = get_node("cam_dest")
	
	cam_look_pos = get_node("cam_look_pos")
	cam_look_dest = get_node("cam_look_dest")
	
	animations.set_current_animation("Double Opening")
	
	set_process(true)

func _process(delta):
	cam_pos.set_translation(cam_pos.get_translation().linear_interpolate(cam_dest.get_translation(), 2*delta))
	cam_look_pos.set_translation(cam_look_pos.get_translation().linear_interpolate(cam_look_dest.get_translation(), 2*delta))

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
			take_camera()

func _on_Area_body_exit_shape( body_id, body, body_shape, area_shape ):
	if body extends preload("res://scripts/player/sanic.gd"):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop_all()
			animations.play("Double Opening", -1, -1)
			animations.seek(pos)
		elif area_shape == 2: # Camera zone
			release_camera()

func take_camera():
	previous_cam_system = globals.camera.get_camera_system()
	
	cam_pos.set_global_transform(previous_cam_system.pos.get_global_transform())
	cam_look_pos.set_global_transform(previous_cam_system.look.get_global_transform())
	
	globals.camera.set_camera_system(cam_pos, cam_look_pos)

func release_camera():
	globals.camera.set_camera_system(previous_cam_system.pos, previous_cam_system.look)
