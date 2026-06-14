-- Raidbound hub HUD: shows player level and gold in the hub world
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local evSync = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlayerDataSync")

-- ── Persistent HUD (level + gold, always visible) ────────────────────────────

local function buildHubHud(level, gold, class)
	local old = playerGui:FindFirstChild("HubHudGui")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name           = "HubHudGui"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.Parent         = playerGui

	local frame = Instance.new("Frame")
	frame.Size              = UDim2.new(0, 200, 0, 72)
	frame.Position          = UDim2.new(1, -214, 0, 14)
	frame.BackgroundColor3  = Color3.fromRGB(14, 14, 22)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel   = 0
	frame.Parent            = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local classLbl = Instance.new("TextLabel")
	classLbl.Size              = UDim2.new(1, -10, 0.38, 0)
	classLbl.Position          = UDim2.new(0, 5, 0, 0)
	classLbl.BackgroundTransparency = 1
	classLbl.Text              = (class or "Warrior") .. "  •  Level " .. (level or 1)
	classLbl.TextColor3        = Color3.fromRGB(200, 200, 255)
	classLbl.TextScaled        = true
	classLbl.Font              = Enum.Font.GothamBold
	classLbl.TextXAlignment    = Enum.TextXAlignment.Left
	classLbl.Parent            = frame

	local goldLbl = Instance.new("TextLabel")
	goldLbl.Name               = "GoldLbl"
	goldLbl.Size               = UDim2.new(1, -10, 0.38, 0)
	goldLbl.Position           = UDim2.new(0, 5, 0.44, 0)
	goldLbl.BackgroundTransparency = 1
	goldLbl.Text               = "Gold: " .. (gold or 0)
	goldLbl.TextColor3         = Color3.fromRGB(255, 200, 40)
	goldLbl.TextScaled         = true
	goldLbl.Font               = Enum.Font.GothamBold
	goldLbl.TextXAlignment     = Enum.TextXAlignment.Left
	goldLbl.Parent             = frame
end

evSync.OnClientEvent:Connect(function(data)
	buildHubHud(data.level, data.gold, data.class)
end)

print("[HubController] Loaded")
