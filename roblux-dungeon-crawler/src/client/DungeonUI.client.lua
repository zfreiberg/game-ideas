-- Raidbound dungeon HUD: mutation banner, gold/loot toasts, extraction UI, result screen
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes               = ReplicatedStorage:WaitForChild("RemoteEvents")
local evDungeonEntered      = remotes:WaitForChild("DungeonEntered")
local evGoldGained          = remotes:WaitForChild("GoldGained")
local evLootDropped         = remotes:WaitForChild("LootDropped")
local evExtractionAvailable = remotes:WaitForChild("ExtractionAvailable")
local evExtractionCountdown = remotes:WaitForChild("ExtractionCountdown")
local evExtractionResult    = remotes:WaitForChild("ExtractionResult")
local evEXPGained           = remotes:WaitForChild("EXPGained")
local evReturnToHub         = remotes:WaitForChild("ReturnToHub")

local RARITY_COLORS = {
	Common = Color3.fromRGB(180, 180, 180),
	Rare   = Color3.fromRGB(60,  120, 255),
	Epic   = Color3.fromRGB(160,  40, 255),
	Mythic = Color3.fromRGB(255, 140,  20),
}

local MUTATION_COLORS = {
	Normal    = Color3.fromRGB(180, 180, 180),
	Golden    = Color3.fromRGB(255, 200,  40),
	Corrupted = Color3.fromRGB(180,  40, 220),
	Treasure  = Color3.fromRGB(40,  220, 255),
}

local MUTATION_DESC = {
	Normal    = "Standard run",
	Golden    = "+50% Gold  •  Enemy Shields Active",
	Corrupted = "Enemies Stronger  •  Loot Quality +1 Tier",
	Treasure  = "Extra Chests  •  No Boss",
}

-- Run-state tracking (client-side for display only)
local runGold      = 0
local runLootCount = 0
local runHudGui    = nil
local countdownGui = nil

-- ── Toast helper ──────────────────────────────────────────────────────────────

local toastY = 0.72  -- stagger offset so toasts don't overlap

local function showToast(text, color, duration)
	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Size                 = UDim2.new(0, 280, 0, 46)
	label.Position             = UDim2.new(0.5, -140, toastY + 0.03, 0)
	label.BackgroundColor3     = Color3.fromRGB(18, 18, 26)
	label.BackgroundTransparency = 0.2
	label.Text                 = text
	label.TextColor3           = color or Color3.new(1, 1, 1)
	label.TextScaled           = true
	label.Font                 = Enum.Font.GothamBold
	label.BorderSizePixel      = 0
	label.Parent               = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent       = label

	TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, -140, toastY, 0) }):Play()

	task.delay(duration or 1.8, function()
		TweenService:Create(label, TweenInfo.new(0.35),
			{ TextTransparency = 1, BackgroundTransparency = 1 }):Play()
		task.wait(0.4)
		gui:Destroy()
	end)
end

-- ── Run HUD (top-left during dungeon) ────────────────────────────────────────

local function createRunHud()
	local old = playerGui:FindFirstChild("RunHudGui")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name           = "RunHudGui"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.Parent         = playerGui

	local frame = Instance.new("Frame")
	frame.Name                 = "HudFrame"
	frame.Size                 = UDim2.new(0, 190, 0, 78)
	frame.Position             = UDim2.new(0, 14, 0, 14)
	frame.BackgroundColor3     = Color3.fromRGB(14, 14, 22)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel      = 0
	frame.Parent               = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent       = frame

	local goldLbl = Instance.new("TextLabel")
	goldLbl.Name               = "GoldLabel"
	goldLbl.Size               = UDim2.new(1, -12, 0.5, 0)
	goldLbl.Position           = UDim2.new(0, 6, 0, 0)
	goldLbl.BackgroundTransparency = 1
	goldLbl.Text               = "Gold: 0"
	goldLbl.TextColor3         = Color3.fromRGB(255, 200, 40)
	goldLbl.TextScaled         = true
	goldLbl.Font               = Enum.Font.GothamBold
	goldLbl.TextXAlignment     = Enum.TextXAlignment.Left
	goldLbl.Parent             = frame

	local lootLbl = Instance.new("TextLabel")
	lootLbl.Name               = "LootLabel"
	lootLbl.Size               = UDim2.new(1, -12, 0.5, 0)
	lootLbl.Position           = UDim2.new(0, 6, 0.5, 0)
	lootLbl.BackgroundTransparency = 1
	lootLbl.Text               = "Items: 0"
	lootLbl.TextColor3         = Color3.fromRGB(180, 140, 255)
	lootLbl.TextScaled         = true
	lootLbl.Font               = Enum.Font.GothamBold
	lootLbl.TextXAlignment     = Enum.TextXAlignment.Left
	lootLbl.Parent             = frame

	runHudGui = gui
