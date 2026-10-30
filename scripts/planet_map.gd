class_name PlanetMap
extends Control

## An original map of Pelara. Coordinates are authored on a 680 x 260 canvas.
## Public centers use local Control coordinates, including responsive letterboxing.

const Roster = preload("res://scripts/roster_data.gd")
const DESIGN_SIZE := Vector2(680, 260)
const P1 := Color("f19858")
const P2 := Color("61d4c7")
const OCEAN := Color("182f40")
const BORDER := Color("142c3a")
const COLORS: Array[Color] = [
	Color("a6b7a0"), Color("c3b286"), Color("839f9a"), Color("a3a58a"),
	Color("b5a485"), Color("9aacac"), Color("b6b990"), Color("8da99b")
]
const CENTERS: Array[Vector2] = [
	Vector2(145, 80), Vector2(266, 89), Vector2(142, 143), Vector2(225, 148),
	Vector2(309, 170), Vector2(480, 87), Vector2(568, 125), Vector2(503, 171)
]

var p1_index: int = 0
var p2_index: int = 1
var active_player: int = 0
var opponent_label: String = "P2"
var show_countries: bool = true
var _clock: float = 0.0
var _countries: Array[PackedVector2Array] = []


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_countries = [
		_polygon([82,66, 112,45, 160,53, 194,39, 228,54, 216,90, 176,113, 130,109, 87,111, 67,94]),
		_polygon([228,54, 257,53, 281,77, 312,79, 334,108, 291,119, 248,120, 216,90]),
		_polygon([87,111, 130,109, 176,113, 191,145, 173,169, 155,186, 125,179, 112,150, 91,139]),
		_polygon([176,113, 216,90, 248,120, 291,119, 285,160, 244,181, 210,196, 173,207, 155,186, 173,169, 191,145]),
		_polygon([334,108, 352,113, 366,143, 347,161, 339,190, 311,204, 288,222, 258,211, 231,215, 210,196, 244,181, 285,160, 291,119]),
		_polygon([429,77, 458,56, 485,61, 512,47, 542,58, 532,100, 492,122, 452,119, 426,111]),
		_polygon([542,58, 561,79, 583,84, 603,110, 594,137, 612,153, 594,178, 565,182, 544,152, 532,100]),
		_polygon([565,182, 548,207, 514,218, 486,198, 469,201, 454,176, 432,164, 441,137, 452,119, 492,122, 532,100, 544,152])
	]


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()


func set_selections(p1: int, p2: int, player: int = 0) -> void:
	p1_index = clampi(p1, 0, 7)
	p2_index = clampi(p2, 0, 7)
	active_player = clampi(player, 0, 1)
	queue_redraw()


func country_center(index: int) -> Vector2:
	return _point(CENTERS[clampi(index, 0, 7)])


func _scale_factor() -> float:
	return maxf(0.01, minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y))


func _point(value: Vector2) -> Vector2:
	var scale_factor := _scale_factor()
	return (size - DESIGN_SIZE * scale_factor) * 0.5 + value * scale_factor


func _scaled(points: PackedVector2Array, shift: Vector2 = Vector2.ZERO) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in points:
		result.append(_point(point + shift))
	return result


func _polygon(values: Array) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(0, values.size(), 2):
		points.append(Vector2(float(values[index]), float(values[index + 1])))
	return points


func _outline(points: PackedVector2Array, color: Color, width: float) -> void:
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, color, width, true)


