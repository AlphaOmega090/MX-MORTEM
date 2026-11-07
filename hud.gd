extends Control

const Story = preload("res://story.gd")
const MXD = preload("res://mxdraw.gd")

var g = null


func bar(pos: Vector2, label: String, frac: float, col: Color) -> void:
	var f := ThemeDB.fallback_font
	draw_rect(Rect2(pos, Vector2(200, 14)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(pos, Vector2(200 * clampf(frac, 0.0, 1.0), 14)), col)
	draw_string(f, pos + Vector2(206, 12), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)


func center_text(text: String, y: float, size: int, col: Color) -> void:
	var vs := get_viewport_rect().size
	draw_multiline_string(ThemeDB.fallback_font, Vector2(vs.x * 0.15, y), text,
		HORIZONTAL_ALIGNMENT_CENTER, vs.x * 0.7, size, -1, col)


func objective() -> String:
	if g.ch.goal == "tapes":
		if g.tapes_got < g.ch.tapes.size():
			return "Find the VHS tapes (%d/%d) - hold E to pull them in" % [g.tapes_got, g.ch.tapes.size()]
		return "The exit is unsealed - reach the green door"
	if g.chase_mode:
		return "RUN! Reach the exit with Allas!"
	if not g.has_key:
		return "Find the keycard - hold E to pull it in"
	if g.grid[g.door_tile.y][g.door_tile.x] == 2:
		return "Unlock Allas's cell - press E at the red door"
	if not g.freed:
		return "Free Allas - hold E next to her"
	return "Reach the green exit with Allas"


func _draw() -> void:
	if g == null:
		return
	var vs := get_viewport_rect().size
	var f := ThemeDB.fallback_font
	match g.state:
		"title":
			draw_rect(Rect2(Vector2.ZERO, vs), Color.BLACK)
			var fl := 0.25 + 0.15 * sin(g.time_acc * 2.0)
			if fmod(g.time_acc, 7.0) > 6.8:
				fl = 0.0
			MXD.draw_mx(self, "omega", Vector2(vs.x * 0.5, vs.y * 0.55), 230.0, fl, 0.0, g.time_acc)
			center_text(Story.TITLE, vs.y * 0.35, 84, Color(0.85, 0.1, 0.1))
			center_text(Story.TAGLINE, vs.y * 0.45, 22, Color(0.8, 0.8, 0.8))
			center_text("Press ENTER / tap", vs.y * 0.85, 20, Color(1, 1, 1, 0.5 + 0.5 * sin(g.time_acc * 3.0)))
			return
		"intro":
			draw_rect(Rect2(Vector2.ZERO, vs), Color.BLACK)
			center_text(Story.INTRO[g.intro_page], vs.y * 0.32, 24, Color(0.9, 0.9, 0.9))
			center_text("ENTER / tap", vs.y * 0.9, 16, Color(0.6, 0.6, 0.6))
			return
		"card":
			draw_rect(Rect2(Vector2.ZERO, vs), Color.BLACK)
			center_text(g.ch.name, vs.y * 0.3, 28, Color(0.7, 0.7, 0.7))
			center_text(g.ch.title, vs.y * 0.42, 64, Color(0.85, 0.1, 0.1))
			center_text(g.ch.card, vs.y * 0.58, 20, Color(0.9, 0.9, 0.9))
			center_text("ENTER / tap", vs.y * 0.9, 16, Color(0.6, 0.6, 0.6))
			return
		"outro":
			draw_rect(Rect2(Vector2.ZERO, vs), Color.BLACK)
			center_text(g.ch.outro, vs.y * 0.35, 24, Color(0.9, 0.9, 0.9))
			center_text("ENTER / tap", vs.y * 0.9, 16, Color(0.6, 0.6, 0.6))
			return
		"end":
			draw_rect(Rect2(Vector2.ZERO, vs), Color.BLACK)
			center_text("THE END", vs.y * 0.35, 72, Color(0.85, 0.1, 0.1))
			center_text("Thanks for playing MX Mortem.", vs.y * 0.5, 22, Color(0.9, 0.9, 0.9))
			center_text("ENTER / tap - back to title", vs.y * 0.9, 16, Color(0.6, 0.6, 0.6))
			return
		"jumpscare":
			var sh := Vector2(randf_range(-18, 18), randf_range(-18, 18))
			draw_rect(Rect2(Vector2.ZERO, vs), Color(0.25 + 0.2 * randf(), 0, 0))
			var sz: float = minf(vs.x, vs.y) * (0.55 + 0.25 * (1.0 - g.scare_t / 1.4))
			MXD.draw_mx(self, g.scare_kind, vs * 0.5 + sh, sz, 1.0, 100.0, g.time_acc)
			return

	_draw_play(vs, f)


func _draw_play(vs: Vector2, f: Font) -> void:
	# atmosphere
	var p: float = g.prox
	for i in range(10):
		draw_rect(Rect2(Vector2(i * 10, i * 10), vs - Vector2(i * 20, i * 20)),
			Color(0.15 * p, 0, 0, 0.05 + 0.03 * p), false, 12.0)
	if p > 0.5:
		for i in range(int((p - 0.5) * 140.0)):
			draw_rect(Rect2(randf() * vs.x, randf() * vs.y, randf_range(2, 14), 2), Color(1, 1, 1, 0.1))

	# status
	var ph := ""
	if g.phase == "day":
		ph = "%s  -  DAY  -  night in %d s" % [g.ch.name, int(ceil(g.clock))]
	else:
		ph = "%s  -  NIGHT  %d:%02d" % [g.ch.name, int(g.clock) / 60, int(g.clock) % 60]
	draw_string(f, Vector2(16, 28), ph, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	bar(Vector2(16, 40), "POWER", g.battery / 100.0, Color(1.0, 0.85, 0.2))
	bar(Vector2(16, 58), "STAMINA", g.stamina / 100.0, Color(0.3, 0.8, 1.0))
	bar(Vector2(16, 76), "LASER", 1.0 - g.laser_cd / 4.0, Color(1.0, 0.25, 0.25))
	var inv := "Inventory: "
	if g.has_key:
		inv += "[Keycard] "
	inv += "[Tapes %d/%d]" % [g.tapes_got, g.ch.tapes.size()]
	draw_string(f, Vector2(16, 108), inv, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.9, 0.9, 0.9))

	var y := 130.0
	if g.in_locker:
		var col := Color(1.0, 0.5, 0.2) if g.gasping else Color(0.5, 0.8, 1.0)
		bar(Vector2(16, y), "BREATH (hold SPACE)", g.breath / 100.0, col)
		y += 18.0
		bar(Vector2(16, y), "NOISE", g.noise_timer / 3.0, Color(1.0, 0.2, 0.2))
		y += 18.0
	for e in g.enemies:
		if e.kind == "kabob" and e.rage > 1.0:
			bar(Vector2(16, y), "KABOB RAGE", e.rage / 100.0, Color(1.0, 0.3, 0.0))
			y += 18.0

	draw_string(f, Vector2(16, vs.y - 16), "Objective: " + objective(), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1.0, 0.95, 0.6))
	if not g.touch_ui:
		draw_string(f, Vector2(vs.x - 640, vs.y - 16),
			"WASD move | Shift sprint | Mouse aim | F light | E hands | Click laser | TAB/C cameras | R retry",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.7, 0.7, 0.7))

	if g.msg_t > 0.0:
		draw_string(f, Vector2(0, vs.y - 90), g.msg, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 20, Color.WHITE)
	if g.sub_t > 0.0:
		draw_rect(Rect2(vs.x * 0.2, vs.y - 66, vs.x * 0.6, 30), Color(0, 0, 0, 0.6))
		draw_string(f, Vector2(0, vs.y - 45), g.sub_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 18, g.sub_col)

	if g.cam_on:
		_draw_cameras(vs, f)

	if g.touch_ui and g.state == "play":
		_draw_touch(vs, f)

	if g.state == "tape":
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 0.82))
		var t: Array = Story.TAPES[g.tape_id]
		draw_rect(Rect2(vs.x * 0.2, vs.y * 0.2, vs.x * 0.6, vs.y * 0.6), Color(0.04, 0.05, 0.04), true)
		draw_rect(Rect2(vs.x * 0.2, vs.y * 0.2, vs.x * 0.6, vs.y * 0.6), Color(0.3, 0.8, 0.4), false, 3.0)
		draw_string(f, Vector2(vs.x * 0.2, vs.y * 0.27), "> " + t[0], HORIZONTAL_ALIGNMENT_CENTER, vs.x * 0.6, 24, Color(0.4, 1.0, 0.5))
		draw_multiline_string(f, Vector2(vs.x * 0.23, vs.y * 0.38), t[1], HORIZONTAL_ALIGNMENT_LEFT, vs.x * 0.54, 20, -1, Color(0.8, 1.0, 0.85))
		draw_string(f, Vector2(vs.x * 0.2, vs.y * 0.76), "ENTER / tap to continue", HORIZONTAL_ALIGNMENT_CENTER, vs.x * 0.6, 14, Color(0.4, 0.8, 0.5))

	if g.state == "dead":
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 0.8))
		draw_string(f, Vector2(0, vs.y / 2 - 20), "YOU DIED", HORIZONTAL_ALIGNMENT_CENTER, vs.x, 56, Color(0.9, 0.1, 0.1))
		draw_string(f, Vector2(0, vs.y / 2 + 20), g.end_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 22, Color.WHITE)
		draw_string(f, Vector2(0, vs.y / 2 + 56), "Press ENTER / tap to retry the chapter", HORIZONTAL_ALIGNMENT_CENTER, vs.x, 18, Color(0.8, 0.8, 0.8))


