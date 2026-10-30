extends Node2D

const Visual = preload("res://scripts/fighter_visual.gd")
const Stage = preload("res://scripts/stage.gd")
const Interface = preload("res://scripts/game_ui.gd")
const Roster = preload("res://scripts/roster_data.gd")
const NAMES = Roster.NAMES
const SPECIALS = ["POWER STEP", "LONG DISTANCE", "REVERSE HUG", "HEAD OVER HEELS", "BEAR NECESSITIES", "QUICK SQUEEZE", "GRAND ENTRANCE", "RETURN TO SENDER"]
const FLOOR_Y = 555.0
const ACTION_KEYS = [[KEY_F, KEY_G, KEY_H, KEY_J], [KEY_K, KEY_L, KEY_SEMICOLON, KEY_APOSTROPHE]]
const MOVE_KEYS = [[KEY_A, KEY_D], [KEY_LEFT, KEY_RIGHT]]
const JUMP_KEYS = [[KEY_W, KEY_SPACE], [KEY_UP]]
const JUMP_PROFILES = [
	{"height": 170.0, "airtime": 0.82, "speed": 250.0, "launch": 245.0, "control": 1450.0},
	{"height": 185.0, "airtime": 0.96, "speed": 210.0, "launch": 200.0, "control": 700.0},
	{"height": 155.0, "airtime": 0.84, "speed": 235.0, "launch": 260.0, "control": 900.0},
	{"height": 215.0, "airtime": 0.94, "speed": 290.0, "launch": 280.0, "control": 1700.0},
	{"height": 135.0, "airtime": 0.80, "speed": 195.0, "launch": 320.0, "control": 620.0},
	{"height": 140.0, "airtime": 0.70, "speed": 340.0, "launch": 360.0, "control": 1200.0},
	{"height": 190.0, "airtime": 1.00, "speed": 225.0, "launch": 220.0, "control": 800.0},
	{"height": 165.0, "airtime": 0.84, "speed": 265.0, "launch": 270.0, "control": 1300.0}
]
const VERTICAL_HUG_REACH = 85.0
var held_keys = {}
var fighters = []
var ui
var running = false
var paused = false
var versus_ai = true
var practice = false
var remaining = 60.0
var reset_timer = 0.0
var status = ""
var status_time = 0.0
var clock = 0.0
var ai_timer = 0.0
var ai_direction = 0.0
var last_picks = [0, 1]
var effects = []
var scores_to_win = 5
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var stage = Stage.new()
	stage.show_behind_parent = true
	add_child(stage)
	for i in range(2):
		var visual = Visual.new()
		add_child(visual)
		fighters.append(make_fighter(i, visual))
	ui = Interface.new()
	add_child(ui)
	ui.start_requested.connect(start_match)
	ui.rematch_requested.connect(func(): start_match(last_picks[0], last_picks[1], versus_ai))
	ui.menu_requested.connect(back_to_menu)
	ui.return_to_selection_requested.connect(return_to_selection)
	ui.resume_requested.connect(func(): paused = false; ui.set_paused(false))
	ui.training_requested.connect(start_practice)
	ui.show_menu()
	set_process_input(true)

func make_fighter(index, visual):
	return {"visual": visual, "character": index, "x": 420.0 + index * 440.0, "facing": 1.0 if index == 0 else -1.0, "action": "idle", "time": 0.0, "duration": 1.0, "resolved": false, "score": 0, "cooldown": 0.0, "move": 0.0, "origin": 0.0, "action_facing": 1.0, "embrace_from": 0.0, "embrace_to": 0.0, "height": 0.0, "vy": 0.0, "vx": 0.0, "jump_elapsed": 0.0, "jump_airtime": 0.82, "jump_gravity": 2000.0, "jump_maxheight": 170.0, "jump_buffer": 0.0, "landing": 0.0, "embrace_height_from": 0.0, "embrace_height_to": 0.0}

