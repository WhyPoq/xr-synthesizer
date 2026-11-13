extends Node3D
## Each instance owns its selection; the active button cannot be deselected.
signal selection_changed(index: int)
@export var options: PackedStringArray = ["LOW", "MIDDLE", "HIGH"]
@export var selected_index: int = 1
var _buttons: Array[Node] = []

func _ready() -> void:
	_buttons = $Buttons.get_children()
	for i in range(_buttons.size()):
		_buttons[i].caption = options[i] if i < options.size() else str(i + 1)
		_buttons[i].get_node("Caption").text = _buttons[i].caption
		_buttons[i].pressed.connect(select.bind(i))
	select(selected_index, false)

func select(index: int, emit_change: bool = true) -> void:
	if _buttons.is_empty():
		selected_index = index
		return
	var next: int = clampi(index, 0, _buttons.size() - 1)
	var changed: bool = next != selected_index
	selected_index = next
	for i in range(_buttons.size()):
		_buttons[i].set_value(1.0 if i == selected_index else 0.0, false)
	if changed and emit_change:
		selection_changed.emit(selected_index)
