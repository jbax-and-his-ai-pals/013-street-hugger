class_name FighterVisual
extends Node2D
## Procedural puppet. Position is the feet anchor, raised by physics when jumping.
## The match owns timing; visuals never change gameplay state or node transforms.

var palette_index: int = 0
var facing: float = 1.0
var pose: String = "idle"
var phase: float = 0.0
var clock: float = 0.0
var stretch: float = 0.0
var airborne: bool = false
var jump_progress: float = 0.0
var flight_progress: float = 0.0
var vertical_speed: float = 0.0
var landing: float = 0.0
var ground_offset: float = 0.0

const INK := Color("20263b")
const SKINS := [Color("d7956f"), Color("b77454"), Color("efbc88"), Color("965e51"), Color("daaa8b"), Color("744d48"), Color("d99677"), Color("b57e66")]
const SUITS := [Color("f1dca9"), Color("56c9bb"), Color("c17ecb"), Color("f3b957"), Color("e68b7a"), Color("70a8e8"), Color("f1ecdb"), Color("90bc77")]
const ACCENTS := [Color("e85c63"), Color("f2d779"), Color("8de0da"), Color("e66c83"), Color("f9dc85"), Color("f0d76c"), Color("b27bce"), Color("f6c293")]

var _flip: float = 1.0
var _bob: float = 0.0
var _lean: float = 0.0
var _angle: float = 0.0
var _lift: float = 0.0
var _squash: float = 0.0

func _p(v: Vector2) -> Vector2:
	v.x += _lean * (-v.y / 150.0)
	v = (v - Vector2(0, -85)).rotated(_angle) + Vector2(0, -85)
	# Squash toward the feet without moving their floor anchor.
	v.x *= 1.0 + _squash * 0.055
	v.y *= 1.0 - _squash * 0.10
	return Vector2(v.x * _flip, v.y + _bob + _lift)

func _line(a: Vector2, b: Vector2, color: Color, width: float) -> void:
	draw_line(_p(a), _p(b), color, width, true)
	draw_circle(_p(a), width * 0.5, color)
	draw_circle(_p(b), width * 0.5, color)

func _limb(a: Vector2, b: Vector2, c: Vector2, color: Color, width: float) -> void:
	_line(a, b, INK, width + 6)
	_line(b, c, INK, width + 6)
	_line(a, b, color, width)
	_line(b, c, color, width)