end

local function updateRunHud()
	if not runHudGui then return end
	local f = runHudGui:FindFirstChild("HudFrame")
	if not f then return end
	local g = f:FindFirstChild("GoldLabel")
	local l = f:FindFirstChild("LootLabel")
	if g then g.Text = "Gold: " .. runGold end
	if l then l.Text = "Items: " .. runLootCount end
end

local function destroyRunUI()
	if runHudGui    then runHudGui:Destroy();    runHudGui    = nil end
	if countdownGui then countdownGui:Destroy(); countdownGui = nil end
	runGold      = 0
	runLootCount = 0
end

-- ── DungeonEntered → mutation banner ─────────────────────────────────────────

local function onDungeonEntered(dungeonName, mutation)
	destroyRunUI()
	createRunHud()

	local mutColor = MUTATION_COLORS[mutation] or Color3.new(1, 1, 1)
	local mutDesc  = MUTATION_DESC[mutation]   or ""

	local gui = Instance.new("ScreenGui")
	gui.Name           = "MutationBannerGui"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.Parent         = playerGui

	local card = Instance.new("Frame")
	card.Size              = UDim2.new(0, 460, 0, 110)
	card.Position          = UDim2.new(0.5, -230, 0.1, -120)
	card.BackgroundColor3  = Color3.fromRGB(12, 12, 20)
	card.BackgroundTransparency = 0.1
	card.BorderSizePixel   = 0
	card.Parent            = gui

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 14)
	cCorner.Parent = card

	-- Colour stripe
	local stripe = Instance.new("Frame")
	stripe.Size           = UDim2.new(1, 0, 0.065, 0)
	stripe.BackgroundColor3 = mutColor
	stripe.BorderSizePixel = 0
	stripe.Parent = card
	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 14)
	sCorner.Parent = stripe

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size             = UDim2.new(1, -16, 0.38, 0)
	nameLabel.Position         = UDim2.new(0, 8, 0.08, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text             = dungeonName
	nameLabel.TextColor3       = Color3.new(1, 1, 1)
	nameLabel.TextScaled       = true
	nameLabel.Font             = Enum.Font.GothamBold
	nameLabel.TextXAlignment   = Enum.TextXAlignment.Left
	nameLabel.Parent           = card

	local mutLabel = Instance.new("TextLabel")
	mutLabel.Size              = UDim2.new(1, -16, 0.28, 0)
	mutLabel.Position          = UDim2.new(0, 8, 0.48, 0)
	mutLabel.BackgroundTransparency = 1
	mutLabel.Text              = (mutation ~= "Normal" and (mutation:upper() .. "  —  ") or "") .. mutDesc
	mutLabel.TextColor3        = mutColor
	mutLabel.TextScaled        = true
	mutLabel.Font              = Enum.Font.GothamBold
	mutLabel.TextXAlignment    = Enum.TextXAlignment.Left
	mutLabel.Parent            = card

	local hintLabel = Instance.new("TextLabel")
	hintLabel.Size             = UDim2.new(1, -16, 0.2, 0)
	hintLabel.Position         = UDim2.new(0, 8, 0.78, 0)
	hintLabel.BackgroundTransparency = 1
	hintLabel.Text             = "Click enemies to fight. Use the Extraction Portal to secure your loot."
	hintLabel.TextColor3       = Color3.fromRGB(140, 140, 140)
	hintLabel.TextScaled       = true
	hintLabel.Font             = Enum.Font.Gotham
	hintLabel.TextXAlignment   = Enum.TextXAlignment.Left
	hintLabel.Parent           = card

	-- Slide in
	TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, -230, 0.1, 0) }):Play()

	task.delay(5.5, function()
		TweenService:Create(card, TweenInfo.new(0.45),
			{ Position = UDim2.new(0.5, -230, 0.1, -130) }):Play()
		task.wait(0.5)
		gui:Destroy()
	end)
end

-- ── GoldGained ────────────────────────────────────────────────────────────────

local function onGoldGained(amount, total)
	runGold = total
	updateRunHud()
	showToast("+ " .. amount .. " Gold", Color3.fromRGB(255, 200, 40), 1.3)
end

-- ── LootDropped ───────────────────────────────────────────────────────────────

local function onLootDropped(item)
	runLootCount += 1
	updateRunHud()

	local color  = RARITY_COLORS[item.rarity] or Color3.new(1, 1, 1)
	local mutStr = item.mutation and ("  [" .. item.mutation .. "]") or ""
	showToast(item.rarity .. "  " .. item.name .. mutStr, color, 2.8)
end

-- ── EXPGained ─────────────────────────────────────────────────────────────────

local function onEXPGained(amount, level)
	showToast("+ " .. amount .. " EXP  •  Lv " .. level, Color3.fromRGB(120, 210, 255), 1.6)
