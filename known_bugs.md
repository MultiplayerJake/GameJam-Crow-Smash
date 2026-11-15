# Known Bugs — Review Snapshot

**Commit reviewed:** `6d7e88b` (`Merge pull request #38`) plus one intentional uncommitted working-tree change: `project.godot:13` now sets `config/name="Crow Smash"`.
**Review date:** 2026-11-15
**Engine used for verification:** Godot `4.7.2.stable.mono.official` (Windows x86_64).
**Scope:** Current working tree; all files under `Scripts/`, `Scenes/`, `Assets/` references, `project.godot`, `export_presets.cfg`, `Saves/`, and `README.md`. Findings were checked by reading the code and by running headless test scenes from a temporary copy of the project. No source files were modified.
**This is a review snapshot, not a fix.** The entries below describe the current tree only.

**Counts:** 1 critical, 4 warnings, 2 suggestions (SUG-2 resolved by the documentation update; the other findings are unchanged).

## Severity definitions

| Severity | Meaning |
| --- | --- |
| **Critical** | Data loss, a crash, a blocker, or a regression that breaks existing users. Fix before shipping. |
| **Warning** | Real behavior bug or a data-loss risk under plausible conditions. Should be fixed. |
| **Suggestion** | Lower-impact correctness/quality/documentation issue. Nice to fix. |

## Top issues

- **The `config/name` rename moves Godot's `user://` directory**, so existing coins, high score, owned/equipped skins, and audio settings in the old `Bounc back template` (or brief `Bounc back`) folder are ignored after the update.
- **Audio volume changes can be lost on exit**: settings are written only after a 0.25 s debounce, so quitting/closing the game before the timer fires drops the change.
- **The tracked `Saves/` files are not the files the game reads.** Runtime saves go to `user://Saves`; the repository files (and older `res://Saves` data) are stale/never migrated.
- **The fullscreen checkbox gets out of sync** when Settings is re-entered while the window is already fullscreen, making the toggle appear broken.
- **Save writes are non-atomic and unchecked**, and a shop purchase commits the coin deduction before skin ownership is safely persisted, so I/O failure or a crash can lose coins/progress silently.

## Findings table

| ID | Severity | Area | File:line | One-line summary |
| --- | --- | --- | --- | --- |
| CRIT-1 | Critical | Save/load, data loss | `project.godot:13`, `Scripts/save_paths.gd:3-9` | Project rename changes the `user://` root; all existing saves become unreachable. |
| WARN-1 | Warning | Audio/settings, data loss | `Scripts/audio_settings.gd:4,26,32,57-61` | Volume changes can be lost if the app exits before the 250 ms save debounce fires. |
| WARN-2 | Warning | Save/load, repository hygiene | `Scripts/save_paths.gd:3`, `Saves/coins.save`, `Saves/high_score.save`, `Saves/settings.cfg`, `.gitignore:1-3` | Repository `Saves/*` files are stale; legacy `res://Saves` data is not migrated and is never read. |
| WARN-3 | Warning | Settings/UI | `Scripts/fullscreen_toggle.gd:5-20`, `Scenes/MainScenes/Settings.tscn:78-83` | Fullscreen checkbox does not reflect the actual window mode on scene re-entry; first click appears to do nothing. |
| WARN-4 | Warning | Save integrity, shop purchase | `Scripts/game.gd:46-55`, `Scripts/shop.gd:149-167`, `Scripts/skin_data.gd:114-124`, `Scripts/audio_settings.gd:57-61` | Save writes are in-place/unchecked; coins are committed before skin ownership, so write failure can lose progress. |
| SUG-1 | Suggestion | Ball presentation | `Scripts/ball.gd:41-42` | Ball spin is frame-rate dependent because rotation is not multiplied by `delta`. |
| SUG-2 | Suggestion | Documentation | `README.md:1,108,151-156,167-176` | README is stale: old project name, no shop/skins/settings docs, wrong tuning values, outdated temp-file note. **Resolved** by the docs rewrite. |

---

## Detailed findings

