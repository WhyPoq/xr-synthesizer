extends Area3D
## Preserves touch events and adds a solid tracked fingertip for physical caps.
## Layer 8 = physical fingertips. Caps detect this layer without exposing one.
var _body: AnimatableBody3D
var _last_position: Vector3

func _ready() -> void:
	_body = AnimatableBody3D.new()
	_body.name = "PhysicalFingertip"
	_body.collision_layer = 128
	_body.collision_mask = 0
	_body.sync_to_physics = false
	_body.input_ray_pickable = false
	add_child(_body)
	_body.top_level = true
	_body.global_transform = global_transform
	for child in get_children():
		if child is CollisionShape3D:
			_body.add_child(child.duplicate())
	_last_position = global_position
	process_physics_priority = -100

func _physics_process(delta: float) -> void:
	var movement: Vector3 = global_position - _last_position
	# Tracking jumps relocate the proxy without a large velocity impulse.
	_body.constant_linear_velocity = movement / delta if movement.length() < 0.15 else Vector3.ZERO
	_body.global_transform = global_transform
	_last_position = global_position
