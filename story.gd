extends RefCounted
# All story text, chapter layouts and MX dialogue live here. Edit freely.

const TITLE := "MX MORTEM"
const TAGLINE := "The facility never sleeps."

const INTRO := [
	"MX Industries never shut down.\n\nThe lights are on, the doors still lock at night, and the MX units keep running their routines, whether or not anyone is there to see them.",
	"You are Saldgs, night technician.\n\nYou took this job for one reason: Allas, held somewhere inside this building, locked in a cell, and still alive.",
	"Your only tool is the Utility Pack:\nflashlight, magnetic hands, a laser cutter, and whatever batteries you can find.\n\nThe MX units are listening. Don't give them a reason to play.",
]

const NAMES := {
	"omega": "OMEGA 090", "snicker": "SNICKER", "kabob": "KABOB",
	"aagar": "AAGAR", "pup": "MX PUP", "hush": "HUSH", "tick": "TICK", "x": "X",
}

const COLORS := {
	"omega": Color(0.8, 0.45, 1.0), "snicker": Color(0.9, 0.9, 1.0),
	"kabob": Color(1.0, 0.5, 0.15), "aagar": Color(0.4, 0.7, 1.0),
	"pup": Color(0.85, 0.65, 0.4), "hush": Color(0.8, 0.88, 0.95), "tick": Color(1.0, 0.85, 0.2), "x": Color(0.3, 0.95, 0.95),
}

const LINES := {
	"omega": {
		"spot": ["I see you, little technician.", "Don't run. It's rude.", "Playtime, Saldgs. My favorite."],
		"idle": ["Welcome to the facility. Stay as long as you like.", "You can't hide from the host.", "Every night, a brand new game."],
	},
	"snicker": {
		"spot": ["hehehehehe...!"],
		"idle": ["heh...", "...hehe."],
	},
	"kabob": {
		"spot": ["YOU'RE ON THE MENU!", "STAND STILL, I'M NOT DONE COOKING!", "GET OVER HERE, TECH!"],
		"idle": ["I SMELL FRESH MEAT!", "WHO TOUCHED MY GRILL?!"],
	},
	"aagar": {
		"spot": ["Found you... *wheeze*"],
		"idle": ["I can hear you breathing...", "*wheeze*... shhh... listen..."],
	},
	"pup": {
		"spot": ["Tag! You're it!", "Play with us!"],
		"idle": ["pup pup pup~", "Hide and seek!"],
	},
	"hush": {
		"spot": ["You looked away.", "There you are."],
		"idle": ["...don't look away.", "shhh."],
	},
	"tick": {
		"spot": ["TICK TICK TICK!"],
		"idle": ["tick... tick...", "Your light is so warm."],
	},
	"x": {
		"spot": ["Look at me. No, really look.", "He lies. I lie better."],
		"idle": ["Omega thinks he owns this place.", "Which of us is real? Guess.", "I never liked his voice."],
	},
}

const TAPES := {
	1: ["VHS 01 - Staff Orientation", "Welcome to the MX facility, technician!\n\nRule one: the MX units are never switched off.\nRule two: if you hear breathing in the dark, hold yours."],
	2: ["VHS 02 - Maintenance Log", "We upgraded Aagar's microphones. He hears everything now.\nEverything.\n\nIf he's close, hide, and do not breathe.\n\nTick loves a warm light. If you hear ticking, turn your flashlight off."],
	3: ["VHS 03 - Omega's Broadcast", "Good evening, everyone. I am Omega 090, your host.\n\nTonight's game is hide and seek.\nI'll count to... never."],
	4: ["VHS 04 - Kabob's Kitchen", "Today's recipe: something that runs!\n\nRemember kids, a Kabob in a rage is a Kabob you can't outrun.\nKeep out of his sight and he cools down."],
	5: ["VHS 05 - Snicker's Lullaby", "He never speaks. He only laughs.\n\nIf you feel watched within thirty feet, you already are.\nThe walls don't matter to him.\n\nHush only moves when nothing is lighting him. Keep your flashlight on him."],
	6: ["VHS 06 - Allas, Intake Record", "Subject: Allas. Not an MX unit.\n\nOmega calls her the guest of honor.\nDo not let her leave."],
	8: ["VHS 08 - Unit X, Test Log", "Unit X was built to rehearse routes before the others walked them.\n\nIt got very good at rehearsing people.\nOmega had it shelved.\n\nX has not forgiven him."],
	9: ["VHS 09 - Omega's Plan", "The cell lock needs power. Omega can't reach the fuse box.\n\nHe needs a technician who will do it for him.\n\nYou are the technician."],
	7: ["VHS 07 - The Last Tape", "If you're watching this, Omega let you get this far.\n\nHe wants you to free her.\n\nThe question is why."],
}

