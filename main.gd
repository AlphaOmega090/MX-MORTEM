extends Node2D
# MX Mortem - story mode. Godot 4.x, GDScript. Everything is generated in code.

const Story = preload("res://story.gd")
const MXD = preload("res://mxdraw.gd")

const T := 48
const SC := 1.25   # speed scale to match the larger rooms
const W := 40
const H := 24
const RATE := 22050

var grid: Array = []
var lockers := {}
var items: Array = []
var enemies: Array = []

var chapter := 0
var ch: Dictionary = {}
var state := "title"     # title, intro, card, play, tape, jumpscare, dead, outro, end
var intro_page := 0

var player_pos := Vector2.ZERO
var facing := 0.0
var stamina := 100.0
var battery := 100.0
var flash_on := true
var has_key := false
var laser_cd := 0.0
var laser_vis := 0.0
var laser_end := Vector2.ZERO
var in_locker := false
var breath := 100.0
var gasping := false
var holding := false
var noise_timer := 0.0
var noise_radius := 0.0
var free_prog := 0.0
var freed := false
var allas_pos := Vector2.ZERO
var exit_pos := Vector2.ZERO
var door_tile := Vector2i(26, 9)
var phase := "day"
var clock := 20.0
var night_t := 0.0
var events: Array = []
var tapes_got := 0
var tape_id := 0
var chase_mode := false
var magnet := false

# touch controls
var touch_ui := false
var t_move := Vector2.ZERO
var t_sprint := false
var t_e := false
var t_cam := false
var t_breath := false
var touches := {}
var stick_origin := Vector2.ZERO
var stick_pos := Vector2.ZERO
var stick_active := false

var cam_on := false
var cam_snap: Array = []
var cam_snap_t := 0.0

var prox := 0.0
var shake := 0.0
var flick_next := 3.0
var flick_left := 0.0
var blackout_t := 0.0
var light_mul := 1.0
var ghost: Dictionary = {}
var hb_t := 0.0
var scare_t := 0.0
var scare_kind := ""
var time_acc := 0.0

var end_text := ""
var msg := ""
var msg_t := 0.0
var sub_text := ""
var sub_col := Color.WHITE
var sub_t := 0.0

var sounds := {}
var drone: AudioStreamPlayer
var static_snd: AudioStreamPlayer
var cam: Camera2D
var hud: Control
var rng := RandomNumberGenerator.new()


# ================================================================= setup

func _ready() -> void:
	rng.randomize()
	touch_ui = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")
	cam = Camera2D.new()
	cam.zoom = Vector2(1.4, 1.4)
	add_child(cam)
	cam.make_current()
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Control.new()
	hud.set_script(load("res://hud.gd"))
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.set("g", self)
	make_sounds()
	build_map()
	populate()
	player_pos = tcenter(Vector2i(3, 3))


func start_chapter(i: int, show_card: bool = true) -> void:
	chapter = i
	ch = Story.CHAPTERS[i]
	build_map()
	populate()
	stamina = 100.0
	battery = 100.0
	flash_on = true
	has_key = false
	laser_cd = 0.0
	laser_vis = 0.0
	in_locker = false
	breath = 100.0
	gasping = false
	holding = false
	noise_timer = 0.0
	noise_radius = 0.0
	free_prog = 0.0
	freed = false
	phase = "day"
	clock = ch.day
	night_t = 0.0
	events = ch.events.duplicate(true)
	tapes_got = 0
	chase_mode = false
	cam_on = false
	prox = 0.0
	shake = 0.0
	blackout_t = 0.0
	flick_left = 0.0
	flick_next = 4.0
	ghost = {}
	msg_t = 0.0
	sub_t = 0.0
	state = "card" if show_card else "play"
	if not show_card:
		say(ch.tip, 5.0)


func carve(x: int, y: int, w: int, h: int) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			grid[yy][xx] = 0


func build_map() -> void:
	grid = []
	for y in range(H):
		var row: Array = []
		for x in range(W):
			row.append(1)
		grid.append(row)
	carve(1, 1, 6, 4)
	carve(9, 1, 8, 4)
	carve(19, 1, 9, 4)
	carve(30, 1, 9, 4)
	for x in [3, 12, 22, 33]:
		carve(x, 5, 2, 1)
	carve(1, 6, 38, 2)
	carve(1, 10, 8, 5)
	carve(11, 10, 9, 5)
	carve(22, 10, 8, 5)
	carve(32, 10, 7, 5)
	for x in [4, 14, 34]:
		carve(x, 8, 2, 2)
		carve(x, 15, 2, 1)
	carve(26, 8, 1, 2)
	grid[door_tile.y][door_tile.x] = 2
	carve(1, 16, 38, 2)
	carve(1, 19, 8, 4)
	carve(11, 19, 10, 4)
	carve(30, 19, 9, 4)
	for x in [4, 15, 35]:
		carve(x, 18, 2, 1)


