# Roblox Dungeon Crawler — CLAUDE.md

## Project Overview
**Raidbound** — a Roblox dungeon crawler inspired by WoW-style progression: run dungeons, collect loot, unlock harder dungeons. Designed to be fun-first and hopefully viral. Core tension: "Do I extract now, or push deeper for better loot?"

## Documentation
All game design ideas, feature specs, and changelogs live in [`/docs`](./docs/). See [`docs/README.md`](./docs/README.md) for how to navigate and update the documentation.

**Always check `/docs` before implementing a feature** — it contains the source of truth for design decisions.

## Tech Stack
- **Engine:** Roblox Studio
- **Language:** Luau (Roblox's Lua variant)
- **Project format:** Rojo 7.7.0-rc.1 (via Aftman) — file-based workflow
- **Project name:** `raidbound` (in `default.project.json`)
- **Place file:** `dungeon-crawler.rbxl` (gitignored — regenerate with `rojo build --output dungeon-crawler.rbxl`)

## Daily Dev Workflow
```powershell
cd "E:\Claude\game-ideas\roblox-dungeon-crawler"
$env:PATH = "$env:PATH;$env:USERPROFILE\.aftman\bin"
rojo serve
```
Then open `dungeon-crawler.rbxl` in Studio → click the Rojo button → Connect → F5 to play.

## Architecture
```
src/
  server/
    WorldBuilder.server.lua     — builds hub + dungeon room procedurally at runtime
    DungeonManager.server.lua   — entry, mutation roll, enemy spawn, extraction, hub return
    EnemyManager.server.lua     — placeholder (Phase 2: movement AI, ranged attacks)
    PlayerData.server.lua       — wires PlayerAdded/Removing to PlayerDataModule
    PlayerDataModule.lua        — in-memory player data: level, EXP, gold, inventory, class
    LootManager.lua             — server-side loot rolls (rarity, mutation, item type)
  client/
    HubController.client.lua    — hub HUD: level + gold display (top-right)
    DungeonUI.client.lua        — mutation banner, run HUD, toasts, extraction UI, result screen
  shared/
    Config.lua                  — global constants (damage, multipliers, extraction timer)
    DungeonData.lua             — Zone 1 dungeon definitions (4 dungeons + capstone)
    EnemyData.lua               — enemy type definitions (BasicCube only for now)
    LootData.lua                — rarities, item mutations, item types, drop chances
docs/                           — game design documentation
default.project.json            — Rojo project config
aftman.toml                     — toolchain: rojo-rbx/rojo@7.7.0-rc.1
```

## RemoteEvents (all in ReplicatedStorage/RemoteEvents)
| Event | Direction | Purpose |
|---|---|---|
| `DungeonEntered` | Server→Client | Triggers mutation banner |
| `GoldGained` | Server→Client | Updates run HUD + toast |
| `LootDropped` | Server→Client | Updates run HUD + toast |
| `ExtractionAvailable` | Server→Client | Portal open toast |
| `ExtractionCountdown` | Server→Client | Countdown UI |
| `ExtractionResult` | Server→Client | Success/fail result screen |
| `EXPGained` | Server→Client | EXP toast |
| `PlayerDataSync` | Server→Client | Syncs level/gold to hub HUD |
| `ReturnToHub` | Client→Server | Player clicks "Return to Hub" |
| `SelectClass` | Client→Server | (stub — Phase 2) |
| `RequestExtraction` | Client→Server | (stub) |

## Current State (Phase 1 Complete)
- Hub world: baseplate, spawn pad, 4 dungeon doors (1 open), Town Showcase Board, Blacksmith, Trade Bench, Quest Board, Storage Vault stubs
- 4 dungeons defined in Zone 1 — The Blighted Reaches:
  - **Dungeon 1 — The Ashen Mine** (Lv 1+, 6 enemies, BasicCube)
  - **Dungeon 2 — Rotwood Crypt** (Lv 4+, 10 enemies) — locked
  - **Dungeon 3 — Brigand's Hideout** (Lv 8+, 14 enemies) — locked
  - **Dungeon 4 — Blight Keep Capstone** (Lv 12+, 18 enemies, isBoss) — locked
- Mutation system on dungeon entry: Normal (65%), Golden (15%), Corrupted (12%), Treasure (8%)
- Click-to-damage enemies (ClickDetector), HP billboards, gold drops per kill
- Loot drops: 4 rarities (Common/Rare/Epic/Mythic), 6 item mutations, 8 Zone 1 item types
- Extraction portal spawns after room clear — 10-second countdown to commit loot
- Extraction result screen: success (grant gold + loot + EXP) or fail (gold lost, gear kept)
- Player data: level, EXP (scales by 1.5x per level), gold, inventory, class (Warrior default)
- Hub HUD: class + level (top-right), run HUD: gold + items collected (top-left during dungeon)

## Not Yet Built (Phase 2+)
- Inventory/equipment UI (no way to view collected items)
- Persistent data (ProfileService) — currently resets on server restart
- Class selection UI
- Enemy movement AI
- Real enemy models (currently BasicCube red parts)
- Hub world art pass
- Leaderboards, party system, daily challenges
- Zone 2+

## Key Design Rules (GDD)
- **Extraction risk:** only unbanked gold is lost on death — gear is always kept (GDD 7.2)
- **Loot is server-side only** — never trust client for drops (GDD 12.3)
- **Corrupted mutation:** enemies stronger (+50% HP), loot quality +1 tier
- **Treasure mutation:** fewer enemies (40%), no boss, extra chests
- **Golden mutation:** +50% gold, enemies have shields (+20% HP)
- Zone 1 level cap: 15 (players should reach Zone 2 within 3–4 sessions)

## Development Workflow
1. Discuss feature ideas → log in `docs/ideas.md`
2. Flesh out design → move to `docs/design.md`
3. Implement (check `/docs` first — source of truth)
4. Update `docs/changelog.md` with what shipped

## Key Design Pillars
1. Simple, satisfying loop: run dungeon → get loot → extract → repeat
2. Clear difficulty progression visible from hub world
3. Extraction tension: push deeper vs. secure what you have
4. Lightweight to start — get the loop fun, then polish
