extends RefCounted
# All story text, chapter layouts and MX dialogue live here. Edit freely.

const TITLE := "MX MORTEM"
const TAGLINE := "Where every night is playtime."

const INTRO := [
	"1994.\n\nMX Funworks promised the children of Dunmere a place where toys came alive.\n\nThen the lights went out, the doors were sealed, and the MX units were never switched off.",
	"You are Saldgs, night technician.\n\nYou don't care about the toys. You came for Allas, who is locked somewhere inside this building. Still alive.",
	"Your only tool is the Utility Pack:\nflashlight, magnetic hands, a laser cutter, and whatever batteries you can find.\n\nThe MX units are listening. Don't give them a reason to play.",
]

const NAMES := {
	"omega": "OMEGA 090", "snicker": "SNICKER", "kabob": "KABOB",
	"aagar": "AAGAR", "pup": "MX PUP",
}

const COLORS := {
	"omega": Color(0.8, 0.45, 1.0), "snicker": Color(0.9, 0.9, 1.0),
	"kabob": Color(1.0, 0.5, 0.15), "aagar": Color(0.4, 0.7, 1.0),
	"pup": Color(0.85, 0.65, 0.4),
}

const LINES := {
	"omega": {
		"spot": ["I see you, little technician.", "Don't run. It's rude.", "Playtime, Saldgs. My favorite."],
		"idle": ["Welcome to Funworks. Stay as long as you like.", "You can't hide from the host.", "Every night, a brand new game."],
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
}

const TAPES := {
	1: ["VHS 01 - Staff Orientation", "Welcome to MX Funworks, technician!\n\nRule one: the MX units are never switched off.\nRule two: if you hear breathing in the dark, hold yours."],
	2: ["VHS 02 - Maintenance Log", "We upgraded Aagar's microphones. He hears everything now.\nEverything.\n\nIf he's close, hide, and do not breathe."],
	3: ["VHS 03 - Omega's Broadcast", "Good evening, children! I am Omega 090, your host.\n\nTonight's game is hide and seek.\nI'll count to... never."],
	4: ["VHS 04 - Kabob's Kitchen", "Today's recipe: something that runs!\n\nRemember kids, a Kabob in a rage is a Kabob you can't outrun.\nKeep out of his sight and he cools down."],
	5: ["VHS 05 - Snicker's Lullaby", "He never speaks. He only laughs.\n\nIf you feel watched within thirty feet, you already are.\nThe walls don't matter to him."],
	6: ["VHS 06 - Allas, Intake Record", "Subject: Allas. Not a toy.\n\nOmega calls her the guest of honor.\nDo not let her leave."],
	7: ["VHS 07 - The Last Tape", "If you're watching this, Omega let you get this far.\n\nHe wants you to free her.\n\nThe question is why."],
}

const CHAPTERS := [
	{
		"name": "CHAPTER 1", "title": "Clock-In",
		"card": "Find the three VHS tapes to unseal the exit.\nHold E near a tape to pull it in with the Magnetic Hands.",
		"tip": "Tip: sprinting is loud. Aagar hears it.",
		"goal": "tapes", "day": 20.0, "allas": false, "chase": false,
		"tapes": [[1, Vector2i(15, 3)], [2, Vector2i(2, 12)], [3, Vector2i(2, 21)]],
		"batteries": [Vector2i(12, 12), Vector2i(37, 12), Vector2i(20, 21)],
		"enemies": [["aagar", Vector2i(20, 16)], ["pup", Vector2i(21, 3)], ["pup", Vector2i(26, 3)]],
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
		"tip": "Tip: lockers hide you. Aagar will hear you breathe, so hold SPACE.",
		"goal": "rescue", "day": 20.0, "allas": true, "chase": false,
		"key": Vector2i(37, 2),
		"tapes": [[4, Vector2i(12, 12)], [5, Vector2i(18, 21)]],
		"batteries": [Vector2i(15, 3), Vector2i(2, 12), Vector2i(2, 21), Vector2i(37, 21)],
		"enemies": [["aagar", Vector2i(20, 16)], ["snicker", Vector2i(15, 12)], ["kabob", Vector2i(35, 12)], ["pup", Vector2i(21, 3)], ["pup", Vector2i(26, 3)]],
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
		"card": "The host is awake.\nThe keycard is far away this time. Free Allas and RUN.\nOmega doesn't forget.",
		"tip": "Tip: the heartbeat betrays him, even when you can't see him.",
		"goal": "rescue", "day": 15.0, "allas": true, "chase": true,
		"key": Vector2i(19, 21),
		"tapes": [[6, Vector2i(15, 3)], [7, Vector2i(2, 12)]],
		"batteries": [Vector2i(12, 2), Vector2i(2, 12), Vector2i(37, 12), Vector2i(36, 19), Vector2i(6, 21)],
		"enemies": [["omega", Vector2i(24, 2)], ["pup", Vector2i(21, 3)], ["pup", Vector2i(26, 3)], ["pup", Vector2i(23, 1)], ["snicker", Vector2i(15, 12)], ["kabob", Vector2i(35, 12)], ["aagar", Vector2i(20, 16)]],
		"events": [
			{"t": 6.0, "type": "whisper", "who": "omega", "say": "I've been waiting for you, Saldgs."},
			{"t": 18.0, "type": "blackout", "dur": 8.0, "who": "omega", "say": "Shhh. The lights are shy."},
			{"t": 35.0, "type": "peek", "kind": "omega"},
			{"t": 55.0, "type": "slam"},
			{"t": 80.0, "type": "blackout", "dur": 6.0, "who": "pup", "say": "Found you found you found you"},
		],
		"outro": "The front doors burst open. Cold air. Moonlight.\n\nYou and Allas stumble out into the night.\n\nBehind you, the Funworks sign flickers once... and goes dark.\n\nBut somewhere inside, a voice is still laughing.",
	},
]