func populate() -> void:
	items = []
	enemies = []
	lockers = {}
	player_pos = tcenter(Vector2i(3, 3))
	allas_pos = tcenter(Vector2i(26, 12))
	exit_pos = tcenter(Vector2i(36, 21))
	for l in [Vector2i(1, 1), Vector2i(9, 1), Vector2i(8, 10), Vector2i(38, 10), Vector2i(1, 19)]:
		lockers[l] = true
	if ch.is_empty():
		return
	if ch.has("key"):
		items.append({"type": "key", "id": 0, "pos": tcenter(ch.key), "taken": false})
	for t in ch.tapes:
		items.append({"type": "tape", "id": t[0], "pos": tcenter(t[1]), "taken": false})
	for b in ch.batteries:
		items.append({"type": "battery", "id": 0, "pos": tcenter(b), "taken": false})
	for e in ch.enemies:
		enemies.append(make_enemy(e[0], e[1]))


func make_enemy(kind: String, tile: Vector2i) -> Dictionary:
	var p := tcenter(tile)
	return {"kind": kind, "pos": p, "target": p, "state": "patrol", "stun": 0.0,
		"dir": Vector2.ZERO, "rep": 0.0, "rage": 0.0, "lost": 0.0,
		"talk": rng.randf_range(3.0, 7.0)}


# ================================================================= grid helpers

func tcenter(t: Vector2i) -> Vector2:
	return Vector2(t.x * T + T / 2.0, t.y * T + T / 2.0)


func tile_of(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / T), floori(p.y / T))


func is_solid(tx: int, ty: int) -> bool:
	if tx < 0 or ty < 0 or tx >= W or ty >= H:
		return true
	return grid[ty][tx] != 0


func is_solid_at(p: Vector2) -> bool:
	return is_solid(floori(p.x / T), floori(p.y / T))


func collides(p: Vector2, r: float) -> bool:
	var x0 := floori((p.x - r) / T)
	var x1 := floori((p.x + r) / T)
	var y0 := floori((p.y - r) / T)
	var y1 := floori((p.y + r) / T)
	for ty in range(y0, y1 + 1):
		for tx in range(x0, x1 + 1):
			if is_solid(tx, ty):
				return true
	return false


func try_move(pos: Vector2, delta: Vector2, r: float) -> Vector2:
	var p := pos
	p.x += delta.x
	if collides(p, r):
		p.x = pos.x
	var q := p
	q.y += delta.y
	if collides(q, r):
		q.y = p.y
	return q


func los(a: Vector2, b: Vector2) -> bool:
	var d := a.distance_to(b)
	var steps := int(d / 8.0)
	for i in range(1, steps):
		if is_solid_at(a.lerp(b, float(i) / float(steps))):
			return false
	return true


func bfs_dist(target: Vector2i) -> Array:
	var d: Array = []
	for y in range(H):
		var row: Array = []
		for x in range(W):
			row.append(-1)
		d.append(row)
	if is_solid(target.x, target.y):
		return d
	var q: Array = [target]
	d[target.y][target.x] = 0
	var head := 0
	var offs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while head < q.size():
		var c: Vector2i = q[head]
		head += 1
		for off in offs:
			var n: Vector2i = c + off
			if is_solid(n.x, n.y) or d[n.y][n.x] != -1:
				continue
			d[n.y][n.x] = d[c.y][c.x] + 1
			q.append(n)
	return d


func dir_toward(from: Vector2, target: Vector2) -> Vector2:
	var ft := tile_of(from)
	var tt := tile_of(target)
	if ft == tt:
		return (target - from).normalized()
	var d := bfs_dist(tt)
	var bd: int = d[ft.y][ft.x]
	if bd == -1:
		return Vector2.ZERO
	var best := ft
	for off in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n: Vector2i = ft + off
		if is_solid(n.x, n.y):
			continue
		var nd: int = d[n.y][n.x]
		if nd != -1 and nd < bd:
			bd = nd
			best = n
	if best == ft:
		return Vector2.ZERO
	return (tcenter(best) - from).normalized()


func random_floor() -> Vector2:
	for i in range(60):
		var rx := rng.randi_range(1, W - 2)
		var ry := rng.randi_range(1, H - 2)
		if grid[ry][rx] == 0:
			return tcenter(Vector2i(rx, ry))
	return tcenter(Vector2i(3, 3))


