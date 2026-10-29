extends SceneTree

var game
var checks = 0
var failures = 0

func _initialize():
	call_deferred("run_tests")

func check(condition, message):
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func fresh(p1 = 0, p2 = 0):
	game.start_match(p1, p2, false)
	game.set_physics_process(false)
	game.set_process(false)
	game.fighters[0].x = 500.0
	game.fighters[1].x = 600.0
	game.fighters[0].facing = 1.0
	game.fighters[1].facing = -1.0

func step(seconds):
	var remaining = seconds
	while remaining > 0.00001:
		var dt = minf(1.0 / 60.0, remaining)
		game._physics_process(dt)
		remaining -= dt

func run_tests():
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	fresh()
	game.begin_action(0, "hug")
	step(0.26)
	check(game.fighters[0].score == 1 and game.fighters[1].score == 0, "An in-range hug scores exactly once for its initiator")
	check(game.reset_timer > 0.0, "Successful contact starts coordinated embrace/reset")
	step(1.3)
	check(game.fighters[0].score == 1, "Holding through the embrace cannot award duplicate points")
	check(game.fighters[0].x == 420.0 and game.fighters[1].x == 860.0, "Players return to fair starting positions")
	fresh()
	game.fighters[1].x = 800.0
	game.begin_action(0, "hug")
	step(0.26)
	check(game.fighters[0].score == 0, "Out-of-range hugs miss")
	check(not game.begin_action(0, "hug"), "Whiff recovery prevents button spam/canceling")
	fresh()
	game.begin_action(0, "hug")
	step(0.1)
	game.begin_action(1, "deflect")
	step(0.16)
	check(game.fighters[0].score == 0 and game.fighters[1].action == "idle", "Timed deflection stops the hug and frees the defender")
	check(game.begin_action(1, "hug"), "Defender can immediately counterhug")
	step(0.26)
	check(game.fighters[1].score == 1, "Deflection provides enough advantage to land a counterhug")
	fresh()
	game.begin_action(1, "deflect")
	step(0.27)
	game.begin_action(0, "hug")
	step(0.26)
	check(game.fighters[0].score == 1, "An early deflect is vulnerable during recovery")
	fresh()
	game.begin_action(0, "feint")
	step(0.25)
	check(game.fighters[0].score == 0 and game.fighters[0].action == "idle", "Feints return quickly and never award points")
	fresh()
	game.begin_action(0, "hug")
	game.begin_action(1, "hug")
	step(0.26)
	check(game.fighters[0].score == 0 and game.fighters[1].score == 0 and game.reset_timer > 0.0, "Simultaneous contact is a scoreless mutual embrace")
	for character in range(8):
		fresh(character)
		var data = game.special_data(character)
		game.fighters[1].x = 500.0 + (0.0 if character == 7 else data.travel) + minf(data.reach - 15.0, 100.0)
		game.begin_action(0, "special")
		step(data.contact + 0.02)
		check(game.fighters[0].score == 1, "Signature can land: " + game.NAMES[character])
	fresh(1)
	game.fighters[1].x = 820.0
	game.begin_action(0, "special")
	step(0.60)
	check(game.fighters[0].score == 1, "Long Arms connects at genuinely ranged distance")
	fresh(6)
	game.begin_action(0, "special")
	step(0.2)
	check(game.begin_action(0, "feint"), "Showboat can cancel early flourish into a feint")
	step(0.25)
	check(not game.begin_action(0, "special"), "Signature cooldown survives a canceled flourish")
	fresh()
	var before = game.remaining
	game.paused = true
	step(0.5)
	check(is_equal_approx(before, game.remaining), "Pause freezes the match clock")
	game.paused = false
	game.practice = true
	game.fighters[0].score = 5
	game.begin_action(0, "hug")
	step(1.5)
	check(game.running and is_equal_approx(before, game.remaining), "Practice remains active beyond five points with an unlimited clock")
	fresh()
	game.fighters[0].score = 4
	game.begin_action(0, "hug")
	step(1.5)
	check(not game.running and game.fighters[0].score == 5, "Fifth point ends the match after the embrace")
	fresh()
	game.remaining = 0.01
	step(0.02)
	check(not game.running, "Clock expiry ends an ordinary match")
	fresh()
	game.fighters[0].x = 590.0
	game.fighters[1].x = 600.0
	step(0.02)
	check(absf(game.fighters[1].x - game.fighters[0].x) >= 67.9, "Idle players cannot overlap")
	for attacker in range(8):
		for receiver in range(8):
			fresh(attacker, receiver)
			var move_data = game.special_data(attacker)
			game.fighters[1].x = 500.0 + (0.0 if attacker == 7 else move_data.travel) + 90.0
			game.begin_action(0, "special")
			step(move_data.contact + 0.02)
			check(game.fighters[0].score == 1, "Pairing %s → %s resolves" % [game.NAMES[attacker], game.NAMES[receiver]])
	for cpu in range(8):
		game.start_match(0, cpu, true)
		game.rng.seed = 100 + cpu
		step(61.5)
		check(not game.running and game.fighters[1].score > 0, "CPU %s completes a match and can score" % game.NAMES[cpu])
	game.queue_free()
	await process_frame
	print("\nRESULT: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures > 0 else 0)
