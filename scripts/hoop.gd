extends Area


const sounds = ["boom", "slam", "jam", "shaq"]

var samples
var index

func _ready():
	samples = get_node("samples")
	index = -1

func _on_hoop_body_enter(body):
	if body.has_node("basketball_model"):
		index += 1
		samples.play(sounds[min(index, sounds.size() - 1)])
		body.queue_free()
