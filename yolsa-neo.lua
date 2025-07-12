--============================================================
--  Neo Soccer League • Modern Kick-Hitbox UI + Core Functionality
--============================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui    = game:GetService("CoreGui")
local lp         = Players.LocalPlayer

-- ▼ Default Settings
local DEFAULT_RANGE      = 10.22
local DEFAULT_RING_COLOR = Color3.fromRGB(0,128,255)
local DEFAULT_IN_COLOR   = Color3.fromRGB(0,255,0)
local DEFAULT_IN_TRANS   = 0.4
local SOUND_ID           = "rbxassetid://541909867"

local SEGMENTS = 48
local BAR_W    = 0.2
local BAR_H    = 0.05

local BALL_MODEL = "PLAIN_BALL"
local BALL_PART  = "HITBOX_BALL"

-- ▼ State
local ringEnabled  = true
local currentRange = DEFAULT_RANGE
local ringColor    = DEFAULT_RING_COLOR
local soundEnabled = true

--============================================================
--  ▼ Utility Functions
--============================================================
local function clearRing(hrp)
	for _,c in ipairs(hrp:GetChildren()) do
		if c.Name == "KickSeg" then c:Destroy() end
	end
end

local function buildRing(hrp)
	clearRing(hrp)
	if not ringEnabled then return end
	local yOff   = -hrp.Size.Y/2 + BAR_H/2 + 0.05
	local step   = math.pi * 2 / SEGMENTS
	local chord  = 2 * currentRange * math.sin(step/2)
	for i = 0, SEGMENTS-1 do
		local theta = i * step + step/2
		local pos   = Vector3.new(math.cos(theta)*currentRange, yOff, math.sin(theta)*currentRange)
		local seg   = Instance.new("Part")
		seg.Name         = "KickSeg"
		seg.Size         = Vector3.new(chord, BAR_H, BAR_W)
		seg.Color        = ringColor
		seg.Transparency = 0.35
		seg.Material     = Enum.Material.Neon
		seg.Anchored     = false
		seg.CanCollide   = false
		seg.Massless     = true
		seg.CFrame       = hrp.CFrame * CFrame.new(pos) * CFrame.Angles(0, -theta, 0)
		seg.Parent       = hrp
		local weld = Instance.new("WeldConstraint", seg)
		weld.Part0, weld.Part1 = hrp, seg
	end
end

local function getSound(hrp)
	local s = hrp:FindFirstChild("KickSound") or Instance.new("Sound", hrp)
	s.Name, s.SoundId, s.Volume = "KickSound", SOUND_ID, 1
	return s
end

local function getLabel(ball)
	local gui = ball:FindFirstChild("ReachGui") or Instance.new("BillboardGui", ball)
	gui.Name          = "ReachGui"
	gui.AlwaysOnTop   = true
	gui.Size          = UDim2.new(0,120,0,40)
	gui.StudsOffset   = Vector3.new(0, ball.Size.Y/2 + 1.5, 0)
	local txt = gui:FindFirstChild("Txt") or Instance.new("TextLabel", gui)
	txt.Name                  = "Txt"
	txt.Size                  = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency= 1
	txt.Font                  = Enum.Font.SourceSansBold
	txt.TextScaled            = true
	return txt
end

--============================================================
--  ▼ UI Construction
--============================================================
local ui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ui.Name = "HitboxSettingsUI"

local panel = Instance.new("Frame", ui)
panel.Size = UDim2.new(0, 240, 0, 300)
panel.Position = UDim2.new(0,20,0,80)
panel.BackgroundColor3 = Color3.fromRGB(40,40,40)
panel.BorderSizePixel  = 0
panel.ClipsDescendants = true

local corner = Instance.new("UICorner", panel)
corner.CornerRadius = UDim.new(0,8)
local stroke = Instance.new("UIStroke", panel)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(60,60,60)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1,0,0,36)
title.Position = UDim2.new(0,0,0,8)
title.BackgroundTransparency = 1
title.Text = "⚙️ Hitbox Ayarları"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Center

local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0,10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Toggle Ring Button
local toggleBtn = Instance.new("TextButton", panel)
toggleBtn.Size = UDim2.new(0,200,0,32)
toggleBtn.LayoutOrder = 2
toggleBtn.Text = "Halka: Açık"
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
local tCorner = Instance.new("UICorner", toggleBtn)
tCorner.CornerRadius = UDim.new(0,6)

-- Range Input
local rangeBox = Instance.new("TextBox", panel)
rangeBox.Size = UDim2.new(0,200,0,30)
rangeBox.LayoutOrder = 3
rangeBox.PlaceholderText = "Yarıçap (stud)"
rangeBox.Text = tostring(currentRange)
rangeBox.Font = Enum.Font.Gotham
rangeBox.TextSize = 18
rangeBox.TextColor3 = Color3.new(1,1,1)
rangeBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
local rCorner = Instance.new("UICorner", rangeBox)
rCorner.CornerRadius = UDim.new(0,6)

