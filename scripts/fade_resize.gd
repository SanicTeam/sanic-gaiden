extends Sprite

var animations

func fade_in():
	animations.play("FadeIn")

func fade_out():
	animations.play("FadeIn", 0.5, -3, true)

func _ready():
	animations = get_node("animation")
	set_process(true)

func _process(delta):
	var vp = get_viewport_rect().size
	var scale = vp
	set_scale(scale*2)
	set_pos(scale/2)