### [CRIT-1] Project rename changes `user://` and orphans all existing save data

**File:** `project.godot:13`, `Scripts/save_paths.gd:3-9`

**Symptom:** The working tree changes `application/config/name` from `Bounc back template` to `Crow Smash`. Godot derives the default `user://` directory from that name. Since all persistence code goes through `SavePaths.file(...)`, which resolves `user://Saves`, the game now reads and writes a brand-new folder:

- Old: `%APPDATA%\Godot\app_userdata\Bounc back template\Saves\`
- New: `%APPDATA%\Godot\app_userdata\Crow Smash\Saves\`

No migration exists, so `coins.save`, `high_score.save`, `skins.save`, and `settings.cfg` in the old folder are never read. If a build was run with the intermediate `Bounc back` name, its `...\Bounc back\Saves\` folder may also exist.

**Reproduction (verified headless):**
1. Place a `coins.save` containing `999` and a `high_score.save` containing `777` in the old `Bounc back template\Saves` user-data folder.
2. Run the current project (`config/name="Crow Smash"`).
3. Load the game scene.

**Expected:** Existing coins/high score/skins/audio settings remain available, or are migrated on first launch.

**Actual:** `SavePaths.dir` resolves to `...\Crow Smash\Saves`; the game loaded `coins=0`, `high_score=0`. The old `999`/`777` files were still present in the old folder but ignored.

**Impact:** Every existing player loses visible progress and settings after the rename: coin balance, high score, purchased/equipped skins, and audio volume. This is a silent data-loss regression.

**Suggested fix:**
- Add a one-time migration on startup: if the new folder is empty/missing, copy the old `app_userdata\Bounc back template\Saves` contents into the new location before any load, then mark/rename the migration source.
- Or keep the storage location stable forever via `application/config/use_custom_user_dir` + a fixed `application/config/custom_user_dir_name`, and set the window title separately (for example with `DisplayServer.window_set_title("Crow Smash")`).
- Do not rely on `config/name` for save-path stability.

---

### [WARN-1] Audio volume changes can be lost when quitting before the debounce timer fires

**File:** `Scripts/audio_settings.gd:4,26,32,57-61`

**Symptom:** `set_music_volume()` / `set_sfx_volume()` only start a 250 ms one-shot timer; `_save_settings()` runs on `timeout`. If the process exits before that timeout, the in-memory value is applied to the audio bus but never written to `settings.cfg`.

**Reproduction (verified headless):**
1. Start with a clean user-data folder.
2. Call/perform a volume change (`AudioSettings.set_music_volume(0.123)`), then quit immediately in the same frame.
3. Relaunch and read `AudioSettings.music_volume` / `settings.cfg`.

**Expected:** `0.123` is persisted, or at minimum saved at shutdown.

**Actual:** After relaunch, `music_volume` was `0.7` (the default) and `settings.cfg` did not exist. The same applies if the player closes the window within 250 ms of moving a slider.

**Impact:** The last volume change is silently lost. This is especially visible for a first-time settings save or for players who adjust volume and immediately close the game.

**Suggested fix:**
- Keep the debounce for slider dragging, but flush with `_save_settings()` in `_exit_tree()` and/or handle `NOTIFICATION_WM_CLOSE_REQUEST` / `NOTIFICATION_WM_GO_BACK_REQUEST` before quitting.
- Alternatively save immediately on each `value_changed`; the config file is tiny, so the write cost is negligible.
- Check the return value of `ConfigFile.save()` and log/notify on failure.

---

### [WARN-2] Repository `Saves/*` files are stale; legacy `res://Saves` data is never migrated

**File:** `Scripts/save_paths.gd:3`, `Saves/coins.save`, `Saves/high_score.save`, `Saves/settings.cfg`, `.gitignore:1-3`

**Symptom:** The repository still tracks `Saves/coins.save`, `Saves/high_score.save`, and `Saves/settings.cfg`, and `.gitignore` does not ignore `Saves/`. However, the current code only reads/writes `user://Saves` via `SavePaths`. Editing the tracked files has no effect on the game, and older builds that used `res://Saves` (before commit `b025ceb`) left progress in a location the current code never imports.

**Reproduction (verified):**
1. Inspect `SavePaths.dir` in a running project: it is under `%APPDATA%\Godot\app_userdata\Crow Smash\Saves`, not `res://Saves`.
2. Change `Saves/coins.save` in the repository to `9999`.
3. Launch the shop/game with a clean user-data folder.

**Expected:** One documented, authoritative save location; either the repository files are used, or they are clearly templates/test fixtures and excluded from version control.

**Actual:** The game shows `Coins: 0` from the user-data file; the repository file is ignored. Older `res://Saves` progress is likewise ignored.

**Impact:** Developers/players can “lose” progress or waste time editing files that the game never reads. It also risks accidentally committing user-specific save data.

**Suggested fix:**
- Delete the tracked `Saves/*` files and add `Saves/` to `.gitignore`, or move them to a clearly named test/fixture directory that is not the real save location.
- Add a one-time migration from the legacy `res://Saves` files (and document that exported builds cannot write to `res://`).
- Document the actual user-data path in the README.

---

### [WARN-3] Fullscreen checkbox does not reflect the actual window mode after re-entering Settings

**File:** `Scripts/fullscreen_toggle.gd:5-20`, `Scenes/MainScenes/Settings.tscn:78-83`

**Symptom:** `fullscreen_toggle.gd` connects `toggled` in `_ready()`, but never initializes the `CheckButton.button_pressed` state from `DisplayServer.window_get_mode()`. `Settings.tscn` has no saved `button_pressed=true` either. Since Settings is a separate scene loaded with `change_scene_to_file`, re-entering it recreates the checkbox as unchecked even when the window is still fullscreen.

**Reproduction:**
1. Start windowed.
2. Open Settings and turn Fullscreen on (checkbox becomes checked; window becomes fullscreen).
3. Press BACK to the menu.
4. Open Settings again while still fullscreen.

**Expected:** The checkbox is checked when the window is fullscreen; one click turns fullscreen off.

**Actual:** The checkbox is unchecked although the window is still fullscreen. Clicking it once calls `_toggled(true)` and sets fullscreen again (no visible change); the user must click a second time to go windowed.

**Verification:** Instantiating `Settings.tscn` and reading `FullscreenToggle.button_pressed` returns `false`; the script has no state-read code. (The headless window backend cannot change real window mode, but the missing synchronization is evident from the script and scene.)

**Impact:** The toggle appears broken/out of sync, and exiting fullscreen takes an extra click. A user may think the first click did nothing.

**Suggested fix:**
- In `_ready()`, set the checkbox with `set_pressed_no_signal(...)` based on `DisplayServer.window_get_mode()` (treat `WINDOW_MODE_FULLSCREEN` and `WINDOW_MODE_EXCLUSIVE_FULLSCREEN` as on), then connect `toggled`.
- Optionally persist the fullscreen preference in `settings.cfg` and apply it at startup (otherwise it remains a known limitation).

---

### [WARN-4] Save writes are in-place/unchecked and the shop purchase is not transactional

**File:** `Scripts/game.gd:46-55`, `Scripts/shop.gd:149-167`, `Scripts/skin_data.gd:114-124`, `Scripts/audio_settings.gd:57-61`, `Scripts/save_paths.gd:9`

**Symptom:** Saves are written directly to their final paths with `FileAccess.WRITE` (which truncates first), and several write failures are silently ignored:
- `game.gd:47` / `game.gd:53` ignore a `null` `FileAccess.open` and never surface I/O errors.
- `shop.gd:81` has the same silent failure.
- `skin_data.gd:116-119` checks `null` but not `store_line()` errors.
- `audio_settings.gd:61` ignores the `ConfigFile.save()` result.
- `save_paths.gd:9` ignores `make_dir_recursive_absolute()` failure.

In addition, `shop.gd` deducts coins and calls `_save_coins()` in `check_if_buyable()` (`shop.gd:162-167`) **before** `add_owned_skin()` / `equip_skin()` persist the skin (`shop.gd:150-153`). If the process dies in that window or the skin write fails, coins are spent but the skin is not persistently owned.

**Reproduction (conditional, not observed in a normal run):** Make the save directory read-only or fill the disk, then change volume, score, or buy a skin. The in-memory state changes, but the file is missing/truncated and no error is shown. Killing the process between the coin save and the skin save reproduces the split-purchase window.

**Expected:** Either the save succeeds atomically (or at least reports failure), and a purchase either commits both coins and skin or neither.

**Actual:** Best-effort writes; silent data loss on failure. A crash during a write can leave a zero-length `coins.save`/`high_score.save`/`skins.save`.

**Impact:** Coins, high score, purchased skins, and settings can be lost without warning. The shop can take coins without granting the skin if the second write fails.

**Suggested fix:**
- Write to a temporary file, flush/close, then rename/replace the destination; keep a `.bak` of the previous file.
- Check and handle `FileAccess.open()`, `store_string()`, `ConfigFile.save()`, and `make_dir_recursive_absolute()` results; surface an error in the UI/log.
- Make purchases commit skins first (or use one transaction/save file) so coins are deducted only after ownership is persisted.

---

### [SUG-1] Ball spin is frame-rate dependent

**File:** `Scripts/ball.gd:41-42`

**Observation:** `$Sprite2D.rotation += rotationx` is applied once per physics frame without multiplying by `delta`. At 120 FPS the visual spin is twice as fast as at 60 FPS. This is presentation-only, but it is a real frame-rate dependency.

**Recommendation:** Use `$Sprite2D.rotation += rotationx * delta` or set a constant angular velocity in radians/second and scale by `delta` (clamp/wrap the angle if desired).

---

### [SUG-2, resolved] README is stale relative to the current tree

**Status:** Resolved by the documentation update that rewrote `README.md` and added `structure.md`.

**File:** `README.md:1,108,151-156,167-176` (the stale version reviewed)

**Observation:** The README still:
- uses the old title/name;
- does not mention the shop, skins, `skin_data.gd`, `save_paths.gd`, `audio_settings.gd`, `music_player.gd`, or the Settings/Shop scenes;
- lists `SPEED` as `200` (actual `Scripts/character.gd:4` is `300.0`);
- lists ball `speed` as `400` (actual `Scripts/ball.gd:6` is `500.0`);
- lists scene `max_ball_speed` as `700` (actual `Scenes/MainScenes/character.tscn:245` is `800.0`);
- says stale `menu.tscn*.tmp` files still exist (they were removed in the current tree);
- says `menu.gd` has an empty `_ready()` (it does not).

**Recommendation:** Update the README after the bugs are fixed. This was done in the documentation update; `README.md` and `structure.md` now describe the current tree.

---

## Verified non-issues / intentional behavior

These items were checked and are working (or are intentional) in the current tree:

- **Sixth shop item:** `Item6` exists in `Scenes/MainScenes/Shop.tscn:180-210` with `ProductID=3`, `Kind="bat"`, price `750`. Buying and equipping it works; it displays `batSkin3`.
- **`has_skin` guard / N/A state:** `Scripts/shop.gd:37-41` and `93-100` correctly disable a missing skin and show `N/A`. All six products currently have textures, so `N/A` is not triggered in this tree.
- **Skin assets:** `batSkin0..3.png` and `crowSkin0..3.png` exist; `batSkin3.png` is lower-case and `batSkin2.png` exists. The catalog loaded all eight skins both from the project and from an exported PCK.
- **Stale editor temp files:** no `Scenes/MainScenes/*.tmp` files remain.
- **Shop purchase/equip/persistence:** verified headless: buying crow skin 1 (100) changed coins `1000 -> 900`, wrote `coins.save`, wrote `skins.save`, and updated the label to `EQUIPPED`; buying bat skin 3 (750) then left `150`; the DEFAULT button reset both kinds to skin 0 and persisted `EQ-BAT: 0`, `EQ-CROW: 0`.
- **Audio/music:** `MusicPlayer` resolves `BackgroundMusic1.mp3`, plays on the `Music` bus, and `AudioSettings` applies the saved 0.7/0.8 values to the `Music`/`SFX` buses. This also worked from an exported PCK.
- **Export preset:** `export_presets.cfg` created a valid Windows Desktop pack; an exported PCK contained all skin textures, music, scenes, and scripts. Dynamic skin/music discovery worked from the PCK. (No Windows export templates were installed, so an EXE was not produced.)
- **Main scene and transitions:** the project starts at `menu.tscn` through `run/main_scene`; all `change_scene_to_file()` paths in menu/shop/settings/game resolve to existing scenes.
- **Game loop:** verified headless that wall hits increment score/coins and save high score, the detection area triggers `_lose()` (label/button visible, ball physics disabled), and post-loss wall signals are ignored. Reset uses `reload_current_scene()`.
- **Swing input:** synthetic Space events trigger `swing` only when `echo=false`; key repeat does not re-trigger a swing. The bat animation returns `Bat1.rotation` to its initial value on finish. The ball hitbox detects the ball and raises `speed` by `hit_speed_boost` (10) up to `max_ball_speed` (800).
- **Collision layers:** ball (`layer 6`, mask 6) hits walls/blocks and is detected by the bat hitbox and detection area (mask 32); the player (mask 14) collides with walls, blocks, and pass-through bodies. The pass-through bodies are player-only obstacles and ball-transparent by design (see the design notes below).
- **Custom `Esc` action / `ui_cancel`:** scripts use the built-in `ui_cancel` (game returns to menu, menu quits). The separate `Esc` input action is unused, as documented in the README.

## Known limitations / design notes

These are not counted as new bugs above; they are current design limitations to be aware of:

- **No win condition.** Score and high score grow indefinitely; there is no target/win state (`Scripts/game.gd`).
- **Fullscreen is not persisted.** `fullscreen_toggle.gd` only changes the current window mode; it is not saved to `settings.cfg` and resets to windowed on restart. The separate checkbox-desync issue is WARN-3.
- **Placeholder art and mismatched scales.** Character/bat/ball visuals are stand-ins. The ball sprite is about 79 px across while its circle collider is about 128 px across; the bat hitbox/sprite transforms are unusual. This causes visual/collision overlap differences but matches the “placeholder” design state.
- **Ball bounce animation leaves the sprite slightly smaller.** The `Bounce` animation ends at scale `0.6` while the initial scene scale is `0.6316`; the sprite stays at `0.6` after the first bounce. Presentation-only.
- **Custom `Esc` action is unused and oddly configured.** `project.godot:32-36` defines `Esc` with `device:16`; no script references it. `ui_cancel` is used instead.
- **`down` is mapped but unused.** No script reads the `down` action.
- **Shop and Settings do not handle `ui_cancel`.** Esc does nothing there; the player must use the Back/Exit buttons. This is consistent with the README’s wording that Esc is handled only in the game and menu, but it is an input inconsistency.
- **Invisible player-only barriers.** `PassThrough` bodies at around `x=56` and `x=751` (`Scenes/MainScenes/game.tscn:93-106`) are solid for the player and pass-through for the ball, but have no visible marker. A headless movement test stopped the player near `x=696` when moving right. This appears intentional per the README collision table, but adding a visual cue (or removing the barriers) would make it clear.
- **Save files are plain text with no version field and no atomic write.** See WARN-2/WARN-4. Save locations are path-based rather than resource-based, which is correct for user data.
- **Empty `_process` stubs and debug prints.** `game.gd`, `menu.gd`, `reset_button.gd`, `exit_button.gd`, and the scene-transition scripts contain empty `_process(delta)` methods; `shop.gd` prints detailed debug logs during normal play. Harmless, but noisy.
- **README drift.** Addressed by the documentation update (SUG-2, resolved).

---

*End of review snapshot. No source code, scene, asset, project setting, or README change was made as part of this review.*