local applyBtn = Instance.new("TextButton", panel)
applyBtn.Size = UDim2.new(0,200,0,28)
applyBtn.LayoutOrder = 4
applyBtn.Text = "Uygula"
applyBtn.Font = Enum.Font.Gotham
applyBtn.TextSize = 18
applyBtn.TextColor3 = Color3.new(1,1,1)
applyBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
local aCorner = Instance.new("UICorner", applyBtn)
aCorner.CornerRadius = UDim.new(0,6)

-- Color Picker
local colorLabel = Instance.new("TextLabel", panel)
colorLabel.Size = UDim2.new(1,-20,0,24)
colorLabel.LayoutOrder = 5
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Renk:"
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextSize = 18
colorLabel.TextColor3 = Color3.new(1,1,1)
colorLabel.TextXAlignment = Enum.TextXAlignment.Left

local colorFrame = Instance.new("Frame", panel)
colorFrame.Size = UDim2.new(0,200,0,40)
colorFrame.LayoutOrder = 6
colorFrame.BackgroundTransparency = 1
local grid = Instance.new("UIGridLayout", colorFrame)
grid.CellSize = UDim2.new(0,48,0,32)
grid.CellPadding = UDim2.new(0,8,0,8)
grid.FillDirection = Enum.FillDirection.Horizontal

local colors = {
	{ name="Mavi",   col=Color3.fromRGB(0,128,255) },
	{ name="Yeşil",  col=Color3.fromRGB(0,255,0) },
	{ name="Kırmızı",col=Color3.fromRGB(255,0,0) },
}
for _,info in ipairs(colors) do
	local btn = Instance.new("TextButton", colorFrame)
	btn.Name = info.name
	btn.Size = UDim2.new(0,48,0,32)
	btn.BackgroundColor3 = info.col
	btn.Text = ""
	local cCorner = Instance.new("UICorner", btn)
	cCorner.CornerRadius = UDim.new(0,6)
	btn.MouseButton1Click:Connect(function()
		ringColor = info.col
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then buildRing(hrp) end
	end)
end

-- Sound Toggle
local soundBtn = Instance.new("TextButton", panel)
soundBtn.Size = UDim2.new(0,200,0,32)
soundBtn.LayoutOrder = 7
soundBtn.Text = "Ses: Açık"
soundBtn.Font = Enum.Font.Gotham
soundBtn.TextSize = 18
soundBtn.TextColor3 = Color3.new(1,1,1)
soundBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
local sCorner = Instance.new("UICorner", soundBtn)
sCorner.CornerRadius = UDim.new(0,6)

-- Reset Button
local resetBtn = Instance.new("TextButton", panel)
resetBtn.Size = UDim2.new(0,200,0,32)
resetBtn.LayoutOrder = 8
resetBtn.Text = "Sıfırla"
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 18
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
local rsCorner = Instance.new("UICorner", resetBtn)
rsCorner.CornerRadius = UDim.new(0,6)

--============================================================
--  ▼ UI Events
--============================================================
toggleBtn.MouseButton1Click:Connect(function()
	ringEnabled = not ringEnabled
	toggleBtn.Text = "Halka: "..(ringEnabled and "Açık" or "Kapalı")
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		if ringEnabled then buildRing(hrp) else clearRing(hrp) end
	end
end)

applyBtn.MouseButton1Click:Connect(function()
	local v = tonumber(rangeBox.Text)
	if v and v>0 then
		currentRange = v
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then buildRing(hrp) end
	end
end)

soundBtn.MouseButton1Click:Connect(function()
	soundEnabled = not soundEnabled
	soundBtn.Text = "Ses: "..(soundEnabled and "Açık" or "Kapalı")
end)

resetBtn.MouseButton1Click:Connect(function()
	ringEnabled, currentRange, ringColor, soundEnabled =
		true, DEFAULT_RANGE, DEFAULT_RING_COLOR, true
	toggleBtn.Text = "Halka: Açık"
	soundBtn.Text  = "Ses: Açık"
	rangeBox.Text  = tostring(currentRange)
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if hrp then buildRing(hrp) end
end)

--============================================================
--  ▼ Character & Ball Logic
--============================================================
local function onCharacter(char)
	local hrp = char:WaitForChild("HumanoidRootPart",3)
	if not hrp then return end
	buildRing(hrp)
	local beep = getSound(hrp)
	local prevInside = false

	task.spawn(function()
		local ball
		repeat
			local m = workspace:FindFirstChild(BALL_MODEL, true)
			ball = m and m:FindFirstChild(BALL_PART, true)
			task.wait(0.2)
		until ball and ball:IsA("BasePart")

		local label = getLabel(ball)
		label.Text = ""
		label.TextColor3 = Color3.new(1,1,1)

		RunService.Heartbeat:Connect(function()
			local inside = (ball.Position - hrp.Position).Magnitude <= currentRange
			if inside and not prevInside and soundEnabled then beep:Play() end
			prevInside = inside

			label.Text = inside and "Reachable" or "Unreachable!"
			label.TextColor3 = inside and DEFAULT_IN_COLOR or Color3.new(1,0,0)
		end)
	end)
end

if lp.Character then onCharacter(lp.Character) end
lp.CharacterAdded:Connect(onCharacter)
