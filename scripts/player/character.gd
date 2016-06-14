extends KinematicBody

const MAX_SPEED = 10
const GRAVITY = Vector3(0, -9.8*3.5, 0)
const MAX_SLOPE_ANGLE = deg2rad(45)
const JUMP_SPEED = 12
const Y_VEC = Vector3(0, -1, 0)

const ACCEL_SPEED = 40
const FRICTION_CONST = 35

const AIR_THRESHOLD = 5

var air_timer
var air_timeout = true
var jump_timer

var camera
var model
var animations

var velocity = Vector3(0, 0, 0)
var destination_rotation = 0

var on_ground = false
var jump_held = false

func _ready():
	camera = get_tree().get_root().get_node("globals").camera
	model = get_node("model")
	animations = model.get_node("AnimationPlayer")
	air_timer = get_parent().get_node("air_timer")
	jump_timer = get_node("../jump_timer")
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
			air_timeout = true
			get_node("sounds").play("jump")
	else:
		jump_held = false
	
	# Rotate the XZ acceleration so that it lines up with the camera
	acceleration = acceleration.rotated(Y_VEC, camera.get_global_yaw())
	
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
	# Make the player model lean into turns.
	var current_model_lean = model.get_rotation().z
	model.set_rotation(Vector3(0, 0, lerp(current_model_lean, -rotation_distance/7, 0.4)))
	
	# This info is useful for animation decisions
	var xz_acceleration = acceleration
	
	# Apply gravity to the acceleration
	acceleration += GRAVITY
	
	# Apply the acceleration to the velocity
	velocity += acceleration*delta
	
	# Break down the velocity vector into XZ and Y components
	var xz_velocity = velocity*Vector3(1, 0, 1)
	var y_velocity = velocity*Vector3(0, 1, 0)
	# Calculate the speed of the XZ component, applying the max speed.
	var xz_speed = min(xz_velocity.length(), MAX_SPEED)
	# Reconstruct the velocity vector with the max speed applied to the XZ
	# component.
	velocity = xz_velocity.normalized()*xz_speed + y_velocity
	
	# Displace the player by the velocity.
	var motion = move(velocity*delta)
	
	var attempts = 4
	
	on_ground = false
	# Loop through and check for collisions multiple times
	while(is_colliding() and attempts > 0):
		var norm = get_collision_normal()
		var current_colliding_ground = false
		if (acos(norm.dot(Vector3(0, 1, 0))) < MAX_SLOPE_ANGLE):
			# If angle to the "up" vectors is < angle tolerance,
			# the character is on floor
			on_ground = true
			
			# current_colliding_ground signifies that the current object being detected by the
			# collider should be treated like ground, and therefore not have it's velocity
			# unfluenced.
			current_colliding_ground = true
		
		var multiplier = 1 
		var collider = get_collider()
		# If we're colliding with a RigidBody that we're not standing on, we're bumping into
		# it and should affect it's velocity.
		if collider.is_type("RigidBody") and not current_colliding_ground:
			collider.set_linear_velocity(velocity)
			multiplier = 0.5
			
			# If the RigidBody is a basketball, play the basketball bounce noise at a volume
			# linearly proportional to our speed.
			if collider.has_node("basketball_model"):
				var basketball_sound = collider.get_node("sounds")
				var target_volume = -20 + velocity.length()*2
				basketball_sound.get_sample_library().sample_set_volume_db("basketball_bounce", target_volume)
				basketball_sound.play("basketball_bounce")
		
		if current_colliding_ground and xz_velocity.length() < MAX_SPEED*0.9:
			motion.y = 0
		motion = norm.slide(motion)
		velocity = norm.slide(velocity)
		motion = move(motion)*multiplier
		
		if motion.length() < 0.001:
			break
		
		attempts -= 1
	
	# Figure out what the animation state should be
	if on_ground:
		air_timeout = false
		
		if xz_acceleration.length_squared() < 0.3:
			set_animation("standing", 0.4)
		else:
			air_timer.start()
			set_animation("walk", 0.3, 1.5)
	else:
		if air_timeout:
			set_animation("jump", 0.5, 0.8)

func set_animation(name, blend=-1, speed=1):
	if !animations.get_current_animation() == name:
		animations.play(name, blend, speed)

func _on_air_timer_timeout():
	air_timeout = true
