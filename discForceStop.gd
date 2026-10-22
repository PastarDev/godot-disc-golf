extends RigidBody3D

func _ready() -> void:
	
	gravity_scale = 0.0 
	
	global_position = Vector3 (0, 1.2, 3)
	
	constant_force = Vector3 (0, 0, 0)


func _process(delta: float) -> void:
	
	if Input.is_action_pressed("throw_disc"):
		
		gravity_scale = 1
		
		constant_force = Vector3 (0, 50, -100)
		
		await get_tree().create_timer(0.2).timeout
		
		constant_force = Vector3 (0, 0, 0)
	
	if global_position.y <= 0.1:
		linear_velocity = Vector3.ZERO