func start_match(p1, p2, use_ai):
	held_keys.clear()
	last_picks = [p1, p2]
	versus_ai = use_ai
	practice = false
	remaining = 60.0
	paused = false
	reset_timer = 0.0
	status = ""
	status_time = 0.0
	effects.clear()
	for i in range(2):
		fighters[i].character = p1 if i == 0 else p2
		fighters[i].score = 0
	reset_positions()
	running = true
	ui.set_paused(false)
	ui.show_match(NAMES[p1], NAMES[p2], versus_ai)
	ui.selected = [p1, p2]
	ui.selected_mode = "single" if use_ai else "multi"
	update_visuals()

func back_to_menu():
	held_keys.clear()
	running = false
	paused = false
	ui.set_paused(false)
	ui.show_menu()

func return_to_selection():
	held_keys.clear()
	running = false
	paused = false
	ui.set_paused(false)
	ui.show_character_select()

func start_practice(p1, p2):
	start_match(p1, p2, false)
	practice = true
	ui.selected_mode = "single"
	ui.set_practice(true)
	# Mode and controls are already identified in the HUD.

func reset_positions():
	for i in range(2):
		var f = fighters[i]
		f.x = 420.0 + i * 440.0
		f.facing = 1.0 if i == 0 else -1.0
		f.action = "idle"
		f.time = 0.0
		f.move = 0.0
		f.cooldown = 0.0
		f.height = 0.0
		f.vy = 0.0
		f.vx = 0.0
		f.jump_buffer = 0.0
		f.jump_elapsed = 0.0
		f.landing = 0.0
	ai_timer = 0.4
	ai_direction = 0.0

func human_controls(index):
	return index == 0 or (not practice and not versus_ai)

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		held_keys.clear()
		for f in fighters:
			f.jump_buffer = 0.0

func _input(event):
	if event is InputEventKey:
		# Use the physical position consistently for both actions and movement.
		# Fall back only for synthetic events that have no physical keycode.
		var code = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if event.pressed:
			held_keys[code] = true
		else:
			held_keys.erase(code)
		if not event.pressed or event.echo:
			return
		if code == KEY_ESCAPE and running:
			held_keys.clear()
			paused = not paused
			ui.set_paused(paused)
			return
		if not running or paused or reset_timer > 0.0:
			return
		for i in range(2):
			if not human_controls(i):
				continue
			if code in JUMP_KEYS[i]:
				request_jump(i)
				return
			for k in range(4):
				if code == ACTION_KEYS[i][k]:
					begin_action(i, ["hug", "deflect", "feint", "special"][k])
					return

func begin_action(index, action):
	var f = fighters[index]
	if f.action == "special" and f.character == 6 and action == "feint" and f.time < 0.45:
		f.action = "idle"
	if f.action != "idle" and f.action != "walk":
		return false
	if action == "special" and f.cooldown > 0.0:
		return false
	if action == "special" and airborne(index):
		return false
	f.action = action
	f.time = 0.0
	f.resolved = false
	f.origin = f.x
	f.action_facing = f.facing
	f.duration = {"hug": 0.68, "deflect": 0.58, "feint": 0.23, "special": 1.0}.get(action, 0.5)
	if action == "special":
		f.duration = special_data(f.character).duration
		f.cooldown = 2.6
		set_status(SPECIALS[f.character], 0.95)
		if f.character == 3:
			launch_jump(index, true)
	return true

func airborne(index):
	return fighters[index].height > 0.001 or fighters[index].vy < 0.0

func move_direction(index):
	if human_controls(index):
		return float(held_keys.has(MOVE_KEYS[index][1])) - float(held_keys.has(MOVE_KEYS[index][0]))
	return ai_direction if versus_ai and not practice else 0.0

func request_jump(index):
	var f = fighters[index]
	if not f.action in ["idle", "walk"]:
		return false
	if airborne(index):
		f.jump_buffer = 0.12
		return false
	launch_jump(index)
	return true

func launch_jump(index, vault = false):
	var f = fighters[index]
	var profile = JUMP_PROFILES[f.character]
	f.jump_maxheight = 155.0 if vault else profile.height
	f.jump_airtime = 0.70 if vault else profile.airtime
	f.jump_gravity = 8.0 * f.jump_maxheight / (f.jump_airtime * f.jump_airtime)
	f.vy = -4.0 * f.jump_maxheight / f.jump_airtime
	f.vx = move_direction(index) * profile.launch
	f.jump_elapsed = 0.0
	f.jump_buffer = 0.0
	f.landing = 0.0

