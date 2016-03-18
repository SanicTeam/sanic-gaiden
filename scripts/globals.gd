# This script manages global state.

extends Node


var score = 0
var time = 0
var rings = 0

var camera

var level = null

var paused = false

func _ready():
	level = get_tree().get_root().get_node("main/level")
	camera = get_tree().get_root().get_node("main/cam")
	set_fixed_process(true)

func _fixed_process(delta):
	if not paused:
		time += delta
	
	if(Input.is_action_pressed("key_1")):
		set_scene("res://levels/level.scn")
	elif(Input.is_action_pressed("key_2")):
		set_scene("res://levels/level2.scn")

func get_time_str():
	# minutes, seconds, and milliseconds
	var timeset = [int(time/60), int(time)%60, int(time*100)%100]
	
	var result = ""
	for t in timeset:
		if t != timeset[0]:
			result += ":"
		result += str(t).pad_zeros(2)
		
	return result


func reset_time():
	time = 0

func pause():
	paused = true

func resume():
	paused = false

func set_scene(scene):
	# Clean up the current level if it's initialized
	if level != null:
		level.queue_free()
	# Load the file passed in as the param "scene"
	var s = ResourceLoader.load(scene)
	# Create an instance of our scene
	level = s.instance()
	# Add scene to main
	get_tree().get_root().get_node("main/scenes").add_child(level)

# A "camera system" is simply a node that represents the transform of the 3D camera.
# The player object has a camera system.
func set_camera_system(node):
	get_tree().get_root().get_node("main/cam").set_camera_system(node)

func remove_camera_system(node):
	get_tree().get_root().get_node("main/cam").remove_camera_system(node)
