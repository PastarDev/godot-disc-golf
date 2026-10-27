extends RigidBody3D

@export var camera: Camera3D
@export var distance_in_front: float = 2.0
@export var follow_strength: float = 50.0
@export var throw_power: float = 80
var delayed_drag = []
var is_holding: bool = true
var hold_disabled: bool = false

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
			var drag_distance = delayed_drag[0] - delayed_drag[4]
			gravity_scale = 1
			var direction_offset = -cam_transform.basis.x*0.65 + (cam_transform.basis.x * mouse_pos.x / 900)
			var direction = -camera.global_transform.basis.z + camera.global_transform.basis.y / 30 + direction_offset
			direction.y += 0.2
			linear_velocity *= 0.5
			if -drag_distance.y / 1000 < 0.1:
				apply_central_impulse(direction.normalized() * throw_power/3 * (-drag_distance.y / 1000))
			else:
				apply_central_impulse(direction.normalized() * throw_power/3 * ((-drag_distance.y / 1000) + 1) / 2)
		else:
			hold_disabled = false
			is_holding = true
	
	if global_position.y <= 0.01:
		linear_velocity = Vector3.ZERO
		
		gravity_scale = 0.0
	
	if Input.is_action_just_pressed("hold_disc"):
		constant_force = Vector3 (0, 0, 0)
		is_holding = not is_holding
		hold_disabled = false
	
	if not is_holding:
		hold_disabled = false

func _on_drag_timer_timeout() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	delayed_drag.push_front(mouse_pos)
	while len(delayed_drag) >= 6:
		delayed_drag.remove_at(-1)
