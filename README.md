# 013-street-hugger

A Godot 4.7 prototype of competitive hugging: serious fighting stances, careful spacing, dramatic fake-outs, and embraces instead of strikes.

Milestone 1 is a rough eight-character mechanically varied demo. It is intended to answer whether the controls, timing, and hug interactions are readable and enjoyable. It is not a finished or competitively balanced game.

## Run

Double-click `play.cmd` to launch using the Godot installation already on this computer.

Open Godot, choose **Import**, select `project.godot` in this folder, and press **F5** to run the project.

Alternatively, run this in PowerShell:

```powershell
& 'C:\Users\baxte\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --path 'C:\jbax-and-his-ai-pals\013-street-hugger'
```

Choose two characters and either a computer opponent or local two-player play. Practice provides a stationary partner and an unlimited timer for isolated experiments. Standard matches are first to five points, with a 60-second match timer.

## Controls

| Action | Player 1 | Player 2, local mode |
| --- | --- | --- |
| Move | A / D | Left / Right arrows |
| Hug | F | K |
| Deflect | G | L |
| Feint | H | Semicolon (`;`) |
| Signature hug | J | Apostrophe (`'`) |
| Pause / resume | Esc | Esc |

A successful embrace scores one point. A simultaneous mutual embrace scores neither player. Deflection has a short active window; early deflection and missed hugs leave openings. A feint has no scoring contact: use it to provoke a premature deflect. Signature hugs have a cooldown and different reach, timing, and movement.

## What to test now

Follow [the specific playtest sequence](docs/PLAYTEST.md), approximately 15 minutes. Please prioritize input response, range clarity, deflect timing, and animation contact over cosmetic polish or fine balance.

The eight prototype characters are Champ, Long Arms, Backwards Baxter, Acrobat, Big Softy, Speedster, Showboat, and Boomerang. Their approaches differ mechanically. They currently share upright contact choreography; Acrobat's inversion is in the approach rather than a completed upside-down embrace. See [character notes](docs/CHARACTERS.md).

## Current boundaries

- Keyboard play, local two-player matches, practice, and a basic computer opponent.
- Original procedural character and environment artwork; zero generated images and no third-party art assets.
- No gamepad support, online play, or audio in this milestone.
- No license has been added to this project.

The name is a working project name.

## Roadmap

1. **Milestone 1 — playable proof:** shared actions, eight rough signatures, scoring, practice, AI, menus, and coordinated contact.
2. **Readability and feel:** adjust movement, timing, recovery, contact alignment, and feedback using playtest results.
3. **Animation pipeline:** refine reusable rigs and add convincing ranged, backward, and inverted contact variants.
4. **Presentation:** finalize a visual direction, polish one character as the production example, add sound, then expand the cast and stage artwork in batches.
5. **Broader play:** gamepads, stronger tutorials and AI, accessibility, and matchup tuning. Evaluate online play separately once the local game is stable.

## Automated checks

From the project directory, run the gameplay regression script with the console executable:

```powershell
& 'C:\Users\baxte\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_game.gd
```

These checks cover gameplay rules; they cannot establish whether the animation or input response feels good to a player.

The initial suite passes **100 checks**, including all 64 ordered character contact pairings and eight seeded computer matches. Rendered menu, arena, attempt, embrace, pause, and result frames have also been inspected. These checks establish basic functionality, not competitive balance.
