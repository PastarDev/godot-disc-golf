extends RigidBody3D

@export var camera: Camera3D
@export var distance_in_front: float = 2.0
@export var follow_strength: float = 10.0

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Input.is_action_pressed("hold_disc"):
		if not camera:
			return
	
		var cam_transform = camera.global_transform
		var target_pos = cam_transform.origin + (-cam_transform.basis.z * distance_in_front)
	
		var to_target = target_pos - global_position
	
		state.linear_velocity = to_target * follow_strength

func _ready() -> void:
	
	#gravity_scale = 0.0 
	
	global_position = Vector3 (0, 1.2, 3)
	
	constant_force = Vector3 (0, 0, 0)


func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("throw_disc"):
		
		gravity_scale = 1
		
		constant_force = Vector3 (0, 50, -100)
		
		await get_tree().create_timer(0.2).timeout
		
		constant_force = Vector3 (0, 0, 0)
	
	if global_position.y <= 0.1:
		linear_velocity = Vector3.ZERO
