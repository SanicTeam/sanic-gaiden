extends Node2D

var scoreLabel
var timeLabel
var ringsLabel
var livesLabel

func _ready():
	scoreLabel = get_node("score")
	timeLabel = get_node("time")
	ringsLabel = get_node("rings")
	set_fixed_process(true)

func _fixed_process(delta):
	scoreLabel.set_text("Score: " + str(globals.score))
	timeLabel.set_text("Time: " + globals.get_time_str())
	ringsLabel.set_text("Rings: " + str(globals.rings))
