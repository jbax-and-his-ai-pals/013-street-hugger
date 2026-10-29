extends Node2D
class_name StreetStage

## A fully procedural neighborhood arena. Feet meet the pavement at y = 555.
## All artwork is drawn locally: this stage consumes no image-generation quota.

var clock: float = 0.0

const INK := Color("33444a")
const CREAM := Color("fff0d0")
const TEAL := Color("397e82")


func _process(delta: float) -> void:
	clock += delta
	queue_redraw()


func _draw() -> void:
	# Keep the upper sky quiet for the game's HUD.
	draw_rect(Rect2(0, 0, 1280, 720), Color("f8dfad"))
	draw_rect(Rect2(0, 0, 1280, 310), Color("9bcbd1"))
	draw_rect(Rect2(0, 0, 1280, 100), Color("aed8db"))
	draw_circle(Vector2(1110, 145), 44, Color("ffe7a0"))
	draw_circle(Vector2(1110, 145), 32, Color("fff0bd"))
	_cloud(Vector2(130 + sin(clock * 0.04) * 10, 141), 0.85)
	_cloud(Vector2(762 + sin(clock * 0.035 + 1.0) * 14, 120), 0.67)
	_cloud(Vector2(974 + sin(clock * 0.03) * 8, 208), 0.5)
	# Muted distant roofs help the street feel larger than the arena.
	draw_rect(Rect2(0, 252, 1280, 175), Color("8cafab"))
	for x in range(0, 1280, 155):
		draw_rect(Rect2(x, 224 + (x % 3) * 11, 125, 205), Color("83a5a5"))
		for wx in range(x + 20, x + 110, 35):
			draw_rect(Rect2(wx, 256, 15, 23), Color("abc7bc"))
	_storefronts()
	_bunting()
	_tree(Vector2(37, 451), 0.9)
	_tree(Vector2(1248, 454), 0.85)
	# Spectators stay towards the sides, leaving both fighters easy to read.
	for index in range(4):
		_spectator(Vector2(115 + index * 39, 447), index)
	for index in range(4):
		_spectator(Vector2(1056 + index * 39, 447), index + 4)
	_railing(74, 278)
	_railing(1020, 1225)
	_pavement()
	_foreground()


func _cloud(at: Vector2, scale_factor: float) -> void:
	var color := Color("d9ebe0")
	draw_circle(at, 24 * scale_factor, color)
	draw_circle(at + Vector2(27, -13) * scale_factor, 32 * scale_factor, color)
	draw_circle(at + Vector2(60, 0) * scale_factor, 22 * scale_factor, color)
	draw_rect(Rect2(at + Vector2(0, -5) * scale_factor, Vector2(62, 26) * scale_factor), color)


