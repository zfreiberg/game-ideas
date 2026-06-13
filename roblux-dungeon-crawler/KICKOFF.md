# Dungeon Crawler — Kickoff

Welcome back! Here's where we are and exactly what to do next.

---

## Status
- Project structure created (Rojo, src/, docs/)
- Git repo initialized at `Z:\gamedev\game-ideas\`
- All game ideas and design specs documented in `docs/`

---

## Before First Code Session

### Step 1 — Install Rojo CLI
Download the standalone binary from https://rojo.space/docs/installation/
Drop `rojo.exe` into this project folder (`roblux-dungeon-crawler/`), or add it to your PATH.

### Step 2 — Install VS Code Extensions
- **Rojo** (by Roblox)
- **Luau LSP** (by JohnnyMorganz)

### Step 3 — Install Rojo Studio Plugin
Download from https://rojo.space and install into Roblox Studio.

### Step 4 — Open Claude Code in the new location
```
Z:\gamedev\game-ideas\roblux-dungeon-crawler
```

---

## Kick Off Message (paste this to start)

> Let's build the dungeon crawler. Start with Phase 1 MVP: hub world with 3 dungeon doors, and Dungeon 1 with red cube enemies that drop EXP, and a completion popup when all enemies are dead. Check docs/design.md for the specs before starting.

---

## Phase 1 Build Order
1. Hub world baseplate + 3 dungeon door Parts in Studio
2. Door proximity prompt → teleport player into dungeon
3. Dungeon 1 room with red cube enemies (EnemyManager spawns them)
4. Enemy takes damage on click, drops EXP on death
5. DungeonManager tracks enemy count → triggers complete when 0
6. Completion popup UI with "Return to Hub" button
