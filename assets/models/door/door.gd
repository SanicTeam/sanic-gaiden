extends Spatial

var globals
var animations

func _ready():
	globals = get_tree().get_root().get_node("globals")
	animations = get_node("door_model/AnimationPlayer")
	animations.set_current_animation("Double Opening")

func _on_Area_body_enter_shape( body_id, body, body_shape, area_shape ):
	if body extends preload("res://scripts/player/sanic.gd"):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop()
			animations.play("Double Opening", -1)
			animations.seek(pos)
		elif area_shape == 1: # Loading zone
			globals.set_scene("res://levels/level2.scn")
		elif area_shape == 2: # Camera zone
			print("Camera zone enter")

func _on_Area_body_exit_shape( body_id, body, body_shape, area_shape ):
	if body extends preload("res://scripts/player/sanic.gd"):
		if area_shape == 0: # Door open zone
			var pos = animations.get_current_animation_pos()
			animations.stop()
			animations.play("Double Opening", -1, -1)
			animations.seek(pos)
		elif area_shape == 2: # Camera zone
			print("Camera zone exit")
