extends KinematicBody


const MAX_SPEED = 10
const GRAVITY = Vector3(0, -9.8*2, 0)
const MAX_SLOPE_ANGLE = deg2rad(30)
const JUMP_SPEED = 10
const Y_VEC = Vector3(0, -1, 0)

const ACCEL_SPEED = 30
const FRICTION_CONST = 25

var cam_base

var velocity = Vector3(0, 0, 0)

var on_ground = false
var jump_held = false

func _ready():
	cam_base = get_parent().get_node("cam_base")
	set_fixed_process(true)

func _fixed_process(delta):
	var acceleration = Vector3(0, 0, 0)
	var friction = FRICTION_CONST
	
	# Input map values
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_pressed("ui_accept")
	
	# Set player acceleration based on user input (relative to the camera's base
	# rotation)
	if up:
		acceleration.z -= 1
	if down:
		acceleration.z += 1
	if left:
		acceleration.x -= 1
	if right:
		acceleration.x += 1
	
	# Make the acceleration speed uniform on the XZ plane
	acceleration = acceleration.normalized()*ACCEL_SPEED
	
	# If we're on the ground and want to jump, set the velocity accordingly
	if jump:
		if on_ground and !jump_held:
			velocity.y = JUMP_SPEED
			jump_held = true
			on_ground = false
	else:
		jump_held = false
	
	# Rotate the XZ acceleration so that it lines up with the camera
	acceleration = acceleration.rotated(Y_VEC, cam_base.get_rotation().y)
	
	# If not touching the ground, apply the acceleration less
	if !on_ground:
		friction /= 2
		acceleration /= 2
	
	# If the player is accelerating the character, change the rotation to match
	# the player's intent
	if acceleration.length_squared():
		set_rotation(Vector3(0, atan2(acceleration.x, acceleration.z), 0))
	# If the player isn't applying acceleration, apply friction
	else:
		var neg_xz_velocity = velocity*Vector3(-1, 0, -1)
		var friction_speed = min(friction*delta, neg_xz_velocity.length())
		velocity += neg_xz_velocity.normalized()*friction_speed
	
	# Apply gravity to the acceleration
	acceleration += GRAVITY
	
	# Apply the acceleration to the velocity
	velocity += acceleration*delta
	
	# Break down the velocity vector into XZ and Y components
	var xz_velocity = velocity*Vector3(1, 0, 1)
	var y_velocity = velocity*Vector3(0, 1, 0)
	# Calculate the speed of the XZ component, applying the max speed
	var xz_speed = min(xz_velocity.length(), MAX_SPEED)
	# Reconstruct the velocity vector with the max speed applied to the XZ
	# component
	velocity = xz_velocity.normalized()*xz_speed + y_velocity
	
	# Displace the player by the velocity
	var motion = move(velocity*delta)
	
	var attempts = 4

	on_ground = false
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
