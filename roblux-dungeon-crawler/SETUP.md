# Setup Guide — Roblox Dungeon Crawler

This guide gets you from a fresh Windows machine to a fully running local dev environment. Follow every step in order.

---

## What You're Installing

| Tool | What it does |
|---|---|
| **Roblox Studio** | The game engine — where you run and test the game |
| **Aftman** | Manages Roblox dev tools (like a version manager) |
| **Rojo** | Syncs your code files into Roblox Studio live |
| **Rojo Studio Plugin** | The Studio-side connector for Rojo |
| **VS Code** (optional) | Code editor with Luau support |

---

## Step 1 — Install Roblox Studio

1. Go to [roblox.com](https://www.roblox.com) and create or log into your account
2. Download and install Roblox Studio from [create.roblox.com](https://create.roblox.com)
3. Open Studio once to make sure it launches correctly, then close it

---

## Step 2 — Install Aftman

Aftman manages the Roblox toolchain (Rojo and others). Install it once and it works globally.

1. Go to [github.com/LPGhatguy/aftman/releases](https://github.com/LPGhatguy/aftman/releases)
2. Download `aftman-v0.3.0-windows-x86_64.zip` (or the latest version)
3. Extract the zip — you'll get `aftman.exe`
4. Open PowerShell in the folder where you extracted it and run:

```powershell
.\aftman.exe self-install
```

5. **Close PowerShell and open a new window** — this picks up the PATH change
6. Verify it worked:

```powershell
aftman --version
```

If you see a version number, Aftman is installed.

---

## Step 3 — Clone the Repo

```powershell
git clone https://github.com/zfreiberg/game-ideas.git
cd game-ideas\roblux-dungeon-crawler
```

> If you don't have Git installed, download it from [git-scm.com](https://git-scm.com) first.

---

## Step 4 — Install Rojo (via Aftman)

From inside the `roblux-dungeon-crawler` folder:

```powershell
aftman install
```

This reads `aftman.toml` and installs the correct version of Rojo automatically.

Verify:

```powershell
rojo --version
```

You should see `Rojo 7.7.x`.

> **If `rojo` is not recognized:** Aftman's bin folder isn't on your PATH. Fix it by running:
> ```powershell
> [System.Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$env:USERPROFILE\.aftman\bin", [System.EnvironmentVariableTarget]::User)
> ```
> Then open a new PowerShell window and try again.

---

## Step 5 — Install the Rojo Studio Plugin

```powershell
rojo plugin install
```

This puts the Rojo plugin directly into Roblox Studio. You only need to do this once.

---

## Step 6 — Build the Place File

Rojo needs a `.rbxl` place file to give Studio something to open. Generate it once:

```powershell
rojo build --output dungeon-crawler.rbxl
```

This creates `dungeon-crawler.rbxl` in the project folder. (It's gitignored — you'll regenerate it on each new machine.)

---

## Step 7 — Open the Project in Studio

1. Open Roblox Studio
2. Click **File → Open from File...**
3. Navigate to `game-ideas\roblux-dungeon-crawler\`
4. Select `dungeon-crawler.rbxl` and open it

---

## Step 8 — Start Rojo and Connect

**In PowerShell** (from the `roblux-dungeon-crawler` folder):

```powershell
rojo serve
```

**In Roblox Studio:**

1. Look for the **Rojo** button in the top toolbar (it appears after plugin install)
2. Click it → click **Connect**
3. You should see "Connected" — your scripts are now live-synced

---

## Step 9 — Play Test

Hit **F5** (or the Play button) in Studio. You should see:

- A grey hub world with a yellow spawn pad
- Three dungeon doors (green, grey, grey)
- Walking up to the green door and pressing **E** enters Dungeon 1
- Click the red cubes to damage them — each takes 2 clicks to kill
- Kill all 5 → completion popup appears → "Return to Hub" takes you back

---

## Daily Workflow (after setup)

Every time you want to work on the game:

```powershell
cd game-ideas\roblux-dungeon-crawler
rojo serve
```

Then open `dungeon-crawler.rbxl` in Studio and click Connect. Any code changes you make in your editor sync into Studio instantly.

---

## Optional — VS Code Setup

For a better coding experience:

1. Download [VS Code](https://code.visualstudio.com)
2. Install these extensions:
   - **Rojo** by Roblox
   - **Luau LSP** by JohnnyMorganz (autocomplete, type checking for Luau)
3. Open the `roblux-dungeon-crawler` folder in VS Code

---

## Troubleshooting

**`rojo` not recognized after install**
→ Run the PATH fix in Step 4, open a new terminal

**Studio doesn't show the Rojo button**
→ Re-run `rojo plugin install`, restart Studio

**Scripts aren't syncing**
→ Make sure `rojo serve` is running in the terminal AND you clicked Connect in Studio

**Place file missing**
→ Re-run `rojo build --output dungeon-crawler.rbxl`