func update_vertical(index, delta):
	var f = fighters[index]
	if airborne(index):
		f.height -= f.vy * delta + 0.5 * f.jump_gravity * delta * delta
		f.vy += f.jump_gravity * delta
		f.jump_elapsed += delta
		if f.height <= 0.001 and f.vy > 0.0:
			f.height = 0.0
			f.vy = 0.0
			f.vx = 0.0
			f.landing = 1.0
			if f.jump_buffer > 0.0 and f.action in ["idle", "walk"]:
				launch_jump(index)

func special_data(character):
	return [
		{"contact": 0.36, "duration": 0.95, "reach": 132.0, "travel": 115.0},
		{"contact": 0.58, "duration": 1.3, "reach": 365.0, "travel": 0.0},
		{"contact": 0.38, "duration": 0.95, "reach": 125.0, "travel": 95.0},
		{"contact": 0.72, "duration": 1.25, "reach": 125.0, "travel": 180.0},
		{"contact": 0.82, "duration": 1.4, "reach": 210.0, "travel": 60.0},
		{"contact": 0.26, "duration": 1.0, "reach": 105.0, "travel": 230.0},
		{"contact": 0.68, "duration": 1.15, "reach": 160.0, "travel": 75.0},
		{"contact": 0.88, "duration": 1.4, "reach": 145.0, "travel": 260.0}
	][character]

func _physics_process(delta):
	if not running or paused:
		return
	clock += delta
	if reset_timer > 0.0:
		reset_timer -= delta
		var slide = smoothstep(0.0, 1.0, clampf((1.15 - reset_timer) / 0.18, 0.0, 1.0))
		for f in fighters:
			f.x = lerpf(f.embrace_from, f.embrace_to, slide)
			var elapsed = 1.15 - reset_timer
			var previous_height = f.height
			f.height = lerpf(f.embrace_height_from, f.embrace_height_to, slide) if elapsed < 0.18 else f.embrace_height_to * (1.0 - smoothstep(0.2, 0.75, elapsed))
			f.jump_elapsed = minf(f.jump_airtime, f.jump_elapsed + delta * 2.0)
			f.landing = 1.0 if previous_height > 0.0 and f.height == 0.0 else maxf(0.0, f.landing - delta / 0.14)
		if reset_timer <= 0.0:
			if not practice and (fighters[0].score >= scores_to_win or fighters[1].score >= scores_to_win or remaining <= 0.0):
				finish_match()
			else:
				reset_positions()
		update_visuals()
		return
	if not practice:
		remaining = maxf(0.0, remaining - delta)
	status_time = maxf(0.0, status_time - delta)
	if status_time <= 0.0:
		status = ""
	if versus_ai:
		update_ai(delta)
	for i in range(2):
		var f = fighters[i]
		var other = fighters[1 - i]
		f.cooldown = maxf(0.0, f.cooldown - delta)
		f.jump_buffer = maxf(0.0, f.jump_buffer - delta)
		f.landing = maxf(0.0, f.landing - delta / 0.14)
		var direction = move_direction(i)
		f.move = direction
		if f.action in ["idle", "walk"]:
			if not airborne(i):
				f.x = clampf(f.x + direction * 245.0 * delta, 90.0, 1190.0)
			f.facing = 1.0 if other.x >= f.x else -1.0
			f.action = "walk" if direction != 0.0 else "idle"
		else:
			f.time += delta
			if f.action == "special":
				var data = special_data(f.character)
				var progress = clampf(f.time / data.contact, 0.0, 1.0)
				var travel = data.travel * progress
				if f.character == 7:
					travel = 260.0 * sin(progress * PI)
				f.x = clampf(f.origin + f.action_facing * travel, 90.0, 1190.0)
			if f.time >= f.duration:
				f.action = "idle"
				f.time = 0.0
		if airborne(i) and f.action != "special":
			var profile = JUMP_PROFILES[f.character]
			f.vx = move_toward(f.vx, direction * profile.speed, profile.control * delta)
			f.x = clampf(f.x + f.vx * delta, 90.0, 1190.0)
		update_vertical(i, delta)
	# Walking cannot pass through a partner. Committed signatures may cross sides.
	var separation = fighters[1].x - fighters[0].x
	if absf(separation) < 68.0 and absf(fighters[0].height - fighters[1].height) < VERTICAL_HUG_REACH and fighters[0].action in ["idle", "walk"] and fighters[1].action in ["idle", "walk"]:
		var order = 1.0 if separation >= 0.0 else -1.0
		if practice:
			fighters[0].x = fighters[1].x - order * 68.0
		else:
			var middle = clampf((fighters[0].x + fighters[1].x) * 0.5, 124.0, 1156.0)
			fighters[0].x = middle - order * 34.0
			fighters[1].x = middle + order * 34.0
	# Both contact candidates are collected before resolution to keep simultaneous hugs fair.
	var attempts = []
	for i in range(2):
		var f = fighters[i]
		if f.action in ["hug", "special"] and not f.resolved:
			var contact = 0.24 if f.action == "hug" else special_data(f.character).contact
			if f.time >= contact:
				f.resolved = true
				attempts.append(i)
	resolve_attempts(attempts)
	if remaining <= 0.0 and reset_timer <= 0.0:
		finish_match()
	ui.update_hud(fighters[0].score, fighters[1].score, remaining, status)
	ui.update_signatures(fighters[0].cooldown, fighters[1].cooldown)
	update_visuals()

