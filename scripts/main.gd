extends Node2D

const Visual = preload("res://scripts/fighter_visual.gd")
const Stage = preload("res://scripts/stage.gd")
const Interface = preload("res://scripts/game_ui.gd")
const NAMES = ["Champ", "Long Arms", "Backwards Baxter", "Acrobat", "Big Softy", "Speedster", "Showboat", "Boomerang"]
const SPECIALS = ["POWER STEP", "LONG DISTANCE", "REVERSE HUG", "HEAD OVER HEELS", "BEAR NECESSITIES", "QUICK SQUEEZE", "GRAND ENTRANCE", "RETURN TO SENDER"]
const FLOOR_Y = 555.0
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
	add_child(Stage.new())
	for i in range(2):
		var visual = Visual.new()
		add_child(visual)
		fighters.append(make_fighter(i, visual))
	ui = Interface.new()
	add_child(ui)
	ui.start_requested.connect(start_match)
	ui.rematch_requested.connect(func(): start_match(last_picks[0], last_picks[1], versus_ai))
	ui.menu_requested.connect(back_to_menu)
	ui.resume_requested.connect(func(): paused = false; ui.set_paused(false))
	ui.training_requested.connect(start_practice)
	ui.show_menu()
	set_process_input(true)

func make_fighter(index, visual):
	return {"visual": visual, "character": index, "x": 420.0 + index * 440.0, "facing": 1.0 if index == 0 else -1.0, "action": "idle", "time": 0.0, "duration": 1.0, "resolved": false, "score": 0, "cooldown": 0.0, "move": 0.0, "origin": 0.0, "action_facing": 1.0, "embrace_from": 0.0, "embrace_to": 0.0}

func start_match(p1, p2, use_ai):
	last_picks = [p1, p2]
	versus_ai = use_ai
	practice = false
	remaining = 60.0
	paused = false
	reset_timer = 0.0
	status = "FIRST TO FIVE • MAKE YOUR MOVE"
	status_time = 2.0
	effects.clear()
	for i in range(2):
		fighters[i].character = p1 if i == 0 else p2
		fighters[i].score = 0
	reset_positions()
	running = true
	ui.set_paused(false)
	ui.show_match(NAMES[p1], NAMES[p2], versus_ai)
	update_visuals()

func back_to_menu():
	running = false
	paused = false
	ui.set_paused(false)
	ui.show_menu()

func start_practice(p1, p2):
	start_match(p1, p2, false)
	practice = true
	ui.set_practice(true)
	set_status("PRACTICE • STATIONARY PARTNER • ESC FOR MENU", 9999.0)

func reset_positions():
	for i in range(2):
		var f = fighters[i]
		f.x = 420.0 + i * 440.0
		f.facing = 1.0 if i == 0 else -1.0
		f.action = "idle"
		f.time = 0.0
		f.move = 0.0
		f.cooldown = 0.0
	ai_timer = 0.4
	ai_direction = 0.0

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and running:
			paused = not paused
			ui.set_paused(paused)
			return
		if not running or paused or reset_timer > 0.0:
			return
		var keys = [[KEY_F, KEY_G, KEY_H, KEY_J], [KEY_K, KEY_L, KEY_SEMICOLON, KEY_APOSTROPHE]]
		for i in range(2):
			if i == 1 and versus_ai:
				continue
			for k in range(4):
				if event.physical_keycode == keys[i][k] or event.keycode == keys[i][k]:
					begin_action(i, ["hug", "deflect", "feint", "special"][k])

