# Gamespec

## Overview
> **Cartoon Wars** is a 2D lane-based strategy game where two bases (player vs AI enemy) send stick-figure troops down a single lane to destroy each other. The player spends regenerating mana to spawn troop types, aims a crossbow turret to pick off approaching enemies, and wins by reducing the enemy base HP to zero before theirs falls. Inspired by the classic "Stick War" web game.

## Core Concepts / Glossary
- **Base** — A tower at each end of the lane (player left, enemy right) with HP, a door, battlements, and a mounted crossbow (player only) that fires in its current aim direction.
- **Lane** — The horizontal strip of ground between the two bases where troops walk and fight. Defined by `LANE_MIN` (left) and `LANE_MAX` (right) in pixels; troops use a `frac` (0..1) position along this lane.
- **Troop** — A unit spawned by either side. Has HP, damage, attack interval, range (fraction of lane), speed (fraction/sec), weapon type, and visual attributes. Walks toward the enemy base; stops to attack enemies in range or the base itself when in range.
- **Mana** — The resource used to spawn troops. Regenerates over time (1 per 1.8s, max 10). Both player and AI have separate mana pools.
- **Crossbow** — A turret on top of the player's base that fires bolts continuously every ~1.4s. Player aims manually (Up/Down). Enemy base does not have a crossbow.
- **Projectile** — Arrows (bowmen), magic bolts (wizards/imps), or crossbow bolts. Travels from origin to target with an arc; deals damage on arrival if the target still exists.
- **Particle** — Visual hit/death effect (small colored circles that fly up and fade).
- **Level** — A playable stage with its own set of available enemy troop types. Levels are selected from a level select screen after the main menu.
- **Enemy Troop** — Monster/robot-like units used by the AI. Distinct from player's human troop types with different stats and visuals.

## Game States
- **MENU** — Title screen with Play button. Gameplay HUD hidden. Press Enter or click Play to go to level select.
- **LEVEL_SELECT** — Level selection screen showing available levels. Each level displays its name and description. Click a level to start it.
- **PLAYING** — Active simulation. HUD visible. Troops spawn, fight, crossbow fires, mana regenerates.
- **OVER** — A base has reached 0 HP. Result overlay shows Victory or Defeat with Play Again / Main Menu buttons.

### Transitions
- MENU → LEVEL_SELECT: Enter key or Play button → `_on_level_select_requested()` → shows level select overlay.
- LEVEL_SELECT → PLAYING: Select a level → `start_level(id)` → `start_game()` (sets enemy types, resets round, shows HUD).
- PLAYING → OVER: `player_hp <= 0` or `enemy_hp <= 0` → `show_result(won)`.
- OVER → PLAYING: Play Again button → `start_game()` (replays current level).
- OVER → MENU: Main Menu button → `_show_menu()`.
- PLAYING → MENU: (via restart) R key restarts the current level.

## Game Flow
1. **Launch** → MENU state. Scene `res://scenes/main.tscn` loads its explicit battlefield, simulation-layer, and HUD children; `Game._ready()` wires their signals and shows the menu overlay.
2. **Level Select** → Enter or Play button → LEVEL_SELECT state. Shows level selection overlay with available levels.
3. **Start** → Select a level → `start_level(id)` sets current level's enemy troop types → `start_game()` resets HP/mana/troops, sets state to PLAYING, hides overlays, shows HUD.
4. **Each frame (`_process`)**:
   a. Advance `time_sec`; redraw background.
   b. Regenerate mana for both sides.
   c. AI decision tick (every 1.2s): randomly spawn an affordable troop.
   d. For each living troop: find nearest enemy ahead; if in range, attack (melee hits instantly, ranged spawns a projectile); otherwise walk forward.
   e. Position troops along the lane; update sprite visuals (walk bob, attack lunge, frame animation, hit flash, HP bar).
    f. Update player crossbow: fire bolt on timer (always fires, no target check needed for firing).
    g. Advance projectiles; on arrival, damage target if alive; spawn hit particles.
    h. Update particles (gravity, fade).
    i. Play authored death animations, then remove dead troops.
    j. Update HUD (HP bars, mana bar, button enabled states).
    k. Check win/lose → OVER state if a base is at 0 HP.