func can_reach(index):
	return hug_miss_reason(index).is_empty()

func hug_miss_reason(index):
	var f = fighters[index]
	var other = fighters[1 - index]
	var reach = 125.0 if f.action == "hug" else special_data(f.character).reach
	var dx = other.x - f.x
	# Baxter turns his back visually while moving toward the committed target.
	var aim = f.action_facing
	if absf(dx) > reach:
		return "Out of reach"
	if dx * aim < -35.0:
		return "Facing away"
	if f.height - other.height > VERTICAL_HUG_REACH:
		return "Too high"
	if other.height - f.height > VERTICAL_HUG_REACH:
		return "Too low"
	return ""

func is_deflecting(index):
	var f = fighters[index]
	return f.action == "deflect" and f.time >= 0.04 and f.time <= 0.24

func resolve_attempts(attempts):
	var landed = []
	for index in attempts:
		if not can_reach(index):
			set_status(hug_miss_reason(index), 0.8)
			continue
		if is_deflecting(1 - index):
			var defender = fighters[1 - index]
			defender.action = "idle"
			defender.time = 0.0
			fighters[index].time = maxf(fighters[index].time, fighters[index].duration - 0.42)
			set_status("Deflected", 0.9)
			add_effect((fighters[0].x + fighters[1].x) / 2.0, Color("6fd4ce"), (fighters[0].height + fighters[1].height) * 0.5)
		else:
			landed.append(index)
	if landed.size() == 2:
		set_status("Mutual hug (no point)", 1.3)
		begin_embrace()
	elif landed.size() == 1:
		var winner = landed[0]
		fighters[winner].score += 1
		set_status(NAMES[fighters[winner].character] + " scores", 1.3)
		begin_embrace()

func begin_embrace():
	var center = clampf((fighters[0].x + fighters[1].x) / 2.0, 150.0, 1130.0)
	var contact_height = (fighters[0].height + fighters[1].height) * 0.5
	var left_index = 0 if fighters[0].x <= fighters[1].x else 1
	for i in range(2):
		fighters[i].embrace_from = fighters[i].x
		fighters[i].embrace_to = center - 35.0 if i == left_index else center + 35.0
		fighters[i].embrace_height_from = fighters[i].height
		fighters[i].embrace_height_to = contact_height
		fighters[i].vy = 0.0
		fighters[i].vx = 0.0
		fighters[i].jump_buffer = 0.0
		fighters[i].facing = 1.0 if i == left_index else -1.0
		fighters[i].action = "embrace"
		fighters[i].time = 0.0
		fighters[i].duration = 1.15
	reset_timer = 1.15
	add_effect(center, Color("ffb06b"), contact_height)

func set_status(message, duration):
	status = message
	status_time = duration

func finish_match():
	running = false
	var a = fighters[0].score
	var b = fighters[1].score
	var message = "Draw" if a == b else NAMES[fighters[0 if a > b else 1].character] + " wins"
	ui.update_hud(a, b, remaining, "")
	ui.show_result(message)