func _oval(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for n in range(40):
		var a := TAU * float(n) / 40.0
		points.append(_p(center + Vector2(cos(a) * radius.x, sin(a) * radius.y)))
	draw_colored_polygon(points, color)

func _shape(points: Array[Vector2], color: Color, outline: bool = true) -> void:
	var polygon := PackedVector2Array()
	for point in points:
		polygon.append(_p(point))
	draw_colored_polygon(polygon, color)
	if outline:
		polygon.append(polygon[0])
		draw_polyline(polygon, INK, 3.5, true)

func _draw() -> void:
	var i := posmod(palette_index, 8)
	var skin: Color = SKINS[i]
	var suit: Color = SUITS[i]
	var accent: Color = ACCENTS[i]
	var t := clampf(phase, 0.0, 1.0)
	var pulse := sin(t * PI)
	_flip = -1.0 if facing < 0.0 else 1.0
	_bob = sin(clock * 5.0 + float(i)) * 2.5
	_lean = 0.0
	_angle = 0.0
	_lift = 0.0
	_squash = clampf(landing, 0.0, 1.0) if not airborne else 0.0
	var front_elbow := Vector2(32, -103)
	var front_hand := Vector2(40, -133)
	var back_elbow := Vector2(-24, -96)
	var back_hand := Vector2(10, -119)
	var left_foot := Vector2(-30, -7)
	var right_foot := Vector2(32, -7)
	var left_knee := Vector2(-25, -31)
	var right_knee := Vector2(20, -35)
	var width := 25.0 if i == 4 else 19.0
	var head_y := -149.0
	if i == 5:
		head_y = -142.0
	if pose == "walk" and not airborne:
		var stride := sin(clock * 13.0)
		_bob = absf(cos(clock * 13.0)) * -4.0
		left_foot.x += stride * 15.0
		right_foot.x -= stride * 15.0
		left_foot.y -= maxf(0.0, stride) * 8.0
		right_foot.y -= maxf(0.0, -stride) * 8.0
		_lean = 6.0
	elif pose == "hug" or pose == "special":
		_lean = pulse * 18.0
		front_elbow = Vector2(31 + 18 * pulse, -97 - 8 * pulse)
		front_hand = Vector2(38 + 45 * pulse, -100 - 5 * pulse)
		back_elbow = Vector2(-34 + 42 * pulse, -113)
		back_hand = Vector2(-32 + 92 * pulse, -125)
		if pose == "special":
			match i:
				1:
					front_elbow.x += maxf(stretch, pulse * 85.0) * 0.45
					front_hand.x += maxf(stretch, pulse * 85.0)
					back_hand.x += maxf(stretch, pulse * 65.0)
				2:
					# A quick, smooth swivel shows him presenting his back.
					var turn := smoothstep(0.0, 0.16, t) * (1.0 - smoothstep(0.82, 1.0, t))
					_flip *= 1.0 - 2.0 * turn
					front_hand = Vector2(-70 * pulse, -100)
					back_hand = Vector2(-65 * pulse, -120)
				3:
					# This move launches actual jump physics. The airborne
					# choreography below owns its only rotation and height.
					pass
				4:
					front_elbow = Vector2(45, -115)
					front_hand = Vector2(75 * pulse + 20, -120)
					back_hand = Vector2(-55 + 110 * pulse, -125)
				5:
					_lean = 30 * pulse
					_bob += 18 * pulse
				6:
					back_hand = Vector2(-28 + sin(t * TAU) * 28, -167)
					front_hand = Vector2(55 * pulse, -110)
				7:
					_lean = sin(t * TAU) * 20
	elif pose == "deflect":
		_lean = -8.0 * pulse
		front_elbow = Vector2(29, -103)
		front_hand = Vector2(25 + 12 * pulse, -155)
		back_elbow = Vector2(2, -110)
		back_hand = Vector2(45, -128)
	elif pose == "feint":
		_lean = pulse * 11.0
		front_hand = Vector2(40 + 15 * pulse, -131 + 15 * pulse)
		back_hand = Vector2(10 + 15 * pulse, -119)
	elif pose == "recover":
		_lean = 16 * pulse
		front_elbow = Vector2(32, -87)
		front_hand = Vector2(40, -69 - t * 20)
		back_hand = Vector2(0, -80 - t * 30)
	elif pose == "embrace":
		var close := smoothstep(0.0, 0.2, t)
		var release := smoothstep(0.78, 1.0, t)
		_lean = 18.0 * (1.0 - release)
		_bob = sin(clock * 9.0) * 1.8
		front_elbow = Vector2(49, -105).lerp(Vector2(35, -84), close).lerp(Vector2(32, -103), release)
		front_hand = Vector2(83, -105).lerp(Vector2(76, -102), close).lerp(Vector2(40, -133), release)
		back_elbow = Vector2(8, -113).lerp(Vector2(35, -128), close).lerp(Vector2(-24, -96), release)
		back_hand = Vector2(60, -125).lerp(Vector2(68, -119), close).lerp(Vector2(10, -119), release)
	elif pose == "stunned":
		_lean = -12.0
		front_hand = Vector2(43, -75)
		back_hand = Vector2(-35, -80)
	# Every self-contained attempt starts and finishes in the common stance.
	# The action's own pulse shapes the reach; this envelope removes baseline
	# discontinuities in elbows and hands when the gameplay state changes.
	var envelope := 1.0
	if pose == "hug" or pose == "special":
		envelope = smoothstep(0.0, 0.2, t) * (1.0 - smoothstep(0.7, 1.0, t))
	elif pose == "deflect":
		envelope = smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.5, 1.0, t))
	elif pose == "feint" or pose == "recover":
		envelope = pulse
	front_elbow = Vector2(32, -103).lerp(front_elbow, envelope)
	front_hand = Vector2(40, -133).lerp(front_hand, envelope)
	back_elbow = Vector2(-24, -96).lerp(back_elbow, envelope)
	back_hand = Vector2(10, -119).lerp(back_hand, envelope)
	# Physics raises the whole puppet; only the leg articulation is cosmetic.
	# Height-based blending extends feet naturally for takeoff and touchdown.
	var tuck := smoothstep(0.0, 0.65, clampf(jump_progress, 0.0, 1.0)) if airborne else 0.0
	if airborne:
		var rising := clampf(-vertical_speed / 700.0, -1.0, 1.0)
		var flight := clampf(flight_progress, 0.0, 1.0)
		var flourish := sin(flight * PI)
		var relaxed_arms := pose == "idle" or pose == "walk"
		left_knee = left_knee.lerp(Vector2(-32, -52), tuck)
		right_knee = right_knee.lerp(Vector2(31, -58), tuck)
		left_foot = left_foot.lerp(Vector2(-22, -30 - rising * 3), tuck)
		right_foot = right_foot.lerp(Vector2(34, -40 + rising * 3), tuck)
		_bob = lerpf(_bob, 0.0, tuck)
		_lean += rising * 4.0 * tuck
		if relaxed_arms:
			front_elbow = front_elbow.lerp(Vector2(33, -110), tuck)
			front_hand = front_hand.lerp(Vector2(43, -144), tuck)
			back_elbow = back_elbow.lerp(Vector2(-26, -104), tuck)
			back_hand = back_hand.lerp(Vector2(2, -127), tuck)
		# Every fighter has a recognizable aerial silhouette. All poses
		# converge to their grounded stance at takeoff and touchdown.
		match i:
			0: # Champ: compact, practiced, and symmetrical.
				left_knee = left_knee.lerp(Vector2(-24, -57), tuck)
				right_knee = right_knee.lerp(Vector2(26, -57), tuck)
				left_foot = left_foot.lerp(Vector2(-22, -38), tuck)
				right_foot = right_foot.lerp(Vector2(25, -38), tuck)
			1: # Long Arms: knees too high and wrists comically dangling.
				_lean -= 8.0 * flourish
				left_knee = left_knee.lerp(Vector2(-33, -76), tuck)
				right_knee = right_knee.lerp(Vector2(37, -68), tuck)
				left_foot = left_foot.lerp(Vector2(-12, -45), tuck)
				right_foot = right_foot.lerp(Vector2(21, -34), tuck)
				if relaxed_arms:
					front_elbow = front_elbow.lerp(Vector2(45, -104), flourish)
					front_hand = front_hand.lerp(Vector2(55, -76), flourish)
					back_elbow = back_elbow.lerp(Vector2(-41, -107), flourish)
					back_hand = back_hand.lerp(Vector2(-51, -83), flourish)
			2: # Baxter: reclines in the air with his feet out ahead.
				_lean -= 24.0 * flourish
				_angle += 0.10 * flourish
				left_knee = left_knee.lerp(Vector2(0, -50), tuck)
				right_knee = right_knee.lerp(Vector2(33, -54), tuck)
				left_foot = left_foot.lerp(Vector2(16, -24), tuck)
				right_foot = right_foot.lerp(Vector2(53, -34), tuck)
			3: # Acrobat: one full somersault, finished before touchdown.
				_angle = -TAU * smoothstep(0.0, 0.94, flight)
				left_knee = left_knee.lerp(Vector2(-27, -83), tuck)
				right_knee = right_knee.lerp(Vector2(29, -83), tuck)
				left_foot = left_foot.lerp(Vector2(-13, -60), tuck)
				right_foot = right_foot.lerp(Vector2(15, -60), tuck)
			4: # Big Softy: a committed belly-first lurch, legs trailing.
				_lean += 22.0 * flourish
				_angle += 0.10 * flourish
				left_knee = left_knee.lerp(Vector2(-35, -37), tuck)
				right_knee = right_knee.lerp(Vector2(20, -43), tuck)
				left_foot = left_foot.lerp(Vector2(-47, -16), tuck)
				right_foot = right_foot.lerp(Vector2(20, -20), tuck)
			5: # Speedster: one forward knee and a trailing sprinter's leg.
				_lean += 19.0 * flourish
				left_knee = left_knee.lerp(Vector2(-34, -40), tuck)
				right_knee = right_knee.lerp(Vector2(39, -77), tuck)
				left_foot = left_foot.lerp(Vector2(-43, -22), tuck)
				right_foot = right_foot.lerp(Vector2(33, -54), tuck)
			6: # Showboat: an unnecessarily theatrical star jump.
				left_knee = left_knee.lerp(Vector2(-40, -49), tuck)
				right_knee = right_knee.lerp(Vector2(43, -48), tuck)
				left_foot = left_foot.lerp(Vector2(-63, -30), tuck)
				right_foot = right_foot.lerp(Vector2(66, -29), tuck)
				if relaxed_arms:
					front_elbow = front_elbow.lerp(Vector2(45, -138), flourish)
					front_hand = front_hand.lerp(Vector2(67, -169), flourish)
					back_elbow = back_elbow.lerp(Vector2(-43, -139), flourish)
					back_hand = back_hand.lerp(Vector2(-66, -169), flourish)
			7: # Boomerang: a twisting, scissoring hop that unwinds on landing.
				var twist := sin(flight * TAU) * flourish
				_flip *= 1.0 - 0.30 * flourish
				_lean += 16.0 * twist
				_angle += 0.16 * twist
				left_knee.x += 14.0 * twist
				right_knee.x -= 14.0 * twist
				left_foot.x += 20.0 * twist
				right_foot.x -= 20.0 * twist
	_bob *= 1.0 - _squash
	# A stable floor shadow grounds the puppet independently of animation.
	# Shadow points deliberately bypass _p and compensate for the raised node.
	var shadow := PackedVector2Array()
	var shadow_height := clampf((maxf(ground_offset, 0.0) + maxf(-_lift, 0.0)) / 250.0, 0.0, 1.0)
	var shadow_scale := lerpf(1.0, 0.56, shadow_height) * (1.0 + _squash * 0.12)
	for n in range(32):
		var a := TAU * float(n) / 32.0
		shadow.append(Vector2(cos(a) * (47.0 if i == 4 else 39.0) * shadow_scale, sin(a) * 7.0 * shadow_scale + 2 + ground_offset))
	draw_colored_polygon(shadow, Color(0.09, 0.13, 0.22, lerpf(0.22, 0.10, shadow_height)))
	# Back arm, legs, and shoes.
	_limb(Vector2(-width + 3, -113), back_elbow, back_hand, suit.darkened(0.12), 14)
	_oval(back_hand, Vector2(9, 10), INK)
	_oval(back_hand, Vector2(6.5, 7.5), skin.darkened(0.06))
	_limb(Vector2(-12, -65), left_knee, left_foot, suit.darkened(0.14), 18)
	_limb(Vector2(12, -65), right_knee, right_foot, suit, 19)
	_line(left_foot + Vector2(-8, 0), left_foot + Vector2(8, 0), INK, 12)
	_line(right_foot + Vector2(-6, 0), right_foot + Vector2(11, 0), INK, 12)
	_line(left_foot + Vector2(-5, -2), left_foot + Vector2(6, -2), accent, 5)
	_line(right_foot + Vector2(-3, -2), right_foot + Vector2(9, -2), accent, 5)
	# Broad shoulders and tapered waist keep stance readable at a distance.
	_shape([Vector2(-width, -122), Vector2(width, -122), Vector2(width + 4, -94), Vector2(17, -62), Vector2(-17, -62), Vector2(-width - 3, -95)], suit)
	_shape([Vector2(-12, -122), Vector2(0, -99), Vector2(13, -122), Vector2(8, -126), Vector2(0, -111), Vector2(-7, -126)], suit.lightened(0.22), false)
	_line(Vector2(-19, -72), Vector2(19, -72), INK, 11)
	_line(Vector2(-19, -74), Vector2(19, -74), accent, 7)
	_shape([Vector2(5, -74), Vector2(12, -74), Vector2(17, -48), Vector2(9, -50)], accent)
	_line(Vector2(0, -128), Vector2(0, -137), skin, 15)
	# Head, ears and intentionally stern eyebrows.
	_oval(Vector2(0, head_y), Vector2(25, 29), INK)
	_oval(Vector2(0, head_y - 1), Vector2(21.5, 25), skin)
	_oval(Vector2(-20, head_y + 3), Vector2(6, 8), skin)
	_oval(Vector2(20, head_y + 3), Vector2(6, 8), skin)
	# Individual silhouette details, drawn from the same palette convention.
	match i:
		0:
			_shape([Vector2(-21, head_y - 15), Vector2(-16, head_y - 29), Vector2(4, head_y - 33), Vector2(21, head_y - 20), Vector2(9, head_y - 21), Vector2(0, head_y - 15)], INK, false)
		1:
			_oval(Vector2(-3, head_y - 25), Vector2(25, 12), INK)
			_line(Vector2(-21, head_y - 17), Vector2(20, head_y - 17), accent, 6)
		2:
			_line(Vector2(-22, head_y - 20), Vector2(20, head_y - 20), accent, 8)
			_shape([Vector2(-20, head_y - 20), Vector2(-44, head_y - 12), Vector2(-34, head_y - 26)], accent)
			_line(Vector2(0, head_y + 11), Vector2(12, head_y + 10), INK, 5)
		3:
			_oval(Vector2(-23, head_y - 15), Vector2(13, 17), INK)
			_oval(Vector2(-23, head_y - 15), Vector2(9, 13), accent)
			_line(Vector2(-19, head_y - 20), Vector2(15, head_y - 22), INK, 9)
		4:
			_shape([Vector2(-20, head_y + 8), Vector2(-15, head_y + 24), Vector2(5, head_y + 28), Vector2(20, head_y + 14), Vector2(12, head_y + 8), Vector2(0, head_y + 17)], INK, false)
		5:
			_shape([Vector2(-23, head_y - 10), Vector2(-26, head_y - 34), Vector2(-9, head_y - 26), Vector2(-6, head_y - 40), Vector2(12, head_y - 26), Vector2(23, head_y - 19)], INK, false)
			_line(Vector2(-17, head_y - 12), Vector2(21, head_y - 12), accent, 6)
		6:
			_shape([Vector2(-23, head_y - 7), Vector2(-24, head_y - 27), Vector2(0, head_y - 36), Vector2(22, head_y - 24), Vector2(18, head_y - 14), Vector2(4, head_y - 21)], accent)
			_oval(Vector2(-19, head_y + 5), Vector2(4, 5), Color("fff3bd"))
		7:
			_oval(Vector2(-4, head_y - 24), Vector2(24, 10), suit.darkened(0.2))
			_line(Vector2(-20, head_y - 17), Vector2(30, head_y - 17), INK, 7)
	var closed := pose == "embrace" and t > 0.08 and t < 0.88
	if closed:
		_line(Vector2(-9, head_y - 2), Vector2(-3, head_y), INK, 2.5)
		_line(Vector2(8, head_y), Vector2(14, head_y - 2), INK, 2.5)
		_line(Vector2(0, head_y + 10), Vector2(7, head_y + 12), INK, 2)
	else:
		_oval(Vector2(-6, head_y - 2), Vector2(2.5, 3.5), INK)
		_oval(Vector2(11, head_y - 2), Vector2(2.5, 3.5), INK)
		_line(Vector2(-12, head_y - 11), Vector2(-2, head_y - 7), INK, 3)
		_line(Vector2(7, head_y - 7), Vector2(17, head_y - 11), INK, 3)
		_line(Vector2(2, head_y + 11), Vector2(10, head_y + 10), INK, 2)
	# Foreground arm is deliberately last, crossing the partner's torso at contact.
	_limb(Vector2(width - 2, -113), front_elbow, front_hand, suit, 16)
	_line(front_hand.lerp(front_elbow, 0.12), front_hand, accent, 17)
	_oval(front_hand, Vector2(11, 10), INK)
	_oval(front_hand, Vector2(8, 7), skin)
	_line(front_hand + Vector2(2, -3), front_hand + Vector2(5, -2), skin.lightened(0.25), 2)
