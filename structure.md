# Crow Smash — Project Structure

This document describes the technical layout of the Crow Smash Godot project. It covers the directory tree, scenes, autoloads, scripts, gameplay rules, collision and input maps, save formats, audio behavior, tuning values, and export/import notes.

The project is a Godot 4.7.x 2D game (`config/features=PackedStringArray("4.7", "Forward Plus")`). The main scene is `Scenes/MainScenes/menu.tscn` (`uid://d4mofrg08uyvg`).

## Directory Tree

`.godot/` is Godot's generated cache and is ignored by Git; it is omitted below. Each `.png`, `.mp3`, and `.ttf` asset has a tracked `.import` sidecar, shown as `(+ .import)`. Each `.gd` script has a tracked `.uid` sidecar, shown as `(+ .uid)`.

```text
GameJame-Juno/
├── project.godot
├── export_presets.cfg
├── default_bus_layout.tres
├── README.md
├── structure.md
├── known_bugs.md
├── .gitignore
├── .gitattributes
├── Saves/                                  # Tracked samples; NOT read at runtime
│   ├── coins.save
│   ├── high_score.save
│   └── settings.cfg
├── Scenes/
│   ├── MusicPlayer.tscn
│   └── MainScenes/
│       ├── menu.tscn                       # Main scene
│       ├── game.tscn
│       ├── Shop.tscn
│       ├── Settings.tscn
│       ├── character.tscn
│       └── ball.tscn
├── Scripts/
│   ├── save_paths.gd (+ .uid)
│   ├── audio_settings.gd (+ .uid)
│   ├── music_player.gd (+ .uid)
│   ├── skin_data.gd (+ .uid)
│   ├── menu.gd (+ .uid)
│   ├── Play_button.gd (+ .uid)
│   ├── shop_button.gd (+ .uid)
│   ├── Settings_button.gd (+ .uid)
│   ├── exit_button.gd (+ .uid)
│   ├── game.gd (+ .uid)
│   ├── character.gd (+ .uid)
│   ├── ball.gd (+ .uid)
│   ├── shop.gd (+ .uid)
│   ├── settings.gd (+ .uid)
│   ├── reset_button.gd (+ .uid)
│   ├── fullscreen_toggle.gd (+ .uid)
│   ├── back_to_menu_settings.gd (+ .uid)
│   └── back_to_menu_shop.gd (+ .uid)
└── Assets/
    ├── Animations/
    │   └── crow fly.res
    ├── AssetsFin/
    │   ├── ball (2).png (+ .import)
    │   ├── backround/
    │   │   ├── backgroundWall.png (+ .import)
    │   │   ├── backroundGrass.png (+ .import)
    │   │   ├── backroundSky1.png (+ .import)
    │   │   ├── cloud1.png (+ .import)
    │   │   ├── cloud2.png (+ .import)
    │   │   └── forgroundGrass.png (+ .import)
    │   ├── bat/
    │   │   └── bat1.png (+ .import)         # Shop placeholder; not a skin
    │   └── character/
    │       ├── bat/
    │       │   ├── batSkin0.png (+ .import)
    │       │   ├── batSkin1.png (+ .import)
    │       │   ├── batSkin2.png (+ .import)
    │       │   └── batSkin3.png (+ .import)
    │       └── crow/
    │           ├── crowSkin0.png (+ .import)
    │           ├── crowSkin1.png (+ .import)
    │           ├── crowSkin2.png (+ .import)
    │           └── crowSkin3.png (+ .import)
    ├── Backgrounds/
    │   ├── demo01_PixelSky_1920x1080.png (+ .import)   # Menu, Shop, Settings
    │   └── demo02_PixelSky_1920x1080.png (+ .import)   # Unused
    ├── Fonts/
    │   ├── Alternity.ttf (+ .import)                    # Used by scenes
    │   └── advanced_pixel_lcd-7.fon                     # Unused, no .import
    ├── Music/
    │   └── BackgroundMusic1.mp3 (+ .import)
    ├── SFX/
    │   └── Swing.mp3 (+ .import)
    └── placeholders/
        ├── ball.png (+ .import)
        ├── bat.png (+ .import)
        ├── batSwing.png (+ .import)
        ├── crow2.png (+ .import)
        ├── ground.jpg (+ .import)
        ├── icon.svg (+ .import)                         # Project icon
        ├── line.jpg (+ .import)
        ├── player.png (+ .import)
        └── wall.jpg (+ .import)
```

