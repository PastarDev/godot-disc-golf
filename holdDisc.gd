extends RigidBody3D

@export var camera: Camera3D
@export var distance_in_front: float = 2.0
@export var follow_strength: float = 50.0
@export var throw_power: float = 80
var is_holding: bool = true

func _ready() -> void:
	
	gravity_scale = 0.0 
	
	#global_position = Vector3 (0, 1.2, 3)
	
	constant_force = Vector3 (0, 0, 0)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:	
	if is_holding:
		var cam_transform = camera.global_transform
		var mouse_pos = get_viewport().get_mouse_position()
		var distance_offset = distance_in_front
		var drag_offset : Vector3
		
		if Input.is_action_pressed("drag_disc"):
			cam_transform.origin.y += -mouse_pos.y / 900 + 0.4
			distance_offset += -mouse_pos.y / 1500
			drag_offset = -cam_transform.basis.x*0.65 + (cam_transform.basis.x * mouse_pos.x / 900)
			
		
		var target_pos = cam_transform.origin + (-cam_transform.basis.z * distance_offset) + drag_offset
		
		target_pos.y -= 0.25

		var to_target = target_pos - global_position
		
		state.angular_velocity = -global_rotation * 5
		
		state.linear_velocity = to_target * follow_strength
		

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("throw_disc"):
		
		constant_force = Vector3.ZERO
		
		is_holding = false
		
		gravity_scale = 1
		
		var direction = global_position - camera.global_position
		direction.y += 0.5
		apply_central_impulse(direction.normalized() * throw_power/3)
		
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
