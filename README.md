# Bounc back template

A small Godot 4.7 breakout/pong-style game where you move a character, swing a bat to deflect a ball, and rack up points by bouncing it off the wall.

## Features

- **Character movement** with left/right control and a jetpack-style jump that applies upward velocity while held.
- **Bat swing deflection** — swing the bat to aim the ball away from the player and toward the bat's direction, boosting its speed on contact (one hit per swing).
- **Ball physics** — reflects off surfaces with true normal-based bouncing, keeps a constant speed, and adds a small random deviation when it hits a wall.
- **Scoring** — each wall hit increments the score (`Score: N`) while the player has not lost.
- **Lose condition** — if the ball reaches the off-screen detection area on the left, the score resets, a `You Lose!` message appears, and the ball freezes.
- **Reset** — the Reset button reloads the current scene for a fresh game.
- **Menu** — Play launches the game, Exit quits the application.

## Requirements

- **Godot 4.7** (project feature tags: `4.7`, `Forward Plus`).
- **Forward Plus** renderer (set in `project.godot`).
- Windows uses the **D3D12** rendering driver by default (`rendering/rendering_device/driver.windows="d3d12"`).
- No external libraries or plugins are required.

The project also sets `physics/3d/physics_engine="Jolt Physics"`. This is a 3D physics setting and has no effect on this 2D game (see [Known notes](#known-notes--limitations)).

## How to run

### From the editor

1. Open the Godot 4.7 Project Manager.
2. **Import** and select `project.godot` in this folder.
3. Press **F5** (Play). The main scene is the menu (`uid://d4mofrg08uyvg` → `res://Scenes/MainScenes/menu.tscn`).

### From the command line

```bash
godot --path "C:\path\to\GameJame-Juno"
```

Use the path to your Godot 4.7 executable if `godot` is not on your `PATH`.

## Controls

| Action | Input | Input action |
| --- | --- | --- |
| Move left | `A` or `Left Arrow` | `left` |
| Move right | `D` or `Right Arrow` | `right` |
| Jetpack / Jump | `W` or `Up Arrow` | `jatpack` |
| Move down | `S` or `Down Arrow` | `down` (defined, unused by scripts) |
| Swing bat | `Space` | `swing` |
| Back to menu / Quit | `Esc` | built-in `ui_cancel` |

`Esc` is handled in code through Godot's built-in `ui_cancel` action: in the game scene it returns to the menu, and in the menu it quits the application. The custom `Esc` input action defined in `project.godot` is currently not referenced by any script.

## Project structure

```text
GameJame-Juno/
├── project.godot                 # Engine config, input map, layers, renderer
├── README.md
├── Assets/
│   ├── Backgrounds/
│   │   ├── demo01_PixelSky_1920x1080.png   # Menu + game background
│   │   └── demo02_PixelSky_1920x1080.png   # Unused alternate background
│   ├── placeholders/
│   │   ├── player.png            # Character sprite
│   │   ├── ball.png              # Ball sprite
│   │   ├── bat.png               # Bat sprite
│   │   ├── ground.jpg            # Floor sprite
│   │   ├── wall.jpg              # Right wall sprite
│   │   ├── line.jpg              # Unused placeholder
│   │   └── icon.svg              # Project icon
│   └── SFX/
│       └── Swing.mp3             # Bat swing sound
├── Scenes/
│   └── MainScenes/
│       ├── menu.tscn             # Main scene: Play / Exit buttons
│       ├── game.tscn             # Playfield, walls, detection area, HUD
│       ├── character.tscn        # Player, bat, hitbox, animation, SFX
│       └── ball.tscn             # Ball body and sprite
└── Scripts/
	├── menu.gd                   # Esc quits from the menu
	├── Play_button.gd            # Loads game.tscn
	├── exit_button.gd            # Quits the application
	├── game.gd                   # Score, lose condition, Esc to menu
	├── character.gd              # Movement, jetpack, bat swing/deflection
	├── ball.gd                   # Bouncing, wall signal, deviation
	└── reset_button.gd           # Reloads the current scene
```

## Architecture

### Character (`Scenes/MainScenes/character.tscn`, `Scripts/character.gd`)

`CharacterBody2D` with a capsule collider, a `Sprite2D`, a `Bat` sprite, a `BatHitbox` (`Area2D`), an `AudioStreamPlayer2D` (swing sound), and an `AnimationPlayer`.

- **Movement:** `Input.get_axis("left", "right")` sets horizontal velocity at `SPEED`; releasing the input decelerates with `move_toward`.
- **Jetpack:** while `jatpack` is held, `velocity.y` is set to `JUMP_VELOCITY` every physics frame; on release it is zeroed. Gravity via `get_gravity()` applies when not on the floor.
- **Swing:** pressing `swing` plays `Swing.mp3`, starts the `BatSwing` animation, and sets `is_swinging = true` / `swing_hit = false`.
- **Deflection:** while swinging and before a hit, `_try_hit_ball()` polls `$Bat/BatHitbox.get_overlapping_bodies()`. On the first `ball`-group body it:
  1. Computes `outward` = normalized vector from the player to the ball.
  2. Computes `bat_direction` = `Vector2.RIGHT.rotated($Bat.global_rotation)`.
  3. Sets the hit direction to `(outward + bat_direction).normalized()`.
  4. Raises `ball.speed` by `hit_speed_boost`, capped at `max_ball_speed`, and sets `ball.velocity = hit_direction * ball.speed`.
  5. Sets `swing_hit = true` and returns, so only one hit is registered per swing.
- The `BatSwing` animation finishes and sets `is_swinging = false`.

### Ball (`Scenes/MainScenes/ball.tscn`, `Scripts/ball.gd`)

`CharacterBody2D` in the `ball` group with a circle collider. It starts with `speed = 400.0` and an initial up-and-right velocity (`Vector2(1, -1).normalized() * speed`).

- Each physics frame calls `move_and_collide(velocity * delta)`.
- On collision it reflects with `velocity.bounce(normal)`.
- If the collider is in the `walls` group, it emits `hit_wall` and applies a random rotation of `±max_deviation_degrees`.
- If the collider is in the `blocks` group, it bounces cleanly with no score.
- After each bounce, velocity is renormalized to `speed` so the ball keeps a consistent speed (until the bat boosts it).

### Game flow (`Scripts/game.gd`, `game.tscn`)

- `_ready()` hides the lose label and reset button, connects `ball.hit_wall` and `Detection area.body_entered`, and shows `Score: 0`.
- **Scoring:** each `hit_wall` increments `score` and updates `ScoreLabel` to `Score: N` (ignored if `has_lost`).
- **Losing:** when a `ball`-group body enters the `Detection area` (`Area2D`, mask 32), `_lose()` sets `has_lost`, resets the score to 0, shows `You Lose!` and the `Reset button`, then zeroes the ball's velocity and disables its physics.
- **Menu navigation:** `ui_cancel` (Esc) changes the scene to `res://Scenes/MainScenes/menu.tscn`.
- **Reset:** `reset_button.gd` calls `get_tree().reload_current_scene()`, restarting the game with a fresh score and ball.

### Collision layers

Godot layer numbers and their bitmask values used by this project:

| Layer | Bitmask value | Used by | Group | Notes |
| --- | --- | --- | --- | --- |
| 1 | 1 | Player body | — | Default layer; ball does not collide with it |
| 2 | 2 | `Walls` | `walls` | Right wall; triggers `hit_wall` and scoring |
| 3 | 4 | `StaticBody2D` floor / `Blocks` ceiling | `blocks` | Ball bounces cleanly, no score |
| 4 | 8 | `PassThrough` obstacles | — | Player collides, ball passes through |
| 6 | 32 | Ball | `ball` | Detected by bat hitbox and detection area |

Masks:

- **Ball** `collision_mask = 6` → hits layers 2 + 3 (Walls + Blocks).
- **Player** `collision_mask = 14` → hits layers 2 + 3 + 4 (Walls + Blocks + PassThrough).
- **`Bat/BatHitbox`** `collision_mask = 32` → detects the ball (layer 0, so it detects only).
- **`Detection area`** `collision_mask = 32` → detects the ball.

Because only the right wall is in the `walls` group, scoring happens on right-wall hits. The floor and ceiling are in `blocks`, and the left side is `PassThrough`, so a ball leaving to the left reaches the off-screen detection area and ends the run.

## Tuning gameplay

Values marked **scene** are overridden in the `.tscn` and take precedence over the script defaults marked **script**.

| Setting | Location | Default | Current effective value | Effect |
| --- | --- | --- | --- | --- |
| `SPEED` | `Scripts/character.gd` | `200.0` | `200.0` | Horizontal player movement speed |
| `JUMP_VELOCITY` | `Scripts/character.gd` | `-400.0` | `-400.0` | Upward velocity while the jetpack is held |
| `hit_speed_boost` | `Scripts/character.gd` (export) | `100.0` | `10.0` (**scene**) | Speed added to the ball per bat hit |
| `max_ball_speed` | `Scripts/character.gd` (export) | `900.0` | `700.0` (**scene**) | Upper speed cap after bat boosts |
| `speed` | `Scripts/ball.gd` (not exported) | `400.0` | `400.0` | Base ball speed and post-bounce speed |
| `max_deviation_degrees` | `Scripts/ball.gd` (export) | `5.0` | `15.0` (**scene**) | Max random angle added on wall hits |

Notes for tuning:

- Boost values set in `character.tscn` override the script defaults, so edit the instance in `character.tscn` (or the exported property in the editor) for gameplay changes.
- `speed` in `ball.gd` is a plain variable, not `@export`, so change it in the script; the initial velocity uses it.
- Changing collision masks/layers requires updating both the ball and the affected bodies (see the collision layer table). For example, giving the player body a non-default layer and adding it to the ball's mask would let the ball bounce off the player.
- To change which surfaces score, add/remove bodies from the `walls` group or adjust `ball.gd`'s group checks.

## Known notes & limitations

- **Placeholder art and odd scaling:** all gameplay visuals are placeholders. Many are scaled unusually, e.g. the player sprite `scale` is `0.206`, the bat sprite uses `scale` `0.0997` with a large `offset` of `(934, -318)` and a `1700 × 400` hitbox, and the ball's collision circle is scaled to `3.197`. These are intentional stand-ins and not final art.
- **Custom `Esc` action is unused:** `project.godot` defines `Esc` with `device:16` while all other actions use `device:-1`. The scripts use the built-in `ui_cancel` action instead, so `Esc` works through `ui_cancel`, and the custom action can be removed or ignored.
- **`down` is unused:** the `down` action (`S` / `Down Arrow`) is mapped but not read by any script.
- **Jolt 3D setting on a 2D game:** `physics/3d/physics_engine="Jolt Physics"` only affects 3D physics and has no impact here.
- **Layer names are render-layer names:** `[layer_names]` only names `2d_render/layer_2="Walls"` and `2d_render/layer_3="Blocks"`; the ball (layer 6) and pass-through (layer 4) are unnamed, and these are render layers rather than physics-layer labels.
- **Scoring only on the right wall:** the floor/ceiling are `blocks` (no score) and the left edge is pass-through, so points come from the right wall via the `walls` group.
- **No win condition:** the game only tracks score and a lose state. Reaching a target score does nothing.
- **Game over freezes the ball:** after losing, the ball's physics is disabled; the Reset button reloads the scene to play again.
- **Stale editor temp files:** `Scenes/MainScenes/` contains leftover `menu.tscn*.tmp` files (Godot editor temporaries). They are not used by the project and can be safely deleted.
- **Empty stub callbacks:** `game.gd` and `menu.gd` contain empty `_process(delta)` (and `menu.gd` an empty `_ready()`), which are harmless placeholders.