The repository `Saves/` folder contains tracked sample files, but the game never reads or writes `res://Saves`. Runtime saves are written to `user://Saves`, which resolves to `%APPDATA%\Godot\app_userdata\Crow Smash\Saves` on Windows.

## Scenes

| Scene | Path | Role | Script(s) | Key nodes |
| --- | --- | --- | --- | --- |
| Menu | `Scenes/MainScenes/menu.tscn` | Main scene and main menu. | `menu.gd` on root; `Play_button.gd`, `shop_button.gd`, `Settings_button.gd`, `exit_button.gd` on the four buttons. | `Background`, `CrowPreview`, `BatPreview`, `Play_button`, `Shop_button`, `Settings_button`, `Exit_button`. |
| Game | `Scenes/MainScenes/game.tscn` | Playfield, HUD, score/coins/high score, lose state. | `game.gd` on root; `reset_button.gd` on `Reset button`. | `Background`, `cloud1`, `cloud2`, `Grass` (group `blocks`), `Walls` (group `walls`), `Blocks` (group `blocks`), `PassThrough`, `Detection area`, `character` instance, `ball` instance, `ScoreLabel`, `HighScoreLabel`, `LoseLabel`, `Reset button`, `CoinsLabel`. |
| Shop | `Scenes/MainScenes/Shop.tscn` | Skin shop with six products. | `shop.gd` on root; `back_to_menu_shop.gd` on `Exit`. | `Background`, `Item1`–`Item6` (each with `Image` and `Price`), `CoinsLabel`, `Default`, `Exit`. |
| Settings | `Scenes/MainScenes/Settings.tscn` | Music/SFX sliders and fullscreen toggle. | `settings.gd` on root; `fullscreen_toggle.gd` on `FullscreenToggle`; `back_to_menu_settings.gd` on `Back`. | `Background`, `Title`, `MusicLabel`, `MusicSlider`, `SfxLabel`, `SfxSlider`, `FullscreenLabel`, `FullscreenToggle`, `Back`. |
| Character | `Scenes/MainScenes/character.tscn` | Player character, bat, hitbox, animations, swing SFX. | `character.gd`. | `AudioStreamPlayer2D` (bus `SFX`), `Bat1`, `Bat1/BatHitbox` (`Area2D`, mask 32), `AnimationPlayer` (crow fly), `Polygon2D` (crow sprite), `Skeleton2D`, `CollisionShape2D` (capsule), `AnimationPlayer2` (bat swing). |
| Ball | `Scenes/MainScenes/ball.tscn` | Ball body, sprite, bounce animation. | `ball.gd`. | Root `CharacterBody2D` (group `ball`, layer 32, mask 6), `Sprite2D`, `CollisionShape2D`, `ball` child node, `AnimationPlayer` (`Bounce`). |
| MusicPlayer | `Scenes/MusicPlayer.tscn` | Autoload music player. | `music_player.gd`. | Root `AudioStreamPlayer` on bus `Music`; the script finds and loops a track at runtime. |

### Scene Flow

```text
menu.tscn (main scene, uid://d4mofrg08uyvg)
├── PLAY     -> game.tscn
├── SHOP     -> Shop.tscn     -> EXIT -> menu.tscn
├── SETTINGS -> Settings.tscn -> BACK -> menu.tscn
└── EXIT     -> quit the application

game.tscn
├── Esc / ui_cancel -> menu.tscn
└── lose -> Reset button -> reload game.tscn

menu.tscn
└── Esc / ui_cancel -> quit the application
```

All transitions use `get_tree().change_scene_to_file()` or `get_tree().reload_current_scene()`. There is no loading screen or fade transition. Shop and Settings do not handle `ui_cancel`; use their on-screen buttons to leave.

## Autoloads

Autoload order is defined in `project.godot`; the `*` prefix means the singleton is enabled.

