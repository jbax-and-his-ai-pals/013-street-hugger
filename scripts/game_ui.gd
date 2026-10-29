class_name GameUI
extends CanvasLayer

signal start_requested(p1: int, p2: int, versus_ai: bool)
signal training_requested(p1: int, p2: int)
signal rematch_requested
signal menu_requested
signal resume_requested

const INK := Color("172d3b")
const CREAM := Color("fff4dc")
const MUTED := Color("5a6b70")
const ORANGE := Color("ed7951")
const TEAL := Color("217f7b")
const NAMES := ["Champ", "Long Arms", "Backwards Baxter", "Acrobat", "Big Softy", "Speedster", "Showboat", "Boomerang"]
const DESCRIPTIONS := [
	"A dependable advancing embrace. Learn the spacing, then own it.",
	"A long-distance squeeze. Great reach demands careful commitment.",
	"Turn away and welcome a pursuer with a backwards embrace.",
	"An upside-down approach with an unusual contact rhythm.",
	"A broad, deliberate bear hug. Patience is part of the technique.",
	"Close the gap in a hurry. Aim that little squeeze carefully.",
	"A theatrical flourish. Press H early to cancel it into a feint.",
	"A passing approach and a return embrace. Watch the turn."
]

var _built := false
var _root: Control
var _shade: ColorRect
var _menu: PanelContainer
var _hud: Control
var _result: PanelContainer
var _pause: PanelContainer
var _p1_select: OptionButton
var _p2_select: OptionButton
var _ai: CheckButton
var _p1_detail: Label
var _p2_detail: Label
var _p1_name: Label
var _p2_name: Label
var _p1_score: Label
var _p2_score: Label
var _timer: Label
var _status: Label
var _result_text: Label
var _p2_controls: Label
var _p1_signature: Label
var _p2_signature: Label
var _round_label: Label
var _practice := false


func _ready() -> void:
	_build()
	show_menu()


