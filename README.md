# Crow Smash

> **Game Jam:** Built at **Haven Prague** — a **Hack Club Haven** game jam — on **14–15 November 2026**.
> Event page: [haven.hackclub.com/prague](https://haven.hackclub.com/prague)

## About the Game

Crow Smash is a small 2D arcade game made with Godot 4.7. You control a crow with a jetpack and a bat: keep the ball in play, swing it into the right wall for points and coins, and spend the coins on crow and bat skins.

## Documentation

- [Project structure](structure.md) — scenes, scripts, autoloads, gameplay formulas, saves, tuning, and export.
- [Known bugs](known_bugs.md) — current review snapshot with severity, reproduction steps, and suggested fixes.

## For Players

### Download & Play

#### You can play it on [Itch.io here.](https://multiplayerjake.itch.io/crow-smash)

1. Open the [latest GitHub release](https://github.com/MultiplayerJake/GameJame-Juno/releases/latest).
2. Download the Windows build and extract it if it is an archive.
3. Run `Crow_Smash.exe`. There is no installer.

The Windows build is unsigned, so SmartScreen may show "Windows protected your PC". Choose **More info**, then **Run anyway** to start the game.

If the download also contains a `.pck` file, keep it in the same folder as `Crow_Smash.exe`.

### How to Play

Keep the ball from leaving the left side of the screen. Swing the bat to send the ball toward the right wall; every hit on the right wall adds 1 point and awards coins. The run ends when the ball leaves on the left.

| Action | Input |
| --- | --- |
| Move left | `A` or `Left Arrow` |
| Move right | `D` or `Right Arrow` |
| Jetpack (hold) | `W` or `Up Arrow` |
| Swing bat | `Space` or `Left Mouse Button` |
| Back to menu / quit | `Esc` |

`Esc` returns to the menu from the game and quits the application from the menu. The Shop and Settings screens do not use `Esc`; use their on-screen **EXIT** / **BACK** buttons. `S` / `Down Arrow` is mapped but not used by the current build.

Scoring and the run:

- Each hit on the right wall adds 1 point (`Score: N`).
- Each right-wall hit also awards `clampi(1 + score / 10, 1, 5)` coins, where `score` is the score before that hit's +1 and `/` is integer division. The first hit awards 1 coin; the award rises to 2 at a pre-hit score of 10, 3 at 20, 4 at 30, and 5 at 40 or more.
- Your high score is saved and shown on the HUD; it persists across runs.
- If the ball leaves the left side, the run ends, "You Lose!" appears, and the **Reset** button is shown. Reset starts a fresh run; coins, high score, and skins are kept.
- There is no win condition; play for a higher score and more coins.

### Shop & Skins

The Shop sells three crow skins and three bat skins. Skin 0 is the default skin for each kind, is owned from the start, and is not sold.

| Item | Kind | Skin | Price |
| --- | --- | --- | --- |
| Crow 1 | `crow` | 1 | 100 |
| Crow 2 | `crow` | 2 | 250 |
| Crow 3 | `crow` | 3 | 500 |
| Bat 1 | `bat` | 1 | 250 |
| Bat 2 | `bat` | 2 | 500 |
| Bat 3 | `bat` | 3 | 750 |

Click an item to buy it when you have enough coins; a purchased skin is equipped immediately. Click an owned skin to equip it. The **DEFAULT** button equips skin 0 for both kinds without spending coins. Coins, ownership, and the equipped skins persist between runs and restarts.

The item label shows `EQUIPPED`, `OWNED`, or the price. If a skin texture is missing, the item shows `N/A` and is disabled; all six current items have textures.

### Settings

- **Music** and **SFX** sliders adjust the two audio buses. Values apply immediately.
- **Fullscreen** toggles the current window mode.
- Fullscreen is not remembered after restart; the game starts windowed again. This is a known limitation.
- Audio volumes are saved automatically; the fullscreen choice is not saved.

### Saving

The game saves automatically; there is no manual save button.

Save folder (Godot `user://Saves`):

```text
%APPDATA%\Godot\app_userdata\Crow Smash\Saves
```

| File | What it stores |
| --- | --- |
| `coins.save` | Current coin balance (plain integer text) |
| `high_score.save` | Best score (plain integer text) |
| `skins.save` | Owned skin numbers and equipped skin numbers |
| `settings.cfg` | Music and SFX volume values |

Coins are written after each scoring hit and after a shop purchase. The high score is written when it is beaten. Skins are written on first load (if the file is missing), on purchase, and on equip; **DEFAULT** equips skin 0 for both kinds. Audio settings are written 0.25 seconds after the last slider change, so quitting within that window can lose the last volume change (see the known bugs below).

Deleting the save folder resets coins, high score, owned/equipped skins, and audio settings to their defaults. The `Saves/` folder in the repository is **not** used at runtime; the tracked files there are stale samples. For save data, the game only reads and writes the user-data folder shown above.

**Migrating from "Bounc back":** the project was renamed from `Bounc back template` (and briefly `Bounc back`) to `Crow Smash`, which changed Godot's `user://` folder. The current build does **not** migrate automatically. To keep old progress, close the game and copy `coins.save`, `high_score.save`, `skins.save`, and `settings.cfg` from:

```text
%APPDATA%\Godot\app_userdata\Bounc back template\Saves
```

If you previously ran a build named `Bounc back`, also check:

```text
%APPDATA%\Godot\app_userdata\Bounc back\Saves
```

Copy the newest copies of those four files to:

```text
%APPDATA%\Godot\app_userdata\Crow Smash\Saves
```

Create the new folder if it does not exist. Do not copy the repository's `Saves/` files; they are not live data.

## For Programmers

### Engine & Setup

- **Engine:** Godot 4.7.x. The project was tested with Godot 4.7.2. It uses the Forward Plus renderer and the D3D12 rendering driver on Windows.
- **Download:** [Godot for Windows](https://godotengine.org/download/windows/)
- **No plugins or external libraries** are used; the project is GDScript plus built-in Godot nodes.

**Run from the editor:**

1. Open the Godot 4.7 Project Manager.
2. Choose **Import** and select `project.godot` in this folder.
3. Press **F5**. The main scene is `Scenes/MainScenes/menu.tscn` (`uid://d4mofrg08uyvg`).

**Run from the command line:**

```bash
godot --path "C:\path\to\GameJame-Juno"
```

Use the full path to your Godot 4.7 executable if `godot` is not on `PATH`.

**Export a Windows build:**

1. Install export templates with **Editor > Manage Export Templates**.
2. Open **Project > Export** and select the **Windows Desktop** preset.
3. Export. The preset writes `../Builds/Build2/Crow_Smash.exe` relative to the project folder, so the output lands in a sibling `Builds/Build2` directory outside this repository. Because `embed_pck` is disabled, the export also produces a `.pck` file; keep it next to the executable.

### Project Structure

```text
GameJame-Juno/
├── project.godot             # Main scene, input map, autoloads, renderer
├── export_presets.cfg        # Windows Desktop preset
├── default_bus_layout.tres   # Master / Music / SFX buses
├── README.md
├── structure.md
├── known_bugs.md
├── Saves/                    # Tracked samples; not read at runtime
├── Scenes/
│   ├── MusicPlayer.tscn      # Autoload music player
│   └── MainScenes/           # menu, game, Shop, Settings, character, ball
├── Scripts/                  # 18 GDScript files
└── Assets/                   # Art, fonts, music, SFX, animation
```

See [structure.md](structure.md) for the full directory tree, scene and script tables, scene flow, autoload dependencies, collision and input maps, gameplay formulas, save formats, audio buses, tuning values, and export/import notes.

### How It Works

**Scene flow.** `menu.tscn` is the main scene. **PLAY** opens `game.tscn`; **SHOP** opens `Shop.tscn`; **SETTINGS** opens `Settings.tscn`; **EXIT** quits. Shop's **EXIT** and Settings' **BACK** return to the menu. In the game, `ui_cancel` (`Esc`) returns to the menu. After a loss, **Reset** reloads `game.tscn`. All transitions use `get_tree().change_scene_to_file()`.

**Autoloads.**

| Autoload | Path | Role |
| --- | --- | --- |
| `SavePaths` | `res://Scripts/save_paths.gd` | Resolves `user://Saves`, creates the folder, and returns file paths. |
| `AudioSettings` | `res://Scripts/audio_settings.gd` | Loads/applies Music and SFX volumes and saves `settings.cfg` after a 0.25 s debounce. |
| `MusicPlayer` | `res://Scenes/MusicPlayer.tscn` | Finds a track in `res://Assets/Music`, loops it, and plays it on the `Music` bus. |
| `SkinData` | `res://Scripts/skin_data.gd` | Builds the skin catalog and handles owned/equipped skin state and `skins.save`. |

**Gameplay loop.**

- `character.gd` moves the player at `SPEED = 300`, applies `JUMP_VELOCITY = -400` while the jetpack is held, and plays the crow fly animation. The swing input starts a bat animation and the bat hitbox polls for the ball while swinging.
- On a bat hit, the outgoing direction is `(outward + bat_direction).normalized()`, where `outward` points from the player to the ball and `bat_direction` is `Vector2.RIGHT.rotated(Bat1.global_rotation)`. Ball speed increases by the scene value `hit_speed_boost = 10`, capped at the scene value `max_ball_speed = 800`. Only the first ball hit per swing is applied.
- `ball.gd` starts at speed `500` in the up-right direction, uses `move_and_collide()`, reflects with `velocity.bounce(normal)`, and renormalizes to `speed` after a bounce. Hitting a body in the `walls` group emits `hit_wall` and adds a random deviation of up to ±15 degrees; `blocks` bounce cleanly.
- `game.gd` connects `ball.hit_wall`. Each hit awards coins, adds 1 to the score, saves a new high score, and refreshes the HUD. If the ball enters the left `Detection area`, the run ends: the ball's velocity is zeroed, physics is disabled, and the lose label and Reset button appear.
- Reset calls `get_tree().reload_current_scene()`. Coins and high score are loaded from disk on the next game start.

**Shop and skin catalog.** Skin indices are 0-based. `SkinData` scans `res://Assets/AssetsFin/character/bat` and `res://Assets/AssetsFin/bat` for `batSkin<number>.png`, and `res://Assets/AssetsFin/character/crow` for `crowSkin<number>.png`. Prefixes and the `.png` extension are matched case-sensitively. Missing files are ignored. `get_texture()` falls back to skin 0, and equipped skins fall back to 0 when they are not owned or have no texture. Skin 0 is always in the owned list. The shop items carry `ProductID` and `Kind` metadata; prices come from each item's `Price` label.

**Audio buses.** `default_bus_layout.tres` defines `Master` with `Music` and `SFX` sending to it. `MusicPlayer` plays on `Music`; the swing sound uses `SFX`. `AudioSettings` converts the 0.0-1.0 values to bus volume in dB and mutes a bus at or below 0.001. Defaults are music `0.7` and SFX `0.8`.

### Save Files

The exact runtime path is:

```text
%APPDATA%\Godot\app_userdata\Crow Smash\Saves
```

`SavePaths.dir` is `ProjectSettings.globalize_path("user://Saves")`. The folder is created on startup.

| File | Format | Written when |
| --- | --- | --- |
| `coins.save` | Decimal integer as text, for example `150` | After each scoring hit and after a shop purchase. |
| `high_score.save` | Decimal integer as text, for example `42` | When the current score beats the stored high score. |
| `skins.save` | Four text lines: `BAT: ...`, `CROW: ...`, `EQ-BAT: N`, `EQ-CROW: N` | On first load if missing; on purchase, equip, and DEFAULT. |
| `settings.cfg` | ConfigFile with an `[audio]` section and `music` / `sfx` floats | 0.25 s after the last Music or SFX slider change. |

Example `skins.save`:

```text
BAT: 0, 1, 2
CROW: 0, 3
EQ-BAT: 1
EQ-CROW: 0
```

Example `settings.cfg`:

```ini
[audio]

music=0.7
sfx=0.8
```

The files are plain text with no version field, and writes use `FileAccess.WRITE` directly. The current code does not recover from partial writes or report most I/O failures (see the known bugs). The repository `Saves/` folder is not the runtime location and is not read.

**Migration.** The rename from `Bounc back template` (and briefly `Bounc back`) changed Godot's default `user://` root, so old saves live under `%APPDATA%\Godot\app_userdata\Bounc back template\Saves` (or `...\Bounc back\Saves`). No migration code runs. Close the game and copy the four files into the new `Crow Smash\Saves` folder to keep progress.

### Known Bugs

The current tree has known issues. These are not fixed by this documentation; see [known_bugs.md](known_bugs.md) for reproduction steps and suggested fixes.

- **The project rename moves `user://` and orphans existing saves.** Old coins, high score, skins, and settings in the `Bounc back template` (or brief `Bounc back`) folder are ignored until copied manually.
- **Audio changes can be lost on exit.** `settings.cfg` is written only after a 0.25 s debounce, so quitting or closing the window before the timer fires drops the last volume change.
- **The tracked `Saves/` files are not the files the game reads.** Runtime saves go to `user://Saves`; repository files and older `res://Saves` data are stale and never migrated.
- **The fullscreen checkbox gets out of sync.** Re-entering Settings while the window is already fullscreen shows an unchecked box, so the first click appears to do nothing. Fullscreen is also not persisted across restarts.
- **Save writes are non-atomic and unchecked, and shop purchases are not transactional.** A failed write or a crash can silently lose coins, high score, skins, or settings; a purchase deducts coins before skin ownership is safely persisted.
