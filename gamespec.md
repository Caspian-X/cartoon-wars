# Gamespec

## Overview
> **Cartoon Wars** is a 2D lane-based strategy game where two bases (player vs AI enemy) send stick-figure troops down a single lane to destroy each other. The player spends regenerating mana to spawn troop types, aims a crossbow turret to pick off approaching enemies, and wins by reducing the enemy base HP to zero before theirs falls. Inspired by the classic "Stick War" web game.

## Core Concepts / Glossary
- **Base** — A tower at each end of the lane (player left, enemy right) with HP, a door, battlements, and a mounted crossbow that fires in its current aim direction.
- **Lane** — The horizontal strip of ground between the two bases where troops walk and fight. Defined by `LANE_MIN` (left) and `LANE_MAX` (right) in pixels; troops use a `frac` (0..1) position along this lane.
- **Troop** — A unit spawned by either side. Has HP, damage, attack interval, range (fraction of lane), speed (fraction/sec), weapon type, and a sprite. Walks toward the enemy base; stops to attack enemies in range or the base itself when in range.
- **Mana** — The resource used to spawn troops. Regenerates over time (1 per 1.8s, max 10). Both player and AI have separate mana pools.
- **Crossbow** — A turret on top of each base that fires bolts at the nearest enemy troop within 75% of the lane. Player aims manually (Up/Down); enemy auto-tracks.
- **Projectile** — Arrows (bowmen), magic bolts (wizards), or crossbow bolts. Travels from origin to target with an arc; deals damage on arrival if the target still exists.
- **Particle** — Visual hit/death effect (small colored circles that fly up and fade).

## Game States
- **MENU** — Title screen with Play button. Gameplay HUD hidden. Press Enter or click Play to start.
- **PLAYING** — Active simulation. HUD visible. Troops spawn, fight, crossbows fire, mana regenerates.
- **OVER** — A base has reached 0 HP. Result overlay shows Victory or Defeat with Play Again / Main Menu buttons.

### Transitions
- MENU → PLAYING: Enter key or Play button → `start_game()` (resets round, shows HUD).
- PLAYING → OVER: `player_hp <= 0` or `enemy_hp <= 0` → `show_result(won)`.
- OVER → PLAYING: Play Again button → `start_game()`.
- OVER → MENU: Main Menu button → `_show_menu()`.
- PLAYING → MENU: (via restart) R key restarts the round.

## Game Flow
1. **Launch** → MENU state. Scene `res://scenes/main.tscn` loads; `Game._ready()` builds bases, layers, HUD, and shows the menu overlay.
2. **Start** → `start_game()` resets HP/mana/troops, sets state to PLAYING, hides menu, shows HUD.
3. **Each frame (`_process`)**:
   a. Advance `time_sec`; redraw background.
   b. Regenerate mana for both sides.
   c. AI decision tick (every 1.2s): randomly spawn an affordable troop.
   d. For each living troop: find nearest enemy ahead; if in range, attack (melee hits instantly, ranged spawns a projectile); otherwise walk forward.
   e. Position troops along the lane; update sprite visuals (walk bob, attack lunge, frame animation, hit flash, HP bar).
   f. Update crossbows: find nearest target in range; fire on timer; enemy crossbow auto-tracks angle.
   g. Advance projectiles; on arrival, damage target if alive; spawn hit particles.
   h. Update particles (gravity, fade).
   i. Remove dead troops.
   j. Update HUD (HP bars, mana bar, button enabled states).
   k. Check win/lose → OVER state if a base is at 0 HP.
4. **End** → Result overlay. Player clicks Play Again (restart) or Main Menu.

## Rules

### Spawning
1. R1: Player spawns via troop buttons (click) or keys 1-4. Each costs the troop's mana cost.
2. R2: Cannot spawn if `player_mana < cost`. Button is disabled (greyed) when unaffordable.
3. R3: Player troops spawn at `frac=0` (left base). Enemy troops spawn at `frac=1` (right base).
4. R4: AI decides every 1.2s: 72% chance to skip; otherwise picks a random affordable troop (weighted 3:1 toward cheaper troops cost≤4).

### Movement
5. R5: Troops walk toward the enemy base at `speed` (fraction of lane per second). Player moves right (+), enemy moves left (-).
6. R6: A troop stops walking when an enemy is within `range` (fraction) ahead of it, or when the enemy base is within `range`.