func _draw_cameras(vs: Vector2, f: Font) -> void:
	var cell := 12.0
	var size := Vector2(g.W * cell, g.H * cell)
	var o := (vs - size) * 0.5
	draw_rect(Rect2(o - Vector2(10, 30), size + Vector2(20, 44)), Color(0, 0.05, 0, 0.92))
	draw_string(f, o - Vector2(0, 12), "CAM 01 - FUNWORKS  (Omega is not on cameras)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.4, 1.0, 0.5))
	for ty in range(g.H):
		for tx in range(g.W):
			if g.grid[ty][tx] != 1:
				draw_rect(Rect2(o + Vector2(tx, ty) * cell, Vector2(cell - 1, cell - 1)), Color(0.1, 0.3, 0.15))
	for s in g.cam_snap:
		var pos: Vector2 = s.pos / g.T * cell + o
		draw_circle(pos, 5.0, Story.COLORS[s.kind])
	draw_circle(g.player_pos / g.T * cell + o, 4.0, Color.WHITE)
	for i in range(80):
		draw_rect(Rect2(o.x + randf() * size.x, o.y + randf() * size.y, randf_range(4, 30), 2), Color(1, 1, 1, 0.15))


func _draw_touch(vs: Vector2, f: Font) -> void:
	var labels := {"e": "HANDS", "laser": "LASER", "sprint": "RUN", "light": "LIGHT", "cam": "CAMS", "breath": "BREATH"}
	var btns: Dictionary = g.touch_buttons(vs)
	for n in btns.keys():
		if n == "breath" and not g.in_locker:
			continue
		var c: Vector2 = btns[n][0]
		var r: float = btns[n][1]
		draw_circle(c, r, Color(1, 1, 1, 0.12))
		draw_arc(c, r, 0.0, TAU, 32, Color(1, 1, 1, 0.45), 2.0)
		draw_string(f, c + Vector2(-r, 5), labels[n], HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 14, Color(1, 1, 1, 0.8))
	if g.stick_active:
		draw_circle(g.stick_origin, 70.0, Color(1, 1, 1, 0.1))
		draw_arc(g.stick_origin, 70.0, 0.0, TAU, 32, Color(1, 1, 1, 0.4), 2.0)
		var knob: Vector2 = g.stick_origin + (g.stick_pos - g.stick_origin).limit_length(70.0)
		draw_circle(knob, 30.0, Color(1, 1, 1, 0.35))
	else:
		var hint := Vector2(vs.x * 0.14, vs.y - 130.0)
		draw_arc(hint, 60.0, 0.0, TAU, 32, Color(1, 1, 1, 0.2), 2.0)
		draw_string(f, hint + Vector2(-60, 5), "MOVE", HORIZONTAL_ALIGNMENT_CENTER, 120.0, 14, Color(1, 1, 1, 0.35))
