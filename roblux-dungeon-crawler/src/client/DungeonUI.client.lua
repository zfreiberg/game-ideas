-- Dungeon HUD: floating EXP notifications + completion popup
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes           = ReplicatedStorage:WaitForChild("RemoteEvents")
local evDungeonComplete = remotes:WaitForChild("DungeonComplete")
local evEXPGained       = remotes:WaitForChild("EXPGained")
local evReturnToHub     = remotes:WaitForChild("ReturnToHub")

-- ── EXP gain notification ────────────────────────────────────────────────────

local function showEXPNotif(amount, level)
	local gui = Instance.new("ScreenGui")
	gui.Name = "EXPNotif"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 220, 0, 44)
	label.Position = UDim2.new(0.5, -110, 0.72, 0)
	label.AnchorPoint = Vector2.new(0, 0)
	label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	label.BackgroundTransparency = 0.3
	label.Text = ("+ %d EXP   •   Lv %d"):format(amount, level)
	label.TextColor3 = Color3.fromRGB(255, 215, 50)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.BorderSizePixel = 0
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	-- Slide up then fade out
	label.Position = UDim2.new(0.5, -110, 0.75, 0)
	TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, -110, 0.72, 0) }):Play()

	task.delay(1.6, function()
		TweenService:Create(label, TweenInfo.new(0.4),
			{ TextTransparency = 1, BackgroundTransparency = 1 }):Play()
		task.wait(0.45)
		gui:Destroy()
	end)
end

-- ── Dungeon complete popup ───────────────────────────────────────────────────

local function showCompletionPopup()
	-- Remove any existing popup
	local existing = playerGui:FindFirstChild("DungeonCompleteGui")
	if existing then existing:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "DungeonCompleteGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	-- Dark overlay
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.Parent = gui

	-- Card
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0, 420, 0, 240)
	card.Position = UDim2.new(0.5, -210, 0.5, -120)
	card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	card.BackgroundTransparency = 0
	card.BorderSizePixel = 0
	card.Parent = gui

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 14)
	cardCorner.Parent = card

	-- Gold top stripe
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(1, 0, 0.08, 0)
	stripe.BackgroundColor3 = Color3.fromRGB(255, 200, 40)
	stripe.BorderSizePixel = 0
	stripe.Parent = card

	local stripeCorner = Instance.new("UICorner")
	stripeCorner.CornerRadius = UDim.new(0, 14)
	stripeCorner.Parent = stripe

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0.38, 0)
	title.Position = UDim2.new(0, 10, 0.1, 0)
	title.BackgroundTransparency = 1
	title.Text = "Dungeon Complete!"
	title.TextColor3 = Color3.fromRGB(255, 215, 50)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = card

	-- Subtitle
	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -20, 0.22, 0)
	sub.Position = UDim2.new(0, 10, 0.46, 0)
	sub.BackgroundTransparency = 1
	sub.Text = "All enemies defeated!"
	sub.TextColor3 = Color3.fromRGB(180, 180, 180)
	sub.TextScaled = true
	sub.Font = Enum.Font.Gotham
	sub.Parent = card

	-- Return to Hub button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.6, 0, 0.22, 0)
	btn.Position = UDim2.new(0.2, 0, 0.72, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 140, 255)
	btn.Text = "Return to Hub"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = card

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		gui:Destroy()
		evReturnToHub:FireServer()
	end)

	-- Hover highlight
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(50, 140, 255)
	end)

	-- Pop-in animation
	card.Size = UDim2.new(0, 0, 0, 0)
	card.Position = UDim2.new(0.5, 0, 0.5, 0)
	TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 420, 0, 240),
		Position = UDim2.new(0.5, -210, 0.5, -120),
	}):Play()
end

-- ── Wire up events ───────────────────────────────────────────────────────────

evEXPGained.OnClientEvent:Connect(showEXPNotif)
evDungeonComplete.OnClientEvent:Connect(showCompletionPopup)

print("[DungeonUI] Loaded")
