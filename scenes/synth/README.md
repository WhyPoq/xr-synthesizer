# Silent synthesizer components

Open `desktop_demo.tscn` and press **F6** for mouse testing. The existing
`scenes/synthesizer.tscn` XR scene also instances `synth_panel.tscn`.
All scenes face local +Z. Panels use metres and can be moved, rotated, or scaled.
No sound generation, filtering, envelope processing, or wave drawing is included.

## Scenes

| Scene | Purpose |
| --- | --- |
| `controls/toggle_switch.tscn` | Electronic rocker switch with I/O markings |
| `controls/mixer_slider.tscn` | Physical vertical fader; optional discrete positions |
| `controls/push_button.tscn` | Latching recorder-style button |
| `controls/exclusive_buttons.tscn` | Three buttons with exactly one selected |
| `controls/wave_buttons.tscn` | Four exclusive waveform buttons |
| `controls/piano_key.tscn` | Momentary key used by the keyboard |
| `blocks/base_frequency.tscn` | Low / middle / high selection, initially middle |
| `blocks/wave_selector.tscn` | Exclusive sin / triangle / saw / square buttons |
| `blocks/filter.tscn` | Cutoff fader |
| `blocks/envelope.tscn` | Reusable enable switch and attack / decay / sustain / release sliders |
| `blocks/filter_envelope.tscn` | Filter envelope instance |
| `blocks/volume.tscn` | Volume fader |
| `blocks/volume_envelope.tscn` | Volume envelope instance |
| `blocks/speaker.tscn` | Static dummy speaker |
| `blocks/wave_display.tscn` | Static display placeholder |
| `blocks/small_keyboard.tscn` | 13 keys, C4 through C5 |
| `synth_panel.tscn` | Assembled controls and blocks |

Instance any scene independently. Meshes, moving parts, collisions, and labels
are saved in the scenes for editing in Godot. The two envelope scenes inherit
their structure from the common envelope scene.

## Interaction

- Click switches and buttons. The selected recorder button stays down and lights up.
- Drag faders vertically with the left mouse button.
- Hold a keyboard key with the mouse; releasing the mouse releases the key.
- In XR, switches/buttons/keys use an `Area3D` in the existing `finger_tip`
  group on collision layer 1.
- Faders have rigid-body caps constrained to local vertical rails, with rotation
  locked. Push the **lower
  edge upward**, or the **upper edge downward**, with a solid fingertip.
  Fingers transfer motion through physical collision; there is no touch-drag
  attachment. Retreating from a cap does not pull it. Damping limits coasting,
  and the rail has end stops.
- `scripts/synth/physical_finger.gd` is attached to both existing fingertip
  areas. It copies their collision shapes into tracked solid bodies. For a
  new hand, attach the same script to its fingertip Area3D before entering
  the scene tree. Physical fingertips use layer **8** (128); reserve that layer.
  Caps have no collision layer and scan only layer 8, so environment bodies
  cannot discover them even with a broad collision mask. Existing touch areas
  stay on layer 1.
- Envelopes start disabled. Their sliders remain adjustable while disabled.
- Power is a standalone state control; it does not disable the other controls.

## Connecting future synth logic

Individual controls expose `value_changed(value: float)`, `pressed`, and
`released`. Values are clamped to **0..1**. Use `set_value(value)` to update both
state and appearance. Switches, buttons, and keys use 0 or 1. Set a slider's
`positions` to snap it to evenly spaced positions (`0` means continuous).
The waveform buttons keep exactly one waveform selected.

The exclusive group exposes `selection_changed(index: int)` and `select(index)`.
Its `options` array labels its child buttons; edit the scene's Buttons
children and options together if changing the number of buttons. Group selection
does not affect other instances.

Blocks expose `parameter_changed(parameter: StringName, value: float)` and
`get_parameter(parameter)`. Parameters are:

- Base frequency: `range` (indices 0 / 1 / 2).
- Wave selector: `waveform` (indices 0 / 1 / 2 / 3: sin / triangle / saw / square).
- Filter: `cutoff` (normalized).
- Volume: `volume` (normalized).
- Envelopes: `enabled`, `attack`, `decay`, `sustain`, `release` (normalized).

Map these normalized values to Hz, seconds, or gain when adding audio later.
The keyboard emits `note_pressed(note: int)` and `note_released(note: int)`
using MIDI note numbers 60..72. Change `first_note` to transpose it.

Run interaction checks with:

```powershell
godot --headless --path . --xr-mode off --script tests/synth_smoke.gd
```
