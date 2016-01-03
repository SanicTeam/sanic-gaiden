extends Node

var score = 0
var timeMin = 0
var timeSec = 0
var timeMSec = 0
var rings = 0
var lives = 3

var level = null

var paused = false

func _ready():
	level = get_tree().get_root().get_node("main/level")
	set_fixed_process(true)

func _fixed_process(delta):
	if not paused:
		timeMSec += delta
		if timeMSec >= 1:
			timeMSec -= 1
			timeSec += 1
			if timeSec >= 60:
				timeSec -= 60
				timeMin += 1
	if(Input.is_action_pressed("key_1")):
		set_scene("res://levels/level.scn")
	elif(Input.is_action_pressed("key_2")):
		set_scene("res://levels/level2.scn")

func get_score():
	return score

func set_score(value):
	score = value

func get_time_str():
	return str(str(timeMin).pad_zeros(2)+":"+str(timeSec).pad_zeros(2)+":"+str(floor(timeMSec*100)).pad_zeros(2))

func get_time_min():
	return timeMin

func get_time_sec():
	return timeSec

func get_time_csec():
	return floor(timeMSec*100)

func set_time(minute, second, csec):
	timeMin = minute
	timeSec = second
	if csec == 0:
		timeMSec = 0
	else:
		timeMSec = csec / 100

func reset_time():
	timeMin = 0
	timeSec = 0
	timeMSec = 0

func get_rings():
	return rings

func set_rings(value):
	rings = value

func get_lives():
	return lives

func set_lives(value):
	lives = value

func pause():
	paused = true

func resume():
	paused = false

func set_scene(scene):
	#clean up the current level
	level.queue_free()
	#load the file passed in as the param "scene"
	var s = ResourceLoader.load(scene)
	#create an instance of our scene
	level = s.instance()
	# add scene to main
	get_tree().get_root().get_node("main").add_child(level)
