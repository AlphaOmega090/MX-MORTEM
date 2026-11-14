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
		for lv in g.levers:
			if (not lv.final) and (not lv.done):
				return "RUN! Hold E at the lever to open the gate"
		if not g.trap_done:
			return "RUN! Reach the exit hall and hold E at the shutter lever"
		return "Reach the exit!"
	if g.ch.has("fuses") and not g.has_key:
		if g.fuses_got < g.ch.fuses.size():
			return "Find the fuses (%d/%d) - hold E to pull them in" % [g.fuses_got, g.ch.fuses.size()]
		return "Put the fuses in the fuse box - press E next to it"
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
		"cutscene":
			_draw_cutscene(vs, f)
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
	if g.ch.has("fuses"):
		inv += "[Fuses %d/%d] " % [g.fuses_got, g.ch.fuses.size()]
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

	if g.DEBUG and not g.touch_ui:
		draw_string(f, Vector2(vs.x - 330, 24), "DEBUG: 1/2/3 chapter | N night | I invincible%s" % (" (ON)" if g.invincible else ""),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 0.4, 0.7))
	if g.msg_t > 0.0:
		draw_string(f, Vector2(0, vs.y - 90), g.msg, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 20, Color.WHITE)
	if g.sub_t > 0.0:
		draw_rect(Rect2(vs.x * 0.2, vs.y - 66, vs.x * 0.6, 30), Color(0, 0, 0, 0.6))
		draw_string(f, Vector2(0, vs.y - 45), g.sub_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 18, g.sub_col)

	if g.glitch_t > 0.0:
		for i in range(14):
			var gy := randf() * vs.y
			var gx := randf_range(-30.0, 30.0)
			var gc := Color(0.2, 1.0, 1.0, 0.18) if i % 2 == 0 else Color(1.0, 0.2, 0.7, 0.18)
			draw_rect(Rect2(gx, gy, vs.x, randf_range(3.0, 16.0)), gc)

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
	draw_string(f, o - Vector2(0, 12), "CAM 01 - FACILITY  (Omega is not on cameras)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.4, 1.0, 0.5))
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


func _draw_cutscene(vs: Vector2, f: Font) -> void:
	var beat: Dictionary = g.cut_beats()[g.cut_i]
	var t: float = g.cut_t
	draw_scene(beat.scene, t, vs, f)
	# fade in and out per beat
	var fade := minf(1.0, minf(t / 0.5, (beat.d - t) / 0.5))
	if fade < 1.0:
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 1.0 - fade))
	# letterbox + caption
	draw_rect(Rect2(0, 0, vs.x, vs.y * 0.1), Color.BLACK)
	draw_rect(Rect2(0, vs.y * 0.82, vs.x, vs.y * 0.18), Color.BLACK)
	var text: String = beat.text
	var shown := mini(text.length(), int(t * 32.0))
	var col := Color(0.95, 0.95, 0.95)
	if text.begins_with("OMEGA"):
		col = Color(0.8, 0.45, 1.0)
	elif text.begins_with("X:"):
		col = Color(0.3, 0.95, 0.95)
	draw_multiline_string(f, Vector2(vs.x * 0.12, vs.y * 0.88), text.substr(0, shown), HORIZONTAL_ALIGNMENT_CENTER, vs.x * 0.76, 24, 2, col)
	draw_string(f, Vector2(0, vs.y - 12), "ENTER / tap: next", HORIZONTAL_ALIGNMENT_CENTER, vs.x, 13, Color(0.5, 0.5, 0.5))


func _rnd(i: float) -> float:
	return fposmod(sin(i * 12.9898) * 43758.5453, 1.0)


