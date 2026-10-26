extends RigidBody3D

@export var camera: Camera3D
@export var distance_in_front: float = 2.0
@export var follow_strength: float = 50.0
@export var throw_power: float = 100
var is_holding: bool = true

func _ready() -> void:
	
	gravity_scale = 0.0 
	
	#global_position = Vector3 (0, 1.2, 3)
	
	constant_force = Vector3 (0, 0, 0)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:	
	if is_holding:
		var cam_transform = camera.global_transform
		var target_pos = cam_transform.origin + (-cam_transform.basis.z * distance_in_front)
		
		target_pos.y -= 0.25

		var to_target = target_pos - global_position
		
		state.linear_velocity = to_target * follow_strength
		
		state.angular_velocity = -global_rotation * 5
		

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("throw_disc"):
		
		constant_force = Vector3.ZERO
		
		is_holding = false
		
		gravity_scale = 1
		
		var direction = global_position - camera.global_position
		apply_central_impulse(direction.normalized() * 25)
		
		#old code:
		#await get_tree().create_timer(0.2).timeout
		#constant_force = Vector3 (100 * 1/linear_velocity.z, 0, 0)
	
	if global_position.y <= 0.01:
		linear_velocity = Vector3.ZERO
		
		gravity_scale = 0.0
	
	if Input.is_action_just_pressed("hold_disc"):
		gravity_scale = 0
		angular_velocity = Vector3.ZERO
		constant_force = Vector3 (0, 0, 0)
		is_holding = not is_holding
