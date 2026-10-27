extends HSlider

@export var disc : RigidBody3D

func _on_value_changed(value: float) -> void:
	disc.throw_power = value