### Combat
7. R7: When stopped with a target, troops attack every `atk_interval` seconds.
8. R8: Melee weapons (spearman, knight) deal damage instantly to the target troop.
9. R9: Ranged weapons (bow→arrow, magic→magic bolt) spawn a projectile that travels to the target's position; damage applies on arrival only if the target is still alive.
10. R10: If no troop target but the enemy base is in range, the troop attacks the base directly (reduces base HP).
11. R11: Troops have a hit-flash (0.12s white blink) when damaged.

### Crossbows
12. R12: Each base has a crossbow that fires every ~1.4s (±0.15s jitter) when an enemy troop is within 75% of the lane. The bolt fires in the crossbow's current aim direction; it does not home in on the target.
13. R13: Player crossbow angle is controlled manually (Up/Down keys or buttons, ±0.05 rad, clamped to [-0.4, 0.8]). Up aims the crossbow upward and Down aims it downward.
14. R14: Enemy crossbow auto-tracks its target's angle (lerp factor 0.06).
15. R15: Crossbow bolts travel with gravity (900 px/s²) at a reduced speed (~420 px/s). They deal 7 damage to the first troop they hit within 20 pixels and spawn hit particles; otherwise they disappear when they hit the ground.

### Victory/Defeat
16. R16: The game ends when either base reaches 0 HP. Enemy at 0 = Victory; Player at 0 = Defeat.

## Entities / Data Model

### Game (controller)
- `state`: menu | playing | over
- `player_hp`, `enemy_hp`: float (max 180)
- `player_mana`, `ai_mana`: float (max 10, regen 1/1.8s)
- `troops`: Array[Troop]
- `projectiles`: Array[Projectile]
- `ai_timer`: float

### Troop Types (TROOP_TYPES)
| Key | Name | Cost | HP | DMG | Atk Interval | Range | Speed | Weapon | Scale |
|---|---|---|---|---|---|---|---|---|---|
| spearman | Spearman | 2 | 35 | 6 | 0.9s | 0.018 | 0.11 | melee | 0.13 |
| bowman | Bowman | 4 | 22 | 9 | 1.1s | 0.16 | 0.09 | bow | 0.13 |
| wizard | Wizard | 6 | 30 | 12 | 1.3s | 0.155 | 0.085 | magic | 0.13 |
| broadsword | Knight | 8 | 120 | 18 | 1.4s | 0.024 | 0.05 | melee | 0.17 |

### Troop
- `side`, `type_idx`, `data` (Dictionary ref to TROOP_TYPES entry)
- `hp`, `max_hp`, `frac` (0..1 lane position), `y_jitter`
- `atk_timer`, `phase` (walk cycle), `state` (walk | attack), `hit_flash`, `alive`

### Base
- `side`, `hp`, `max_hp` (180), `crossbow_angle`, `fire_timer`

### Projectile
- `start`, `end`, `progress` (0..1), `speed`, `target` (Troop), `damage`, `kind` (arrow | bolt | magic)

## UI / Feedback
- **Top HUD**: Styled bordered panels with Player HP bar (blue, left) and Enemy HP bar (red, right) with numeric labels and shadowed text.
- **Bottom tray**: Styled mana diamond + bordered mana bar (left), 4 troop buttons (centered, each bordered with troop-type color accent showing name + cost, disabled when unaffordable).
- **Aim buttons**: Styled Up/Down buttons in a bordered panel (bottom-left) for player crossbow angle.
- **Menu overlay**: Dark dim + styled bordered panel with "CARTOON WARS" title, controls hint, PLAY button, and "Press Enter to start" hint.
- **Result overlay**: Dark dim + styled bordered panel with Victory!/Defeat... title (colored), subtitle, Play Again + Main Menu styled buttons.
- **In-game visuals**: Bright sky gradient with mountains and hills, sun with glow halo, puffy white clouds, grass tufts with rocks and flowers, a dirt path along the lane, two stone towers with brick patterns, glowing windows, animated waving flags, detailed battlements and crossbows, ground shadows, procedural stick-figure troops with weapons (spear/bow/staff/sword) and walk/attack animations, animated HP bars (green→red by ratio), arrows/bolts/magic projectiles with trails and arcs, colored hit particles.
- **Controls**: 1-4 = spawn troops, Up/Down = aim crossbow, R = restart, Enter = start from menu.

## Open Questions / TODOs
- Sound effects: none yet (could add via AudioStreamPlayer).
- Balance: current values may need tuning after extended playtesting.
- Mobile/touch controls: only keyboard + mouse buttons currently.
- Procedural troop animations: walk cycle and attack lunge use simple sine waves; could add frame-by-frame limb positioning for more natural motion.
