MX MORTEM - Story Mode (Godot 4.3+, GL Compatibility renderer)

RUN: Godot -> Import -> project.godot -> F5.
EXPORT: Project > Export > Web (preset included, single-threaded so it works on any host).

CONTROLS
Keyboard/mouse: WASD move | Shift sprint | Mouse aim | F flashlight | E hands |
  Click laser | TAB or C cameras | Space hold breath | ENTER story | R retry
Touch: left = move stick; right = HANDS / LASER / RUN / LIGHT / CAMS buttons.

All story, tapes, MX dialogue, chapters and scare events: story.gd

NEW: Hush (freezes in your flashlight light) and Tick (hunts your flashlight).
Chapter 3 uses a fuse box puzzle instead of a keycard. Debug keys: set DEBUG in main.gd.

v3: bigger facility with doors (walk into them to open, E to close), X (illusions),
cutscenes, and a multi-stage Omega chase in chapter 3 with levers, gates and side ambushes.
