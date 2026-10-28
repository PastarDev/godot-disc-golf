extends RigidBody3D

@export var camera: Camera3D
@export var distance_in_front: float = 2.0
@export var follow_strength: float = 50.0
@export var throw_power: float = 80
var delayed_drag = []
var is_holding: bool = true
var hold_disabled: bool = false
var flight_time : int = 0

#using flight numbers of a tbird for testing
@export var speed : float = 7.0
@export var glide : float = 5.0
@export var turn : float = 0.0
@export var fade : float = 2.0

func _ready() -> void:
	constant_force = Vector3 (0, 0, 0)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:	
	if is_holding:
		var cam_transform = camera.global_transform
		var mouse_pos = get_viewport().get_mouse_position()
		var distance_offset = distance_in_front
		var drag_offset : Vector3
		
		if Input.is_action_pressed("drag_disc") and not hold_disabled:
			cam_transform.origin.y += -mouse_pos.y / 900 + 0.4
			distance_offset += -mouse_pos.y / 1500
			drag_offset = -cam_transform.basis.x*0.65 + (cam_transform.basis.x * mouse_pos.x / 900)
		
		var target_pos = cam_transform.origin + (-cam_transform.basis.z * distance_offset) + drag_offset
		
		target_pos.y -= 0.25
		
		flight_time = 0
		var to_target = target_pos - global_position
		
		state.angular_velocity = -global_rotation * 5
		
		if Input.is_action_just_released("drag_disc"):
			is_holding = false
		
		if is_holding:
			state.linear_velocity = to_target * follow_strength
		

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("drag_disc"):
		if mouse_pos.y > 622:
			hold_disabled = true
	
	if Input.is_action_just_released("drag_disc"):
		if not hold_disabled:
			var cam_transform = camera.global_transform
			is_holding = false
			var drag_distance = abs(delayed_drag[0] - delayed_drag[4])
			gravity_scale = 1
			flight_time = 1
			var direction_offset = -cam_transform.basis.x*0.65 + (cam_transform.basis.x * mouse_pos.x / 900)
			var direction = -camera.global_transform.basis.z + camera.global_transform.basis.y / 30 + direction_offset
			direction.y += 0.2
			linear_velocity *= 0.2
			global_basis = camera.global_basis
			await get_tree().create_timer(0.01).timeout
			apply_central_impulse(direction.normalized() * throw_power/3 * (clamp(drag_distance.y / 100, 0.2, 1.5)))
			
			#global_rotation = camera.global_rotation
		else:
			hold_disabled = false
			is_holding = true
	
	if global_position.y <= 0.01:
		linear_velocity = Vector3.ZERO
		
		gravity_scale = 0.0
	
	if Input.is_action_just_pressed("hold_disc"):
		#constant_force = Vector3 (0, 0, 0)
		is_holding = not is_holding
		hold_disabled = false
	
	if not is_holding:
		hold_disabled = false

func _on_drag_timer_timeout() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	delayed_drag.push_front(mouse_pos)
	while len(delayed_drag) >= 6:
		delayed_drag.remove_at(-1)
	if not is_holding and flight_time >= 1:
		flight_time += 1
		linear_velocity.x *= 0.99
		linear_velocity.z *= 0.99
		constant_force.y = -(linear_velocity.x + linear_velocity.z) * 2 / (100 - glide * 8)
		var velocityxz = abs(linear_velocity.x + linear_velocity.z)
		if global_rotation_degrees.z < 40 and global_rotation_degrees.z > -40 and global_position.y > 0.5:
			rotation_degrees.z += 10 / clamp(velocityxz, 2, 12) * fade/5 + 0.5 + (flight_time / 1000) + speed/5
			rotation_degrees.z -= 1.2 * velocityxz / clamp(speed, 5, 15) * (turn/-5 + 0.4)
		var fade_direction = -clamp(rotation_degrees.z, -50, 50) / 40
		linear_velocity += (global_transform.basis.x * fade_direction * clamp(velocityxz / 10, 0.6, 30)) /2