end

-- ── ExtractionAvailable ───────────────────────────────────────────────────────

local function onExtractionAvailable()
	showToast("EXTRACTION PORTAL OPEN!", Color3.fromRGB(60, 255, 160), 3.5)
end

-- ── ExtractionCountdown ───────────────────────────────────────────────────────

local function onExtractionCountdown(seconds)
	if not countdownGui then
		countdownGui = Instance.new("ScreenGui")
		countdownGui.Name           = "ExtractionCountdownGui"
		countdownGui.ResetOnSpawn   = false
		countdownGui.IgnoreGuiInset = true
		countdownGui.Parent         = playerGui

		local frame = Instance.new("Frame")
		frame.Name              = "CdFrame"
		frame.Size              = UDim2.new(0, 260, 0, 86)
		frame.Position          = UDim2.new(0.5, -130, 0.07, 0)
		frame.BackgroundColor3  = Color3.fromRGB(8, 36, 18)
		frame.BackgroundTransparency = 0.1
		frame.BorderSizePixel   = 0
		frame.Parent            = countdownGui

		local fCorner = Instance.new("UICorner")
		fCorner.CornerRadius = UDim.new(0, 12)
		fCorner.Parent = frame

		local topLbl = Instance.new("TextLabel")
		topLbl.Size              = UDim2.new(1, 0, 0.44, 0)
		topLbl.BackgroundTransparency = 1
		topLbl.Text              = "EXTRACTING"
		topLbl.TextColor3        = Color3.fromRGB(60, 255, 160)
		topLbl.TextScaled        = true
		topLbl.Font              = Enum.Font.GothamBold
		topLbl.Parent            = frame

		local numLbl = Instance.new("TextLabel")
		numLbl.Name              = "CountNum"
		numLbl.Size              = UDim2.new(1, 0, 0.54, 0)
		numLbl.Position          = UDim2.new(0, 0, 0.44, 0)
		numLbl.BackgroundTransparency = 1
		numLbl.Text              = tostring(seconds)
		numLbl.TextColor3        = Color3.new(1, 1, 1)
		numLbl.TextScaled        = true
		numLbl.Font              = Enum.Font.GothamBold
		numLbl.Parent            = frame
	else
		local f = countdownGui:FindFirstChild("CdFrame")
		local n = f and f:FindFirstChild("CountNum")
		if n then n.Text = tostring(seconds) end
	end

	-- Flash red when low
	if seconds <= 3 then
		local f = countdownGui:FindFirstChild("CdFrame")
		if f then
			TweenService:Create(f, TweenInfo.new(0.1),
				{ BackgroundColor3 = Color3.fromRGB(60, 10, 10) }):Play()
			task.delay(0.1, function()
				TweenService:Create(f, TweenInfo.new(0.2),
					{ BackgroundColor3 = Color3.fromRGB(8, 36, 18) }):Play()
			end)
		end
	end
end

-- ── ExtractionResult ─────────────────────────────────────────────────────────

