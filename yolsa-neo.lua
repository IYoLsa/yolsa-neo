--============================================================
--  Neo Soccer League • Kick-Hitbox, Ayar UI, Ses + “Reachable” etiketi
--============================================================

------------------ GENEL AYARLAR ------------------
local DEFAULT_RANGE      = 10.22
local DEFAULT_RING_COLOR = Color3.fromRGB(0,128,255)
local DEFAULT_IN_COLOR   = Color3.fromRGB(0,255,0)
local DEFAULT_IN_TRANS   = 0.4
local SOUND_ID           = "rbxassetid://541909867"      -- kısa bip

local SEGMENTS = 48
local BAR_W    = 0.2
local BAR_H    = 0.05

local BALL_MODEL = "PLAIN_BALL"
local BALL_PART  = "HITBOX_BALL"

------------------ SERVİSLER ------------------
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui    = game:GetService("CoreGui")
local lp         = Players.LocalPlayer

------------------ DURUM ------------------
local ringEnabled  = true
local currentRange = DEFAULT_RANGE
local ringColor    = DEFAULT_RING_COLOR
local soundEnabled = true

--============================================================
--  ▼ UI PANELİ
--============================================================
local ui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ui.Name = "HitboxSettingsUI"

local panel = Instance.new("Frame", ui)
panel.Size, panel.Position = UDim2.fromOffset(220, 268), UDim2.fromOffset(20, 100)
panel.BackgroundColor3, panel.BorderSizePixel = Color3.fromRGB(30,30,30), 0

local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment, layout.VerticalAlignment = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top

local function makeLabel(text, order)
	local l = Instance.new("TextLabel", panel)
	l.BackgroundTransparency, l.Size = 1, UDim2.new(1,-10,0,28)
	l.Text, l.Font, l.TextSize, l.TextColor3, l.LayoutOrder =
		text, Enum.Font.SourceSansBold, 20, Color3.new(1,1,1), order
	return l
end
makeLabel("⚙️ Hitbox Ayarları",1)

local function makeButton(text, order, h)
	local b = Instance.new("TextButton", panel)
	b.Size, b.Text, b.LayoutOrder = UDim2.fromOffset(200,h or 30), text, order
	return b
end

local toggleBtn = makeButton("Halka: Açık",2)
local rangeBox  = Instance.new("TextBox", panel)
rangeBox.Size, rangeBox.LayoutOrder, rangeBox.Text =
	UDim2.fromOffset(200,26),3,tostring(currentRange)
rangeBox.ClearTextOnFocus, rangeBox.PlaceholderText = false,"Yarıçap (stud)"

local applyBtn  = makeButton("Uygula",4,24)

-- renk butonları
for i,info in ipairs({
	{txt="Mavi",  col=Color3.fromRGB(0,128,255)},
	{txt="Yeşil", col=Color3.fromRGB(0,255,0)},
	{txt="Kırmızı",col=Color3.fromRGB(255,0,0)}
}) do
	local b = makeButton(info.txt,4+i,24)
	b.BackgroundColor3, b.TextColor3 = info.col, Color3.new(1,1,1)
	b.MouseButton1Click:Connect(function()
		ringColor = info.col
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then buildRing(hrp) end
	end)
end

local soundBtn = makeButton("Ses: Açık",8)
local resetBtn = makeButton("Sıfırla",9)

--============================================================
--  ▼ HALKA OLUŞTUR / TEMİZLE
--============================================================
local function clearRing(hrp)
	for _,p in ipairs(hrp:GetChildren()) do
		if p.Name=="KickSeg" then p:Destroy() end
	end
end

