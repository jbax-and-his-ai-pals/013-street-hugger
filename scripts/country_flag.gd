extends Control
## Small, deliberately wonky fictional flags. Geometry is stable between frames.

var country_index: int = 0:
	set(value):
		country_index = posmod(value, 8)
		queue_redraw()

const COLORS = [
	[Color("246a70"), Color("ffe6a3"), Color("f48367")],
	[Color("e8b34d"), Color("644b82"), Color("69c7bd")],
	[Color("805c99"), Color("b9e4c4"), Color("fff0c5")],
	[Color("e28a52"), Color("243b62"), Color("fff0b9")],
	[Color("bb6363"), Color("f4d7a4"), Color("315d59")],
	[Color("4b7dab"), Color("e6d56c"), Color("26384c")],
	[Color("f1e5b8"), Color("725783"), Color("dc7c98")],
	[Color("578775"), Color("f2bd8e"), Color("33464e")]
]

func _init():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_text = ""

func _ready():
	resized.connect(queue_redraw)

func _draw():
	draw_flag(self, Rect2(Vector2.ZERO, size), country_index)

static func polygon(canvas: CanvasItem, rect: Rect2, points: Array, color: Color):
	var transformed = PackedVector2Array()
	for point in points:
		transformed.append(rect.position + point * rect.size)
	canvas.draw_colored_polygon(transformed, color)

static func draw_flag(canvas: CanvasItem, rect: Rect2, index: int, pole: bool = false):
	var colors = COLORS[posmod(index, 8)]
	if pole:
		canvas.draw_line(rect.position + Vector2(-2, -3), rect.position + Vector2(-2, rect.size.y + 10), Color("233b43"), 2.0, true)
	# A crooked hem, off-center emblems, and uneven bands are intentional.
	var hem = [Vector2(0, 0.06), Vector2(0.98, 0), Vector2(0.95, 0.98), Vector2(0.03, 0.92)]
	polygon(canvas, rect, hem, colors[0])
	match posmod(index, 8):
		0:
			polygon(canvas, rect, [Vector2(0.04,0.62), Vector2(0.96,0.50), Vector2(0.95,0.74), Vector2(0.04,0.82)], colors[1])
			canvas.draw_circle(rect.position + rect.size * Vector2(0.34, 0.31), rect.size.y * 0.15, colors[2])
		1:
			polygon(canvas, rect, [Vector2(0.1,0.08), Vector2(0.39,0.04), Vector2(0.81,0.95), Vector2(0.48,0.94)], colors[1])
			polygon(canvas, rect, [Vector2(0.63,0.20), Vector2(0.86,0.30), Vector2(0.69,0.53)], colors[2])
		2:
			polygon(canvas, rect, [Vector2(0.03,0.91), Vector2(0.95,0.21), Vector2(0.95,0.98)], colors[1])
			polygon(canvas, rect, [Vector2(0.29,0.18), Vector2(0.43,0.34), Vector2(0.31,0.55), Vector2(0.17,0.37)], colors[2])
		3:
			polygon(canvas, rect, [Vector2(0.10,0.06), Vector2(0.29,0.04), Vector2(0.89,0.97), Vector2(0.64,0.95)], colors[1])
			for point in [Vector2(0.65,0.28), Vector2(0.31,0.72)]:
				canvas.draw_circle(rect.position + rect.size * point, rect.size.y * 0.11, colors[2])
		4:
			polygon(canvas, rect, [Vector2(0.04,0.65), Vector2(0.25,0.37), Vector2(0.42,0.59), Vector2(0.66,0.29), Vector2(0.95,0.56), Vector2(0.95,0.91), Vector2(0.05,0.86)], colors[1])
			canvas.draw_circle(rect.position + rect.size * Vector2(0.72,0.19), rect.size.y * 0.10, colors[2])
		5:
			polygon(canvas, rect, [Vector2(0.15,0.19), Vector2(0.46,0.44), Vector2(0.16,0.80), Vector2(0.37,0.84), Vector2(0.73,0.45), Vector2(0.40,0.15)], colors[1])
			polygon(canvas, rect, [Vector2(0.69,0.19), Vector2(0.88,0.44), Vector2(0.71,0.75)], colors[2])
		6:
			polygon(canvas, rect, [Vector2(0.04,0.72), Vector2(0.96,0.63), Vector2(0.95,0.86), Vector2(0.04,0.91)], colors[2])
			var star = []
			for vertex in range(10):
				var angle = -PI / 2.0 + TAU * vertex / 10.0
				var radius = 0.31 if vertex % 2 == 0 else 0.14
				star.append(Vector2(0.43 + cos(angle) * radius * 0.65, 0.37 + sin(angle) * radius))
			polygon(canvas, rect, star, colors[1])
		7:
			canvas.draw_circle(rect.position + rect.size * Vector2(0.49,0.46), rect.size.y * 0.30, colors[1])
			canvas.draw_circle(rect.position + rect.size * Vector2(0.57,0.42), rect.size.y * 0.19, colors[0])
			polygon(canvas, rect, [Vector2(0.12,0.77), Vector2(0.83,0.64), Vector2(0.85,0.82), Vector2(0.15,0.91)], colors[2])
	var outline = PackedVector2Array()
	for point in hem:
		outline.append(rect.position + point * rect.size)
	outline.append(outline[0])
	canvas.draw_polyline(outline, Color("233541"), maxf(1.0, rect.size.y / 24.0), true)