# ================================================================= audio

func wav(data: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	var b := PackedByteArray()
	b.resize(data.size() * 2)
	for i in range(data.size()):
		b.encode_s16(i * 2, int(clampf(data[i], -1.0, 1.0) * 32767.0))
	s.data = b
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = data.size()
	return s


func gen(dur: float, fn: Callable) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var a := PackedFloat32Array()
	a.resize(n)
	for i in range(n):
		a[i] = fn.call(float(i) / RATE, dur)
	return a


func make_sounds() -> void:
	sounds["drone"] = wav(gen(2.0, func(t, _d):
		var trem: float = 0.8 + 0.2 * sin(TAU * 0.5 * t)
		return (sin(TAU * 55.0 * t) * 0.3 + sin(TAU * 82.5 * t) * 0.15 + sin(TAU * 165.0 * t) * 0.05) * trem), true)
	sounds["beat"] = wav(gen(0.6, func(t, _d):
		var a: float = exp(-t * 16.0) * sin(TAU * 55.0 * t)
		var t2: float = t - 0.22
		if t2 > 0.0:
			a += 0.7 * exp(-t2 * 16.0) * sin(TAU * 48.0 * t2)
		return a * 0.9))
	sounds["scream"] = wav(gen(1.3, func(t, d):
		var env: float = pow(maxf(0.0, 1.0 - t / d), 0.5)
		var tone: float = sin(TAU * (900.0 * t - 300.0 * t * t))
		tone = 1.0 if tone > 0.0 else -1.0
		return (tone * 0.35 + (randf() * 2.0 - 1.0) * 0.5) * env))
	sounds["stinger"] = wav(gen(1.2, func(t, d):
		var env: float = exp(-t * 3.0)
		return (sin(TAU * 220.0 * t) + sin(TAU * 233.0 * t) + sin(TAU * 311.0 * t)) * 0.2 * env))
	sounds["slam"] = wav(gen(0.8, func(t, _d):
		return ((randf() * 2.0 - 1.0) * exp(-t * 14.0) + sin(TAU * 45.0 * t) * exp(-t * 7.0)) * 0.9))
	sounds["tape"] = wav(gen(0.5, func(t, _d):
		return sin(TAU * (300.0 + 400.0 * t) * t) * 0.3 * (1.0 - t / 0.5)))
	sounds["static"] = wav(gen(0.5, func(_t, _d):
		return (randf() * 2.0 - 1.0) * 0.25), true)
	drone = AudioStreamPlayer.new()
	drone.stream = sounds["drone"]
	drone.volume_db = -14.0
	add_child(drone)
	static_snd = AudioStreamPlayer.new()
	static_snd.stream = sounds["static"]
	static_snd.volume_db = -16.0
	add_child(static_snd)


func sfx(name: String, db: float = 0.0) -> void:
	if not sounds.has(name):
		return
	var p := AudioStreamPlayer.new()
	p.stream = sounds[name]
	p.volume_db = db
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


# ================================================================= text

func say(s: String, t: float = 3.0) -> void:
	msg = s
	msg_t = t


func speak(who: String, text: String, dur: float = 3.5) -> void:
	sub_text = Story.NAMES[who] + ": " + text
	sub_col = Story.COLORS[who]
	sub_t = dur


func pick(arr: Array) -> String:
	return arr[rng.randi_range(0, arr.size() - 1)]


# ================================================================= input

func advance() -> void:
	match state:
		"title":
			state = "intro"
			intro_page = 0
			if not drone.playing:
				drone.play()
		"intro":
			intro_page += 1
			if intro_page >= Story.INTRO.size():
				start_chapter(0)
		"card":
			state = "play"
			say(ch.tip, 5.0)
		"tape":
			state = "play"
		"outro":
			if chapter + 1 < Story.CHAPTERS.size():
				start_chapter(chapter + 1)
			else:
				state = "end"
		"end":
			state = "title"
		"dead":
			start_chapter(chapter, false)


func touch_buttons(vs: Vector2) -> Dictionary:
	return {
		"e": [Vector2(vs.x - 120.0, vs.y - 150.0), 56.0],
		"laser": [Vector2(vs.x - 280.0, vs.y - 100.0), 48.0],
		"sprint": [Vector2(vs.x - 110.0, vs.y - 300.0), 46.0],
		"light": [Vector2(vs.x - 280.0, vs.y - 240.0), 40.0],
		"cam": [Vector2(vs.x - 420.0, vs.y - 100.0), 40.0],
		"breath": [Vector2(vs.x - 420.0, vs.y - 220.0), 40.0],
	}


func touch_down(idx: int, pos: Vector2) -> void:
	if state != "play":
		if state != "jumpscare":
			advance()
		return
	var vs := get_viewport_rect().size
	var btns := touch_buttons(vs)
	for n in btns.keys():
		if pos.distance_to(btns[n][0]) <= btns[n][1] * 1.25:
			touches[idx] = {"btn": n}
			match n:
				"e":
					t_e = true
					press_interact()
				"sprint":
					t_sprint = true
				"cam":
					t_cam = true
				"breath":
					t_breath = true
				"light":
					if battery > 0.0:
						flash_on = not flash_on
				"laser":
					auto_aim()
					fire_laser()
			return
	if pos.x < vs.x * 0.55 and not stick_active:
		stick_active = true
		stick_origin = pos
		stick_pos = pos
		t_move = Vector2.ZERO
		touches[idx] = {"stick": true}


func touch_drag(idx: int, pos: Vector2) -> void:
	if touches.has(idx) and touches[idx].has("stick"):
		stick_pos = pos
		t_move = ((pos - stick_origin) / 80.0).limit_length(1.0)
		if t_move.length() < 0.15:
			t_move = Vector2.ZERO


func touch_up(idx: int) -> void:
	if not touches.has(idx):
		return
	var t: Dictionary = touches[idx]
	if t.has("stick"):
		stick_active = false
		t_move = Vector2.ZERO
	elif t.has("btn"):
		match t.btn:
			"e":
				t_e = false
			"sprint":
				t_sprint = false
			"cam":
				t_cam = false
			"breath":
				t_breath = false
	touches.erase(idx)


func auto_aim() -> void:
	var best := 320.0
	for e in enemies:
		var d: float = e.pos.distance_to(player_pos)
		if d < best and los(player_pos, e.pos):
			best = d
			facing = (e.pos - player_pos).angle()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch_ui = true
		if event.pressed:
			touch_down(event.index, event.position)
		else:
			touch_up(event.index)
		return
	if event is InputEventScreenDrag:
		touch_drag(event.index, event.position)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k: int = event.keycode
		if k == KEY_ENTER or k == KEY_KP_ENTER or k == KEY_SPACE:
			if state != "play" and state != "jumpscare":
				advance()
		elif k == KEY_R:
			if state == "play" or state == "dead":
				start_chapter(chapter, false)
		elif k == KEY_F:
			if state == "play" and battery > 0.0:
				flash_on = not flash_on
		elif k == KEY_E:
			if state == "tape":
				state = "play"
			else:
				press_interact()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		fire_laser()


func press_interact() -> void:
	if state != "play":
		return
	if in_locker:
		in_locker = false
		return
	for k in lockers.keys():
		var c := tcenter(k)
		if player_pos.distance_to(c) < 42.0:
			if chase_mode:
				say("No hiding. He can smell you.", 2.0)
				return
			in_locker = true
			player_pos = c
			say("Hiding. Don't breathe.", 2.0)
			return
	var dc := tcenter(door_tile)
	if ch.allas and player_pos.distance_to(dc) < 72.0 and grid[door_tile.y][door_tile.x] == 2:
		if has_key:
			grid[door_tile.y][door_tile.x] = 0
			sfx("slam", -8.0)
			say("Cell door unlocked. Hold E next to Allas.", 4.0)
		else:
			say("Locked. You need the keycard.", 2.5)


func fire_laser() -> void:
	if state != "play" or in_locker or cam_on:
		return
	if laser_cd > 0.0 or battery < 15.0:
		return
	laser_cd = 4.0
	battery -= 15.0
	var dir := Vector2.from_angle(facing)
	var tip := player_pos
	var l := 0.0
	while l < 300.0:
		var np := player_pos + dir * (l + 6.0)
		if is_solid_at(np):
			break
		tip = np
		l += 6.0
	laser_end = tip
	laser_vis = 0.15
	for e in enemies:
		var rel: Vector2 = e.pos - player_pos
		var along := rel.dot(dir)
		if along > 0.0 and along < l + 10.0 and absf(rel.cross(dir)) < 16.0:
			e.stun = 4.0
			if e.kind == "omega" and chase_mode:
				e.stun = 1.5


# ================================================================= update

func _process(dt: float) -> void:
	time_acc += dt
	if msg_t > 0.0:
		msg_t -= dt
	if sub_t > 0.0:
		sub_t -= dt
	if state == "play":
		update_game(dt)
	elif state == "jumpscare":
		scare_t -= dt
		shake = 14.0
		if scare_t <= 0.0:
			state = "dead"
			shake = 0.0
	if state != "play" and static_snd.playing:
		static_snd.stop()
	cam.position = player_pos
	cam.offset = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * shake
	hud.queue_redraw()
	queue_redraw()


func update_game(dt: float) -> void:
	laser_cd = maxf(0.0, laser_cd - dt)
	laser_vis -= dt

	if phase == "day":
		clock -= dt
		if clock <= 0.0:
			phase = "night"
			clock = 0.0
			sfx("stinger", -6.0)
			say("NIGHT - the facility wakes up.", 4.0)
	else:
		clock += dt
		night_t += dt
		run_events()

	if t_move.length() > 0.2:
		facing = t_move.angle()
	elif not touch_ui:
		facing = (get_global_mouse_position() - player_pos).angle()

	# FNAF-style camera monitor (hold TAB): you can't move while watching it
	cam_on = (Input.is_key_pressed(KEY_TAB) or Input.is_key_pressed(KEY_C) or t_cam) and battery > 0.0
	if cam_on:
		battery = maxf(0.0, battery - 4.0 * dt)
		cam_snap_t -= dt
		if cam_snap_t <= 0.0:
			cam_snap = []
			for e in enemies:
				if e.kind != "omega":
					cam_snap.append({"kind": e.kind, "pos": e.pos})
			cam_snap_t = 1.5
		if not static_snd.playing:
			static_snd.play()
	elif static_snd.playing:
		static_snd.stop()

	# movement
	var dir := Vector2.ZERO
	if not in_locker and not cam_on:
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			dir.y -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			dir.y += 1.0
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			dir.x -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			dir.x += 1.0
		if t_move.length() > 0.0:
			dir = t_move
	var sprint := (Input.is_key_pressed(KEY_SHIFT) or t_sprint) and stamina > 0.0 and dir != Vector2.ZERO
	var spd := 120.0
	if sprint:
		spd = 200.0
		stamina = maxf(0.0, stamina - 30.0 * dt)
	else:
		stamina = minf(100.0, stamina + 15.0 * dt)
	if freed:
		spd *= 0.9
	spd *= SC
	if dir != Vector2.ZERO:
		player_pos = try_move(player_pos, dir.limit_length(1.0) * spd * dt, 10.0)
	noise_radius = 0.0
	if dir != Vector2.ZERO:
		noise_radius = 260.0 if sprint else 110.0

	# flashlight
	if flash_on and not in_locker:
		battery = maxf(0.0, battery - 2.0 * dt)
		if battery <= 0.0:
			flash_on = false
			say("Flashlight battery dead!", 2.5)

	# magnetic hands
	magnet = (Input.is_key_pressed(KEY_E) or t_e) and not in_locker and not cam_on
	if magnet:
		pull_items(dt)
		if state != "play":
			return
		if ch.allas and (not freed) and grid[door_tile.y][door_tile.x] == 0 and player_pos.distance_to(allas_pos) < 62.0:
			free_prog += dt
			if free_prog >= 1.5:
				freed = true
				say("Allas is free! Get her to the exit.", 4.0)
				if ch.chase:
					start_chase()
		else:
			free_prog = maxf(0.0, free_prog - dt)
	else:
		free_prog = maxf(0.0, free_prog - dt)

	if freed:
		var to := player_pos - allas_pos
		if to.length() > 50.0:
			allas_pos = try_move(allas_pos, to.normalized() * 115.0 * SC * dt, 8.0)

	update_hiding(dt)

	if phase == "night":
		for e in enemies:
			update_enemy(e, dt)
		if state != "play":
			return

	update_atmosphere(dt)

	# ghost (scripted peek)
	if not ghost.is_empty():
		ghost.t -= dt
		if ghost.t <= 0.0:
			ghost = {}
			sfx("slam", -14.0)

	# exit
	if player_pos.distance_to(exit_pos) < 40.0:
		var ok := false
		var why := ""
		if ch.goal == "tapes":
			ok = tapes_got >= ch.tapes.size()
			why = "The exit is sealed. %d tape(s) left." % (ch.tapes.size() - tapes_got)
		else:
			ok = freed
			why = "You can't leave without Allas."
		if ok:
			state = "outro"
			sfx("stinger", -4.0)
			shake = 0.0
		elif msg_t <= 0.0:
			say(why, 2.5)


func update_hiding(dt: float) -> void:
	holding = false
	if in_locker:
		var near := false
		if phase == "night":
			for e in enemies:
				if e.kind == "aagar" and e.pos.distance_to(player_pos) < 220.0:
					near = true
		if near:
			if breath <= 0.0:
				gasping = true
			if gasping and breath >= 35.0:
				gasping = false
			holding = (Input.is_key_pressed(KEY_SPACE) or t_breath) and not gasping and breath > 0.0
			if holding:
				breath = maxf(0.0, breath - 35.0 * dt)
				noise_timer = maxf(0.0, noise_timer - dt)
			else:
				breath = minf(100.0, breath + 25.0 * dt)
				noise_timer += dt * (1.5 if gasping else 1.0)
			if noise_timer > 3.0:
				die("Aagar heard you breathing.", "aagar")
		else:
			breath = minf(100.0, breath + 40.0 * dt)
			noise_timer = maxf(0.0, noise_timer - dt)
			gasping = false
	else:
		breath = minf(100.0, breath + 40.0 * dt)
		noise_timer = 0.0
		gasping = false


func update_atmosphere(dt: float) -> void:
	# proximity of the nearest awake unit (omega's camouflage still raises it)
	prox = 0.0
	if phase == "night":
		for e in enemies:
			if e.stun > 0.0:
				continue
			prox = maxf(prox, 1.0 - e.pos.distance_to(player_pos) / 320.0)
	shake = maxf(0.0, shake - 25.0 * dt)
	if prox > 0.55:
		shake = maxf(shake, (prox - 0.55) * 9.0)

	# lights
	blackout_t = maxf(0.0, blackout_t - dt)
	light_mul = 1.0
	if phase == "night":
		flick_next -= dt
		if flick_next <= 0.0:
			flick_left = rng.randf_range(0.08, 0.3)
			var gap := rng.randf_range(2.0, 6.0) * (1.0 - 0.7 * prox)
			if chase_mode:
				gap = rng.randf_range(0.4, 1.5)
			flick_next = gap
		if flick_left > 0.0:
			flick_left -= dt
			light_mul = rng.randf_range(0.05, 0.45)

	# heartbeat
	if prox > 0.05:
		hb_t -= dt
		if hb_t <= 0.0:
			sfx("beat", -20.0 + prox * 16.0)
			hb_t = lerpf(1.1, 0.38, prox)


func run_events() -> void:
	for ev in events:
		if ev.get("done", false):
			continue
		if night_t >= ev.t:
			ev["done"] = true
			fire_event(ev)


func fire_event(ev: Dictionary) -> void:
	match ev.type:
		"whisper":
			speak(ev.who, ev.say, 4.0)
			sfx("stinger", -12.0)
		"blackout":
			blackout_t = ev.dur
			sfx("stinger", -4.0)
			shake = 5.0
			speak(ev.who, ev.say, 4.0)
		"slam":
			sfx("slam", 0.0)
			shake = 9.0
			say("Something slammed a door nearby...", 3.0)
		"peek":
			var base := facing
			for d in [200.0, 150.0, 100.0, 60.0]:
				var p: Vector2 = player_pos + Vector2.from_angle(base) * d
				if not is_solid_at(p) and los(player_pos, p):
					ghost = {"kind": ev.kind, "pos": p, "t": 0.9}
					sfx("stinger", -2.0)
					shake = 6.0
					break


func start_chase() -> void:
	chase_mode = true
	sfx("stinger", 0.0)
	shake = 10.0
	speak("omega", "RUN, LITTLE TECHNICIAN.", 4.0)
	say("OMEGA IS HUNTING YOU. Get to the exit!", 4.0)


func pull_items(dt: float) -> void:
	for it in items:
		if it.taken:
			continue
		var d: float = it.pos.distance_to(player_pos)
		if d < 180.0 and los(player_pos, it.pos):
			it.pos += (player_pos - it.pos).normalized() * 280.0 * dt
			if it.pos.distance_to(player_pos) < 14.0:
				it.taken = true
				if it.type == "key":
					has_key = true
					say("Keycard acquired. Unlock the red door (E).", 4.0)
				elif it.type == "tape":
					tapes_got += 1
					tape_id = it.id
					state = "tape"
					sfx("tape", -2.0)
					return
				else:
					battery = minf(100.0, battery + 50.0)
					say("Battery +50", 1.5)


func die(why: String, kind: String = "") -> void:
	if state != "play":
		return
	end_text = why
	if kind == "":
		state = "dead"
	else:
		state = "jumpscare"
		scare_kind = kind
		scare_t = 1.4
		sfx("scream", 2.0)
		shake = 14.0


func update_enemy(e: Dictionary, dt: float) -> void:
	if e.stun > 0.0:
		e.stun -= dt
		return
	var k: String = e.kind
	var dist: float = e.pos.distance_to(player_pos)
	var sees := false
	match k:
		"omega":
			sees = (not in_locker) and dist < 320.0 and los(e.pos, player_pos)
			if chase_mode:
				sees = true
		"snicker":
			sees = (not in_locker) and dist < 240.0
		"kabob":
			sees = (not in_locker) and dist < 260.0 and los(e.pos, player_pos)
		"pup":
			sees = (not in_locker) and dist < 170.0 and los(e.pos, player_pos)
		"aagar":
			sees = noise_radius > 0.0 and dist < noise_radius

	if k == "kabob":
		if sees:
			e.rage = minf(100.0, e.rage + 40.0 * dt)
		else:
			e.rage = maxf(0.0, e.rage - 15.0 * dt)

	var was_chasing: bool = e.state == "chase"
	if sees:
		e.state = "chase"
		e.target = player_pos
		e.lost = 4.0
		if k == "omega":
			for p in enemies:
				if p.kind == "pup":
					p.state = "chase"
					p.target = player_pos
					p.lost = 4.0
	elif e.state == "chase":
		e.lost -= dt
		if e.lost <= 0.0 or e.pos.distance_to(e.target) < 16.0:
			e.state = "patrol"
			e.target = e.pos

	# personality: voice lines
	e.talk -= dt
	if e.state == "chase" and not was_chasing:
		if rng.randf() < 0.8:
			speak(k, pick(Story.LINES[k].spot), 2.5)
		e.talk = 6.0
	elif e.talk <= 0.0 and dist < 360.0 and sub_t <= 0.0:
		speak(k, pick(Story.LINES[k].idle), 3.0)
		e.talk = rng.randf_range(9.0, 15.0)
	elif e.talk <= 0.0:
		e.talk = 3.0

	if e.state == "patrol" and e.pos.distance_to(e.target) < 24.0:
		if k == "pup":
			for o in enemies:
				if o.kind == "omega":
					e.target = o.pos + Vector2(rng.randf_range(-60.0, 60.0), rng.randf_range(-60.0, 60.0))
			if e.pos.distance_to(e.target) < 24.0:
				e.target = random_floor()
		else:
			e.target = random_floor()

	var chasing: bool = e.state == "chase"
	var spd := 70.0
	match k:
		"omega":
			spd = 135.0 if chasing else 70.0
			if chase_mode:
				spd = 172.0
		"snicker":
			spd = 150.0 if chasing else 60.0
		"kabob":
			if chasing:
				spd = 250.0 if e.rage >= 100.0 else 120.0
			else:
				spd = 60.0
		"aagar":
			spd = 170.0 if chasing else 55.0
		"pup":
			spd = 150.0 if chasing else 90.0

	spd *= SC
	e.rep -= dt
	if e.rep <= 0.0:
		e.dir = dir_toward(e.pos, e.target)
		e.rep = 0.2
	e.pos = try_move(e.pos, e.dir * spd * dt, 9.0)

	if (not in_locker) and e.pos.distance_to(player_pos) < 20.0:
		var names := {"omega": "Omega 090", "snicker": "Snicker", "kabob": "Kabob",
			"aagar": "Aagar", "pup": "an MX Pup"}
		die("Caught by %s." % names[k], k)


# ================================================================= drawing

func shade(c: Color, b: float) -> Color:
	return Color(c.r * b, c.g * b, c.b * b, 1.0)


func bright_at(p: Vector2) -> float:
	var d := p.distance_to(player_pos)
	if blackout_t > 0.0:
		return clampf(1.0 - d / 45.0, 0.0, 1.0) * 0.5
	var day := phase == "day"
	var amb := 300.0 if day else 110.0
	var b := clampf(1.0 - d / amb, 0.0, 1.0) * (0.9 if day else 0.45)
	if flash_on and battery > 0.0 and not in_locker and d < 280.0:
		var ang := absf(angle_difference(facing, (p - player_pos).angle()))
		if ang < 0.5:
			var edge := clampf((0.5 - ang) / 0.15, 0.0, 1.0)
			b = maxf(b, clampf(1.0 - d / 280.0, 0.0, 1.0) * edge)
	return b * light_mul


func _draw() -> void:
	if state == "title" or state == "intro" or state == "card" or state == "outro" or state == "end":
		return
	var pt := tile_of(player_pos)
	for ty in range(maxi(0, pt.y - 7), mini(H, pt.y + 8)):
		for tx in range(maxi(0, pt.x - 10), mini(W, pt.x + 11)):
			var c := Vector2(tx * T + T / 2.0, ty * T + T / 2.0)
			var b := bright_at(c)
			if b < 0.03:
				continue
			var t: int = grid[ty][tx]
			var col: Color = Color(0.42, 0.44, 0.48) if ((tx + ty) % 2 == 0) else Color(0.38, 0.40, 0.44)
			if t == 1:
				col = Color(0.14, 0.16, 0.22)
			elif t == 2:
				col = Color(0.65, 0.18, 0.18)
			draw_rect(Rect2(tx * T, ty * T, T, T), shade(col, b))
			if lockers.has(Vector2i(tx, ty)):
				draw_rect(Rect2(tx * T + 6, ty * T + 3, T - 12, T - 6), shade(Color(0.45, 0.3, 0.15), b))

	var exit_open: bool = (ch.goal == "tapes" and tapes_got >= ch.tapes.size()) or (ch.goal != "tapes" and freed)
	var ecol := Color(0.2, 0.9, 0.4) if exit_open else Color(0.7, 0.15, 0.15)
	draw_rect(Rect2(exit_pos - Vector2(14, 14), Vector2(28, 28)), shade(ecol, maxf(bright_at(exit_pos), 0.35)))

	for it in items:
		if it.taken:
			continue
		var b := bright_at(it.pos)
		if b < 0.05:
			continue
		var bb := maxf(b, 0.5)
		if it.type == "key":
			draw_circle(it.pos, 7.0, shade(Color(1.0, 0.85, 0.1), bb))
		elif it.type == "tape":
			draw_rect(Rect2(it.pos - Vector2(8, 5), Vector2(16, 10)), shade(Color(0.9, 0.9, 0.9), bb))
			draw_rect(Rect2(it.pos - Vector2(5, 2), Vector2(10, 4)), shade(Color(0.15, 0.15, 0.15), bb))
		else:
			draw_rect(Rect2(it.pos - Vector2(5, 7), Vector2(10, 14)), shade(Color(0.2, 0.9, 0.3), bb))

	if ch.allas:
		var ab := bright_at(allas_pos)
		if ab > 0.05 or freed:
			draw_circle(allas_pos, 9.0, shade(Color(1.0, 0.55, 0.75), maxf(ab, 0.5)))
			if free_prog > 0.0:
				draw_arc(allas_pos, 16.0, 0.0, TAU * (free_prog / 1.5), 24, Color(0.4, 1, 0.6), 3.0)

	for e in enemies:
		var d: float = e.pos.distance_to(player_pos)
		var eb := bright_at(e.pos)
		# eyes glow in the dark
		if phase == "night" and eb < 0.3 and d < 420.0 and (d < 120.0 or los(player_pos, e.pos)):
			var blink := 0.5 + 0.5 * sin(time_acc * 3.0 + e.pos.x)
			var ea := clampf(1.0 - d / 420.0, 0.1, 1.0) * (0.4 + 0.6 * blink)
			if e.kind == "omega" and not chase_mode:
				ea *= 0.35
			MXD.draw_eyes(self, e.kind, e.pos, 12.0, ea)
		if eb < 0.05:
			continue
		var al := clampf(eb + 0.2, 0.0, 1.0)
		var r := 11.0
		match e.kind:
			"omega":
				r = 14.0
				if d > 130.0 and e.stun <= 0.0 and not chase_mode:
					al *= 0.1
			"kabob":
				r = 12.0 + e.rage * 0.05
			"pup":
				r = 7.0
		MXD.draw_mx(self, e.kind, e.pos, r, al, e.rage, time_acc)
		if e.stun > 0.0:
			draw_arc(e.pos, r + 5.0, 0.0, TAU, 20, Color(1, 1, 0.2), 2.0)

	if not ghost.is_empty():
		var ga := 0.5 + 0.5 * sin(time_acc * 25.0)
		MXD.draw_mx(self, ghost.kind, ghost.pos, 15.0, ga, 0.0, time_acc)

	if in_locker:
		draw_arc(player_pos, 14.0, 0.0, TAU, 20, Color(0.5, 0.8, 1.0, 0.6), 2.0)
	else:
		if noise_radius > 0.0:
			draw_arc(player_pos, noise_radius, 0.0, TAU, 48, Color(1, 1, 1, 0.12), 1.5)
		draw_circle(player_pos, 10.0, Color(0.3, 0.85, 1.0))
		draw_line(player_pos, player_pos + Vector2.from_angle(facing) * 16.0, Color.WHITE, 3.0)
		if magnet:
			draw_arc(player_pos, 180.0, 0.0, TAU, 48, Color(0.4, 0.5, 1.0, 0.25), 2.0)
	if laser_vis > 0.0:
		draw_line(player_pos, laser_end, Color(1.0, 0.1, 0.1), 2.5)
