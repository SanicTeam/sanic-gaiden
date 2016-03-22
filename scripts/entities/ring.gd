extends Area

var taken = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	rotate_y(PI / 60)

func _on_ring_body_enter(body):
	if not taken and globals.is_character(body):
		get_node("animation").play("collect")
		globals.rings += 1
		taken = true
		get_node("sounds").play("ring")

func _on_animation_finished():
	queue_free()
	hide()
