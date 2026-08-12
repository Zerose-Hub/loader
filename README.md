# Zerose Hub Loader

A **Hina Hub style** loader without a key system. Users paste **`Run.lua`**, which waits for the game to load, checks the current game against a scripts table, sets `getgenv().ZeroseHub`, and loads **`Loader.lua`** from GitHub. The loader prints the logo and fetches/runs the script for the matched game.

## How it works

```
Run.lua  (users paste this into their executor)
   │  1. waits for game:IsLoaded()
   │  2. anti re-execute flag (getgenv().ZeroseHub_Executed)
   │  3. Scripts table: game id -> { name, script_id }
   │  4. unsupported game -> notification + return
   │  5. getgenv().ZeroseHub = { hub, discord, name, script_id }
   ▼
Loader.lua  (hosted on GitHub - users never edit this)
   │  1. validates getgenv().ZeroseHub
   │  2. prints logo + game name + discord
   │  3. resolves script_id -> URL (full URL or dply.me paste id)
   │  4. fetches, compiles and runs the game's script
   ▼
The game's script (e.g. ZeroseHub_Loader.lua - the full hub UI)
```

**No key system** — the loader is open by design. Add one later if you want (see below).

## Files

| File | Purpose | Who edits it |
|------|---------|--------------|
| `Run.lua` | The script users paste. Sets everything. | You (per project) |
| `Loader.lua` | Core loader: logo + fetch/run the game script. | Rarely |
| `ZeroseHub_Loader.lua` | Full hub UI for Anime Dungeons (the game script). | Per game |
| `README.md` | This file. | You |

## Quick start

1. Edit `Run.lua`:
   - Set `Hub`, `Discord_Invite`.
   - Fill the `Scripts` table: `[placeId] = { name = "...", script_id = "..." }`.
   - Replace the two `raw.githubusercontent.com/<YOUR_USERNAME>/<YOUR_REPO>` URLs with your own repo.
2. Upload `Loader.lua`, `Run.lua`, `ZeroseHub_Loader.lua`, `README.md` to GitHub.
3. Users paste `Run.lua` into their executor.

## script_id formats

The `script_id` in the Scripts table can be either:

- **A full URL** — e.g. the GitHub raw URL of the game's config script:
  `script_id = "https://raw.githubusercontent.com/<YOU>/<REPO>/main/ZeroseHub_Loader.lua"`
- **A dply.me paste id** — e.g. `script_id = "abc123"` → the loader fetches `https://api.dply.me/abc123/raw`

## Supported games

| Game | Key | script_id |
|------|-----|-----------|
| Anime Dungeons | `70863683083739` (PlaceId) | URL of `ZeroseHub_Loader.lua` |

Add more entries to `Scripts` — you can key by `game.PlaceId` or `game.CreatorId` (the loader checks `Scripts[game.PlaceId] or Scripts[game.CreatorId]`).

## Features (Anime Dungeons script)

| Tab | Feature |
|-----|---------|
| **Main** | Auto Attack (remote spam), Auto Farm (teleport to closest monster + attack), stand position (Front/Back/Left/Right/Above/Below/Center), Auto Dodge |
| **Skill** | Auto Skill — 3 slots (Spell1/2/3), staggered casting with configurable delay |
| **Dungeon** | Auto Create Room (teleport → click UI → start), Auto Play Again, Auto Start Dungeon, room mode/difficulty/private/hardcore, save positions & teleport (6 slots) |
| **Settings** | Theme, config save/load (per game) |

## Adding a new game

Everything game-specific lives in the `GAME_CONFIGS` table at the top of `ZeroseHub_Loader.lua`:

- `PlaceIds`, `RemotesFolder` / `AttackRemote` / `DungeonRemote` / `StartDungeonRemote` (paths inside `ReplicatedStorage`)
- `AttackArgs` / `SkillArgs` — the `FireServer` argument template (`%WEAPON%`, `%DIR%`, `%SLOT%`, `%SKILL%` are replaced at runtime)
- `EnemiesFolderPath` (inside `Workspace`), `EnemyHRPNames`, `HealthValueName`, `HasDiedName`, `LobbyEnemyKeyword`
- `DungeonUIClickSequence` — ordered list of buttons to click to create a room:
  - `{ "ButtonName" }` — click a fixed button by name/text
  - `{ mode = "DungeonMode" }` — click the value currently selected in that dropdown
  - `{ "JoinStatus", onlyIf = "DungeonPrivate" }` — only click when that toggle is on
- `SaveSlots`, `Weapons`, `Spells`, `DungeonModes`, `DungeonDifficulties` — UI values
- `HasDungeon = false` / `HasSkills = false` — hide tabs for games without those systems

### Finding the values
- `game.PlaceId` / `game.CreatorId` identify the game.
- Dump `ReplicatedStorage` to find remote names and the `Items` folder contents.
- The dungeon UI flow is the hardest part — dump `StarterGui` and match the button names/text in the order you see them in-game (e.g. Play → select dungeon → select difficulty → Create → Start).

## Adding a key system later

If you want keys, the simplest spot is `Run.lua` (before setting `getgenv().ZeroseHub`) or the top of `Loader.lua`: compare an input key against a value fetched from a URL (e.g. a paste), and `return` if it doesn't match. The original Hina-style key system used Luarmor key links like:
```
https://ads.luarmor.net/get_key?for=<HUB_NAME>-<KEY_ID>
```
and a separate key-system UI loader — you can load that UI instead of `Loader.lua` when keys are enabled.

## Notes

- Built on [dawid-scripts/Fluent](https://github.com/dawid-scripts/Fluent) (UI library, loaded at runtime).
- `getgenv().ZeroseHub_Executed` prevents the script from running twice in one session.
- Save positions are in-memory (reset on re-run). Enable Settings → config save to persist UI options.