func _storefronts() -> void:
	# Left: a little grocery with a striped canopy.
	_box(Rect2(43, 205, 306, 245), Color("c98469"), 4)
	draw_rect(Rect2(54, 222, 283, 207), Color("e2ae88"))
	draw_rect(Rect2(48, 203, 296, 13), Color("f4cba3"))
	_window(Rect2(77, 238, 76, 58))
	_window(Rect2(240, 238, 75, 58))
	_box(Rect2(66, 308, 264, 45), TEAL, 6)
	_center_text("CORNER STORE", Vector2(198, 338), 24, CREAM)
	draw_rect(Rect2(79, 365, 164, 83), Color("689695"))
	draw_rect(Rect2(257, 365, 52, 83), Color("517f81"))
	draw_rect(Rect2(264, 373, 38, 44), Color("a0bbb0"))
	draw_circle(Vector2(298, 426), 3, CREAM)
	_awning(64, 350, 269, Color("e48769"), Color("f6dfb8"))
	# Center: the neighborhood hugging club. Quiet wall behind the actors.
	_box(Rect2(358, 198, 565, 253), Color("ecd7b3"), 5)
	draw_rect(Rect2(367, 207, 547, 10), Color("fff0cd"))
	draw_rect(Rect2(376, 224, 529, 114), Color("e3caa5"))
	for x in range(386, 900, 42):
		draw_line(Vector2(x, 231), Vector2(x + 18, 231), Color("ceb48e"), 2)
		draw_line(Vector2(x + 14, 320), Vector2(x + 31, 320), Color("ceb48e"), 2)
	_box(Rect2(448, 239, 385, 62), Color("bd5e52"), 10)
	_box(Rect2(455, 245, 371, 50), Color("cf705b"), 7)
	_center_text("STREET HUGGER", Vector2(641, 281), 35, Color("fff0cc"))
	_center_text("NEIGHBORHOOD INVITATIONAL", Vector2(642, 326), 13, Color("8a7060"))
	# Large broad panes are intentionally low contrast around the hug poses.
	draw_rect(Rect2(393, 351, 188, 98), Color("abc0ad"))
	draw_rect(Rect2(701, 351, 188, 98), Color("abc0ad"))
	draw_rect(Rect2(595, 351, 92, 98), Color("8daaa0"))
	for x in [393, 487, 581, 595, 641, 687, 701, 795, 889]:
		draw_line(Vector2(x, 351), Vector2(x, 449), Color("d5c6a5"), 5)
	draw_line(Vector2(393, 395), Vector2(889, 395), Color("d5c6a5"), 5)
	draw_circle(Vector2(631, 414), 3, Color("ead5ad"))
	draw_circle(Vector2(651, 414), 3, Color("ead5ad"))
	# Right: the tea shop.
	_box(Rect2(937, 220, 301, 232), Color("97b5a0"), 4)
	draw_rect(Rect2(945, 228, 284, 13), Color("c3d0ac"))
	_window(Rect2(961, 253, 72, 54))
	_window(Rect2(1135, 253, 72, 54))
	_box(Rect2(957, 318, 263, 39), Color("527f74"), 5)
	_center_text("HUG IN A MUG", Vector2(1089, 345), 23, CREAM)
	draw_rect(Rect2(966, 369, 174, 78), Color("719d92"))
	draw_rect(Rect2(1152, 369, 53, 78), Color("668f85"))
	_awning(955, 356, 265, Color("e1bd79"), Color("f7e4b7"))
	# Shared foundation and a warm band of light on the walls.
	draw_rect(Rect2(42, 446, 1196, 15), Color("b8a687"))
	draw_rect(Rect2(44, 446, 1192, 4), Color("f4dfb8"))


func _window(rect: Rect2) -> void:
	draw_rect(rect.grow(4), Color("e9cba4"))
	draw_rect(rect, Color("648d8c"))
	draw_polygon(PackedVector2Array([rect.position, rect.position + Vector2(rect.size.x, 0), rect.position + rect.size]), PackedColorArray([Color("7fa6a0")]))
	draw_line(rect.position + Vector2(rect.size.x * 0.5, 0), rect.position + Vector2(rect.size.x * 0.5, rect.size.y), Color("dec4a0"), 4)


func _awning(x: float, y: float, width: float, a: Color, b: Color) -> void:
	var stripe_width := width / 12.0
	for index in range(12):
		var color := a if index % 2 == 0 else b
		draw_rect(Rect2(x + index * stripe_width, y, stripe_width + 1, 14), color)
		draw_circle(Vector2(x + (index + 0.5) * stripe_width, y + 14), stripe_width * 0.5, color)
	draw_line(Vector2(x, y), Vector2(x + width, y), Color("806e58"), 2)


func _bunting() -> void:
	var previous := Vector2(0, 150)
	for index in range(1, 33):
		var x := index * 40.0
		var y := 150 + sin(x / 1280.0 * PI) * 50
		var point := Vector2(x, y)
		draw_line(previous, point, Color("6a817b"), 2, true)
		previous = point
	var colors: Array[Color] = [Color("d97865"), Color("e8c67c"), Color("5b9990"), Color("f0ddb2")]
	for index in range(21):
		var x := 24.0 + index * 62
		var y := 150 + sin(x / 1280.0 * PI) * 50
		var sway := sin(clock * 1.5 + index * 0.7) * 3
		draw_polygon(PackedVector2Array([Vector2(x - 11, y), Vector2(x + 11, y + 2), Vector2(x + sway, y + 25)]), PackedColorArray([colors[index % colors.size()]]))


func _tree(at: Vector2, size: float) -> void:
	draw_line(at, at + Vector2(0, -125) * size, Color("8e8060"), 12 * size)
	for index in range(5):
		var offset := Vector2(sin(index * 2.0) * 32, -132 + cos(index * 2.0) * 26) * size
		draw_circle(at + offset, 40 * size, Color("789a76"))
	draw_circle(at + Vector2(-14, -151) * size, 27 * size, Color("92b086"))


