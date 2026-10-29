# Jumping: first playable rules

Jumping is a core part of the duel. Ground position and height are separate gameplay coordinates. Artwork follows collision height; animation does not grant extra reach or immunity.

| Character | Height (px) | Flight (seconds) | Air speed (px/s) | Intended feel |
| --- | ---: | ---: | ---: | --- |
| Champ | 170 | 0.82 | 250 | Disciplined tuck, predictable arc and responsive steering |
| Long Arms | 185 | 0.96 | 210 | Awkward knees-up float, loose wrists, slower steering |
| Backwards Baxter | 155 | 0.84 | 235 | Reclined feet-forward hop with carried momentum |
| Acrobat | 215 | 0.94 | 290 | High full somersault, strong steering |
| Big Softy | 135 | 0.80 | 195 | Belly-first lurch; stronger initial momentum than sustained air speed |
| Speedster | 140 | 0.70 | 340 | Low fast arc, forward knee, fast entry |
| Showboat | 190 | 1.00 | 225 | Theatrical star jump and long hang time |
| Boomerang | 165 | 0.84 | 265 | Twisting scissor hop with moderate control |

P1 uses W or Space; P2 uses Up. One jump per takeoff; holding a key does not auto-hop. A fresh press in the last 120 ms of flight may buffer the next jump. Grounded jump requests require idle/walk; recovery cannot be escaped by jumping.

Horizontal movement carries into the air. Steering changes velocity gradually according to the character, including during aerial hugs/deflections/feints. The fighter turns toward the opponent while idle, including after crossing sides; committed actions retain their original aim.

Hugs need horizontal reach, correct aim, and no more than 85 pixels of height difference at contact. A high jump can clear a ground hug. Low rising/falling hugs and matching-height air hugs can connect. Deflection uses the same timed window in the air. Signatures start grounded; Acrobat's signature launches a separate real 155-pixel/0.70-second vault and lands before its contact frame.

Successful aerial contact preserves initial height, aligns the pair over a short interval, and lowers them together to the floor. A mutual aerial contact remains scoreless. Practice disables all partner inputs, including jump, and ordinary walking cannot push the partner. A high jump can cross sides.

These numbers are starting values for feel testing. The next decision is whether the eight jumps are fun and readable; competitive balance and bespoke upside-down embrace choreography follow.