| Order | Name | Path | Type | Responsibilities | Dependencies |
| --- | --- | --- | --- | --- | --- |
| 1 | `SavePaths` | `res://Scripts/save_paths.gd` | `Node` | Sets `dir` to the globalized `user://Saves` path, creates the directory, and returns save file paths. | None. |
| 2 | `AudioSettings` | `res://Scripts/audio_settings.gd` | `Node` | Holds `music_volume` / `sfx_volume`, loads `settings.cfg`, applies volumes to the `Music` and `SFX` buses, and saves after a 0.25 s debounce. | `SavePaths` for `settings.cfg`. |
| 3 | `MusicPlayer` | `res://Scenes/MusicPlayer.tscn` | `AudioStreamPlayer` | Finds a track in `res://Assets/Music`, enables looping, and plays it on the `Music` bus. | `default_bus_layout.tres` for the `Music` bus; relies on `AudioSettings` having applied bus volume first (autoload order). |
| 4 | `SkinData` | `res://Scripts/skin_data.gd` | `Node` | Builds the skin texture catalog and loads/saves owned and equipped skin numbers. | `SavePaths` in `load_skins()` and `save_skins()`. |

`SkinData._ready()` only builds the catalog. Menus, the character, and the shop call `SkinData.load_skins()` when they need persisted state.

## Scripts

| Script | Base / attached to | Responsibilities | Key functions / signals |
| --- | --- | --- | --- |
| `save_paths.gd` | `Node` (autoload) | Owns the save directory and file path helper. | `_init()` creates `user://Saves`; `file(file_name)` joins a name onto `dir`. |
| `audio_settings.gd` | `Node` (autoload) | Music/SFX volume state, bus application, `settings.cfg` load/save. | `set_music_volume()`, `set_sfx_volume()`, `_apply_bus()`, `_load_settings()`, `_save_settings()`; internal one-shot `Timer` (0.25 s). |
| `music_player.gd` | `AudioStreamPlayer` (autoload scene) | Finds and loops background music. | `_find_track()` checks `theme.ogg` / `theme.wav` / `theme.mp3`, then scans `res://Assets/Music`; `_enable_loop()` loops Ogg/MP3/WAV. |
| `skin_data.gd` | `Node` (autoload) | Skin catalog, ownership, equipment, and `skins.save` persistence. | `_build_catalog()`, `_scan_skins()`, `load_skins()`, `save_skins()`, `add_owned_skin()`, `is_owned()`, `is_equipped()`, `has_skin()`, `get_texture()`, `equip_skin()`, `_parse_skin_list()`, `_format_skin_list()`. |
| `menu.gd` | `Node2D` (menu root) | Loads equipped skins into the menu previews; `Esc` quits. | `_ready()` calls `SkinData.load_skins()` and sets `CrowPreview` / `BatPreview` textures; `_input()` handles `ui_cancel`. |
| `Play_button.gd` | `Button` | Menu → game. | `_ready()` connects `pressed`; `_on_pressed()` changes to `game.tscn`. |
| `shop_button.gd` | `Button` | Menu → Shop. | `_on_pressed()` changes to `Shop.tscn`. |
| `Settings_button.gd` | `Button` | Menu → Settings. | `_on_pressed()` changes to `Settings.tscn`. |
| `exit_button.gd` | `Button` | Quits the application. | `_on_pressed()` calls `get_tree().quit()`. |
| `game.gd` | `Node2D` (game root) | Score, coins, high score, lose state, HUD, `Esc` to menu. | Connects `$ball.hit_wall` to `_on_ball_hit_wall()` and `Detection area.body_entered` to `_on_detection_area_body_entered()`; `_award_coins()`, `_lose()`, `_load_coins()`, `_load_high_score()`, `_save_coins()`, `_save_high_score()`, `_input()`. |
| `character.gd` | `CharacterBody2D` | Horizontal movement, jetpack, swing animation, bat hit detection and deflection. | `_physics_process()`, `_try_hit_ball()`, `_input()` for `swing`, `_on_animation_finished()`; consts `SPEED`, `JUMP_VELOCITY`; exports `hit_speed_boost`, `max_ball_speed`. |
| `ball.gd` | `CharacterBody2D` | Ball movement, bouncing, wall signal, random deviation, visual spin. | Signal `hit_wall`; `_ready()` sets initial velocity; `_physics_process()` uses `move_and_collide()`, `velocity.bounce(normal)`, and emits `hit_wall` for the `walls` group. |
| `shop.gd` | `Node2D` (Shop root) | Builds shop item state, handles buy/equip, DEFAULT, coin display. | Iterates `Item1`–`Item6`; `_on_button_pressed()`, `check_if_buyable()`, `_on_default_button_pressed()`, `_update_item_status()`, `_refresh_statuses()`, `_load_coins()`, `_save_coins()`. |
| `settings.gd` | `Node2D` (Settings root) | Initializes sliders from `AudioSettings` and forwards changes. | `_on_music_changed()`, `_on_sfx_changed()`. |
| `reset_button.gd` | `Button` | Restarts the game after a loss. | `_on_pressed()` calls `get_tree().reload_current_scene()`. |
| `fullscreen_toggle.gd` | `CheckButton` | Switches between fullscreen and windowed mode. | `_toggled()` calls `DisplayServer.window_set_mode()`. Does not initialize the checkbox from the current window mode and does not save the choice. |
| `back_to_menu_settings.gd` | `Button` | Settings → menu. | `_on_pressed()` changes to `menu.tscn`. |
| `back_to_menu_shop.gd` | `Button` | Shop → menu. | `_on_pressed()` changes to `menu.tscn`. |

