# Street Hugger: first roster

The first visuals use original procedural cutout puppets, with no image-generation requests. All eight share joint conventions and floor contact. Their colors, hair, accessories, and body widths distinguish them. Every fighter maintains an intense martial arts stance until the successful embrace softens their expression.

| Index | Character | Signature concept | Animation identity |
|---|---|---|---|
| 0 | Champ | Balanced advancing hug | Cream gi, red belt, disciplined stance |
| 1 | Long Arms | Stationary ranged hug with recovery | Teal outfit, gold headband, extending forearms |
| 2 | Backwards Baxter | Reverse embrace to catch pursuit | Purple gi, turquoise scarf, mustache, reverse reach |
| 3 | Acrobat | Delayed inverted hug on a fixed route | Gold outfit, rose details, bun, full handspring |
| 4 | Big Softy | Broad, slow bear hug | Coral outfit, gold belt, broad torso, beard |
| 5 | Speedster | Fast entry with limited grabbing range | Blue outfit, yellow details, spiked hair, low sliding pose |
| 6 | Showboat | Flourish with variable commitment | White outfit, purple belt, sculpted gold hair, raised-arm flourish |
| 7 | Boomerang | Pass-and-return approach | Green outfit, peach details, cap, turning lean |

## Visual interface

`FighterVisual` is a `Node2D` whose position is its feet anchor. The match raises that node above the floor using actual jump physics. Typical body height is 180 pixels including hair. The match sets `palette_index`, `facing` (-1 or +1), `pose`, `phase` (0–1), `clock` (seconds), and optional `stretch` (pixels), then calls `queue_redraw()`.

Jump fields: `airborne` (bool), `jump_progress` (height divided by the character's maximum jump height, clamped 0–1), `flight_progress` (elapsed time divided by total airborne time, 0–1), `vertical_speed` (pixels/second, negative while rising), `landing` (impact envelope from 1 to 0 over approximately 0.12 seconds), and `ground_offset` (positive height in pixels from the feet anchor down to the floor). Defaults are false and zero. The shadow stays on the floor, shrinking and fading with height. Legs articulate in the air during ordinary movement and during hug, deflect, and feint actions. Landing gently compresses the body toward its feet without moving the actual physics anchor.

## Jump personalities

All eight characters jump through real gameplay physics. Their visual personalities are layered onto those trajectories:

| Character | Airborne choreography |
|---|---|
| Champ | Disciplined, compact, symmetrical knee tuck |
| Long Arms | Awkward knees-up hop with comically dangling wrists |
| Backwards Baxter | Backward lean with feet sticking out in front |
| Acrobat | A full tucked somersault, returning upright before touchdown |
| Big Softy | Belly-first committed lurch, with legs trailing |
| Speedster | High forward knee and trailing sprinting leg |
| Showboat | Exaggerated star jump with arms spread above the shoulders |
| Boomerang | A twisting, scissoring hop that unwinds before landing |

Character-specific arm flourishes yield to hug, deflect, and feint arm poses so aerial actions remain recognizable. The Acrobat keeps the somersault through aerial actions. Its special uses the same physics and flight-driven rotation, rather than stacking an additional cosmetic jump on top.

Poses: `idle`, `walk`, `hug`, `special`, `deflect`, `feint`, `recover`, `embrace`, and `stunned`. The renderer never changes gameplay state or scene transforms. A successful hug should be driven by one shared timeline for both players. Layering between two complete puppets remains a prototype limitation: production contact choreography should split their foreground arms into separate layers.

## Specific animation playtests

1. **Idle and walking:** Do the fighters read as poised martial artists? Are their feet grounded without distracting skating?
2. **Hug attempt:** Can you distinguish the open-arm anticipation from the actual contact window?
3. **Deflect and feint:** Are these poses different enough to learn at match speed?
4. **Successful hug:** Does contact read as a sincere embrace? Watch for floating hands, excessive overlap, or arms passing through faces.
5. **Long Arms and Acrobat:** Is the direction and timing of their unusual attempt understandable, even before knowing its rules?
6. **Jumping:** Do ascent, apex, descent, and landing look continuous? Watch whether feet tuck cleanly instead of walking through the air, the shadow stays on the sidewalk, and aerial hug or guard actions retain readable arms.

The procedural art establishes timing, silhouettes, and animation integration. Detailed contact poses, bespoke hands, and refined recipient reactions are the next visual investment after the mechanics pass playtesting.

Attempts ease from the common fighting stance and return to that stance during recovery. Deflection raises the guard quickly and lowers it smoothly. A successful embrace closes the arms over the first fifth of its shared timeline, then releases them during the final fifth. Baxter swivels into and out of his reverse stance rather than popping between facing directions.

The Acrobat somersaults through a real airborne **approach**, followed by the same upright contact pose used by the rest of the roster. A sustained upside-down embrace is not implemented yet. Contact also still uses whole-puppet draw ordering, so the prototype does not fully interleave each fighter's foreground and background arms. Both are specific visual refinements to assess after core match testing.
