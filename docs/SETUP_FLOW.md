# Arcade setup

The setup uses familiar fighting-game navigation with original artwork, fictional geography, and the existing characters. No franchise portraits, logos, world maps, flags, fonts, or sound effects are imported.

## Flow

1. Main menu: Single Player or Multiplayer.
2. Character select: eight portraits arranged in two rows of four, two player selections, and a map of Pelara.
3. Confirm both choices, then start the match. Single Player selects a CPU opponent; Multiplayer uses two local keyboard players.
4. Practice is a secondary option on the single-player character screen. It retains the stationary-partner rules.
5. Pause/results can return to character select. A main-menu route allows changing modes.

The portrait art is rendered from the same procedural character drawings used during matches. Country highlights and character cards use matching orange P1 and teal P2 colors. Mirror choices remain legal and both map markers must stay visible.

## Pelara roster

| Character | Country |
| --- | --- |
| Champ | Merrow |
| Long Arms | Talune |
| Backwards Baxter | Vesk |
| Acrobat | Ivara |
| Big Softy | Brindle |
| Speedster | Serrin |
| Showboat | Solenne |
| Boomerang | Oru |

Names live in scripts/roster_data.gd so portraits, country labels, and gameplay remain consistent. Country names are worldbuilding; they do not introduce stat bonuses or undocumented mechanics.

## Focused user test

- Start Single Player, navigate all eight portraits, confirm a fighter and CPU opponent, and start a match. Check that portrait, name, highlighted country, and actual match character agree.
- Back out while selecting or confirming, then try Multiplayer. Both selectors should work independently, including when both choose the same fighter.
- Return from pause/results to character select and change a fighter. Rematch should reuse the confirmed fighters.
- Launch Practice from Single Player. Only P1 should respond to gameplay inputs.

Report a stuck selection, unclear active player, mismatched portrait/country, accidental match launch, or navigation that takes you somewhere unexpected. Character balance and new combat mechanics are outside this change.
