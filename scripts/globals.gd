# This script manages global state.
extends Node

var score = 0
var time = 0
var rings = 0

var camera
var fade

var switch_timer = null
var next_scene_name

var player = null
var character = null

var level = null

var paused = false

func _ready():
	var main_scene = get_tree().get_root().get_node("main")
	
	camera = ResourceLoader.load("res://camera.scn").instance()
	main_scene.add_child(camera)
	
	fade = ResourceLoader.load("res://fade.scn").instance()
	main_scene.add_child(fade)
	
	set_scene("test_level0")
	fade.fade_in()
	
	set_fixed_process(true)

func _fixed_process(delta):
	if not paused:
		time += delta
	
	if(Input.is_action_pressed("key_1")):
		transition_scene("test_level0")
	elif(Input.is_action_pressed("key_2")):
		transition_scene("test_level1")

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

# Players are within levels and need to register themselves when they enter the scene
func register_player(player_object):
	player = player_object
	character = player.get_node("character")

func transition_scene(scene):
	if switch_timer != null:
		return
	
	next_scene_name = scene
	
	switch_timer = Timer.new()
	switch_timer.set_wait_time(0.8)
	switch_timer.set_one_shot(true)
	switch_timer.set_autostart(true)
	switch_timer.connect("timeout", self, "_on_switch_timeout")
	add_child(switch_timer)
	
	fade.fade_out()

func _on_switch_timeout():
	if next_scene_name == null:
		print("WARNING: Scene switch timeout called, but there's no scene to switch to.")
		return
	set_scene(next_scene_name)
	
	fade.fade_in()
	
	switch_timer.queue_free()
	switch_timer = null
	next_scene_name = null

func set_scene(scene):
	# Clean up the current level if it's initialized
	if level != null:
		level.queue_free()
	# Load the file passed in as the param "scene"
	var s = ResourceLoader.load("res://levels/" + scene + ".scn")
	# Create an instance of our scene
	level = s.instance()
	# Add scene to main
	get_tree().get_root().get_node("main/scenes").add_child(level)

func is_character(body):
	return body == character
