class_name GameUI
extends CanvasLayer

signal start_requested(p1: int, p2: int, versus_ai: bool)
signal training_requested(p1: int, p2: int)
signal rematch_requested
signal menu_requested
signal resume_requested
signal return_to_selection_requested

const INK := Color("172d3b")
const CREAM := Color("fff4dc")
const MUTED := Color("5a6b70")
const ORANGE := Color("ed7951")
const TEAL := Color("217f7b")
const Roster = preload("res://scripts/roster_data.gd")
const NAMES = Roster.NAMES
const DESCRIPTIONS = Roster.DESCRIPTIONS

var screen: String = "main"
var selected_mode: String = "single"
var selected: Array = [0, 1]
var locked: Array = [false, false]
var active_player: int = 0

var _built := false
var _root: Control
var _shade: ColorRect
var _menu: PanelContainer
var _hud: Control
var _result: PanelContainer
var _pause: PanelContainer
var _selection: Control
var _planet_map: Control
var _previews: Array = []
var _preview_names: Array[Label] = []
var _preview_countries: Array[Label] = []
var _preview_flags: Array[Control] = []
var _preview_descriptions: Array[Label] = []
var _player_tabs: Array[Button] = []
var _cards: Array[Button] = []
var _card_p1: Array[Label] = []
var _card_p2: Array[Label] = []
var _main_buttons: Array[Button] = []
var _main_choice := 0
var _selection_context: Label
var _selection_mode: Label
var _selection_keys: Label
var _confirm_button: Button
var _start_button: Button
var _practice_button: Button
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
	button.focus_mode = Control.FOCUS_NONE
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
	_build_character_select()
	_build_hud()
	_build_result()
	_build_pause()


func _build_menu() -> void:
	_menu = _panel(_root, Rect2(360, 134, 560, 452))
	var margin := MarginContainer.new()
	_menu.add_child(margin)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 22)
	var column := VBoxContainer.new()
	margin.add_child(column)
	column.add_theme_constant_override("separation", 20)
	var title := _label("STREET HUGGER", 43)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var rule := _label("First to five hugs.", 20, MUTED)
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(rule)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 12
	column.add_child(spacer)
	for index in range(2):
		var button := _button("Single Player" if index == 0 else "Multiplayer", TEAL)
		button.custom_minimum_size.y = 64
		column.add_child(button)
		_main_buttons.append(button)
		button.pressed.connect(choose_mode.bind("single" if index == 0 else "multi"))
		button.mouse_entered.connect(_set_main_choice.bind(index))
	var keys := _label("↑ / ↓ choose    Enter select", 15, MUTED)
	keys.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(keys)
	_refresh_main_buttons()


func _set_main_choice(index: int) -> void:
	_main_choice = index
	_refresh_main_buttons()


func _refresh_main_buttons() -> void:
	for index in range(_main_buttons.size()):
		var color := TEAL if index == _main_choice else INK
		_main_buttons[index].add_theme_stylebox_override("normal", _style(color))
		_main_buttons[index].add_theme_stylebox_override("hover", _style(color.lightened(0.1)))


func _place_label(parent: Node, text: String, font_size: int, rect: Rect2, color: Color = INK) -> Label:
	var label := _label(text, font_size, color)
	parent.add_child(label)
	label.position = rect.position
	label.size = rect.size
	return label


func _make_portrait(parent: Control, rect: Rect2, index: int, look_direction: float, animate: bool) -> Control:
	var portrait_script = load("res://scripts/fighter_portrait.gd")
	var portrait: Control = portrait_script.new()
	parent.add_child(portrait)
	portrait.position = rect.position
	portrait.size = rect.size
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.set("facing", look_direction)
	portrait.set("animated", animate)
	portrait.call("set_character", index)
	return portrait

func _make_flag(parent: Control, rect: Rect2, index: int) -> Control:
	var flag = load("res://scripts/country_flag.gd").new()
	parent.add_child(flag)
	flag.position = rect.position
	flag.size = rect.size
	flag.country_index = index
	return flag


