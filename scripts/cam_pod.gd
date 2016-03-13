extends Spatial

const MAX_RAY_LENGTH = 5

var ray

func _ready():
	ray = get_node("ray")
	reset_ray()
	set_fixed_process(true)

func _fixed_process(delta):
	var position = get_translation()
	var velocity = position - position.linear_interpolate(Vector3(0, 0, 0), 4)
	
	set_translation(position - velocity*delta)
	reset_ray()
	
	if ray.is_colliding():
		# Set the position to the ray's collision point
		global_translate(ray.get_collision_point() - get_global_transform().origin)
		
		# Make sure that only the Z change is applied
		set_translation(get_translation()*Vector3(0, 0, 1))
		reset_ray()
		
		# Limit how close the camera can move (-MAX_RAY_LENGTH)
		set_translation(Vector3(0, 0, max(-MAX_RAY_LENGTH, get_translation().z)))
		reset_ray()

func reset_ray():
	var trans = Vector3(0, 0, -MAX_RAY_LENGTH - get_translation().z)
	ray.set_cast_to(-trans)
	ray.set_translation(trans)
