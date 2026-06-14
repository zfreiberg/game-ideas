# Game Design Specs

Fleshed-out designs for features that are ready to build. Items here have been thought through enough to implement.

---

## Hub World — v1 Spec

**Goal:** A central area where players spawn, see available dungeons, and choose where to run next.

**Layout:**
- Open plaza area (simple baseplate to start)
- Multiple dungeon doors arranged in a row or arc, visible from spawn point
- Each door is labeled (e.g., "Dungeon 1 — Beginner", "Dungeon 2 — Easy")
- Doors locked/unlocked based on player progression

**Door behavior:**
- Walking up to a door and clicking (or touching a prompt) teleports player into that dungeon
- Locked doors show a tooltip explaining what's needed to unlock

**Status:** ✅ Implemented (Phase 1)

---

## Dungeon — v1 Bare-Bones Spec

**Goal:** A playable dungeon that demonstrates the core loop. Not pretty — just functional.

**Enemies:**
- Red cube `Part` in Roblox Studio
- Has a health value (e.g., 100 HP)
- Takes damage when player attacks
- Drops EXP (numeric value added to player's data) on death
- Simple behavior: stand still or walk toward player

**Win Condition:**
- Script tracks how many enemies are in the dungeon
- When enemy count hits 0 → trigger "Dungeon Complete" event

**Completion UI:**
- A `ScreenGui` popup appears: "Dungeon Complete!"
- Button: "Return to Hub" — teleports player back to hub world

**Status:** ✅ Implemented (Phase 1)

---

*More specs will be added as ideas are fleshed out. See `ideas.md` for the raw backlog.*