local function onExtractionResult(result)
	destroyRunUI()

	-- Remove mutation banner if still showing
	local mb = playerGui:FindFirstChild("MutationBannerGui")
	if mb then mb:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name           = "ExtractionResultGui"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.Parent         = playerGui

	local overlay = Instance.new("Frame")
	overlay.Size              = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3  = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel   = 0
	overlay.Parent            = gui

	local card = Instance.new("Frame")
	card.Size             = UDim2.new(0, 0, 0, 0)   -- animates in
	card.Position         = UDim2.new(0.5, 0, 0.5, 0)
	card.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
	card.BorderSizePixel  = 0
	card.Parent           = gui

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 16)
	cCorner.Parent = card

	local stripeColor = result.success
		and Color3.fromRGB(60, 255, 150)
		or  Color3.fromRGB(220, 40, 40)

	local stripe = Instance.new("Frame")
	stripe.Size           = UDim2.new(1, 0, 0.05, 0)
	stripe.BackgroundColor3 = stripeColor
	stripe.BorderSizePixel = 0
	stripe.Parent = card
	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 16)
	sCorner.Parent = stripe

	local titleText = result.success and "EXTRACTION SUCCESSFUL" or "EXTRACTION FAILED"
	local title = Instance.new("TextLabel")
	title.Size             = UDim2.new(1, -20, 0.2, 0)
	title.Position         = UDim2.new(0, 10, 0.07, 0)
	title.BackgroundTransparency = 1
	title.Text             = titleText
	title.TextColor3       = stripeColor
	title.TextScaled       = true
	title.Font             = Enum.Font.GothamBold
	title.Parent           = card

	if result.success then
		-- Gold secured
		local goldLbl = Instance.new("TextLabel")
		goldLbl.Size           = UDim2.new(1, -20, 0.16, 0)
		goldLbl.Position       = UDim2.new(0, 10, 0.29, 0)
		goldLbl.BackgroundTransparency = 1
		goldLbl.Text           = "Gold secured: " .. result.goldKept
		goldLbl.TextColor3     = Color3.fromRGB(255, 200, 40)
		goldLbl.TextScaled     = true
		goldLbl.Font           = Enum.Font.GothamBold
		goldLbl.TextXAlignment = Enum.TextXAlignment.Left
		goldLbl.Parent         = card

		-- Items secured
		local lootCount = #(result.lootKept or {})
		local lootLbl = Instance.new("TextLabel")
		lootLbl.Size           = UDim2.new(1, -20, 0.14, 0)
		lootLbl.Position       = UDim2.new(0, 10, 0.46, 0)
		lootLbl.BackgroundTransparency = 1
		lootLbl.Text           = "Items secured: " .. lootCount
		lootLbl.TextColor3     = Color3.fromRGB(180, 140, 255)
		lootLbl.TextScaled     = true
		lootLbl.Font           = Enum.Font.GothamBold
		lootLbl.TextXAlignment = Enum.TextXAlignment.Left
		lootLbl.Parent         = card

		-- Preview first item if present
		if lootCount > 0 then
			local first   = result.lootKept[1]
			local mutStr  = first.mutation and ("  [" .. first.mutation .. "]") or ""
			local itemLbl = Instance.new("TextLabel")
			itemLbl.Size           = UDim2.new(1, -20, 0.13, 0)
			itemLbl.Position       = UDim2.new(0, 10, 0.61, 0)
			itemLbl.BackgroundTransparency = 1
			itemLbl.Text           = first.rarity .. "  " .. first.name .. mutStr
			itemLbl.TextColor3     = RARITY_COLORS[first.rarity] or Color3.new(1,1,1)
			itemLbl.TextScaled     = true
			itemLbl.Font           = Enum.Font.Gotham
			itemLbl.TextXAlignment = Enum.TextXAlignment.Left
			itemLbl.Parent         = card
		end
	else
		-- Death recap (GDD 7.3) — motivates immediate re-entry
		local lostLbl = Instance.new("TextLabel")
		lostLbl.Size           = UDim2.new(1, -20, 0.2, 0)
		lostLbl.Position       = UDim2.new(0, 10, 0.29, 0)
		lostLbl.BackgroundTransparency = 1
		lostLbl.Text           = result.goldLost .. " gold was left behind..."
		lostLbl.TextColor3     = Color3.fromRGB(255, 100, 100)
		lostLbl.TextScaled     = true
		lostLbl.Font           = Enum.Font.GothamBold
		lostLbl.TextXAlignment = Enum.TextXAlignment.Left
		lostLbl.Parent         = card

		local retryLbl = Instance.new("TextLabel")
		retryLbl.Size           = UDim2.new(1, -20, 0.16, 0)
		retryLbl.Position       = UDim2.new(0, 10, 0.5, 0)
		retryLbl.BackgroundTransparency = 1
		retryLbl.Text           = "Your gear is safe. Try again?"
		retryLbl.TextColor3     = Color3.fromRGB(180, 180, 180)
		retryLbl.TextScaled     = true
		retryLbl.Font           = Enum.Font.Gotham
		retryLbl.TextXAlignment = Enum.TextXAlignment.Left
		retryLbl.Parent         = card
	end

	-- Return to Hub button
	local btn = Instance.new("TextButton")
	btn.Size            = UDim2.new(0.56, 0, 0.16, 0)
	btn.Position        = UDim2.new(0.22, 0, 0.8, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 140, 255)
	btn.Text            = "Return to Hub"
	btn.TextColor3      = Color3.new(1, 1, 1)
	btn.TextScaled      = true
	btn.Font            = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent          = card

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 8)
	bCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		gui:Destroy()
		evReturnToHub:FireServer()
	end)
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(80, 160, 255) end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 140, 255) end)

	-- Pop-in animation
	TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size     = UDim2.new(0, 460, 0, 320),
		Position = UDim2.new(0.5, -230, 0.5, -160),
	}):Play()
end

-- ── Wire events ───────────────────────────────────────────────────────────────

evDungeonEntered.OnClientEvent:Connect(onDungeonEntered)
evGoldGained.OnClientEvent:Connect(onGoldGained)
evLootDropped.OnClientEvent:Connect(onLootDropped)
evEXPGained.OnClientEvent:Connect(onEXPGained)
evExtractionAvailable.OnClientEvent:Connect(onExtractionAvailable)
evExtractionCountdown.OnClientEvent:Connect(onExtractionCountdown)
evExtractionResult.OnClientEvent:Connect(onExtractionResult)

print("[DungeonUI] Loaded")