`game.gd`, `menu.gd`, and several button scripts contain empty `_process(delta)` stubs. `shop.gd` prints debug messages during normal use.

## Gameplay

### Loop and Formulas

**Character movement**

- Horizontal input: `Input.get_axis("left", "right")`.
- With input: `velocity.x = direction * 300.0` (`SPEED`).
- Without input: `velocity.x = move_toward(velocity.x, 0, 300.0)` per physics frame.
- Gravity is applied when `not is_on_floor()`.
- Jetpack: while `jatpack` is held, `velocity.y = -400.0` (`JUMP_VELOCITY`); on release, `velocity.y = 0`.
- The crow fly animation plays while `velocity.y != 0`; otherwise `AnimationPlayer` is paused. Its `speed_scale` is set to `2`.
- `move_and_slide()` applies the final movement.

**Bat swing and deflection**

1. `_input()` receives `swing`, plays `Swing.mp3`, plays the `batSwing` animation, sets `is_swinging = true` and `swing_hit = false`.
2. While `is_swinging` is true and `swing_hit` is false, `_try_hit_ball()` checks `$Bat1/BatHitbox.get_overlapping_bodies()`.
3. On the first body in the `ball` group:

   ```text
   outward       = normalize(ball.global_position - player.global_position)
   bat_direction = Vector2.RIGHT.rotated(Bat1.global_rotation)
   hit_direction = normalize(outward + bat_direction)   # fallback: outward
   ball.speed    = min(ball.speed + hit_speed_boost, max_ball_speed)
   ball.velocity = hit_direction * ball.speed
   swing_hit     = true                                # one hit per swing
   ```

4. When the `batSwing` animation finishes, `is_swinging` becomes false.

**Ball movement**

- `_ready()` sets `velocity = Vector2(1, -1).normalized() * speed` with `speed = 500.0`.
- Each physics frame: `move_and_collide(velocity * delta)`.
- On a collision:
  - Play the `Bounce` animation.
  - Reflect: `velocity = velocity.bounce(normal)`.
  - If the collider is in `walls`: emit `hit_wall`, flip `rotationx`, and rotate velocity by a random angle in `[-max_deviation_degrees, +max_deviation_degrees]` (scene value ±15 degrees).
  - If the collider is in `blocks`: keep the clean reflection, with no score and no random deviation.
  - Renormalize: `velocity = velocity.normalized() * speed`.
- The sprite spins by `rotationx` each physics frame while the ball is moving. This is frame-rate dependent (`rotationx` is not multiplied by `delta`).

**Scoring, coins, and high score**

`game.gd` handles the ball's `hit_wall` signal:

```text
if has_lost: return
coins += clampi(1 + score / 10, 1, 5)   # integer division, before score increments
score += 1
if score > high_score:
    high_score = score
    save high_score.save
refresh labels
```

