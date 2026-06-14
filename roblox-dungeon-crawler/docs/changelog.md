# Changelog

Running log of what has been built and shipped.

---

## 2026-06-14 — Phase 1 MVP (Hub World + Dungeon 1)

**Scripts written (Rojo / Luau):**
- `WorldBuilder.server.lua` — procedurally creates hub baseplate, SpawnLocation, 3 dungeon doors with labels and ProximityPrompts, and Dungeon 1 walled room. No Studio Parts needed.
- `PlayerDataModule.lua` — singleton ModuleScript for player EXP/level, shared across server scripts. Handles level-up math.
- `PlayerData.server.lua` — wires `PlayerAdded`/`PlayerRemoving` to the module.
- `DungeonManager.server.lua` — main orchestrator: ProximityPrompt → teleport into dungeon → spawn red cube enemies with HP billboards and ClickDetectors → track kills → fire `DungeonComplete` + grant bonus EXP on clear.
- `DungeonUI.client.lua` — floating EXP gain notifications (slide-up, fade-out) + completion popup card with pop-in animation and "Return to Hub" button.
- `default.project.json` — added `WorldBuilder`, `PlayerDataModule`, and `RemoteEvents` folder (`DungeonComplete`, `EXPGained`, `ReturnToHub`).

**How to play:**
1. Sync with Rojo, hit Play in Studio.
2. Walk up to the green Dungeon 1 door → press E to enter.
3. Click the red cubes to deal 25 damage each (50 HP = 2 clicks per enemy).
4. Each kill drops EXP with a floating notification; clearing all 5 enemies fires the completion popup.
5. Click "Return to Hub" to teleport back.

**Dungeons 2 & 3:** doors are visible but locked (no ProximityPrompt). Wired up when rooms are built.

---

## 2026-06-14 — Project Initialized
- Created project directory structure
- Created CLAUDE.md with project overview and workflow
- Created `/docs` folder with README, ideas, design, roadmap, and changelog files
- Documented initial game concept: WoW-style dungeon crawler on Roblox
- Documented hub world concept (multiple doors → dungeons of increasing difficulty)
- Documented bare-bones dungeon v1 spec (red cube enemies, EXP drops, completion popup)