5. **End** → Result overlay. Player clicks Play Again (restart) or Main Menu.

## Rules

### Spawning
1. R1: Player spawns via troop buttons (click) or keys 1-5. Each costs the troop's mana cost.
2. R2: Cannot spawn if `player_mana < cost`. Button is disabled (greyed) when unaffordable.
3. R3: Player troops spawn at `frac=0` (left base). Enemy troops spawn at `frac=1` (right base).
4. R4: AI decides every 1.2s: 72% chance to skip; otherwise picks a random affordable enemy troop from the current `LevelDefinition` roster (weighted 3:1 toward cheaper troops cost≤4).

### Movement
5. R5: Troops walk toward the enemy base at `speed` (fraction of lane per second). Player moves right (+), enemy moves left (-).
6. R6: A troop stops walking when an enemy is within `range` (fraction) ahead of it, or when the enemy base is within `range`.

### Combat
7. R7: When stopped with a target, troops attack every `atk_interval` seconds.
8. R8: Melee weapons (spearman, knight, golem) deal damage instantly to the target troop.
9. R9: Ranged weapons (bow→arrow, magic→magic bolt) spawn a projectile that travels to the target's position; damage applies on arrival only if the target is still alive. Both player and enemy ranged units use this system (skeleton→arrow, imp→magic bolt).
10. R10: If no troop target but the enemy base is in range, the troop attacks the base directly (reduces base HP).
11. R11: Troops have a hit-flash (0.12s white blink) when damaged.
11a. R11a: Flamethrowers continuously emit a flame stream while attacking. Each attack damages the primary target and all enemy troops within 0.065 lane distance of it.

### Crossbows
12. R12: Only the player's base has a crossbow. It fires every ~1.4s (±0.15s jitter) continuously, regardless of enemies. The bolt fires in the crossbow's current aim direction; it does not home in on the target.
13. R13: Player crossbow angle is controlled manually (Up/Down keys or buttons, ±0.05 rad, clamped to [-0.4, 0.8]). Up aims the crossbow upward and Down aims it downward.
14. R14: Crossbow bolts travel with gravity (900 px/s²) at a reduced speed (~420 px/s). They deal 7 damage to the first troop they hit within 20 pixels and spawn hit particles; otherwise they disappear when they hit the ground. Bolts only damage enemies within the crossbow's targeting range (75% of the lane).

### Victory/Defeat
16. R16: The game ends when either base reaches 0 HP. Enemy at 0 = Victory; Player at 0 = Defeat.

## Entities / Data Model

### Game (controller)
- `state`: menu | level_select | playing | over
- `player_hp`, `enemy_hp`: float (max 180)
- `player_mana`, `ai_mana`: float (max 10, regen 1/1.8s)
- Active troops and projectiles are owned and updated by `CombatSystem`.
- `ai_timer`: float

### Player Unit Definitions
| Key | Name | Cost | HP | DMG | Atk Interval | Range | Speed | Weapon | Scale |
|---|---|---|---|---|---|---|---|---|---|---|
| spearman | Spearman | 2 | 35 | 6 | 0.9s | 0.018 | 0.11 | melee | 0.13 |
| bowman | Bowman | 4 | 22 | 9 | 1.1s | 0.16 | 0.09 | bow | 0.13 |
| wizard | Wizard | 6 | 30 | 12 | 1.3s | 0.155 | 0.085 | magic | 0.13 |
| broadsword | Knight | 8 | 120 | 18 | 1.4s | 0.024 | 0.05 | melee | 0.17 |
| soldier_flamethrower | Flamer | 5 | 48 | 14 AoE | 0.65s | 0.10 | 0.075 | flame | 0.15 |

