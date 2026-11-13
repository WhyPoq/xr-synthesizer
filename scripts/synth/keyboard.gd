extends Node3D
## One octave C4..C5. Signals carry MIDI note numbers, with no sound generation.
signal note_pressed(note: int)
signal note_released(note: int)
@export var first_note: int = 60

func _ready() -> void:
	for key in $Keys.get_children():
		key.value_changed.connect(_on_key_changed.bind(first_note + int(key.get_meta("semitone"))))

func _on_key_changed(value: float, note: int) -> void:
	if value > 0.5:
		note_pressed.emit(note)
	else:
		note_released.emit(note)
