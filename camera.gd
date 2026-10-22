extends Camera3D

var rotation_speed: float = 2.0
@export var camera: Node3D

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("slow_turn"): rotation_speed = 0.5
	
	else: rotation_speed = 2.0
	
	if Input.is_action_pressed("cam_up"): camera.rotation.x += (rotation_speed * delta)
	if Input.is_action_pressed("cam_down"): camera.rotation.x += (-rotation_speed * delta)
	if Input.is_action_pressed("cam_right"): camera.rotation.y += (-rotation_speed * delta)
	if Input.is_action_pressed("cam_left"): camera.rotation.y += (rotation_speed * delta)
