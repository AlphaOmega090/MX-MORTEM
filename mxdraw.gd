extends RefCounted
# Draws each MX unit with primitives. Used in-world (small) and for jumpscares (huge).
# ci = the CanvasItem currently inside its _draw(), c = centre, s = radius in px.


static func P(c: Vector2, s: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, y) * s


static func tri(ci: CanvasItem, c: Vector2, s: float, a: Vector2, b: Vector2, d: Vector2, col: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([P(c, s, a.x, a.y), P(c, s, b.x, b.y), P(c, s, d.x, d.y)]), col)


static func eye_color(kind: String) -> Color:
	match kind:
		"omega":
			return Color(0.9, 0.5, 1.0)
		"snicker":
			return Color(1.0, 1.0, 1.0)
		"kabob":
			return Color(1.0, 0.35, 0.05)
		"aagar":
			return Color(0.4, 0.8, 1.0)
	return Color(1.0, 0.8, 0.4)


static func draw_eyes(ci: CanvasItem, kind: String, c: Vector2, s: float, al: float) -> void:
	var col := eye_color(kind)
	col.a = al
	ci.draw_circle(P(c, s, -0.4, -0.2), maxf(1.5, s * 0.16), col)
	ci.draw_circle(P(c, s, 0.4, -0.2), maxf(1.5, s * 0.16), col)


static func draw_mx(ci: CanvasItem, kind: String, c: Vector2, s: float, al: float, extra: float, t: float) -> void:
	var w := maxf(1.0, s * 0.07)
	match kind:
		"omega":
			var body := Color(0.38, 0.1, 0.55, al)
			tri(ci, c, s, Vector2(-0.75, -0.5), Vector2(-0.55, -1.6), Vector2(-0.15, -0.9), body)
			tri(ci, c, s, Vector2(0.75, -0.5), Vector2(0.55, -1.6), Vector2(0.15, -0.9), body)
			ci.draw_circle(c, s, body)
			var glow := Color(0.95, 0.8, 1.0, al)
			tri(ci, c, s, Vector2(-0.75, -0.35), Vector2(-0.15, -0.05), Vector2(-0.7, -0.05), glow)
			tri(ci, c, s, Vector2(0.75, -0.35), Vector2(0.15, -0.05), Vector2(0.7, -0.05), glow)
			var pts := PackedVector2Array()
			for i in range(8):
				pts.append(P(c, s, -0.7 + i * 0.2, 0.4 if i % 2 == 0 else 0.65))
			ci.draw_polyline(pts, Color(1, 1, 1, al), w)
		"snicker":
			ci.draw_circle(c, s, Color(0.88, 0.88, 0.92, al))
			ci.draw_circle(P(c, s, -0.4, -0.2), s * 0.22, Color(0, 0, 0, al))
			ci.draw_circle(P(c, s, 0.4, -0.2), s * 0.22, Color(0, 0, 0, al))
			ci.draw_circle(P(c, s, -0.4, -0.2), s * 0.06, Color(1, 1, 1, al))
			ci.draw_circle(P(c, s, 0.4, -0.2), s * 0.06, Color(1, 1, 1, al))
			ci.draw_arc(P(c, s, 0, 0.05), s * 0.7, PI * 0.12, PI * 0.88, 24, Color(0.05, 0, 0, al), s * 0.2)
			for i in range(7):
				var a := PI * (0.18 + i * 0.1)
				var p0 := P(c, s, 0, 0.05) + Vector2.from_angle(a) * s * 0.6
				var p1 := P(c, s, 0, 0.05) + Vector2.from_angle(a) * s * 0.8
				ci.draw_line(p0, p1, Color(1, 1, 1, al), w)
		"kabob":
			var hot := clampf(extra / 100.0, 0.0, 1.0)
			var body := Color(1.0, 0.45 - 0.3 * hot, 0.1, al)
			for i in range(5):
				var fx := -0.8 + i * 0.4
				var fh := 1.5 + hot * 0.7 + 0.12 * sin(t * 9.0 + i)
				tri(ci, c, s, Vector2(fx - 0.25, -0.7), Vector2(fx, -fh), Vector2(fx + 0.25, -0.7), Color(1.0, 0.8, 0.1, al))
			ci.draw_circle(c, s, body)
			ci.draw_circle(P(c, s, -0.4, -0.15), s * 0.2, Color(1, 1, 1, al))
			ci.draw_circle(P(c, s, 0.4, -0.15), s * 0.2, Color(1, 1, 1, al))
			ci.draw_circle(P(c, s, -0.4, -0.12), s * 0.08, Color(0.8, 0, 0, al))
			ci.draw_circle(P(c, s, 0.4, -0.12), s * 0.08, Color(0.8, 0, 0, al))
			ci.draw_line(P(c, s, -0.75, -0.55), P(c, s, -0.1, -0.3), Color(0.15, 0, 0, al), w * 1.5)
			ci.draw_line(P(c, s, 0.75, -0.55), P(c, s, 0.1, -0.3), Color(0.15, 0, 0, al), w * 1.5)
			ci.draw_colored_polygon(PackedVector2Array([P(c, s, -0.5, 0.25), P(c, s, 0.5, 0.25), P(c, s, 0.4, 0.75), P(c, s, -0.4, 0.75)]), Color(0.1, 0, 0, al))
			var teeth := PackedVector2Array()
			for i in range(6):
				teeth.append(P(c, s, -0.45 + i * 0.18, 0.25 if i % 2 == 0 else 0.45))
			ci.draw_polyline(teeth, Color(1, 1, 1, al), w)
		"aagar":
			var body := Color(0.25, 0.5, 0.95, al)
			ci.draw_circle(P(c, s, -1.0, -0.2), s * 0.55, body)
			ci.draw_circle(P(c, s, 1.0, -0.2), s * 0.55, body)
			ci.draw_circle(P(c, s, -1.0, -0.2), s * 0.3, Color(0.6, 0.8, 1.0, al))
			ci.draw_circle(P(c, s, 1.0, -0.2), s * 0.3, Color(0.6, 0.8, 1.0, al))
			ci.draw_circle(c, s, body)
			ci.draw_line(P(c, s, -0.6, -0.15), P(c, s, -0.15, -0.15), Color(0, 0, 0.1, al), w * 1.5)
			ci.draw_line(P(c, s, 0.6, -0.15), P(c, s, 0.15, -0.15), Color(0, 0, 0.1, al), w * 1.5)
			ci.draw_circle(P(c, s, 0, 0.4), s * (0.16 + 0.05 * sin(t * 4.0)), Color(0, 0, 0.1, al))
		"pup":
			var body := Color(0.7, 0.5, 0.3, al)
			tri(ci, c, s, Vector2(-0.9, -0.5), Vector2(-1.3, 0.5), Vector2(-0.5, 0.0), Color(0.45, 0.3, 0.15, al))
			tri(ci, c, s, Vector2(0.9, -0.5), Vector2(1.3, 0.5), Vector2(0.5, 0.0), Color(0.45, 0.3, 0.15, al))
			ci.draw_circle(c, s, body)
			ci.draw_circle(P(c, s, -0.35, -0.2), s * 0.14, Color(0, 0, 0, al))
			ci.draw_circle(P(c, s, 0.35, -0.2), s * 0.14, Color(0, 0, 0, al))
			ci.draw_circle(P(c, s, 0, 0.1), s * 0.14, Color(0.1, 0.05, 0.05, al))
			ci.draw_arc(P(c, s, 0, 0.15), s * 0.4, PI * 0.15, PI * 0.85, 12, Color(0.1, 0.05, 0.05, al), w)