func _style(background: Color, border: Color = INK, radius: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _label(text: String, size: int, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(text: String, color: Color = ORANGE) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", CREAM)
	button.add_theme_color_override("font_pressed_color", CREAM)
	button.add_theme_stylebox_override("normal", _style(color))
	button.add_theme_stylebox_override("hover", _style(color.lightened(0.12)))
	button.add_theme_stylebox_override("pressed", _style(color.darkened(0.13)))
	button.add_theme_stylebox_override("focus", _style(Color(1, 1, 1, 0), ORANGE, 14))
	return button


func _panel(parent: Node, rect: Rect2, background: Color = CREAM) -> PanelContainer:
	var panel := PanelContainer.new()
	parent.add_child(panel)
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", _style(background))
	return panel


func _build() -> void:
	if _built:
		return
	_built = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_root = Control.new()
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shade = ColorRect.new()
	_root.add_child(_shade)
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.color = Color(0.045, 0.10, 0.14, 0.56)
	_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_build_menu()
	_build_hud()
	_build_result()
	_build_pause()


func _build_menu() -> void:
	_menu = _panel(_root, Rect2(150, 34, 980, 652))
	var margin := MarginContainer.new()
	_menu.add_child(margin)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	var layout := VBoxContainer.new()
	margin.add_child(layout)
	layout.add_theme_constant_override("separation", 8)
	var eyebrow := _label("NEIGHBORHOOD INVITATIONAL  /  PLAYABLE PROTOTYPE", 15, TEAL)
	layout.add_child(eyebrow)
	var title := _label("STREET HUGGER", 48)
	layout.add_child(title)
	var subtitle := _label("Serious stances. Sincere embraces. First to five hugs wins.", 20, MUTED)
	layout.add_child(subtitle)
	var divider := HSeparator.new()
	layout.add_child(divider)
	var picks := HBoxContainer.new()
	picks.add_theme_constant_override("separation", 24)
	layout.add_child(picks)
	var first := _character_picker("PLAYER ONE", ORANGE)
	var second := _character_picker("PLAYER TWO", TEAL)
	picks.add_child(first)
	picks.add_child(second)
	_p1_select = first.get_meta("selector") as OptionButton
	_p2_select = second.get_meta("selector") as OptionButton
	_p1_detail = first.get_meta("detail") as Label
	_p2_detail = second.get_meta("detail") as Label
	_p2_select.select(1)
	_p1_detail.text = DESCRIPTIONS[0]
	_p2_detail.text = DESCRIPTIONS[1]
	_p1_select.item_selected.connect(func(index: int) -> void: _p1_detail.text = DESCRIPTIONS[index])
	_p2_select.item_selected.connect(func(index: int) -> void: _p2_detail.text = DESCRIPTIONS[index])
	_ai = CheckButton.new()
	_ai.text = "Computer opponent   /   switch off for local two-player"
	_ai.button_pressed = true
	_ai.add_theme_color_override("font_color", INK)
	_ai.add_theme_color_override("font_pressed_color", INK)
	_ai.add_theme_color_override("font_hover_color", INK)
	_ai.add_theme_color_override("font_hover_pressed_color", INK)
	_ai.add_theme_color_override("font_focus_color", INK)
	_ai.add_theme_color_override("font_disabled_color", MUTED)
	_ai.add_theme_font_size_override("font_size", 18)
	layout.add_child(_ai)
	var rules := _label("HUG catches an opening. DEFLECT stops a hug. FEINT baits a deflect.\nMissed attempts leave you open. Your signature changes the approach.", 17, MUTED)
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(rules)
	var controls := _label("P1   A / D move    F hug    G deflect    H feint    J signature\nP2   ← / → move    K hug    L deflect    ; feint    ' signature", 17)
	layout.add_child(controls)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	layout.add_child(actions)
	var start := _button("STEP INTO THE STREET", TEAL)
	start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start.add_theme_font_size_override("font_size", 18)
	actions.add_child(start)
	start.pressed.connect(func() -> void:
		start.release_focus()
		_p1_select.release_focus()
		_p2_select.release_focus()
		_ai.release_focus()
		start_requested.emit(_p1_select.selected, _p2_select.selected, _ai.button_pressed)
	)
	var practice := _button("PRACTICE • stationary partner", ORANGE)
	practice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	practice.add_theme_font_size_override("font_size", 18)
	actions.add_child(practice)
	practice.pressed.connect(func() -> void:
		practice.release_focus()
		_p1_select.release_focus()
		_p2_select.release_focus()
		_ai.release_focus()
		training_requested.emit(_p1_select.selected, _p2_select.selected)
	)
	var note := _label("Land a hug. Read the reply. Run it back.", 14, MUTED)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(note)


func _character_picker(caption: String, accent: Color) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	box.add_child(_label(caption, 16, accent))
	var selector := OptionButton.new()
	selector.custom_minimum_size = Vector2(420, 44)
	selector.add_theme_font_size_override("font_size", 22)
	selector.add_theme_color_override("font_color", INK)
	selector.add_theme_color_override("font_hover_color", INK)
	selector.add_theme_stylebox_override("normal", _style(Color("f3e6cb")))
	selector.add_theme_stylebox_override("hover", _style(Color("f9edd5"), accent))
	selector.add_theme_stylebox_override("pressed", _style(Color("eadbbd"), accent))
	for character_name in NAMES:
		selector.add_item(character_name)
	box.add_child(selector)
	var detail := _label("", 17, MUTED)
	detail.custom_minimum_size = Vector2(0, 64)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(detail)
	box.set_meta("selector", selector)
	box.set_meta("detail", detail)
	return box


func _build_hud() -> void:
	_hud = Control.new()
	_root.add_child(_hud)
	_hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top := _panel(_hud, Rect2(36, 20, 1208, 88))
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	top.add_child(row)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 20)
	var first_column := VBoxContainer.new()
	first_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	first_column.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(first_column)
	_p1_name = _label("PLAYER ONE", 24, ORANGE)
	first_column.add_child(_p1_name)
	_p1_signature = _label("SIGNATURE READY", 13, TEAL)
	first_column.add_child(_p1_signature)
	_p1_score = _label("0", 44, ORANGE)
	row.add_child(_p1_score)
	var center := VBoxContainer.new()
	center.custom_minimum_size.x = 150
	row.add_child(center)
	_round_label = _label("FIRST TO FIVE", 13, MUTED)
	_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_round_label)
	_timer = _label("60", 32)
	_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_timer)
	_p2_score = _label("0", 44, TEAL)
	row.add_child(_p2_score)
	var second_column := VBoxContainer.new()
	second_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	second_column.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(second_column)
	_p2_name = _label("PLAYER TWO", 24, TEAL)
	_p2_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	second_column.add_child(_p2_name)
	_p2_signature = _label("SIGNATURE READY", 13, TEAL)
	_p2_signature.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	second_column.add_child(_p2_signature)
	_status = _label("", 26, CREAM)
	_hud.add_child(_status)
	_status.position = Vector2(130, 124)
	_status.size = Vector2(1020, 46)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_color_override("font_shadow_color", INK)
	_status.add_theme_constant_override("shadow_offset_x", 2)
	_status.add_theme_constant_override("shadow_offset_y", 2)
	var strip := _panel(_hud, Rect2(36, 634, 1208, 64), Color("172d3b"))
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var controls := VBoxContainer.new()
	strip.add_child(controls)
	controls.add_theme_constant_override("separation", 2)
	var p1_controls := _label("P1   A/D MOVE     F HUG     G DEFLECT     H FEINT     J SIGNATURE", 15, CREAM)
	p1_controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_child(p1_controls)
	_p2_controls = _label("", 15, Color("9cd8cb"))
	_p2_controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_child(_p2_controls)


