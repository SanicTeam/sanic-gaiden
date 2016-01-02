extends TestCube

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	rotate_y(PI / 60)
