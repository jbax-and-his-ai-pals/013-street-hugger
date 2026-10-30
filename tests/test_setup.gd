extends SceneTree

var game
var ui
var checks = 0
var failures = 0

func _initialize():
	call_deferred("run_tests")

func check(condition, message):
	checks += 1
	if condition:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func setup_key(code):
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	ui._unhandled_key_input(event)

func run_tests():
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	ui = game.ui
	check(ui.screen == "main" and not game.running, "Game opens at mode selection without starting a match")
	ui.choose_mode("single")
	check(ui.screen == "select" and ui.selected_mode == "single", "Single Player opens character selection")
	ui.choose_character(0, 5)
	ui.choose_character(1, 3)
	ui.launch_selection()
	check(not game.running, "A match cannot begin before both choices are confirmed")
	ui.confirm_player(0)
	check(ui.locked[0] and ui.active_player == 1, "Single-player confirmation advances to CPU selection")
	ui.confirm_player(1)
	ui.launch_selection()
	check(game.running and game.versus_ai and not game.practice, "Single-player setup starts a CPU match")
	check(game.fighters[0].character == 5 and game.fighters[1].character == 3, "Confirmed characters reach the gameplay system")
	check(ui.screen == "match", "Setup input handling closes once gameplay begins")
	game.return_to_selection()
	check(not game.running and ui.screen == "select" and ui.selected_mode == "single", "Returning to character selection stops the match and preserves single-player mode")
	check(ui.selected[0] == 5 and ui.selected[1] == 3, "Returning preserves character choices")
	ui.choose_mode("multi")
	ui.choose_character(0, 4)
	ui.choose_character(1, 7)
	ui.confirm_player(0)
	ui.confirm_player(1)
	ui.launch_selection()
	check(game.running and not game.versus_ai and not game.practice, "Multiplayer starts a local two-player match")
	check(game.fighters[0].character == 4 and game.fighters[1].character == 7, "Multiplayer keeps both players' independent choices")
	game.return_to_selection()
	check(ui.selected_mode == "multi", "Multiplayer mode survives return to setup")
	ui.choose_mode("multi")
	ui.choose_character(0, 0)
	ui.choose_character(1, 1)
	setup_key(KEY_S)
	check(ui.selected[0] == 4 and ui.selected[1] == 1, "P1 moves down exactly one row of four portraits")
	setup_key(KEY_D)
	check(ui.selected[0] == 5, "P1 moves right within the portrait grid")
	setup_key(KEY_W)
	check(ui.selected[0] == 1, "P1 moves up exactly one row")
	setup_key(KEY_DOWN)
	check(ui.selected[1] == 5 and ui.selected[0] == 1, "P2 arrows navigate only P2's selector")
	setup_key(KEY_F)
	check(ui.locked[0] and not ui.locked[1], "P1 confirm does not lock P2")
	setup_key(KEY_K)
	check(ui.locked[1], "P2 has an independent confirm key")
	ui.choose_mode("single")
	ui.choose_character(0, 2)
	ui.choose_character(1, 6)
	ui._practice_button.pressed.emit()
	check(game.practice and not game.versus_ai and game.running, "Practice from single-player selection still launches correctly")
	check(ui.selected_mode == "single", "Practice preserves single-player setup mode")
	check(not game.human_controls(1), "Practice still disables the partner's controls")
	game.back_to_menu()
	check(ui.screen == "main" and not game.running, "Main-menu navigation stops active gameplay")
	ui.choose_mode("single")
	ui.confirm_player(0)
	ui.back_setup()
	check(ui.screen == "select" and not ui.locked[0], "Back cancels a confirmed choice before leaving setup")
	ui.back_setup()
	check(ui.screen == "main", "Back from unconfirmed character selection returns to mode selection")
	setup_key(KEY_DOWN)
	setup_key(KEY_ENTER)
	check(ui.screen == "select" and ui.selected_mode == "multi", "Main menu is navigable by keyboard")
	ui.choose_character(0, 0)
	ui._cards[4].pressed.emit()
	check(ui.selected[0] == 4, "Clicking a portrait button selects its character")
	ui._confirm_button.pressed.emit()
	check(ui.locked[0] and ui.active_player == 1, "Mouse confirmation advances the active selector")
	ui._cards[7].pressed.emit()
	ui._confirm_button.pressed.emit()
	ui._start_button.pressed.emit()
	check(game.running and game.fighters[0].character == 4 and game.fighters[1].character == 7, "Mouse selection/confirm/start buttons launch the chosen matchup")
	ui.return_to_selection_requested.emit()
	check(not game.running and ui.screen == "select", "Character-select navigation signal is connected to the gameplay lifecycle")
	ui.choose_mode("multi")
	ui.confirm_player(0)
	var committed = ui.selected[0]
	setup_key(KEY_D)
	check(ui.selected[0] == committed, "Confirmed character cannot drift while the other player chooses")
	ui.choose_mode("multi")
	ui.choose_character(0, 3)
	ui.choose_character(1, 3)
	ui.confirm_player(0)
	ui.confirm_player(1)
	ui.launch_selection()
	check(game.running and game.fighters[0].character == game.fighters[1].character, "Mirror matches remain selectable")
	game.back_to_menu()
	var map_script = load("res://scripts/planet_map.gd")
	var maps = []
	for node in ui.find_children("*", "Control", true, false):
		if node.get_script() == map_script:
			maps.append(node)
	check(maps.size() == 1, "Character selection includes exactly one fictional world map")
	if maps.size() == 1:
		ui.choose_mode("single")
		for index in range(8):
			ui.choose_character(0, index)
			check(maps[0].p1_index == index, "Map follows P1's home country: " + game.NAMES[index])
		ui.choose_character(1, 6)
		check(maps[0].p2_index == 6, "Map tracks the opponent's home country independently")
		var centers = []
		for index in range(8):
			centers.append(maps[0].country_center(index))
		check(centers.size() == 8 and centers[0] != centers[7], "Country markers occupy distinct map locations")
	game.queue_free()
	await process_frame
	print("\nSETUP RESULT: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures > 0 else 0)
