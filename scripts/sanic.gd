extends KinematicBody


const SPEED = 5
const GRAVITY = -9.8 * 2
const MAX_SLOPE_ANGLE = deg2rad(30)
const JUMP_SPEED = 10

var cam_base

var velocity = Vector3(0, 0, 0)

var on_ground = false
var jump_held = false

func _ready():
	cam_base = get_parent().get_node("cam_base")
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
	
	if Input.is_action_pressed("ui_accept"):
		if on_ground == true and jump_held == false:
			velocity.y = JUMP_SPEED
			jump_held = true
			on_ground = false
	else:
		jump_held = false

	velocity.x = transX*SPEED
	velocity.z = transZ*SPEED
	velocity.y += GRAVITY*delta

	var motion = velocity.rotated(Vector3(0, -1, 0), cam_base.get_rotation().y)*delta
	motion = move(motion)
	
	if transX || transZ:
		var direction = Vector3(velocity.x, 0, velocity.z).rotated(Vector3(0, -1, 0), cam_base.get_rotation().y)
		set_rotation(Vector3(0, atan2(direction.x, direction.z), 0))
	
	var attempts = 4

	while(is_colliding() and attempts > 0):
		var norm = get_collision_normal()
		
		if (acos(norm.dot(Vector3(0, 1, 0))) < MAX_SLOPE_ANGLE):
			# If angle to the "up" vectors is < angle tolerance,
			# char is on floor
			#floor_velocity = get_collider_velocity()
			on_ground = true
		
		motion = norm.slide(motion)
		velocity = norm.slide(velocity)
		motion = move(motion)

		if motion.length() < 0.001:
			break

		attempts -= 1
