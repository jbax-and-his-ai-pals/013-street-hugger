# Project instructions

## User-facing writing

The user explicitly dislikes generic slogan filler in LLM-authored products. Treat this as an editing principle, not a blacklist of words or punctuation.

- Leave idle HUD/status space empty. Show temporary feedback for actual events, outcomes, or failures.
- UI labels should identify an action or state. Instructions should explain an executable action, relevant rule, or observed cause.
- Do not add motivational taglines, symmetrical verb triplets, theme puns in routine menus, or generic descriptions of the intended experience just to fill space.
- Prefer Play, Paused, Rematch, and a specific miss reason over themed substitutes or generalized encouragement.
- Preserve original shop names, character identities, distinctive animation, and other concrete worldbuilding. The user likes the shop names. This is not a request for a humorless game.
- Character descriptions should distinguish implemented behavior. Do not imply abilities that the current code does not support.
- Before adding copy, ask: what does the player learn or do because this text exists? If nothing, omit it. Flavor needs a specific place, character, or event that earns it.
- Review copy by itself after implementation. Deletion is a valid outcome; do not automatically replace removed filler with different filler.

See docs/UI_COPY.md for examples and the review procedure.

## Existing constraints

- Godot project name: 013-street-hugger.
- Do not add a project license.
- Keep code, characters, and art original; do not copy recognizable franchise designs or assets.
- Keep image-generation use deliberate and limited; the prototype uses procedural art.
- Give the user specific playtests when gameplay changes need their feedback.