func draw_scene(name: String, t: float, vs: Vector2, f: Font) -> void:
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.02, 0.02, 0.04))
	var cx := vs.x * 0.5
	match name:
		"facility":
			var bw := vs.x * 0.62
			var bx := vs.x * 0.19
			var by := vs.y * 0.28
			draw_rect(Rect2(bx, by, bw, vs.y * 0.52), Color(0.06, 0.07, 0.1))
			for r in range(5):
				for c in range(11):
					var on := sin(float(r * 31 + c * 17) + t * (0.6 + (c % 3) * 0.4)) > -0.3
					var wc := Color(1.0, 0.85, 0.4, 0.9) if on else Color(0.1, 0.1, 0.13)
					draw_rect(Rect2(bx + 24 + c * ((bw - 48.0) / 11.0), by + 28 + r * 56, 30, 30), wc)
			draw_rect(Rect2(0, vs.y * 0.8, vs.x, vs.y * 0.2), Color(0.04, 0.04, 0.06))
			draw_string(f, Vector2(bx, by - 18), "MX INDUSTRIES", HORIZONTAL_ALIGNMENT_CENTER, bw, 44, Color(0.9, 0.15, 0.15, 0.7 + 0.3 * sin(t * 4.0)))
		"corridor":
			var vp := Vector2(cx, vs.y * 0.45)
			for i in range(9):
				var k := 1.0 - i * 0.11
				var hw := vs.x * 0.45 * k
				var hh := vs.y * 0.4 * k
				var fl := 0.5 + 0.5 * sin(t * 9.0 + i * 1.7)
				var lc := Color(0.25, 0.28, 0.35, 0.8) if (i % 2 == 0 or fl > 0.5) else Color(0.08, 0.09, 0.12, 0.8)
				draw_rect(Rect2(vp.x - hw, vp.y - hh, hw * 2.0, hh * 2.0), lc, false, 3.0)
			draw_line(Vector2(0, vs.y), vp, Color(0.2, 0.22, 0.28), 3.0)
			draw_line(Vector2(vs.x, vs.y), vp, Color(0.2, 0.22, 0.28), 3.0)
			if t > 1.2:
				MXD.draw_mx(self, "omega", vp, 8.0 + (t - 1.2) * 10.0, minf(0.9, (t - 1.2) * 0.5), 0.0, t)
		"eyes":
			var kinds := ["omega", "kabob", "aagar", "x", "snicker", "hush", "tick"]
			for i in range(14):
				var kx := _rnd(i * 3.1) * vs.x
				var ky := vs.y * 0.15 + _rnd(i * 7.7) * vs.y * 0.65
				var vis := clampf(sin(t * 1.6 + i * 2.3) * 2.0, 0.0, 1.0)
				MXD.draw_eyes(self, kinds[i % kinds.size()], Vector2(kx, ky), 24.0, vis)
		"omega":
			MXD.draw_mx(self, "omega", Vector2(cx, vs.y * 0.5), 150.0 + t * 18.0, minf(1.0, t * 0.7), 0.0, t)
		"x":
			var xs := 150.0 + sin(t * 3.0) * 6.0
			MXD.draw_mx(self, "x", Vector2(cx, vs.y * 0.5), xs, 1.0, 0.0, t)
			for i in range(7):
				var gy := _rnd(floor(t * 8.0) + i * 5.0) * vs.y
				var gc := Color(0.2, 1.0, 1.0, 0.2) if i % 2 == 0 else Color(1.0, 0.2, 0.7, 0.2)
				draw_rect(Rect2(randf_range(-40.0, 40.0), gy, vs.x, randf_range(4.0, 20.0)), gc)
		"intercom":
			draw_rect(Rect2(cx - 150, vs.y * 0.25, 300, 260), Color(0.12, 0.13, 0.16))
			draw_rect(Rect2(cx - 150, vs.y * 0.25, 300, 260), Color(0.35, 0.37, 0.42), false, 4.0)
			for r in range(6):
				for c in range(8):
					draw_circle(Vector2(cx - 105 + c * 30, vs.y * 0.25 + 40 + r * 30), 5.0, Color(0.05, 0.05, 0.07))
			for i in range(40):
				var ah := 4.0 + absf(sin(t * 11.0 + i * 0.7)) * 40.0
				draw_line(Vector2(cx - 195 + i * 10, vs.y * 0.72 - ah), Vector2(cx - 195 + i * 10, vs.y * 0.72 + ah), Color(0.8, 0.45, 1.0, 0.7), 3.0)
		"door":
			for i in range(10):
				draw_rect(Rect2(cx - 120 - i * 14, vs.y * 0.18, 240 + i * 28, vs.y * 0.6), Color(1.0, 0.95, 0.8, 0.05 + 0.02 * i))
			draw_rect(Rect2(cx - 90, vs.y * 0.22, 180, vs.y * 0.56), Color(1.0, 0.97, 0.85))
			var sway := sin(t * 1.5) * 4.0
			draw_circle(Vector2(cx - 40 + sway, vs.y * 0.52), 22.0, Color(0.02, 0.02, 0.03))
			draw_rect(Rect2(cx - 58 + sway, vs.y * 0.56, 36, 110), Color(0.02, 0.02, 0.03))
			draw_circle(Vector2(cx + 30 - sway, vs.y * 0.54), 20.0, Color(0.02, 0.02, 0.03))
			draw_rect(Rect2(cx + 12 - sway, vs.y * 0.58, 36, 100), Color(0.02, 0.02, 0.03))
		"shutter":
			MXD.draw_mx(self, "omega", Vector2(cx, vs.y * 0.5), 140.0, 0.8, 0.0, t)
			var sy := minf(vs.y * 0.82, t * vs.y * 1.2) 
			draw_rect(Rect2(0, vs.y * 0.1, vs.x, sy - vs.y * 0.1), Color(0.5, 0.52, 0.58))
			for i in range(int(sy / 34.0)):
				draw_rect(Rect2(0, vs.y * 0.1 + i * 34.0, vs.x, 4), Color(0.2, 0.21, 0.26))
