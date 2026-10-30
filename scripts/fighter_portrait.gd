class_name FighterPortrait
extends Control
## Responsive bust portrait built from the same original puppet used in matches.

const FIGHTER_SCRIPT = preload("res://scripts/fighter_visual.gd")
const BACKGROUND := Color("111c30")

var character_index: int = 0:
	set(value):
		character_index = posmod(value, 8)
		_refresh()
var facing: float = 1.0:
	set(value):
		facing = -1.0 if value < 0.0 else 1.0
		_refresh()
var animated: bool = true:
	set(value):
		animated = value
		set_process(animated)

var _fighter: Node2D
var _clock: float = 0.0

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true

func _ready() -> void:
	_fighter = FIGHTER_SCRIPT.new()
	add_child(_fighter)
	resized.connect(_refresh)
	set_process(animated)
	_refresh()

func set_character(index: int) -> void:
	character_index = index

func _refresh() -> void:
	if not is_instance_valid(_fighter):
		return
	# Crop feet and hips rather than scaling the complete fighter into a tiny
	# icon. Hair, eyebrows, accessories, shoulders and hands stay recognizable.
	var zoom := maxf(0.01, minf(size.x / 108.0, size.y / 112.0))
	_fighter.scale = Vector2.ONE * zoom
	_fighter.position = Vector2(size.x * (0.46 if facing > 0.0 else 0.54), size.y * 0.10 + 185.0 * zoom)
	_fighter.palette_index = character_index
	_fighter.facing = facing
	_fighter.pose = "idle"
	_fighter.phase = 0.0
	_fighter.clock = _clock * 0.42
	_fighter.queue_redraw()
	queue_redraw()

func _process(delta: float) -> void:
	_clock += delta
	if is_instance_valid(_fighter):
		# Portraits breathe subtly; they do not play combat loops in the menu.
		_fighter.clock = _clock * 0.42
		_fighter.queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var suit: Color = FIGHTER_SCRIPT.SUITS[character_index]
	var accent: Color = FIGHTER_SCRIPT.ACCENTS[character_index]
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
	# Character-color light sweeps across a dark studio-like background.
	for row in range(28):
		var fraction := float(row) / 27.0
		var tint := BACKGROUND.lerp(suit.darkened(0.62), 0.60 * (1.0 - fraction))
		draw_rect(Rect2(0, size.y * float(row) / 28.0, size.x, size.y / 28.0 + 1.0), tint)
	var diagonal := PackedVector2Array([
		Vector2(size.x * 0.62, 0), Vector2(size.x, 0),
		Vector2(size.x * 0.38, size.y), Vector2(-size.x * 0.05, size.y)
	])
	draw_colored_polygon(diagonal, Color(suit.r, suit.g, suit.b, 0.10))
	var glow_center := Vector2(size.x * 0.47, size.y * 0.43)
	for layer in range(5, 0, -1):
		var radius := minf(size.x, size.y) * (0.25 + float(layer) * 0.075)
		draw_circle(glow_center, radius, Color(accent.r, accent.g, accent.b, 0.023))
	# Quiet technical framing gives each portrait a consistent arcade panel.
	var line_color := Color(accent.r, accent.g, accent.b, 0.16)
	var gutter := maxf(7.0, size.x * 0.055)
	draw_line(Vector2(gutter, gutter), Vector2(gutter + size.x * 0.18, gutter), line_color, 1.0, true)
	draw_line(Vector2(gutter, gutter), Vector2(gutter, gutter + size.y * 0.13), line_color, 1.0, true)
	draw_line(Vector2(size.x - gutter, size.y - gutter), Vector2(size.x - gutter - size.x * 0.18, size.y - gutter), line_color, 1.0, true)
	draw_line(Vector2(size.x - gutter, size.y - gutter), Vector2(size.x - gutter, size.y - gutter - size.y * 0.13), line_color, 1.0, true)