Because the coin award runs before the score increments, the first hit awards 1 coin; the award becomes 2 when the pre-hit score is 10, 3 at 20, 4 at 30, and reaches the cap of 5 at 40 or more. `coins.save` is written on every scoring hit.

**Losing and resetting**

- The left `Detection area` (`Area2D`, mask 32) detects a body in the `ball` group.
- `_lose()` sets `has_lost = true`, resets `score` to 0, shows `LoseLabel` and `Reset button`, sets the ball's velocity to `Vector2.ZERO`, and disables the ball's physics processing.
- The high score and coins are not reset. Post-loss `hit_wall` signals are ignored.
- `Reset` reloads the current scene, which creates a fresh ball and loads the saved coins and high score.
- There is no win condition.

### Collision Layers and Masks

Physics layer bit values: layer 1 = 1, layer 2 = 2, layer 3 = 4, layer 4 = 8, layer 5 = 16, layer 6 = 32. `project.godot` names `2d_render/layer_2` as "Walls" and `2d_render/layer_3` as "Blocks"; those are render-layer names, not physics-layer names.

| Node | Physics layer | Collision mask | Groups | Behavior |
| --- | --- | --- | --- | --- |
| Player (`character` root) | 1 (default) | 14 (2 + 4 + 8) | — | Collides with Walls, Blocks, and PassThrough. The ball does not collide with the player body. |
| `Grass` (`StaticBody2D`) | 4 | 1 (default) | `blocks` | Floor. Ball bounces cleanly; no score. |
| `Walls` (`StaticBody2D`) | 2 | 1 (default) | `walls` | Right wall. Ball emits `hit_wall` and scores. |
| `Blocks` (`StaticBody2D`) | 4 | 1 (default) | `blocks` | Ceiling. Ball bounces cleanly; no score. |
| `PassThrough` (`StaticBody2D`) | 8 | 1 (default) | — | Invisible player-only barriers at about `x = 56` and `x = 751`; the ball passes through. |
| `ball` (`CharacterBody2D`) | 32 | 6 (2 + 4) | `ball` | Collides with Walls and Blocks; detected by the bat and the left detection area. |
| `Bat1/BatHitbox` (`Area2D`) | 0 | 32 | — | Detects only the ball; does not collide physically. |
| `Detection area` (`Area2D`) | 1 (default) | 32 | — | Detects the ball when it leaves the left side and triggers the loss. |

The left side is not a wall: the ball passes through the `PassThrough` barrier (which only stops the player) and reaches the off-screen `Detection area`.

### Input Map

| Action | Events | Deadzone | Device | Used by |
| --- | --- | --- | --- | --- |
| `left` | `A` (physical 65), `Left Arrow` (physical 4194319) | 0.2 | -1 | `character.gd` |
| `right` | `D` (physical 68), `Right Arrow` (physical 4194321) | 0.2 | -1 | `character.gd` |
| `jatpack` | `W` (physical 87), `Up Arrow` (physical 4194320) | 0.2 | -1 | `character.gd` (note the internal spelling `jatpack`) |
| `down` | `S` (physical 83), `Down Arrow` (physical 4194322) | 0.2 | -1 | Unused |
| `swing` | `Space` (physical 32), left mouse button | 0.2 | -1 | `character.gd` |
| `Esc` | `Escape` (physical 4194305) | 0.2 | 16 | Unused |
| Built-in `ui_cancel` | `Escape` by default | — | — | `game.gd` (return to menu), `menu.gd` (quit) |

The scripts use the built-in `ui_cancel` action for `Esc` behavior. The custom `Esc` action in `project.godot` is not referenced by any script.

## Skins and Saves

### Skin Catalog Rules

- Indices are 0-based. The default skin for each kind is index 0.
- Bat skins are scanned in `res://Assets/AssetsFin/character/bat` and `res://Assets/AssetsFin/bat` with the prefix `batSkin`.
- Crow skins are scanned in `res://Assets/AssetsFin/character/crow` with the prefix `crowSkin`.
- A matching file must end in `.png`, and the text between the prefix and the extension must be a valid integer.
- Prefix and extension matching is case-sensitive: `batSkin1.png` and `crowSkin1.png` match; `BatSkin1.png` or `BATSKIN1.PNG` do not. This matters on case-sensitive filesystems and in exported PCKs.
- Non-matching files are ignored. For example, `AssetsFin/bat/bat1.png` is not a skin.
- `get_texture(kind, number)` returns the requested texture, or the skin 0 texture if the requested number is missing, or `null` if the catalog has no textures for that kind.
- `has_skin(kind, number)` reports whether a texture exists. The shop shows `N/A` and disables the item when this is false.
- The owned lists always contain 0. The equipped skin falls back to 0 when it is not owned or has no texture.
- `equip_skin()` only equips an owned skin; if its texture is missing, it equips skin 0 instead. It writes `skins.save` on success.