func _draw() -> void:
	if size.x < 2 or size.y < 2:
		return
	var scale_factor := _scale_factor()
	var frame := StyleBoxFlat.new()
	frame.bg_color = OCEAN
	frame.border_color = Color("3a5360")
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(12)
	draw_style_box(frame, Rect2(Vector2.ZERO, size))
	# Latitude/longitude guides form a restrained background, not an Earth map.
	var grid := Color(0.57, 0.72, 0.75, 0.09)
	for x in range(30, 660, 50):
		draw_line(_point(Vector2(x, 18)), _point(Vector2(x, 242)), grid, 1.0)
	for y in range(30, 250, 40):
		draw_line(_point(Vector2(20, y)), _point(Vector2(660, y)), grid, 1.0)
	# A tiny compass gives this fictional geography a cartographic anchor.
	var compass := _point(Vector2(35, 205))
	var compass_color := Color("6b8790")
	draw_line(compass + Vector2(0, -11) * scale_factor, compass + Vector2(0, 10) * scale_factor, compass_color, 1.0)
	draw_line(compass + Vector2(-8, 0) * scale_factor, compass + Vector2(8, 0) * scale_factor, compass_color, 1.0)
	draw_colored_polygon(_scaled(_polygon([32,198, 35,190, 38,198])), compass_color)
	_text("N", Vector2(35, 185), 10, compass_color)
	# Offset land shadows separate the coast from the water without noisy textures.
	for points in _countries:
		draw_colored_polygon(_scaled(points, Vector2(0, 3)), Color("0d2534"))
	for index in range(_countries.size()):
		var fill := COLORS[index]
		if index == p1_index and index == p2_index:
			fill = P1.lerp(P2, 0.5).darkened(0.12)
		elif index == p1_index:
			fill = P1.darkened(0.1)
		elif index == p2_index:
			fill = P2.darkened(0.15)
		var points := _scaled(_countries[index])
		draw_colored_polygon(points, fill)
		_outline(points, BORDER, maxf(1.3, 2.0 * scale_factor))
	# Selected borders are drawn last, so neighbors never cover the highlight.
	var active_index := p1_index if active_player == 0 else p2_index
	var active_color := P1 if active_player == 0 else P2
	if p1_index == p2_index:
		_outline(_scaled(_countries[p1_index]), P1.lightened(0.15), maxf(2.0, 5.0 * scale_factor))
		_outline(_scaled(_countries[p1_index]), P2.lightened(0.18), maxf(1.0, 2.0 * scale_factor))
	else:
		_outline(_scaled(_countries[p1_index]), P1.lightened(0.15), maxf(1.5, 3.0 * scale_factor))
		_outline(_scaled(_countries[p2_index]), P2.lightened(0.15), maxf(1.5, 3.0 * scale_factor))
	var pulse_alpha := 0.11 + 0.06 * sin(_clock * 2.5)
	draw_colored_polygon(_scaled(_countries[active_index]), Color(active_color, pulse_alpha))
	if show_countries:
		for index in range(CENTERS.size()):
			var selected := index == p1_index or index == p2_index
			var baseline := CENTERS[index] + Vector2(0, 14 if selected else 4)
			_text(Roster.COUNTRIES[index], baseline, 12, Color("142b36"))
	if p1_index == p2_index:
		_marker(CENTERS[p1_index] + Vector2(-17, -9), "P1", P1, active_player == 0)
		_marker(CENTERS[p2_index] + Vector2(17, -9), opponent_label, P2, active_player == 1)
	else:
		_marker(CENTERS[p1_index] + Vector2(0, -9), "P1", P1, active_player == 0)
		_marker(CENTERS[p2_index] + Vector2(0, -9), opponent_label, P2, active_player == 1)


func _marker(at: Vector2, value: String, color: Color, active: bool) -> void:
	var scale_factor := _scale_factor()
	var center := _point(at)
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("173141")
	panel.border_color = color.lightened(0.2) if active else color
	panel.set_border_width_all(2 if active else 1)
	panel.set_corner_radius_all(maxi(2, int(4 * scale_factor)))
	draw_style_box(panel, Rect2(center - Vector2(15, 10) * scale_factor, Vector2(30, 20) * scale_factor))
	_text(value, at + Vector2(0, 4), 11, color.lightened(0.12))


func _text(value: String, baseline: Vector2, font_size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var scaled_size := maxi(8, roundi(font_size * _scale_factor()))
	var text_width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, scaled_size).x
	draw_string(font, _point(baseline) - Vector2(text_width * 0.5, 0), value, HORIZONTAL_ALIGNMENT_LEFT, -1, scaled_size, color)
