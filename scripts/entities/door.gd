# The gateway to new worlds.
extends Spatial

var globals
var animations

var cam_dest
var cam_look_dest

var previous_cam_system

func _ready():
	globals = get_tree().get_root().get_node("globals")
	animations = get_node("door_model/AnimationPlayer")
	
	cam_dest = get_node("cam_dest")
	cam_look_dest = get_node("cam_look_dest")
	
	animations.set_current_animation("Double Opening")

func _on_Area_body_enter_shape( body_id, body, body_shape, area_shape ):
	if body extends preload("res://scripts/player/character.gd"):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop_all()
			animations.play("Double Opening", -1)
			animations.seek(pos)
		elif area_shape == 1: # Loading zone
			globals.set_scene("res://levels/test_level1.scn")
		elif area_shape == 2: # Camera zone
			take_camera()

func _on_Area_body_exit_shape( body_id, body, body_shape, area_shape ):
	if body extends preload("res://scripts/player/character.gd"):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop_all()
			animations.play("Double Opening", -1, -1)
			animations.seek(pos)
		elif area_shape == 2: # Camera zone
			release_camera()

func take_camera():
	previous_cam_system = globals.camera.get_camera_system()
	
	globals.camera.set_camera_system(cam_dest, cam_look_dest, 0.08)

func release_camera():
	var cam_base = previous_cam_system.pos.get_parent().get_parent().get_parent().get_parent()
	
	var new_rotation = Vector2(globals.camera.get_global_yaw(), globals.camera.get_global_pitch()/2)
	cam_base.reset_rotation(new_rotation)
	
	globals.camera.set_camera_system(previous_cam_system.pos, previous_cam_system.look)