### Shop Catalog

The shop scene has six buttons with metadata. Prices are read from each `Price` label at runtime.

| Button | `ProductID` | `Kind` | Price | Displayed status |
| --- | --- | --- | --- | --- |
| `Item1` | 1 | `crow` | 100 | Price / `OWNED` / `EQUIPPED` |
| `Item2` | 2 | `crow` | 250 | Price / `OWNED` / `EQUIPPED` |
| `Item3` | 3 | `crow` | 500 | Price / `OWNED` / `EQUIPPED` |
| `Item4` | 1 | `bat` | 250 | Price / `OWNED` / `EQUIPPED` |
| `Item5` | 2 | `bat` | 500 | Price / `OWNED` / `EQUIPPED` |
| `Item6` | 3 | `bat` | 750 | Price / `OWNED` / `EQUIPPED` |

Clicking an unowned item with enough coins calls `check_if_buyable()`, which subtracts and saves the coins, then adds and equips the skin. Clicking an owned item equips it. `DEFAULT` equips skin 0 for both kinds without changing owned lists or coins. Products with `ProductID <= 0` are rejected by the click handler, so the shop does not sell skin 0; it is the free default.

### Save Formats

Location:

```text
%APPDATA%\Godot\app_userdata\Crow Smash\Saves
```

`SavePaths.dir = ProjectSettings.globalize_path("user://Saves")`, and `_init()` calls `DirAccess.make_dir_recursive_absolute(dir)`.

| File | Format | Produced by | Timing |
| --- | --- | --- | --- |
| `coins.save` | Decimal integer, no newline required, for example `150`. | `game.gd`, `shop.gd` | Every scoring hit; every shop purchase. |
| `high_score.save` | Decimal integer, for example `42`. | `game.gd` | Whenever the current score exceeds the stored high score. |
| `skins.save` | Four text lines: `BAT: ...`, `CROW: ...`, `EQ-BAT: N`, `EQ-CROW: N`. | `skin_data.gd` | On first `load_skins()` if the file is missing; on add, equip, and DEFAULT. |
| `settings.cfg` | `ConfigFile` with `[audio]` and float `music` / `sfx` values in 0.0-1.0. | `audio_settings.gd` | 0.25 s after the last `set_music_volume()` / `set_sfx_volume()` call. |

Example `skins.save`:

```text
BAT: 0, 1, 2
CROW: 0, 3
EQ-BAT: 1
EQ-CROW: 0
```

- `BAT` / `CROW` are comma-separated owned skin numbers. Parsing ignores empty entries, whitespace, and non-integers. The game adds new skins with `add_owned_skin()`, which appends and sorts the list. On load, 0 is forced into each list if missing (and the list is sorted at that point).
- `EQ-BAT` / `EQ-CROW` are equipped skin numbers. They must be owned and have a texture; otherwise they fall back to 0 on load.
- Unknown keys and lines without `:` are ignored.

Example `settings.cfg`:

```ini
[audio]

music=0.7
sfx=0.8
```

Load behavior: missing or unreadable files keep the current defaults (coins `0`, high score `0`, skins `0`, music `0.7`, SFX `0.8`). File contents are parsed with `int(...)` or `float(...)`; malformed values generally become `0`.

Save behavior and caveats:

- Writes use `FileAccess.open(..., FileAccess.WRITE)` or `ConfigFile.save()` directly at the final path. They are not atomic and do not use a temporary file or backup.
- Several write failures are not surfaced: `game.gd` and `shop.gd` ignore a `null` file handle, `audio_settings.gd` ignores the `ConfigFile.save()` result, and `save_paths.gd` ignores `make_dir_recursive_absolute()` failure.
- The shop deducts and saves coins before writing skin ownership, so an I/O failure or crash in between can spend coins without granting the skin.
- `settings.cfg` is saved after a 0.25 s debounce; there is no flush on exit, so quitting within that window can lose the last volume change.
- `skins.save` is created on the first `SkinData.load_skins()` when it is missing.
- The repository `Saves/` files (`coins.save`, `high_score.save`, `settings.cfg`) are stale samples and are never read at runtime. The repository does not track a `skins.save`.

**Migration note.** `config/name="Crow Smash"` determines Godot's default `user://` folder. The previous name `Bounc back template` used `%APPDATA%\Godot\app_userdata\Bounc back template\Saves`; a build briefly named `Bounc back` used `%APPDATA%\Godot\app_userdata\Bounc back\Saves`. The current code has no migration, so old files are ignored. To migrate manually, close the game and copy `coins.save`, `high_score.save`, `skins.save`, and `settings.cfg` from the old folder to the new `Crow Smash\Saves` folder.

## Audio and Settings

`default_bus_layout.tres` defines three buses:

| Bus | Sends to | Used by |
| --- | --- | --- |
| `Master` | — | Final output. |
| `Music` | `Master` | `MusicPlayer` autoload. |
| `SFX` | `Master` | `character.tscn` swing `AudioStreamPlayer2D`. |

Behavior:

- `MusicPlayer` is an `AudioStreamPlayer` on the `Music` bus. It looks for `res://Assets/Music/theme.ogg`, `theme.wav`, or `theme.mp3`, then falls back to the first audio file in that directory. The current track is `BackgroundMusic1.mp3`. It enables looping and calls `play()`.
- `AudioSettings` defaults to `music_volume = 0.7` and `sfx_volume = 0.8`. `_apply_bus()` uses `linear_to_db(max(value, 0.001))` and mutes the bus when `value <= 0.001`.
- The Settings scene sets each `HSlider` to `AudioSettings` value × 100 and forwards `value / 100.0` on `value_changed`. Audio changes apply immediately to the buses.
- Only audio is stored in `settings.cfg`. The fullscreen checkbox calls `DisplayServer.window_set_mode(WINDOW_MODE_FULLSCREEN)` or `WINDOW_MODE_WINDOWED` but is not initialized from the current mode and is not saved. Fullscreen therefore resets to windowed after restart, and re-entering Settings while fullscreen shows an unchecked box (known issues).

## Tuning

The script value is the value in GDScript. The scene value is set on the node in the `.tscn` and takes precedence when present.

| Setting | Location | Script value | Scene value | Effective value |
| --- | --- | --- | --- | --- |
| `SPEED` | `Scripts/character.gd` | `300.0` | — | `300.0` |
| `JUMP_VELOCITY` | `Scripts/character.gd` | `-400.0` | — | `-400.0` |
| `hit_speed_boost` | `Scripts/character.gd` export | `100.0` | `10.0` in `character.tscn` | `10.0` |
| `max_ball_speed` | `Scripts/character.gd` export | `900.0` | `800.0` in `character.tscn` | `800.0` |
| `speed` | `Scripts/ball.gd` (plain var) | `500.0` | — | `500.0` |
| `max_deviation_degrees` | `Scripts/ball.gd` export | `5.0` | `15.0` in `ball.tscn` | `15.0` |
| `rotationx` | `Scripts/ball.gd` (plain var) | `-0.1` | — | `-0.1` (per physics frame) |
| `AnimationPlayer.speed_scale` | `Scripts/character.gd` | `2` (set in `_ready()`) | — | Crow fly plays at 2× speed. |
| `batSwing` length | `character.tscn` | — | `0.23` s | Bat swing duration. |
| `Bounce` animation length | `ball.tscn` | — | `0.1` s | Sprite scale goes `0.6316` → `0.8` → `0.6`. |
| Player collision capsule | `character.tscn` | — | radius `24.0`, height `68.0` | Character collider. |
| Ball sprite / collider scales | `ball.tscn` | — | sprite `0.63158685`; collider `3.196805` | Placeholder visuals; collider is larger than the drawn ball. |

Notes:

- Change `hit_speed_boost` and `max_ball_speed` on the `character` node in `character.tscn` (or the exported properties in the editor). The script defaults are not the effective gameplay values.
- `speed` is not exported; edit `ball.gd` to change the base ball speed. Bat boosts increase the current ball's `speed` for the rest of the run; Reset reloads the scene and creates a fresh ball at `500.0`.
- `max_deviation_degrees` is overridden to 15 in `ball.tscn`; edit the ball instance to tune wall randomness.
- `rotationx` is applied once per physics frame, so the visual spin speed depends on the frame rate.
- Because the ball renormalizes to `speed` after every collision, changing `speed` changes the maintained ball speed after a bat hit.

## Export and Assets

### Export Settings

`export_presets.cfg` contains one runnable preset:

| Setting | Value |
| --- | --- |
| Preset name | `Windows Desktop` |
| Platform | `Windows Desktop` |
| Architecture | `x86_64` |
| Export path | `../Builds/Build2/Crow_Smash.exe` |
| Export filter | `all_resources` |
| Embedded PCK | `false` (`binary_format/embed_pck=false`) |
| Script export mode | `2` |
| S3TC/BPTC textures | enabled |
| ETC2/ASTC textures | disabled |
| Custom templates | none |
| Code signing | disabled |

Export steps:

1. Install the Godot 4.7 export templates with **Editor > Manage Export Templates**.
2. Open **Project > Export** and select **Windows Desktop**.
3. Export to the configured path. It resolves to a `Builds/Build2` folder next to the repository, not inside it.

With `embed_pck` disabled, the export produces `Crow_Smash.exe` plus a `.pck` file. Keep them together. The build is unsigned, so Windows SmartScreen may warn on first launch.

### UIDs and Import Files

- The main scene is referenced by UID `uid://d4mofrg08uyvg` in `project.godot`; that UID belongs to `Scenes/MainScenes/menu.tscn`.
- Scene headers and `ext_resource` entries use UIDs alongside resource paths. Scripts have tracked `.uid` sidecars. Godot uses these to keep references stable when files are moved or renamed in the editor.
- Skin and music discovery uses hard-coded directory paths and filename patterns in GDScript, not UIDs. Moving skin files, changing the `batSkin` / `crowSkin` prefixes, or changing the `.png` extension can break the catalog even if Godot can still open the asset.
- `.import` files store import settings for textures, audio, and fonts. They are tracked in Git. Reimport assets through the editor rather than editing or deleting the sidecars manually.
- `.godot/` is the generated import cache; it is ignored by Git and can be regenerated.
- Skin filenames are matched case-sensitively in code. Use exactly `batSkin<number>.png` and `crowSkin<number>.png`; the number must be a valid integer.
- `Assets/AssetsFin/bat/bat1.png` is used as a temporary texture in `Shop.tscn` and is replaced at runtime; it is not a purchasable skin because it does not match the skin prefix pattern.
- `Assets/placeholders/` mostly contains older stand-in art that current scenes do not use, with the exception of `icon.svg`, which is the project icon. The current game art lives under `Assets/AssetsFin/` and `Assets/Backgrounds/demo01_PixelSky_1920x1080.png`.
- `Assets/Fonts/advanced_pixel_lcd-7.fon` is not imported or referenced by the current scenes.
- The placeholder art has intentionally mismatched visual and collision scales (for example, the ball sprite is smaller than its collider, and the bat hitbox has unusual transforms). This is a presentation limitation, not a gameplay bug.

## Known Limitations

See [known_bugs.md](known_bugs.md) for the full review snapshot, including severity, reproduction steps, and suggested fixes. The main current issues are:

- The project rename moved Godot's `user://` folder, so saves from the old `Bounc back template` (or brief `Bounc back`) name are not migrated automatically.
- Audio volume changes can be lost if the game exits within the 0.25 s save debounce.
- The tracked repository `Saves/` files are not used at runtime, and older `res://Saves` data is never migrated.
- The fullscreen checkbox is not synchronized with the current window mode on scene re-entry, and fullscreen is not persisted.
- Save writes are non-atomic and unchecked, and shop purchases can deduct coins before skin ownership is safely written.

There is also no win condition, Shop and Settings do not handle `ui_cancel`, and the ball's visual spin is frame-rate dependent.