const CUTSCENES := {
	"intro": [
		{"d": 4.5, "scene": "facility", "text": "MX Industries. Open every hour of every day."},
		{"d": 4.5, "scene": "corridor", "text": "Day shift runs the line. Night shift keeps it quiet."},
		{"d": 4.5, "scene": "eyes", "text": "Nobody mentions what the MX units do when the shift changes."},
	],
	"x_intro": [
		{"d": 4.0, "scene": "intercom", "text": "OMEGA: Welcome back, Saldgs. I do hope you slept."},
		{"d": 4.0, "scene": "x", "text": "X: Don't listen to him. He lies about everything."},
		{"d": 4.5, "scene": "intercom", "text": "OMEGA: Unit X. You were told to stay in storage."},
		{"d": 5.0, "scene": "x", "text": "X: And you were told to share. Run along, technician. I'll make this interesting."},
	],
	"omega_arrives": [
		{"d": 3.5, "scene": "door", "text": "The cell lock clicks open. Allas breathes in."},
		{"d": 3.5, "scene": "corridor", "text": "Every light in the hall dies at once."},
		{"d": 4.5, "scene": "omega", "text": "OMEGA: Thank you, Saldgs. I couldn't open that door myself."},
		{"d": 3.0, "scene": "eyes", "text": "RUN."},
	],
	"shutter": [
		{"d": 3.0, "scene": "shutter", "text": "The shutter slams down."},
		{"d": 4.0, "scene": "omega", "text": "OMEGA: ...clever. Do come back, Saldgs."},
	],
	"ending": [
		{"d": 4.5, "scene": "door", "text": "You and Allas step out into the morning."},
		{"d": 4.5, "scene": "facility", "text": "Behind you, the facility opens for another day."},
		{"d": 4.5, "scene": "x", "text": "X: Not bad. I'll see you on the next shift."},
	],
}

