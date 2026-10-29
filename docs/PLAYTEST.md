# Milestone 1 playtest

**When:** after the first playable build opens and reaches the character-selection screen. Repeat the affected section after a timing, collision, input, or animation change. Save broad character balance feedback for a later pass.

**Goal:** establish whether you can predict what your input will do, see why a hug lands or misses, and understand the opening created by a deflect or feint.

Allow approximately **15 minutes** for this first pass. A second person helps with the local deflect test, but one person can operate both keyboard layouts.

## 1. Movement and input response — 2 minutes

Select **Champ** against **Champ** in Practice. Practice uses a stationary partner and an unlimited timer.

- Walk left and right, tap to make small adjustments, and release the keys. Does motion begin and end when expected?
- Approach the partner and walk away. Ordinary walking should stop at personal space rather than pass through them. Does facing remain sensible? Later, check side changes during a signature that travels past the partner.
- Move to both arena edges. Does either character disappear, jitter, or get stuck?
- In Practice, arrow keys and K/L/semicolon/apostrophe should do nothing. A/D and F/G/H/J control only the fighter marked P1. The partner should not be pushed by ordinary walking (they still participate in a successful embrace).
- Tap Hug, Deflect, and Feint separately while idle. Does each begin immediately? Actions intentionally commit for a short time; report unexpected delay while idle separately from being unable to interrupt a move.
- Press Esc, try movement while paused, then resume. Movement and scoring should stay paused.

**Report:** sticky movement, ignored idle inputs, facing flips, jitter, or keys that trigger an unintended action. If simultaneous keys fail, list the exact combination so we can distinguish keyboard rollover from a game issue.

## 2. Hug range and misses — 1 minute

Stay in Practice with Champ.

- Try a hug far away: it should miss and award no point.
- Move closer in small steps and repeat until it lands.
- Observe a completed hug: can you see whose arms are where, when the point is earned, and when control returns after the reset?

**Report:** the closest miss that looked like a hit, the farthest hit that looked like a miss, arm/body intersections, sliding feet, or an unclear reset. Approximate distance is fine; a screenshot is useful if convenient.

## 3. Deflection and bluffing — 2 minutes

Return to the menu and start a local Champ-versus-Champ match. Player 1 uses **A/D, F/G/H/J**; Player 2 uses **arrows, K/L/;/apostrophe**.

- Get within hugging range. P1 presses **F** while P2 experiments with **L** shortly before contact. A well-timed deflect should prevent the point and announce the opening.
- Have P2 deflect much too early, then P1 hug after the guard drops. P1 should have an opportunity to score.
- P1 presses **H** to feint; P2 deliberately reacts with **L**. P1 then presses **F** after the feint completes. Compare this with a real hug attempt.
- Finally, press both hug buttons together. A genuinely simultaneous successful hug should produce a mutual embrace without awarding either player a point.

**Report:** whether the guard window can be understood from the pose, whether a successful deflect leaves enough time to act, and whether the feint visually resembles a credible threat. A feint alone is not expected to force a mechanical win.

## 4. Eight signature hugs — about 1 minute per character

Use Practice, keep the same stationary partner, and change P1 between all eight characters. Press **J** at close, medium, and long distances. Wait for the signature cooldown between attempts. Try one ordinary hug with **F** for comparison.

| Character | Specifically inspect |
| --- | --- |
| Champ | Is the advancing step and its extra reach obvious? |
| Long Arms | Do the extended arms explain the longer reach? Does a miss look committed? |
| Backwards Baxter | Does the backward presentation make the intended target and travel direction clear? |
| Acrobat | Is the inverted approach readable, and does the delayed contact match your expectation? Contact currently returns to the shared upright embrace. |
| Big Softy | Is the slow wind-up distinguishable from a move that failed to start? Is the broad reach understandable? |
| Speedster | Can you predict where the fast entry finishes? Does short reach still require deliberate spacing? |
| Showboat | Can you identify the flourish and eventual contact moment? Press H early during the J flourish to cancel into a feint; the signature cooldown should still apply. |
| Boomerang | Is the outbound-and-return route obvious? Does the contact moment read as the return rather than a random hit? |

**Report:** anything impossible to land, nearly impossible to read, or visually disconnected from the target. Do not rank the roster yet; this pass tests whether each move communicates its behavior.

## 5. Computer match and match flow — 2 minutes

Return to the menu, enable the computer opponent, and select any familiar character.

- Play a match, then choose Rematch.
- Check that points, timer, names, and result text make sense.
- Try returning to character selection and starting a different matchup.
- Notice whether the computer gives you opportunities to approach, bait, and recover. It is intentionally an early opponent, not a final difficulty benchmark.

**Report:** an unresponsive opponent, unavoidable loops, broken rematches, stale scores, a confusing result, or menus that obstruct play.

## Feedback format

Send one entry per distinct issue:

```text
Mode: Practice / Local / Computer
Matchup: my character vs opponent
Action and setup: keys pressed, approximate distance, who was moving
Expected: what I thought would happen
Actual: what happened instead
Type: controls / timing / visual readability / match flow
Repeatable: every time / sometimes / once
```

Three short observations also help: **most satisfying moment**, **most confusing moment**, and **first thing you wanted to try again**.

Polished art, audio, gamepads, online play, final matchup balance, and unique contact choreography for every signature are outside this first test. The current artwork is procedural, with zero image-generation requests and no third-party art assets.
