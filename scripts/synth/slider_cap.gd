extends RigidBody3D
## A real rigid body constrained to the panel's local vertical rail.
const HALF_TRAVEL: float = 0.075
@onready var control: Area3D = get_parent()

func set_fraction(fraction: float) -> void:
	position = Vector3(0, lerpf(-HALF_TRAVEL, HALF_TRAVEL, fraction), 0)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var local: Vector3 = control.to_local(state.transform.origin)
	local = Vector3(0, clampf(local.y, -HALF_TRAVEL, HALF_TRAVEL), 0)
	var transform_on_rail: Transform3D = state.transform
	transform_on_rail.origin = control.to_global(local)
	transform_on_rail.basis = control.global_basis.orthonormalized()
	state.transform = transform_on_rail
	var axis: Vector3 = control.global_basis.y.normalized()
	var speed: float = state.linear_velocity.dot(axis)
	if (local.y <= -HALF_TRAVEL and speed < 0.0) or (local.y >= HALF_TRAVEL and speed > 0.0):
		speed = 0.0
	state.linear_velocity = axis * speed
	state.angular_velocity = Vector3.ZERO
	# Detented sliders settle to the nearest position after the finger leaves.
	if control.positions > 1 and state.get_contact_count() == 0 and not control._mouse_drag:
		var fraction: float = (local.y + HALF_TRAVEL) / (2.0 * HALF_TRAVEL)
		var detent: float = roundf(fraction * (control.positions - 1)) / (control.positions - 1)
		var target: float = lerpf(-HALF_TRAVEL, HALF_TRAVEL, detent)
		state.linear_velocity += axis * ((target - local.y) * control.global_basis.y.length() * 100.0 - speed * 10.0) * state.step
	control.read_physical_fraction((local.y + HALF_TRAVEL) / (2.0 * HALF_TRAVEL))