func update_ai(delta):
	ai_timer -= delta
	var f = fighters[1]
	var opponent = fighters[0]
	var distance = absf(opponent.x - f.x)
	var toward = 1.0 if opponent.x > f.x else -1.0
	if ai_timer <= 0.0:
		ai_timer = rng.randf_range(0.18, 0.4)
		ai_direction = toward if distance > 100.0 else (-toward if rng.randf() < 0.3 else 0.0)
		# Decisions use visible action history after a reaction delay, never human inputs.
		if airborne(1):
			if distance < 130.0 and absf(f.height - opponent.height) < VERTICAL_HUG_REACH and rng.randf() < 0.7:
				begin_action(1, "hug")
		elif airborne(0) and distance < 240.0 and rng.randf() < 0.5:
			request_jump(1)
		elif opponent.action in ["hug", "special", "feint"] and opponent.time > 0.13 and distance < 190.0 and rng.randf() < 0.55:
			if rng.randf() < 0.3:
				request_jump(1)
			else:
				begin_action(1, "deflect")
		elif distance < 120.0:
			var roll = rng.randf()
			begin_action(1, "hug" if roll < 0.6 else ("feint" if roll < 0.82 else "deflect"))
		elif distance < 330.0 and rng.randf() < 0.32:
			begin_action(1, "special")
		elif distance > 130.0 and distance < 280.0 and rng.randf() < 0.22:
			request_jump(1)

func update_visuals():
	for f in fighters:
		var v = f.visual
		v.position = Vector2(f.x, FLOOR_Y - f.height)
		v.airborne = f.height > 0.001 or f.vy < 0.0
		v.jump_progress = clampf(f.height / f.jump_maxheight, 0.0, 1.0)
		v.flight_progress = clampf(f.jump_elapsed / f.jump_airtime, 0.0, 1.0)
		v.vertical_speed = f.vy
		v.ground_offset = f.height
		v.landing = f.landing
		v.palette_index = f.character
		v.facing = f.facing
		v.pose = f.action
		v.phase = clampf(f.time / f.duration, 0.0, 1.0)
		if f.action == "embrace":
			v.phase = 1.0 - maxf(reset_timer, 0.0) / 1.15
		v.clock = clock
		v.stretch = 0.0
		if f.action == "special" and f.character == 1:
			v.stretch = sin(clampf(f.time / 0.58, 0.0, 1.0) * PI / 2.0) * 270.0 if f.time < 0.58 else maxf(0.0, 1.0 - (f.time - 0.58) / 0.72) * 270.0
		v.rotation = 0.0
		v.queue_redraw()
	queue_redraw()

func add_effect(x, color, height = 0.0):
	effects.append({"x": x, "time": 0.0, "color": color, "height": height})

func _process(delta):
	if paused:
		return
	for effect in effects:
		effect.time += delta
	effects = effects.filter(func(effect): return effect.time < 0.65)
	queue_redraw()

func _draw():
	if running:
		for i in range(2):
			var label = "P1" if i == 0 else ("PARTNER" if practice else ("CPU" if versus_ai else "P2"))
			var label_width = ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
			# Keep ownership at the ground shadow so jump labels cannot obscure HUD messages.
			var point = Vector2(fighters[i].x, FLOOR_Y + 40.0)
			draw_style_box(marker_style(), Rect2(point + Vector2(-label_width / 2.0 - 10.0, -19.0), Vector2(label_width + 20.0, 28.0)))
			draw_string(ThemeDB.fallback_font, point + Vector2(-label_width / 2.0, 0.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("172d3b"))
	for effect in effects:
		var t = effect.time / 0.65
		var color = effect.color
		color.a = 1.0 - t
		for j in range(10):
			var angle = TAU * j / 10.0
			var center = Vector2(effect.x, FLOOR_Y - effect.height - 105.0)
			var direction = Vector2(cos(angle), sin(angle))
			draw_line(center + direction * (30.0 + t * 70.0), center + direction * (45.0 + t * 90.0), color, 5.0, true)

func marker_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color("fff4dc")
	style.set_corner_radius_all(8)
	return style
