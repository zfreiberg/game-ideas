# Documentation Folder — How It Works

This folder is the source of truth for all game design, ideas, and progress on the Roblox Dungeon Crawler project.

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `ideas.md` | Raw ideas and brainstorming — anything goes here first |
| `design.md` | Fleshed-out feature specs and game design decisions |
| `changelog.md` | Running log of what has been built/shipped |
| `roadmap.md` | Prioritized list of what's next |

---

## How to Update Documentation

### New idea or suggestion?
→ Add it to `ideas.md` under the appropriate section. Use `- [ ]` for unstarted ideas.

### Idea is ready to design?
→ Move it from `ideas.md` into `design.md` with a proper spec. Mark the idea in `ideas.md` with `[moved to design.md]`.

### Feature is built?
→ Add an entry to `changelog.md` with today's date and a short description. Mark the idea in `design.md` as `✅ Shipped`.

### Working on something next?
→ Update `roadmap.md` to reflect current priorities.

---

## Instructions for Claude

When the user shares a new idea:
1. Log it in `ideas.md` immediately.
2. If the idea is detailed enough, also create or update a spec in `design.md`.
3. Never silently drop an idea — every suggestion gets documented.

When something is built:
1. Update `changelog.md`.
2. Mark the relevant item in `design.md` as shipped.
