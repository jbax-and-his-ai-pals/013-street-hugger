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

`FighterVisual` is a `Node2D` whose position is its feet on the floor. Typical height is 180 pixels including hair. The match sets `palette_index`, `facing` (-1 or +1), `pose`, `phase` (0–1), `clock` (seconds), and optional `stretch` (pixels), then calls `queue_redraw()`.

Poses: `idle`, `walk`, `hug`, `special`, `deflect`, `feint`, `recover`, `embrace`, and `stunned`. The renderer never changes gameplay state or scene transforms. A successful hug should be driven by one shared timeline for both players. Layering between two complete puppets remains a prototype limitation: production contact choreography should split their foreground arms into separate layers.

## Specific animation playtests

1. **Idle and walking:** Do the fighters read as poised martial artists? Are their feet grounded without distracting skating?
2. **Hug attempt:** Can you distinguish the open-arm anticipation from the actual contact window?
3. **Deflect and feint:** Are these poses different enough to learn at match speed?
4. **Successful hug:** Does contact read as a sincere embrace? Watch for floating hands, excessive overlap, or arms passing through faces.
5. **Long Arms and Acrobat:** Is the direction and timing of their unusual attempt understandable, even before knowing its rules?

The procedural art establishes timing, silhouettes, and animation integration. Detailed contact poses, bespoke hands, and refined recipient reactions are the next visual investment after the mechanics pass playtesting.

Attempts ease from the common fighting stance and return to that stance during recovery. Deflection raises the guard quickly and lowers it smoothly. A successful embrace closes the arms over the first fifth of its shared timeline, then releases them during the final fifth. Baxter swivels into and out of his reverse stance rather than popping between facing directions.

The Acrobat's current signature demonstrates an inverted handspring **approach**, followed by the same upright contact pose used by the rest of the roster. A sustained upside-down embrace is not implemented yet. Contact also still uses whole-puppet draw ordering, so the prototype does not fully interleave each fighter's foreground and background arms. Both are specific visual refinements to assess after core match testing.
