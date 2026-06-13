# Roblox Dungeon Crawler — CLAUDE.md

## Project Overview
A Roblox dungeon crawler game inspired by WoW-style progression: run dungeons, collect gear, unlock harder dungeons. Designed to be fun-first and hopefully viral.

## Documentation
All game design ideas, feature specs, and changelogs live in [`/docs`](./docs/). See [`docs/README.md`](./docs/README.md) for how to navigate and update the documentation.

**Always check `/docs` before implementing a feature** — it contains the source of truth for design decisions.

## Tech Stack
- **Engine:** Roblox Studio
- **Language:** Luau (Roblox's Lua variant)
- **Project format:** TBD (likely Rojo for file-based workflow)
- **MCP:** TBD — being set up

## Architecture (Planned)
- `src/` — all game scripts (ServerScriptService, StarterPlayerScripts, etc.)
- `docs/` — game design documentation and update log

## Development Workflow
1. Discuss feature ideas → they get logged in `docs/ideas.md`
2. Flesh out design → moved to appropriate `docs/` spec file
3. Implement in Roblox Studio
4. Update `docs/changelog.md` with what shipped

## Key Design Pillars
1. Simple, satisfying gameplay loop (run dungeon → get loot → repeat)
2. Clear difficulty progression visible from hub world
3. Lightweight to start — get the loop fun, then polish
