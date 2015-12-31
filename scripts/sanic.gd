extends KinematicBody


const MAX_SPEED = 10
const GRAVITY = Vector3(0, -9.8*2, 0)
const MAX_SLOPE_ANGLE = deg2rad(45)
const JUMP_SPEED = 10
const Y_VEC = Vector3(0, -1, 0)

const ACCEL_SPEED = 40
const FRICTION_CONST = 25

const AIR_THRESHOLD = 5

var air_timer = 0

var cam_base
var animations

var velocity = Vector3(0, 0, 0)
var destination_rotation = 0

var on_ground = false
var jump_held = false

func _ready():
	cam_base = get_parent().get_node("cam_base")
	animations = get_node("sanic_model/AnimationPlayer")
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
		destination_rotation = atan2(acceleration.x, acceleration.z)
	# If the player isn't applying acceleration, apply friction
	else:
		var neg_xz_velocity = velocity*Vector3(-1, 0, -1)
		var friction_speed = min(friction*delta, neg_xz_velocity.length())
		velocity += neg_xz_velocity.normalized()*friction_speed
	
	if on_ground and acceleration.length_squared():
		air_timer = AIR_THRESHOLD
		if !animations.get_current_animation() == "walk":
			animations.play("walk", 0.5, 1.5)
	else:
		if air_timer:
			air_timer -= 1
		elif !animations.get_current_animation() == "standing":
			animations.play("standing", 0.5)
	
	# Rotation easing
	var current_rotation = get_rotation().y
	# This is necessary because when the rotation is less than -PI/2 or greater
	# than PI/2, get_rotation() switches to an alternate representation where
	# the X and Z rotations are -PI. Since we're working only with the Y rotation,
	# we need to adjust Y when this happens to arrive at an unambiguous
	# representation of the direction.
	if get_rotation().x != 0:
		current_rotation = PI*sign(current_rotation) - current_rotation
	var rotation_distance = destination_rotation - current_rotation
	# If the rotation distance is larger than PI, subtract 2*PI from the distance
	# to get the most efficient route
	if abs(rotation_distance) > PI:
		rotation_distance = (abs(rotation_distance) - 2*PI)*sign(rotation_distance)
	rotate_y(-rotation_distance*5*delta)
	
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
