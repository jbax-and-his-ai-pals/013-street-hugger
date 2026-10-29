# Prototype checkpoint: jumping and aerial hugs

Project name: `013-street-hugger`. No project license added. All character and stage art is drawn procedurally in Godot; no image-generation requests used.

## Existing playable baseline

- Eight selectable original prototype appearances and signature approaches.
- Hug, timed deflect, feint, recovery, movement, and a signature cooldown.
- Showboat early signature-to-feint cancel.
- First-to-five matches, 60-second match clock, mutual embraces, coordinated contact/reset.
- Local two-player keyboard controls, seeded-testable basic AI, stationary-partner practice.
- Character selection, pause/resume, return to menu, results, rematch.
- A procedural neighborhood stage with animated clouds, bunting, and spectators.
- One-click local launcher and gameplay regression checks.

## Jump milestone scope

- P1 jumps with W or Space; P2 jumps with Up in local play. Practice continues to disable all P2 controls.
- Jump launches from grounded idle/walk. A/D or Left/Right steer in the air. No double jump.
- Character-specific jumps ranging from 135–215 pixels and 0.70–1.00 seconds, with distinct launch momentum, air control, poses, a 120-millisecond pre-landing jump buffer, and a short landing cue.
- Crossing above a partner when height separation exceeds 85 pixels, while grounded walking retains personal space.
- Hug, Deflect, and Feint available in the air. Signatures begin grounded; Acrobat's signature launches its own physical vault.
- Height-aware hug contact: separation must be at most 85 pixels. Matching-height aerial and low rising/falling contact can work; apex-over-ground attempts miss.
- A successful aerial embrace aligns both fighters to a shared height and settles to the floor smoothly.

## Validation status

The first feedback pass found Practice still accepting P2 input and ordinary walking pushing the partner. Both were corrected in the baseline. Input consistently uses physical key positions, releases clear held movement, and losing window focus clears held keys. Above-character P1/P2/CPU/PARTNER labels identify control ownership even after side changes.

The **pre-jump baseline** passed 126/126 regression checks, including scoring compatibility for all 64 ordered character combinations, eight seeded AI matches, and keyboard routing in Practice/local modes. Rendered menu, arena, attempt, contact, pause, and result captures were inspected. Native keyboard signature input, Practice entry, and pause were exercised in the running game.

The jump build passes **167/167 regression checks**. Added checks cover jump input ownership, no double jump, pre-landing buffering and expiry, air steering and crossing, height-aware misses, descending and air-to-air hugs, aerial deflection/mutual contact, smooth joint descent, pause/reset, all eight authored apexes/landings, and Acrobat's real physical vault. All eight jump personalities plus the updated menu and aerial embrace were inspected in rendered captures. Ownership markers now sit below the ground shadow to avoid overlap with the HUD during high jumps. These checks establish basic functionality, not artistic quality or balanced matchups.

## Next user gate — jump build, about five minutes

Use the focused jump sequence in [PLAYTEST.md](PLAYTEST.md#next-gate-jumping--about-5-minutes):

1. Practice neutral/moving jumps — 30 seconds.
2. Jump over the stationary partner and inspect facing — 30 seconds.
3. Try F near the apex versus while descending; inspect aerial embrace/landing — 1 minute.
4. Local matching-height aerial hugs and deflects — 1 minute.
5. One computer match with jumps — 1 minute.

Allow the remaining time for mode changes and a short report. Send the most confusing moment, expected versus actual behavior, character/matchup, key, and rising/apex/falling phase. We need control response, height/range readability, and landing/contact feedback first.

## Following interaction gate

The longer PLAYTEST.md sequence covers local bluffing/counterhugs, all eight signatures, and match flow after jump/readability fixes.

## Art gate — after the interaction rules stabilize

Choose the visual direction and polish one character/contact sequence as the production example. Decide whether image generation would materially improve that example before spending any requests on the rest of the roster.

## Known prototype limits

All characters currently use shared upright embrace contact. Inverted, ranged, and reverse approaches have distinct motion but need bespoke finishing choreography. Whole-puppet drawing cannot perfectly interleave both characters' arms; production work should split front/back arm layers. High-refresh presentation and broader action buffering beyond the short jump buffer remain further feel improvements. No sound, gamepads, online play, difficulty selector, or final balance yet.
