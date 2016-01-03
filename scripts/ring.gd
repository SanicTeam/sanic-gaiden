extends Area

var globals
var taken = false

func _ready():
	globals = get_tree().get_root().get_node("globals")
	set_fixed_process(true)

func _fixed_process(delta):
	rotate_y(PI / 60)

func _on_ring_body_enter(body):
	if not taken and body extends preload("res://scripts/sanic.gd"):
		globals.set_rings(globals.get_rings() + 1)
		#queue_free()
		hide()
		taken = true