func _spectator(at: Vector2, index: int) -> void:
	var sway := sin(clock * 2.0 + index * 1.2) * 2.0
	var skin: Array[Color] = [Color("dca77d"), Color("986d55"), Color("e7bd91"), Color("bb8663")]
	var shirts: Array[Color] = [Color("7faaa1"), Color("d59a78"), Color("d0bc78"), Color("929eac")]
	var head := at + Vector2(sway, -47)
	draw_line(at + Vector2(-5, 0), at + Vector2(-5 + sway, -21), Color("6c827c"), 8)
	draw_line(at + Vector2(6, 0), at + Vector2(6 + sway, -21), Color("6c827c"), 8)
	_box(Rect2(at + Vector2(-12 + sway, -35), Vector2(25, 29)), shirts[index % 4], 7)
	draw_circle(head, 12, skin[index % 4])
	draw_arc(head, 12, PI, TAU, 12, Color("675e50"), 5, true)
	draw_circle(head + Vector2(-4, 1), 1.2, Color("5a6359"))
	draw_circle(head + Vector2(4, 1), 1.2, Color("5a6359"))
	# Little claps and cheers, never large distracting motion.
	var hand := at + Vector2(15 + sway, -28 - sin(clock * 3 + index) * 3)
	draw_line(at + Vector2(9 + sway, -29), hand, shirts[index % 4], 7)
	draw_circle(hand, 4, skin[index % 4])


func _railing(left: float, right: float) -> void:
	for x in range(int(left), int(right), 36):
		draw_line(Vector2(x, 422), Vector2(x, 457), Color("778d80"), 3)
	draw_line(Vector2(left, 423), Vector2(right, 423), Color("8b9f8c"), 5)
	draw_line(Vector2(left, 439), Vector2(right, 439), Color("8b9f8c"), 3)


func _pavement() -> void:
	draw_rect(Rect2(0, 459, 1280, 111), Color("d5c8ab"))
	draw_rect(Rect2(0, 460, 1280, 4), Color("e7d7b4"))
	draw_line(Vector2(0, 501), Vector2(1280, 501), Color("c1b69a"), 2)
	for x in range(-80, 1400, 160):
		draw_line(Vector2(x + 45, 462), Vector2(x, 568), Color("c1b69a"), 2)
	# Subtle arena marking: visually locates the fighting plane without a cage.
	draw_line(Vector2(121, 554), Vector2(1159, 554), Color("efe0bd"), 3)
	for x in [121, 1159]:
		draw_line(Vector2(x, 546), Vector2(x, 562), Color("efe0bd"), 3)
	draw_rect(Rect2(0, 570, 1280, 16), Color("9f9d89"))
	draw_rect(Rect2(0, 570, 1280, 4), Color("efe0bd"))
	draw_rect(Rect2(0, 586, 1280, 134), Color("64797b"))
	for x in range(-50, 1360, 230):
		draw_rect(Rect2(x, 645, 105, 6), Color("a7b0a1"))
	draw_line(Vector2(0, 590), Vector2(1280, 590), Color("526b70"), 4)


func _foreground() -> void:
	# Small corner planters frame the arena, below and outside the play space.
	for x in [23.0, 1205.0]:
		draw_ellipse_shadow(Vector2(x + 23, 646), Vector2(46, 9), Color(0.15, 0.23, 0.23, 0.22))
		draw_polygon(PackedVector2Array([Vector2(x, 599), Vector2(x + 50, 599), Vector2(x + 43, 642), Vector2(x + 7, 642)]), PackedColorArray([Color("b66f58")]))
		_box(Rect2(x - 3, 592, 56, 12), Color("cf8a68"), 3)
		for index in range(7):
			var tip := Vector2(x + 25 + sin(index * 2.7) * 26, 573 - absf(cos(index * 1.8)) * 25)
			draw_line(Vector2(x + 25, 595), tip, Color("608875"), 5, true)
			draw_circle(tip, 8, Color("7ca082"))


func draw_ellipse_shadow(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(32):
		var angle := float(index) / 32.0 * TAU
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)


func _box(rect: Rect2, color: Color, radius: float) -> void:
	var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	draw_rect(Rect2(rect.position + Vector2(r, 0), rect.size - Vector2(2 * r, 0)), color)
	draw_rect(Rect2(rect.position + Vector2(0, r), rect.size - Vector2(0, 2 * r)), color)
	for corner in [Vector2(r, r), Vector2(rect.size.x - r, r), Vector2(r, rect.size.y - r), Vector2(rect.size.x - r, rect.size.y - r)]:
		draw_circle(rect.position + corner, r, color)


func _center_text(value: String, baseline: Vector2, font_size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, baseline - Vector2(width * 0.5, 0), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
