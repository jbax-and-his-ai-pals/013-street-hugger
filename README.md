# 013-street-hugger

A Godot 4.7 prototype of competitive hugging: serious fighting stances, careful spacing, dramatic fake-outs, and embraces instead of strikes.

Milestone 1 is a rough eight-character mechanically varied demo. The next milestone adds jumping, aerial hugs, and passing over opponents. It is intended to answer whether the controls, timing, and hug interactions are readable and enjoyable. It is not a finished or competitively balanced game.

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
| Jump | W or Space | Up arrow |
| Hug | F | K |
| Deflect | G | L |
| Feint | H | Semicolon (`;`) |
| Signature hug | J | Apostrophe (`'`) |
| Pause / resume | Esc | Esc |

A successful embrace scores one point. A simultaneous mutual embrace scores neither player. Deflection has a short active window; early deflection and missed hugs leave openings. A feint has no scoring contact: use it to provoke a premature deflect. Signature hugs have a cooldown and different reach, timing, and movement.

Practice accepts only Player 1 controls. Player 2 keys, including Up, are disabled and ordinary walking cannot push the stationary partner. You can jump over that partner. In local matches both keyboard layouts are enabled. Letter bindings refer to physical QWERTY key positions; movement and actions use the same physical-key handling.

Jump from a grounded idle or walk, then use the movement keys to steer in the air. There is no double jump. A jump rises roughly 170 pixels and lasts about 0.8 seconds; a press within 120 milliseconds before landing can buffer the next jump. Hug, Deflect, and Feint also work in the air. Signature moves must start grounded; Acrobat's signature launches its own physical vault.

Characters can pass over each other when their heights differ by more than 85 pixels. A hug needs a height difference of at most 85 pixels as well as horizontal reach: matching-height aerial hugs and low rising/falling hugs can connect, while a hug near the apex over a grounded partner should miss. Successful aerial embraces align at a shared height and settle smoothly to the floor.

## What to test now

Start with [the focused jump playtest](docs/PLAYTEST.md#next-gate-jumping--about-5-minutes), about five minutes including mode changes and feedback. The same document retains the approximately 15-minute full baseline sequence. Please prioritize input response, height/range clarity, deflect timing, and animation contact over cosmetic polish or fine balance.

The eight prototype characters are Champ, Long Arms, Backwards Baxter, Acrobat, Big Softy, Speedster, Showboat, and Boomerang. Their approaches differ mechanically. They currently share upright contact choreography; Acrobat's inversion is in the approach rather than a completed upside-down embrace. See [character notes](docs/CHARACTERS.md).

## Current boundaries

- Keyboard play, local two-player matches, practice, and a basic computer opponent.
- Original procedural character and environment artwork; zero generated images and no third-party art assets.
- No gamepad support, online play, or audio in this milestone.
- No license has been added to this project.

The name is a working project name.

## Roadmap

1. **Milestone 1 — playable proof:** shared actions, eight rough signatures, scoring, practice, AI, menus, and coordinated contact.
2. **Jumping and aerial interaction:** steerable jumps, crossing above opponents, height-aware hugs/deflects, and smooth aerial contact/landing. Validate with the focused five-minute playtest.
3. **Readability and feel:** adjust movement, timing, recovery, contact alignment, and feedback using playtest results.
4. **Animation pipeline:** refine reusable rigs and add convincing ranged, backward, and inverted contact variants.
5. **Presentation:** finalize a visual direction, polish one character as the production example, add sound, then expand the cast and stage artwork in batches.
6. **Broader play:** gamepads, stronger tutorials and AI, accessibility, and matchup tuning. Evaluate online play separately once the local game is stable.

## Automated checks

From the project directory, run the gameplay regression script with the console executable:

```powershell
& 'C:\Users\baxte\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_game.gd
```

These checks cover gameplay rules; they cannot establish whether the animation or input response feels good to a player.

The current suite passes **167 checks**, including all 64 ordered character contact pairings, eight seeded computer matches, input ownership, jump profiles/buffering/landing, and aerial hugging/deflection. All eight jump silhouettes and an aerial embrace have been inspected in rendered captures. More detail is in [the progress notes](docs/PROGRESS.md). These checks establish basic functionality, not competitive balance.
