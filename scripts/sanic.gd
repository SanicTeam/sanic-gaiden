extends KinematicBody


const SPEED = 5
const GRAVITY = -9.8


var cam_base

var velocity = Vector3(0, 0, 0)

func _ready():
	cam_base = get_tree().get_root().get_node("main/cam_base")
	set_fixed_process(true)

func _fixed_process(delta):
	var transX = 0
	var transZ = 0

	if Input.is_action_pressed("ui_up"):
		transZ -= 1
	if Input.is_action_pressed("ui_down"):
		transZ += 1

	if Input.is_action_pressed("ui_left"):
		transX -= 1
	if Input.is_action_pressed("ui_right"):
		transX += 1

	velocity.x = transX*SPEED
	velocity.z = transZ*SPEED
	velocity.y += GRAVITY*delta

	var motion = velocity.rotated(Vector3(0, -1, 0), cam_base.get_rotation().y)*delta
	motion = move(motion)

	var attempts = 4

	while(is_colliding() and attempts > 0):
		var norm = get_collision_normal()
		motion = norm.slide(motion)
		velocity = norm.slide(velocity)
		motion = move(motion)

		if motion.length() < 0.001:
			break

		attempts -= 1
