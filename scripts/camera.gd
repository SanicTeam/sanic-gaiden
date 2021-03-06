# This script controls the position and rotation of the 3D camera.
extends Spatial

const UP = Vector3(0, 1, 0)
const FORWARD = Vector3(0, 0, 1)

var cam

var cam_system = null
var cam_system_look = null

var cam_system_lerp = 1
var look_position = -FORWARD

var transition_speed = 0.5

func _ready():
	cam = get_node("Camera")
	set_process(true)

func _process(delta):
	cam_system_lerp = min(1, cam_system_lerp + transition_speed*delta)
	
	# If there's a camera system set, snap/ease the camera to it.
	if cam_system != null and cam_system_look != null:
		var new_translation = get_translation().linear_interpolate(cam_system.get_global_transform().origin, cam_system_lerp)
		var new_look_translation = look_position.linear_interpolate(cam_system_look.get_global_transform().origin, cam_system_lerp)
		
		reset_camera_positions(new_translation, new_look_translation)

func set_camera_system(cam_pos, look_pos, speed=0.5):
	cam_system = cam_pos
	cam_system_look = look_pos
	cam_system_lerp = 0
	transition_speed = speed

func reset_camera_positions(cam_pos, look_pos):
	look_position = look_pos
	set_translation(cam_pos)
	cam.look_at(look_pos, UP)

func get_camera_system():
	return {'pos': cam_system, 'look': cam_system_look}

func remove_camera_system(cam_pos):
	if cam_system == cam_pos:
		cam_system = null
		cam_system_look = null

func activate_player_camera(speed=0.5):
	if globals.player != null:
		var current_rotation = Vector2(get_global_yaw(), get_global_pitch()/2)
		globals.player.reset_camera_system_rotation(current_rotation)
		
		var system = globals.player.get_camera_system()
		set_camera_system(system.pos, system.look, speed)

func get_global_look():
	return cam_system_look.get_global_transform().origin - cam_system.get_global_transform().origin

func get_global_yaw():
	if cam_system == null:
		return 0
	
	var right = get_global_look().cross(UP).normalized()
	var forward = right.cross(UP)
	
	return acos(FORWARD.dot(forward))*sign(forward.x)

func get_global_pitch():
	if cam_system == null:
		return 0
	
	return get_global_look().rotated(UP, -get_global_yaw()).normalized().x