func _build_result() -> void:
	_result = _panel(_root, Rect2(390, 238, 500, 244))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	_result.add_child(column)
	var caption := _label("A WELL-FOUGHT EMBRACE", 16, TEAL)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(caption)
	_result_text = _label("", 30)
	_result_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_result_text)
	var rematch := _button("ONE MORE ROUND", TEAL)
	column.add_child(rematch)
	rematch.pressed.connect(func() -> void:
		rematch.release_focus()
		rematch_requested.emit()
	)
	var back := _button("CHOOSE CHARACTERS", ORANGE)
	column.add_child(back)
	back.pressed.connect(func() -> void:
		back.release_focus()
		menu_requested.emit()
	)


func _build_pause() -> void:
	_pause = _panel(_root, Rect2(430, 220, 420, 280))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	_pause.add_child(column)
	var title := _label("TAKE A BREATHER", 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var instruction := _label("Press ESC to return to the match.", 18, MUTED)
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(instruction)
	var resume := _button("RESUME", TEAL)
	column.add_child(resume)
	resume.pressed.connect(func() -> void:
		resume.release_focus()
		resume_requested.emit()
	)
	var back := _button("CHOOSE CHARACTERS", ORANGE)
	column.add_child(back)
	back.pressed.connect(func() -> void:
		back.release_focus()
		menu_requested.emit()
	)


func show_menu() -> void:
	_build()
	_shade.show()
	_menu.show()
	_hud.hide()
	_result.hide()
	_pause.hide()


func show_match(p1_name: String, p2_name: String, versus_ai: bool) -> void:
	_build()
	set_practice(false)
	_menu.hide()
	_shade.hide()
	_hud.show()
	_result.hide()
	_pause.hide()
	_p1_name.text = p1_name
	_p2_name.text = p2_name + ("  / CPU" if versus_ai else "")
	_p2_controls.text = "CPU OPPONENT     •     ESC PAUSE" if versus_ai else "P2   ←/→ MOVE     K HUG     L DEFLECT     ; FEINT     ' SIGNATURE     •     ESC PAUSE"
	update_hud(0, 0, 60.0, "")
	update_signatures(0.0, 0.0)


func update_hud(p1_score: int, p2_score: int, seconds: float, status: String) -> void:
	_build()
	_p1_score.text = str(p1_score)
	_p2_score.text = str(p2_score)
	_timer.text = "∞" if _practice else "%02d" % maxi(0, int(ceil(seconds)))
	_timer.add_theme_color_override("font_color", ORANGE if not _practice and seconds <= 10.0 else INK)
	_status.text = status


func set_practice(value: bool) -> void:
	_build()
	_practice = value
	_round_label.text = "PRACTICE" if value else "FIRST TO FIVE"
	if value:
		_timer.text = "∞"
		_timer.add_theme_color_override("font_color", INK)
		_p2_controls.text = "STATIONARY PARTNER     •     ESC PAUSE / CHOOSE CHARACTERS"


func show_result(message: String) -> void:
	_build()
	_pause.hide()
	_shade.show()
	_result.show()
	_result_text.text = message


func update_signatures(p1_cooldown: float, p2_cooldown: float) -> void:
	_build()
	_signature_label(_p1_signature, p1_cooldown)
	_signature_label(_p2_signature, p2_cooldown)


func _signature_label(label: Label, cooldown: float) -> void:
	label.text = "SIGNATURE READY" if cooldown <= 0.0 else "SIGNATURE  %.1fs" % cooldown
	label.add_theme_color_override("font_color", TEAL if cooldown <= 0.0 else MUTED)


func set_paused(value: bool) -> void:
	_build()
	_pause.visible = value
	_shade.visible = value or _menu.visible or _result.visible