### Enemy Unit Definitions
| Key | Name | Cost | HP | DMG | Atk Interval | Range | Speed | Weapon | Scale |
|---|---|---|---|---|---|---|---|---|---|---|
| golem | Golem | 4 | 80 | 10 | 1.2s | 0.022 | 0.06 | melee | 0.17 |
| skeleton | Skeleton | 3 | 18 | 7 | 1.0s | 0.14 | 0.10 | bow | 0.13 |
| imp | Imp | 5 | 20 | 10 | 1.0s | 0.14 | 0.12 | magic | 0.10 |

Enemy units are monster/robot-like: Golem (stone melee tank), Skeleton (bone archer), Imp (demon fire mage). The AI picks from the current level's available enemy types.

### Level Definitions
| ID | Name | Description | Enemy Types |
|---|---|---|---|
| 1 | The Beginning | Repel the enemy's monstrous forces! | Golem, Skeleton, Imp (all 3) |

### Troop
- `side`, `definition` (`UnitDefinition` Resource)
- `hp`, `max_hp`, `frac` (0..1 lane position), `y_jitter`
- `atk_timer`, `phase` (walk cycle), `state` (walk | attack), `hit_flash`, `alive`

### Base
- `side`, `hp`, `max_hp` (180), `has_crossbow` (player only), `crossbow_angle`, `fire_timer`

### Projectile
- `start`, `end`, `progress` (0..1), `speed`, `target` (Troop), `damage`, `kind` (arrow | bolt | magic)

## UI / Feedback
- **Top HUD**: Styled bordered panels with Player HP bar (blue, left) and Enemy HP bar (red, right) with numeric labels and shadowed text.
- **Bottom tray**: Styled mana diamond + bordered mana bar (left), with 5 square troop deployment tiles centered entirely below the ground line. Each tile shows the troop image, its `1-5` deployment key, and its mana cost in blue; clicking a tile deploys that troop, and unaffordable tiles are disabled.
- **Aim buttons**: Styled Up/Down buttons in a bordered panel (bottom-left) for player crossbow angle.
- **Menu overlay**: Dark dim + styled bordered panel with "CARTOON WARS" title, controls hint, PLAY button, and "Press Enter to select level" hint.
- **Level select overlay**: Dark dim + styled bordered panel with "SELECT LEVEL" title and level buttons showing name and description.
- **Result overlay**: Dark dim + styled bordered panel with Victory!/Defeat... title (colored), subtitle, Play Again + Main Menu styled buttons.
- **In-game visuals**: Bright sky gradient with mountains and hills, sun with glow halo, puffy white clouds, grass tufts with rocks and flowers, a dirt path along the lane, two stone towers with brick patterns, glowing windows, animated waving flags, detailed battlements and crossbows, ground shadows, live 3D Blender Spearman, Wizard, and Flamethrower models rendered into the 2D lane, a Grease Pencil Blender Knight rendered as authored 2D walk/attack/death sprite frames, procedural visuals for the remaining troops, animated HP bars (green→red by ratio), arrows/bolts/magic projectiles with trails and arcs, colored hit particles.
- **Controls**: 1-5 = spawn troops, Up/Down = aim crossbow, R = restart level, Enter = open level select from menu.

## Architecture
- Feature code lives under `res://features/`; authored gameplay data lives in typed `UnitDefinition` and `LevelDefinition` resources under `res://data/`.
- `res://scenes/main.tscn` explicitly composes the background `Battlefield`, bases, troop/projectile layers, particles, `CombatSystem`, and the instanced HUD scene. `Game` coordinates state, resources, AI timing, base HP results, and HUD; `CombatSystem` owns movement, targeting, attacks, projectiles, particles, and combat cleanup.
- Unit presentation mode and optional presentation scene are selected by `UnitDefinition`; procedural rendering remains the fallback.

## Open Questions / TODOs
- Sound effects: none yet (could add via AudioStreamPlayer).
- Balance: current values may need tuning after extended playtesting.
- Mobile/touch controls: only keyboard + mouse buttons currently.
- Procedural troop animations: walk cycle and attack lunge use simple sine waves; could add frame-by-frame limb positioning for more natural motion.
- Level progression: future levels should unlock new player units and introduce new enemy types.
- Unit upgrades: between levels, players could spend currency to upgrade existing units.