func begin_action(index, action):
	var f = fighters[index]
	if f.action == "special" and f.character == 6 and action == "feint" and f.time < 0.45:
		f.action = "idle"
	if f.action != "idle" and f.action != "walk":
		return false
	if action == "special" and f.cooldown > 0.0:
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
	return true

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
		status = "READ • BAIT • EMBRACE"
	if versus_ai:
		update_ai(delta)
	for i in range(2):
		var f = fighters[i]
		var other = fighters[1 - i]
		f.cooldown = maxf(0.0, f.cooldown - delta)
		if f.action in ["idle", "walk"]:
			var direction = 0.0
			if i == 0:
				direction = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
			elif versus_ai:
				direction = ai_direction
			else:
				direction = float(Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_LEFT))
			f.move = direction
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
	# Walking cannot pass through a partner. Committed signatures may cross sides.
	var separation = fighters[1].x - fighters[0].x
	if absf(separation) < 68.0 and fighters[0].action in ["idle", "walk"] and fighters[1].action in ["idle", "walk"]:
		var middle = clampf((fighters[0].x + fighters[1].x) * 0.5, 124.0, 1156.0)
		var order = 1.0 if separation >= 0.0 else -1.0
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
	var f = fighters[index]
	var other = fighters[1 - index]
	var reach = 125.0 if f.action == "hug" else special_data(f.character).reach
	var dx = other.x - f.x
	# Baxter turns his back visually while moving toward the committed target.
	var aim = f.action_facing
	return absf(dx) <= reach and (dx * aim >= -35.0)

func is_deflecting(index):
	var f = fighters[index]
	return f.action == "deflect" and f.time >= 0.04 and f.time <= 0.24

func resolve_attempts(attempts):
	var landed = []
	for index in attempts:
		if not can_reach(index):
			set_status("WHIFF! CLOSE THE DISTANCE", 0.8)
			continue
		if is_deflecting(1 - index):
			var defender = fighters[1 - index]
			defender.action = "idle"
			defender.time = 0.0
			fighters[index].time = maxf(fighters[index].time, fighters[index].duration - 0.42)
			set_status("DEFLECT! YOUR OPENING", 0.9)
			add_effect((fighters[0].x + fighters[1].x) / 2.0, Color("6fd4ce"))
		else:
			landed.append(index)
	if landed.size() == 2:
		set_status("MUTUAL! TOO WHOLESOME TO CALL", 1.3)
		begin_embrace()
	elif landed.size() == 1:
		var winner = landed[0]
		fighters[winner].score += 1
		set_status(NAMES[fighters[winner].character].to_upper() + " • HUG LANDED!", 1.3)
		begin_embrace()

func begin_embrace():
	var center = clampf((fighters[0].x + fighters[1].x) / 2.0, 150.0, 1130.0)
	var left_index = 0 if fighters[0].x <= fighters[1].x else 1
	for i in range(2):
		fighters[i].embrace_from = fighters[i].x
		fighters[i].embrace_to = center - 35.0 if i == left_index else center + 35.0
		fighters[i].facing = 1.0 if i == left_index else -1.0
		fighters[i].action = "embrace"
		fighters[i].time = 0.0
		fighters[i].duration = 1.15
	reset_timer = 1.15
	add_effect(center, Color("ffb06b"))

func set_status(message, duration):
	status = message
	status_time = duration

func finish_match():
	running = false
	var a = fighters[0].score
	var b = fighters[1].score
	var message = "A PERFECTLY FRIENDLY DRAW" if a == b else NAMES[fighters[0 if a > b else 1].character].to_upper() + " WINS!"
	ui.update_hud(a, b, remaining, "GOOD GAME • GREAT HUGS")
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
		if opponent.action in ["hug", "special", "feint"] and opponent.time > 0.13 and distance < 190.0 and rng.randf() < 0.55:
			begin_action(1, "deflect")
		elif distance < 120.0:
			var roll = rng.randf()
			begin_action(1, "hug" if roll < 0.6 else ("feint" if roll < 0.82 else "deflect"))
		elif distance < 330.0 and rng.randf() < 0.32:
			begin_action(1, "special")

func update_visuals():
	for f in fighters:
		var v = f.visual
		v.position = Vector2(f.x, FLOOR_Y)
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

func add_effect(x, color):
	effects.append({"x": x, "time": 0.0, "color": color})

func _process(delta):
	if paused:
		return
	for effect in effects:
		effect.time += delta
	effects = effects.filter(func(effect): return effect.time < 0.65)
	queue_redraw()

func _draw():
	for effect in effects:
		var t = effect.time / 0.65
		var color = effect.color
		color.a = 1.0 - t
		for j in range(10):
			var angle = TAU * j / 10.0
			var center = Vector2(effect.x, FLOOR_Y - 105.0)
			var direction = Vector2(cos(angle), sin(angle))
			draw_line(center + direction * (30.0 + t * 70.0), center + direction * (45.0 + t * 90.0), color, 5.0, true)