function buildRing(hrp)
	clearRing(hrp)
	if not ringEnabled then return end
	local y = -hrp.Size.Y/2 + BAR_H/2 + 0.05
	local step, chord = (2*math.pi)/SEGMENTS, 2*currentRange*math.sin(math.pi/SEGMENTS)

	for i=0, SEGMENTS-1 do
		local theta = i*step + step/2
		local pos = Vector3.new(math.cos(theta)*currentRange, y, math.sin(theta)*currentRange)
		local seg = Instance.new("Part")
		seg.Name, seg.Size = "KickSeg", Vector3.new(chord,BAR_H,BAR_W)
		seg.Color, seg.Transparency, seg.Material = ringColor,0.35,Enum.Material.Neon
		seg.Anchored, seg.CanCollide, seg.Massless = false,false,true
		seg.CFrame = hrp.CFrame * CFrame.new(pos) * CFrame.Angles(0,-theta,0)
		seg.Parent = hrp
		local weld = Instance.new("WeldConstraint", seg)
		weld.Part0, weld.Part1 = hrp, seg
	end
end

--============================================================
--  ▼ SES & ETİKET YARDIMCILARI
--============================================================
local function getSound(hrp)
	local s = hrp:FindFirstChild("KickSound") or Instance.new("Sound", hrp)
	s.Name, s.SoundId, s.Volume = "KickSound", SOUND_ID, 1
	return s
end

local function getLabel(ball)
	local gui = ball:FindFirstChild("ReachGui") or Instance.new("BillboardGui", ball)
	gui.Name, gui.AlwaysOnTop, gui.Size = "ReachGui", true, UDim2.fromOffset(120,40)
	gui.StudsOffset = Vector3.new(0, ball.Size.Y/2 + 1.5, 0)
	local lbl = gui:FindFirstChild("Txt") or Instance.new("TextLabel", gui)
	lbl.Name, lbl.Size, lbl.BackgroundTransparency = "Txt", UDim2.fromScale(1,1),1
	lbl.Font, lbl.TextScaled = Enum.Font.SourceSansBold, true
	return lbl
end

--============================================================
--  ▼ UI ETKİLEŞİMLERİ
--============================================================
toggleBtn.MouseButton1Click:Connect(function()
	ringEnabled = not ringEnabled
	toggleBtn.Text = "Halka: "..(ringEnabled and "Açık" or "Kapalı")
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if hrp then (ringEnabled and buildRing or clearRing)(hrp) end
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
	toggleBtn.Text, soundBtn.Text, rangeBox.Text = "Halka: Açık","Ses: Açık",tostring(currentRange)
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if hrp then buildRing(hrp) end
end)

--============================================================
--  ▼ KARAKTER YÜKLEME
--============================================================
local function onCharacter(char)
	local hrp = char:WaitForChild("HumanoidRootPart",3)
	if not hrp then return end
	buildRing(hrp)
	local beep = getSound(hrp)
	local prev = false

	-- top bul
	task.spawn(function()
		local ball
		repeat
			local model = workspace:FindFirstChild(BALL_MODEL,true)
			ball = model and model:FindFirstChild(BALL_PART,true)
			task.wait(0.2)
		until ball and ball:IsA("BasePart")

		local lbl = getLabel(ball)

		RunService.Heartbeat:Connect(function()
			local inside = (ball.Position-hrp.Position).Magnitude <= currentRange
			if inside and not prev and soundEnabled then beep:Play() end
			prev = inside
			lbl.Text, lbl.TextColor3 = inside and "Reachable" or "Unreachable!",
				inside and Color3.new(0,1,0) or Color3.new(1,0,0)

			for _,a in ipairs(CoreGui:GetDescendants()) do
				if a.Name=="InHitbox" then a:Destroy() end
			end
			if inside then
				local ad = Instance.new("SphereHandleAdornment")
				ad.Name, ad.Adornee = "InHitbox", ball
				ad.Radius, ad.Color3, ad.Transparency = ball.Size.X/2, DEFAULT_IN_COLOR, DEFAULT_IN_TRANS
				ad.AlwaysOnTop, ad.ZIndex, ad.Parent = true,10,CoreGui
			end
		end)
	end)
end

if lp.Character then onCharacter(lp.Character) end
lp.CharacterAdded:Connect(onCharacter)
