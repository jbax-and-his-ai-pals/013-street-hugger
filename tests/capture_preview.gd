extends SceneTree
## Rendered QA utility: run without --headless; saves previews inside ignored .godot/.

func _initialize():
	call_deferred("capture")

func save_frame(file_name):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/" + file_name)

func capture():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	await save_frame("preview_menu.png")
	game.start_practice(0, 1)
	await save_frame("preview_arena.png")
	game.fighters[0].x = 550.0
	game.fighters[1].x = 655.0
	game.begin_action(0, "hug")
	for frame in range(30):
		game._physics_process(1.0 / 60.0)
		await process_frame
		if frame == 10:
			await save_frame("preview_attempt.png")
		if frame == 25:
			await save_frame("preview_hug.png")
	game.ui.set_paused(true)
	await save_frame("preview_pause.png")
	game.ui.set_paused(false)
	game.ui.show_result("BACKWARDS BAXTER WINS!")
	await save_frame("preview_result.png")
	for character in range(8):
		game.start_practice(character, 0)
		game.request_jump(0)
		var frames = int(game.JUMP_PROFILES[character].airtime * 0.45 * 60.0)
		for frame in range(frames):
			game._physics_process(1.0 / 60.0)
		await save_frame("preview_jump_%d.png" % character)
	game.start_match(0, 1, false)
	game.fighters[0].x = 550.0
	game.fighters[1].x = 650.0
	game.request_jump(0)
	game.request_jump(1)
	for frame in range(12):
		game._physics_process(1.0 / 60.0)
	game.begin_action(0, "hug")
	for frame in range(23):
		game._physics_process(1.0 / 60.0)
	await save_frame("preview_air_hug.png")
	print("Saved menu/contact frames, eight jump personalities, and an aerial hug in .godot/")
	game.queue_free()
	await process_frame
	quit()
