# Dungeon Crawler — Developer Notes

## One-Time Setup

### 1. Install Rojo
1. **VS Code extension**: Extensions → search **Rojo** (by Roblox) → Install
   - Also install **Luau LSP** (by JohnnyMorganz) for autocomplete
2. **Studio plugin**: [rojo.space](https://rojo.space) → download Studio plugin → install
3. **Rojo CLI**: download standalone binary from [rojo.space/docs/installation](https://rojo.space/docs/installation/)
   - Drop `rojo.exe` into the project folder, or add it to your PATH

### 2. Connect VS Code → Studio (every session)

```bash
# From this project folder:
rojo serve
```

Then in Roblox Studio → open the Rojo plugin panel → click **Connect**.
Files now sync live — save in VS Code, it instantly appears in Studio.

---

## Project Structure

```
src/
  server/
    DungeonManager.lua  → manages dungeon entry, enemy tracking, completion
    EnemyManager.lua    → spawns/manages enemies
    PlayerData.lua      → per-player level, exp, gear
  client/
    HubController.lua   → hub world UI and door interactions
    DungeonUI.lua       → in-dungeon HUD and completion popup
  shared/
    Config.lua          → global constants
    DungeonData.lua     → dungeon tier definitions
    EnemyData.lua       → enemy type definitions
default.project.json    ← Rojo config
docs/                   ← game design documentation
```

---

## Key Roblox Concepts

| Concept | Meaning |
|---------|---------|
| `Script` (`.server.lua`) | Runs on server only |
| `LocalScript` (`.client.lua`) | Runs on each player's client |
| `ModuleScript` (`.lua`) | Shared library, required by other scripts |
| `RemoteEvent` | Server ↔ Client messaging (fire & forget) |
| `RemoteFunction` | Server ↔ Client (with return value) |

## Studio Shortcuts
- **F5** — Playtest
- **Shift+F5** — Stop playtest
- **Explorer** — scene hierarchy
- **Properties** — selected object properties
- **Output** — print() and errors
