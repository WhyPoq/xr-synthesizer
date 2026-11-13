extends Area3D
## Silent controls. Front is +Z; values are normalized to 0..1.
signal value_changed(value: float)
signal pressed
signal released

@export_enum("Switch:0", "Slider:2", "Button:3", "Key:4") var kind: int = 0
@export_range(0.0, 1.0) var value: float = 0.0
@export var positions: int = 0
@export var caption: String = ""
@export var choices: PackedStringArray = []
@export var latching: bool = false

var _mouse_drag: bool = false
var _fingers: Array[Area3D] = []
var _value_start: float
var _face_material: StandardMaterial3D
var _reading_physics: bool = false

func _ready() -> void:
	input_event.connect(_on_input_event)
	if kind != 2:
		area_entered.connect(_on_area_entered)
		area_exited.connect(_on_area_exited)
	if kind >= 3 or kind == 0:
		var face: MeshInstance3D
		if kind == 0:
			face = $Moving/Indicator
		else:
			face = $Moving/Mesh if kind == 4 else $Moving/Cap
		_face_material = face.material_override.duplicate()
		face.material_override = _face_material
	set_value(value, false)
	if has_node("Caption"):
		$Caption.text = caption

func set_value(new_value: float, emit_change: bool = true) -> void:
	var next: float = clampf(new_value, 0.0, 1.0)
	if kind == 0 or kind >= 3:
		next = 1.0 if next >= 0.5 else 0.0
	elif positions > 1:
		next = roundf(next * (positions - 1)) / (positions - 1)
	var changed: bool = not is_equal_approx(value, next)
	value = next
	if is_node_ready():
		match kind:
			0: $Moving.rotation.x = deg_to_rad(-12.0 if value > 0.5 else 12.0)
			2:
				if not _reading_physics:
					$Moving.set_fraction(value)
			3, 4: $Moving.position.z = -0.009 * value
		if _face_material:
			var rest: Color = Color.WHITE if kind == 4 else Color("0e1113")
			_face_material.albedo_color = Color("72d6bf") if value > 0.5 else get_meta("rest_color", rest)
		if has_node("Readout"):
			$Readout.text = ("ON" if value > 0.5 else "OFF") if kind == 0 else "%d%%" % roundi(value * 100.0)
			if not choices.is_empty():
				$Readout.text = choices[roundi(value * (choices.size() - 1))]
	if changed and emit_change:
		value_changed.emit(value)

func read_physical_fraction(fraction: float) -> void:
	_reading_physics = true
	set_value(fraction)
	_reading_physics = false

func activate() -> void:
	pressed.emit()
	if kind == 0:
		set_value(1.0 - value)
	elif kind >= 3:
		set_value(1.0)

func release() -> void:
	if _mouse_drag or not _fingers.is_empty():
		return
	if kind >= 3 and not latching:
		set_value(0.0)
	released.emit()

func _on_input_event(_camera: Node, event: InputEvent, _point: Vector3, _normal: Vector3, _shape: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_mouse_drag = true
		_value_start = value
		activate()
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if not _mouse_drag:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_mouse_drag = false
		release()
	elif event is InputEventMouseMotion and kind == 2:
		_value_start = clampf(_value_start - event.relative.y * 0.006, 0.0, 1.0)
		set_value(_value_start)

func _on_area_entered(area: Area3D) -> void:
	if kind == 2 or not area.is_in_group("finger_tip") or _fingers.has(area):
		return
	_fingers.append(area)
	if _fingers.size() == 1:
		activate()

func _on_area_exited(area: Area3D) -> void:
	if not _fingers.has(area):
		return
	_fingers.erase(area)
	if _fingers.is_empty():
		release()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and _mouse_drag:
		_mouse_drag = false
		release()
