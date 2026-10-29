# Milestone 1 checkpoint

Project name: `013-street-hugger`. No project license added. All character and stage art is drawn procedurally in Godot; no image-generation requests used.

## Ready now

- Eight selectable original prototype appearances and signature approaches.
- Hug, timed deflect, feint, recovery, movement, and a signature cooldown.
- Showboat early signature-to-feint cancel.
- First-to-five matches, 60-second match clock, mutual embraces, coordinated contact/reset.
- Local two-player keyboard controls, seeded-testable basic AI, stationary-partner practice.
- Character selection, pause/resume, return to menu, results, rematch.
- A procedural neighborhood stage with animated clouds, bunting, and spectators.
- One-click local launcher and gameplay regression checks.

## Validation

Godot 4.7.2 console script checks and gameplay suite: 100/100 passing. Pairing checks cover scoring compatibility for all 64 ordered character combinations, not artistic quality or balanced matchups. Eight seeded AI matches complete and each CPU character can score. Rendered menu, arena, attempt, contact, pause, and result captures were checked. Native keyboard signature input, practice entry, and pause were exercised in the running game.

## First user gate — now, about five minutes

The first feedback pass found practice mode still accepting P2 input and ordinary walking pushing the partner. Both are fixed. Input now consistently uses physical key positions, releases clear held movement, and losing window focus clears held keys. Above-character P1/P2/CPU/PARTNER labels identify control ownership even after side changes. The expanded regression suite passes 126/126 checks.

1. Practice with Champ: walk, stop, and hug at several distances. Identify any delay from idle or disagreement between visible arms and scoring range.
2. Practice with Long Arms and Acrobat: try J near and far. Identify any contact you cannot explain visually. The Acrobat currently completes an upright shared embrace after an inverted approach.
3. Play one computer match, use pause, and rematch. Report anything that interrupts or confuses the loop.

Send the most confusing moment and what you expected instead. A character name, key, and approximate distance usually suffice.

## Second user gate — after the first feel/readability adjustments

Follow the full sequence in PLAYTEST.md, including local deflect/counterhug experiments and all eight signatures. This checks timing, readable strengths/weaknesses, and whether bluffing gives you useful decisions.

## Art gate — after the interaction rules stabilize

Choose the visual direction and polish one character/contact sequence as the production example. Decide whether image generation would materially improve that example before spending any requests on the rest of the roster.

## Known prototype limits

All characters currently use shared upright embrace contact. Inverted, ranged, and reverse approaches have distinct motion but need bespoke finishing choreography. Whole-puppet drawing cannot perfectly interleave both characters' arms; production work should split front/back arm layers. Movement and poses run on fixed game ticks; high-refresh interpolation and deeper input buffering remain candidates after player feedback. No sound, gamepads, online play, difficulty selector, or final balance yet.