func _build_character_select() -> void:
	_selection = Control.new()
	_root.add_child(_selection)
	_selection.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_selection.mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	_selection.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("102733")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place_label(_selection, "CHARACTER SELECT", 27, Rect2(42, 19, 440, 40), CREAM)
	_selection_mode = _place_label(_selection, "", 17, Rect2(860, 25, 378, 30), Color("a9ccc4"))
	_selection_mode.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for player in range(2):
		var x := 42.0 if player == 0 else 994.0
		var preview_panel := _panel(_selection, Rect2(x, 78, 244, 244), CREAM)
		preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var content := Control.new()
		preview_panel.add_child(content)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tab := _button("P1" if player == 0 else "OPPONENT", ORANGE if player == 0 else TEAL)
		_selection.add_child(tab)
		tab.position = Vector2(x, 75)
		tab.size = Vector2(244, 39)
		tab.custom_minimum_size.y = 39
		tab.add_theme_font_size_override("font_size", 16)
		tab.pressed.connect(_edit_player.bind(player))
		_player_tabs.append(tab)
		var portrait := _make_portrait(content, Rect2(4, 30, 204, 143), selected[player], 1.0 if player == 0 else -1.0, true)
		_previews.append(portrait)
		var name_label := _place_label(content, "", 21, Rect2(0, 169, 208, 28))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_preview_names.append(name_label)
		var country := _place_label(content, "", 16, Rect2(0, 198, 208, 22), MUTED)
		country.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_preview_countries.append(country)
		_preview_flags.append(_make_flag(content, Rect2(44, 198, 36, 22), selected[player]))
		var detail_x := 46.0 if player == 0 else 1028.0
		var detail := _place_label(_selection, "", 17, Rect2(detail_x, 348, 206, 130), CREAM)
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_preview_descriptions.append(detail)
	var map_script = load("res://scripts/planet_map.gd")
	_planet_map = map_script.new()
	_selection.add_child(_planet_map)
	_planet_map.position = Vector2(306, 76)
	_planet_map.size = Vector2(668, 241)
	_planet_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place_label(_selection, Roster.PLANET, 14, Rect2(322, 83, 120, 22), Color("a9ccc4"))
	_selection_context = _place_label(_selection, "", 18, Rect2(304, 312, 672, 30), CREAM)
	_selection_context.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for index in range(8):
		var card := Button.new()
		_selection.add_child(card)
		card.position = Vector2(266 + (index % 4) * 190, 350 + (index / 4) * 128)
		card.size = Vector2(178, 118)
		card.focus_mode = Control.FOCUS_NONE
		card.clip_contents = true
		card.pressed.connect(_click_character.bind(index))
		card.add_theme_stylebox_override("normal", _style(CREAM))
		card.add_theme_stylebox_override("hover", _style(Color("fffaf0"), TEAL))
		card.add_theme_stylebox_override("pressed", _style(Color("ecdfc3"), ORANGE))
		_make_portrait(card, Rect2(12, 4, 154, 73), index, 1.0, false)
		var character_name := _place_label(card, NAMES[index], 17, Rect2(6, 76, 166, 22))
		character_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var country_width := ThemeDB.fallback_font.get_string_size(Roster.COUNTRIES[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		var country_start := (178.0 - country_width - 28.0) * 0.5
		_make_flag(card, Rect2(country_start, 101, 22, 13), index)
		_place_label(card, Roster.COUNTRIES[index], 13, Rect2(country_start + 28, 98, country_width + 2, 17), MUTED)
		var first_mark := _place_label(card, "P1", 13, Rect2(8, 4, 78, 20), ORANGE)
		var second_mark := _place_label(card, "CPU", 13, Rect2(88, 4, 82, 20), TEAL)
		second_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_card_p1.append(first_mark)
		_card_p2.append(second_mark)
		_cards.append(card)
	_selection_keys = _place_label(_selection, "", 14, Rect2(266, 611, 750, 36), Color("c0d4cf"))
	_selection_keys.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var back := _button("BACK", INK)
	_selection.add_child(back)
	back.position = Vector2(42, 654)
	back.size = Vector2(144, 42)
	back.custom_minimum_size.y = 42
	back.pressed.connect(back_setup)
	_practice_button = _button("PRACTICE (stationary partner)", INK)
	_selection.add_child(_practice_button)
	_practice_button.position = Vector2(200, 654)
	_practice_button.size = Vector2(332, 42)
	_practice_button.custom_minimum_size.y = 42
	_practice_button.add_theme_font_size_override("font_size", 16)
	_practice_button.pressed.connect(_launch_practice)
	_confirm_button = _button("CONFIRM P1", ORANGE)
	_selection.add_child(_confirm_button)
	_confirm_button.position = Vector2(798, 654)
	_confirm_button.size = Vector2(216, 42)
	_confirm_button.custom_minimum_size.y = 42
	_confirm_button.add_theme_font_size_override("font_size", 17)
	_confirm_button.pressed.connect(_confirm_active)
	_start_button = _button("START MATCH", TEAL)
	_selection.add_child(_start_button)
	_start_button.position = Vector2(1030, 654)
	_start_button.size = Vector2(208, 42)
	_start_button.custom_minimum_size.y = 42
	_start_button.add_theme_font_size_override("font_size", 18)
	_start_button.pressed.connect(launch_selection)
	_selection.hide()


func choose_mode(mode: String) -> void:
	selected_mode = "multi" if mode == "multi" else "single"
	show_character_select()


func show_character_select() -> void:
	_build()
	screen = "select"
	locked = [false, false]
	active_player = 0
	_menu.hide()
	_selection.show()
	_shade.hide()
	_hud.hide()
	_result.hide()
	_pause.hide()
	_refresh_selection()


func choose_character(player: int, index: int) -> void:
	if player < 0 or player > 1 or screen != "select" or locked[player]:
		return
	selected[player] = clampi(index, 0, 7)
	active_player = player
	_refresh_selection()


func confirm_player(player: int) -> void:
	if player < 0 or player > 1 or screen != "select":
		return
	locked[player] = true
	active_player = 1 - player if not locked[1 - player] else player
	_refresh_selection()


func _confirm_active() -> void:
	confirm_player(active_player)


func _edit_player(player: int) -> void:
	active_player = player
	locked[player] = false
	_refresh_selection()


func _click_character(index: int) -> void:
	locked[active_player] = false
	choose_character(active_player, index)


func back_setup() -> void:
	if screen != "select":
		show_menu()
		return
	if locked[active_player]:
		locked[active_player] = false
	elif locked[1 - active_player]:
		active_player = 1 - active_player
		locked[active_player] = false
	else:
		show_menu()
		return
	_refresh_selection()


func launch_selection() -> void:
	if screen != "select" or not (locked[0] and locked[1]):
		return
	screen = "match"
	get_viewport().gui_release_focus()
	start_requested.emit(selected[0], selected[1], selected_mode == "single")


func _launch_practice() -> void:
	if screen != "select" or selected_mode != "single":
		return
	screen = "match"
	get_viewport().gui_release_focus()
	training_requested.emit(selected[0], selected[1])


func _refresh_selection() -> void:
	var opponent := "CPU" if selected_mode == "single" else "P2"
	_selection_mode.text = "Single Player" if selected_mode == "single" else "Multiplayer / local"
	for player in range(2):
		var index: int = selected[player]
		_previews[player].call("set_character", index)
		_preview_names[player].text = NAMES[index]
		_preview_countries[player].text = Roster.COUNTRIES[index]
		var country_width := ThemeDB.fallback_font.get_string_size(Roster.COUNTRIES[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		var country_start := (208.0 - country_width - 44.0) * 0.5
		_preview_flags[player].set("country_index", index)
		_preview_flags[player].position = Vector2(country_start, 198)
		_preview_countries[player].position = Vector2(country_start + 44, 198)
		_preview_countries[player].size = Vector2(country_width + 2, 22)
		_preview_countries[player].horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_preview_descriptions[player].text = DESCRIPTIONS[index]
		var player_caption := "P1" if player == 0 else opponent
		_player_tabs[player].text = player_caption + (" / LOCKED" if locked[player] else " / SELECTING" if player == active_player else " / EDIT")
		var tab_color := ORANGE if player == 0 else TEAL
		_player_tabs[player].add_theme_stylebox_override("normal", _style(tab_color if player == active_player else tab_color.darkened(0.3)))
	for index in range(8):
		var is_first: bool = selected[0] == index
		var is_second: bool = selected[1] == index
		_card_p1[index].visible = is_first
		_card_p2[index].visible = is_second
		_card_p1[index].text = "P1 ✓" if locked[0] else "P1"
		_card_p2[index].text = opponent + (" ✓" if locked[1] else "")
		var edge := ORANGE if is_first else TEAL if is_second else Color("63808a")
		var style := _style(CREAM, edge, 10)
		style.set_border_width_all(4 if is_first or is_second else 1)
		_cards[index].add_theme_stylebox_override("normal", style)
		var hover_style := style.duplicate() as StyleBoxFlat
		hover_style.bg_color = CREAM.lightened(0.04)
		_cards[index].add_theme_stylebox_override("hover", hover_style)
		var pressed_style := style.duplicate() as StyleBoxFlat
		pressed_style.bg_color = CREAM.darkened(0.06)
		_cards[index].add_theme_stylebox_override("pressed", pressed_style)
	_planet_map.set("opponent_label", opponent)
	_planet_map.call("set_selections", selected[0], selected[1], active_player)
	var ready: bool = locked[0] and locked[1]
	_selection_context.text = "Both players ready" if ready else "Select P1" if active_player == 0 else "Select opponent" if selected_mode == "single" else "Select P2"
	_start_button.visible = ready
	_confirm_button.visible = not ready
	_confirm_button.text = "CONFIRM P1" if active_player == 0 else "CONFIRM CPU" if selected_mode == "single" else "CONFIRM P2"
	_practice_button.visible = selected_mode == "single"
	_selection_keys.text = "A/D/W/S choose    F confirm    G back    Tab switch player\nEnter starts when both characters are confirmed" if selected_mode == "single" else "P1  A/D/W/S choose · F confirm · G back     P2  arrows choose · K confirm · L back\nEnter starts when both characters are confirmed"


func _move_selector(player: int, horizontal: int, vertical: int) -> void:
	if locked[player]:
		return
	var index: int = selected[player]
	var column := (index % 4 + horizontal + 4) % 4
	var row := (index / 4 + vertical + 2) % 2
	choose_character(player, row * 4 + column)


func _unhandled_key_input(event: InputEvent) -> void:
	if screen != "main" and screen != "select":
		return
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	var handled := true
	if screen == "main":
		match key:
			KEY_UP, KEY_W:
				_set_main_choice((_main_choice + 1) % 2)
			KEY_DOWN, KEY_S:
				_set_main_choice((_main_choice + 1) % 2)
			KEY_ENTER, KEY_KP_ENTER, KEY_F:
				choose_mode("single" if _main_choice == 0 else "multi")
			_:
				handled = false
	else:
		var p1 := active_player if selected_mode == "single" else 0
		match key:
			KEY_A: _move_selector(p1, -1, 0)
			KEY_D: _move_selector(p1, 1, 0)
			KEY_W: _move_selector(p1, 0, -1)
			KEY_S: _move_selector(p1, 0, 1)
			KEY_F: confirm_player(p1)
			KEY_G:
				active_player = p1
				back_setup()
			KEY_LEFT:
				if selected_mode == "multi": _move_selector(1, -1, 0)
				else: _move_selector(active_player, -1, 0)
			KEY_RIGHT:
				if selected_mode == "multi": _move_selector(1, 1, 0)
				else: _move_selector(active_player, 1, 0)
			KEY_UP:
				if selected_mode == "multi": _move_selector(1, 0, -1)
				else: _move_selector(active_player, 0, -1)
			KEY_DOWN:
				if selected_mode == "multi": _move_selector(1, 0, 1)
				else: _move_selector(active_player, 0, 1)
			KEY_K:
				if selected_mode == "multi": confirm_player(1)
				else: confirm_player(active_player)
			KEY_L:
				if selected_mode == "multi":
					active_player = 1
					back_setup()
				else:
					back_setup()
			KEY_TAB: _edit_player(1 - active_player)
			KEY_ESCAPE: back_setup()
			KEY_ENTER, KEY_KP_ENTER:
				if locked[0] and locked[1]: launch_selection()
				else: confirm_player(active_player)
			_:
				handled = false
	if handled:
		get_viewport().set_input_as_handled()

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
	var p1_controls := _label("P1   A/D MOVE    W/SPACE JUMP    F HUG    G DEFLECT    H FEINT    J SIGNATURE", 15, CREAM)
	p1_controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_child(p1_controls)
	_p2_controls = _label("", 15, Color("9cd8cb"))
	_p2_controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_child(_p2_controls)


func _build_result() -> void:
	_result = _panel(_root, Rect2(390, 214, 500, 292))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	_result.add_child(column)
	_result_text = _label("", 30)
	_result_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_result_text)
	var rematch := _button("REMATCH", TEAL)
	column.add_child(rematch)
	rematch.pressed.connect(func() -> void:
		rematch.release_focus()
		rematch_requested.emit()
	)
	var back := _button("CHOOSE CHARACTERS", ORANGE)
	column.add_child(back)
	back.pressed.connect(func() -> void:
		back.release_focus()
		return_to_selection_requested.emit()
	)
	var main_menu := _button("MAIN MENU", INK)
	column.add_child(main_menu)
	main_menu.pressed.connect(func() -> void: menu_requested.emit())


func _build_pause() -> void:
	_pause = _panel(_root, Rect2(430, 195, 420, 330))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	_pause.add_child(column)
	var title := _label("PAUSED", 30)
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
		return_to_selection_requested.emit()
	)
	var main_menu := _button("MAIN MENU", INK)
	column.add_child(main_menu)
	main_menu.pressed.connect(func() -> void: menu_requested.emit())


func show_menu() -> void:
	_build()
	screen = "main"
	_shade.show()
	_menu.show()
	_selection.hide()
	_hud.hide()
	_result.hide()
	_pause.hide()


func show_match(p1_name: String, p2_name: String, versus_ai: bool) -> void:
	_build()
	screen = "match"
	set_practice(false)
	_menu.hide()
	_selection.hide()
	_shade.hide()
	_hud.show()
	_result.hide()
	_pause.hide()
	_p1_name.text = "P1 / " + p1_name
	_p2_name.text = ("CPU / " if versus_ai else "P2 / ") + p2_name
	_p2_controls.text = "CPU OPPONENT     •     ESC PAUSE" if versus_ai else "P2   ←/→ MOVE    ↑ JUMP    K HUG    L DEFLECT    ; FEINT    ' SIGNATURE    •    ESC PAUSE"
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
		_p2_name.text = _p2_name.text.replace("P2 / ", "PARTNER / ")
		_timer.text = "∞"
		_timer.add_theme_color_override("font_color", INK)
		_p2_controls.text = "PARTNER CONTROLS DISABLED     •     ESC PAUSE / CHOOSE CHARACTERS"


func show_result(message: String) -> void:
	_build()
	screen = "result"
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
	if value:
		screen = "paused"
	elif screen == "paused":
		screen = "match"
	_pause.visible = value
	_shade.visible = value or _menu.visible or _result.visible
