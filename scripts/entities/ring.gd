extends Area

var globals
var taken = false

func _ready():
	globals = get_tree().get_root().get_node("globals")
	set_fixed_process(true)

func _fixed_process(delta):
	rotate_y(PI / 60)

func _on_ring_body_enter(body):
	if not taken and body extends preload("res://scripts/player/sanic.gd"):
		get_node("animation").play("collect")
		globals.rings += 1
		taken = true
		get_node("sounds").play("ring")

func _on_animation_finished():
	queue_free()
	hide()
