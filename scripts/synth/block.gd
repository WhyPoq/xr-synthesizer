extends Node3D
## Named parameters for later synthesis wiring. No audio or DSP is performed.
signal parameter_changed(parameter: StringName, value: float)
@export var parameters: Dictionary = {}

func _ready() -> void:
	for parameter in parameters:
		var control: Node = get_node(parameters[parameter])
		var event: StringName = &"selection_changed" if control.has_signal("selection_changed") else &"value_changed"
		control.connect(event, _on_parameter_changed.bind(StringName(parameter)))

func _on_parameter_changed(value: float, parameter: StringName) -> void:
	parameter_changed.emit(parameter, value)

func get_parameter(parameter: StringName) -> float:
	var control: Node = get_node(parameters[String(parameter)])
	return float(control.selected_index) if control.has_signal("selection_changed") else float(control.value)