const CHAPTERS := [
	{
		"name": "CHAPTER 1", "title": "Clock-In",
		"card": "Find the three VHS tapes to unseal the exit.\nHold E near a tape to pull it in with the Magnetic Hands.\nDoors open when you walk into them. Press E next to one to close it.",
		"tip": "Tip: sprinting is loud, and Tick is drawn to your flashlight.",
		"goal": "tapes", "day": 20.0, "allas": false, "chase": false,
		"seal": [[37, 0, 27, 40]],
		"exit": Vector2i(22, 33),
		"tapes": [[1, Vector2i(15, 3)], [2, Vector2i(4, 17)], [3, Vector2i(5, 35)]],
		"batteries": [Vector2i(18, 17), Vector2i(30, 4), Vector2i(22, 31), Vector2i(6, 24)],
		"enemies": [["aagar", Vector2i(20, 24)], ["pup", Vector2i(28, 3)], ["pup", Vector2i(31, 5)], ["tick", Vector2i(28, 9)]],
		"events": [
			{"t": 10.0, "type": "whisper", "who": "omega", "say": "Welcome, little technician. Do try to enjoy yourself."},
			{"t": 25.0, "type": "blackout", "dur": 6.0, "who": "pup", "say": "Lights out! Lights out!"},
			{"t": 45.0, "type": "peek", "kind": "pup"},
			{"t": 70.0, "type": "slam"},
			{"t": 95.0, "type": "peek", "kind": "omega"},
		],
		"outro": "The exit door hisses open.\n\nBehind you, the intercom crackles:\n\n\"First night done, Saldgs. Come back tomorrow. We'll be waiting.\"",
	},
	{
		"name": "CHAPTER 2", "title": "Playtime",
		"card": "A keycard unlocks the red cell door. Allas is inside.\nFree her (hold E), then get her out.\nTapes are optional, but they explain things.",
		"tip": "Tip: Hush only moves when no light is on him. X's illusions pop when your flashlight touches them.",
		"goal": "rescue", "day": 20.0, "allas": true, "chase": false,
		"cut_start": "x_intro",
		"seal": [[53, 0, 11, 40]],
		"exit": Vector2i(31, 35),
		"key": Vector2i(44, 3),
		"tapes": [[4, Vector2i(41, 17)], [5, Vector2i(33, 32)], [8, Vector2i(6, 35)]],
		"batteries": [Vector2i(15, 3), Vector2i(2, 17), Vector2i(44, 24), Vector2i(20, 34), Vector2i(37, 34)],
		"enemies": [["aagar", Vector2i(20, 24)], ["snicker", Vector2i(18, 17)], ["kabob", Vector2i(44, 17)], ["pup", Vector2i(28, 3)], ["pup", Vector2i(31, 5)], ["hush", Vector2i(16, 3)], ["x", Vector2i(43, 4)]],
		"events": [
			{"t": 8.0, "type": "whisper", "who": "kabob", "say": "WHO'S IN MY KITCHEN?!"},
			{"t": 20.0, "type": "blackout", "dur": 7.0, "who": "snicker", "say": "...hehehe."},
			{"t": 38.0, "type": "peek", "kind": "snicker"},
			{"t": 60.0, "type": "slam"},
			{"t": 80.0, "type": "peek", "kind": "pup"},
		],
		"outro": "Allas leans on you, shaking, but alive.\n\nThe intercom hums:\n\n\"You found her. How brave. Now the real game begins.\"",
	},
	{
		"name": "CHAPTER 3", "title": "Omega's Night",
		"card": "The host is awake.\nFind two fuses and power the lock on Allas's cell.\nThen free her and RUN. Omega doesn't forget.",
		"tip": "Tip: the fuse box is in the upper hallway. Your heartbeat betrays Omega.",
		"goal": "rescue", "day": 15.0, "allas": true, "chase": true,
		"seal": [],
		"exit": Vector2i(58, 35),
		"fuses": [Vector2i(60, 3), Vector2i(3, 35)],
		"fusebox": Vector2i(28, 9),
		"tapes": [[6, Vector2i(15, 3)], [7, Vector2i(4, 17)], [9, Vector2i(45, 34)]],
		"batteries": [Vector2i(8, 5), Vector2i(18, 17), Vector2i(44, 17), Vector2i(60, 17), Vector2i(20, 34), Vector2i(36, 34), Vector2i(5, 24)],
		"enemies": [["omega", Vector2i(30, 3)], ["pup", Vector2i(26, 3)], ["pup", Vector2i(32, 5)], ["pup", Vector2i(29, 5)], ["snicker", Vector2i(18, 17)], ["kabob", Vector2i(44, 17)], ["aagar", Vector2i(36, 24)], ["hush", Vector2i(58, 3)], ["tick", Vector2i(8, 34)], ["x", Vector2i(46, 33)]],
		"chase_cfg": {
			"omega_start": Vector2i(16, 9),
			"levers": [
				{"tile": Vector2i(52, 12), "gates": [Vector2i(51, 16), Vector2i(52, 16)], "hold": 0.7},
			],
			"final": {"tile": Vector2i(55, 30), "gates": [Vector2i(53, 31), Vector2i(53, 32)], "hold": 0.7},
			"ambush": [
				{"trig": Vector2i(52, 22), "r": 45.0, "doors": [Vector2i(50, 17), Vector2i(50, 18), Vector2i(53, 17), Vector2i(53, 18)],
					"spawns": [["kabob", Vector2i(50, 17)], ["pup", Vector2i(53, 17)], ["pup", Vector2i(53, 18)]]},
				{"trig": Vector2i(54, 31), "r": 45.0, "doors": [],
					"spawns": [["snicker", Vector2i(46, 31)], ["pup", Vector2i(45, 32)], ["pup", Vector2i(45, 31)], ["x", Vector2i(44, 31)]]},
			],
		},
		"events": [
			{"t": 6.0, "type": "whisper", "who": "omega", "say": "I've been waiting for you, Saldgs."},
			{"t": 18.0, "type": "blackout", "dur": 8.0, "who": "omega", "say": "Shhh. The lights are shy."},
			{"t": 35.0, "type": "peek", "kind": "omega"},
			{"t": 55.0, "type": "slam"},
			{"t": 80.0, "type": "blackout", "dur": 6.0, "who": "pup", "say": "Found you found you found you"},
		],
		"outro": "The front doors burst open. Cold air. Morning light.\n\nYou and Allas stumble out into the day.\n\nBehind you, every light in the facility goes dark at once.\n\nBut somewhere inside, a voice is still laughing.",
	},
]
