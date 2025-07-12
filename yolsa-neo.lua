--============================================================
--  Neo Soccer League • Exploit-Tarzı Sekmeli UI + Kick-Hitbox
--  Tam LocalScript – 2025-07-12
--============================================================
--  Videodaki stil: koyu zemin, neon vurgu, sekmeli yan menü,
--  sürüklenebilir başlık.              :contentReference[oaicite:0]{index=0}
--============================================================

--▼ Ayarlar ---------------------------------------------------
local DEFAULT_RANGE      = 10.22
local DEFAULT_RING_COLOR = Color3.fromRGB(0, 128, 255)
local ACCENT_COLOR       = Color3.fromRGB(0, 170, 255)
local SOUND_ID           = "rbxassetid://541909867"

local SEGMENTS           = 48
local BAR_W, BAR_H       = 0.2, 0.05
local BALL_MODEL, BALL_PART = "PLAIN_BALL", "HITBOX_BALL"

--▼ Servisler -------------------------------------------------
local Players, RunService, TweenService, CoreGui =
      game:GetService("Players"), game:GetService("RunService"),
      game:GetService("TweenService"), game:GetService("CoreGui")
local lp = Players.LocalPlayer

--▼ Durum -----------------------------------------------------
local ringEnabled, currentRange, ringColor, soundEnabled =
      true,        DEFAULT_RANGE, DEFAULT_RING_COLOR, true

--============================================================
-- 1) UI Kurulumu (sekmeli) ----------------------------------
--============================================================
local gui     = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior = "HitboxUI", false, Enum.ZIndexBehavior.Global

--++ Ana Pencere ++++++++++++++++++++++++++++++
local window  = Instance.new("Frame", gui)
window.Size, window.Position = UDim2.fromOffset(420, 280), UDim2.fromOffset(60, 120)
window.BackgroundColor3, window.BackgroundTransparency = Color3.fromRGB(25,25,25), 0.08
window.BorderSizePixel = 0
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
-- gölge
local shadow = Instance.new("ImageLabel", window)
shadow.Size, shadow.Position = UDim2.new(1, 14, 1, 14), UDim2.fromOffset(-7,-7)
shadow.Image, shadow.ImageTransparency, shadow.BackgroundTransparency =
    "rbxassetid://1316045217", 0.7, 1
shadow.ScaleType, shadow.SliceCenter, shadow.ZIndex = Enum.ScaleType.Slice, Rect.new(10,10,118,118), -1

--++ Başlık Bar +++++++++++++++++++++++++++++++++
local titleBar = Instance.new("Frame", window)
titleBar.Size = UDim2.new(1,0,0,30)
titleBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,8)
local tLabel = Instance.new("TextLabel", titleBar)
tLabel.Size, tLabel.Position = UDim2.new(1,-60,1,0), UDim2.fromOffset(10,0)
tLabel.BackgroundTransparency, tLabel.TextXAlignment = 1, Enum.TextXAlignment.Left
tLabel.Font, tLabel.TextSize, tLabel.TextColor3 = Enum.Font.GothamBold, 18, ACCENT_COLOR
tLabel.Text = "Neo Soccer • Hitbox GUI"
-- kapat
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size, closeBtn.Position = UDim2.fromOffset(24,24), UDim2.fromScale(1,0)+UDim2.fromOffset(-32,3)
closeBtn.Text, closeBtn.Font, closeBtn.TextSize = "×", Enum.Font.GothamBlack, 22
closeBtn.BackgroundTransparency, closeBtn.TextColor3 = 1, Color3.new(1,1,1)
closeBtn.MouseButton1Click:Connect(function() window.Visible = not window.Visible end)

-- sürükle
local drag, startPos, dragSt
titleBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; dragSt=i.Position; startPos=window.Position end end)
titleBar.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        window.Position = UDim2.fromOffset(startPos.X.Offset+(i.Position-dragSt).X, startPos.Y.Offset+(i.Position-dragSt).Y)
    end
end)
titleBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)

--++ Yan Sekme Çubuğu +++++++++++++++++++++++++
local side = Instance.new("Frame", window)
side.Size = UDim2.new(0, 90, 1, -30)
side.Position = UDim2.fromOffset(0,30)
side.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", side).CornerRadius = UDim.new(0,8)
-- sekme düzeni
local tabList = Instance.new("UIListLayout", side)
tabList.Padding, tabList.FillDirection = UDim.new(0,4), Enum.FillDirection.Vertical
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.VerticalAlignment = Enum.VerticalAlignment.Top
tabList.Padding = UDim.new(0,6)

local pages = {}  -- container’lar
local currentPage

local function makeTab(name, icon, order)
    local btn = Instance.new("TextButton", side)
    btn.LayoutOrder, btn.Size = order, UDim2.fromOffset(70,30)
    btn.Text = icon.."  "..name
    btn.Font, btn.TextSize = Enum.Font.GothamMedium, 15
    btn.TextColor3, btn.BackgroundColor3 = Color3.new(1,1,1), Color3.fromRGB(35,35,35)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    -- page container
    local page = Instance.new("Frame", window)
    page.Visible = false
    page.Size, page.Position = UDim2.new(1,-100,1,-40), UDim2.fromOffset(100,40)
    page.BackgroundTransparency = 1
    pages[name] = page
    -- tab click
    btn.MouseButton1Click:Connect(function()
        if currentPage then currentPage.Visible=false end
        currentPage = page; page.Visible=true
        for _,b in ipairs(side:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3=Color3.fromRGB(35,35,35) end end
        btn.BackgroundColor3 = ACCENT_COLOR
    end)
    return page
end

local generalPage = makeTab("General","⚙",1)
local colorPage   = makeTab("Colors","🎨",2)
local audioPage   = makeTab("Audio","🔊",3)
-- varsayılan aç
task.defer(function() side:GetChildren()[1]:FindFirstChildOfClass("TextButton"):Activate() end)

--++ Genel Sekme Elemanları -------------------------------
local function gButton(txt, parent)
    local b = mkButton(txt); b.Parent = parent; return b
end
local function gInput(def,parent)
    local i = mkInput(def); i.Parent = parent; return i
end
local genList = Instance.new("UIListLayout", generalPage)
genList.Padding = UDim.new(0,4); genList.HorizontalAlignment=Enum.HorizontalAlignment.Center

local ringToggle = gButton("Ring: ON", generalPage)
local rangeInput = gInput(tostring(currentRange), generalPage)
local applyBtn   = gButton("Apply", generalPage)

--++ Color Sekme  ----------------------------------------
local colList = Instance.new("UIGridLayout", colorPage)
colList.CellPadding, colList.CellSize = UDim2.fromOffset(6,6), UDim2.fromOffset(60,28)

for _,opt in ipairs(colorOptions) do
    local c = mkButton(opt[1],24); c.BackgroundColor3 = opt[2]; c.Parent = colorPage
    c.MouseButton1Click:Connect(function()
        ringColor = opt[2]; local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then buildRing(hrp) end
    end)
end

--++ Audio Sekme -----------------------------------------
local audToggle = mkButton("Sound: ON", audioPage); audToggle.Parent = audioPage

--============================================================
-- 2) Halka, Ses, Etiket İşlevleri
--============================================================
local function clearRing(hrp) for _,c in ipairs(hrp:GetChildren()) do if c.Name=="KickSeg" then c:Destroy() end end end

function buildRing(hrp)
    clearRing(hrp); if not ringEnabled then return end
    local y = -hrp.Size.Y/2 + BAR_H/2 + 0.05
    local step, chord = (2*math.pi)/SEGMENTS, 2*currentRange*math.sin(math.pi/SEGMENTS)
    for i=0, SEGMENTS-1 do
        local th = i*step + step/2
        local seg = Instance.new("Part")
        seg.Name, seg.Size = "KickSeg", Vector3.new(chord,BAR_H,BAR_W)
        seg.Color, seg.Transparency, seg.Material = ringColor, 0.25, Enum.Material.Neon
        seg.Anchored, seg.CanCollide, seg.Massless = false,false,true
        seg.CFrame = hrp.CFrame * CFrame.new(math.cos(th)*currentRange,y,math.sin(th)*currentRange) * CFrame.Angles(0,-th,0)
        seg.Parent = hrp
        Instance.new("WeldConstraint", seg).Part0, seg.Part1
    end
end

local function getSound(hrp)
    local s = hrp:FindFirstChild("KickSnd") or Instance.new("Sound", hrp)
    s.Name, s.SoundId, s.Volume = "KickSnd", SOUND_ID, 1; return s
end

local function getLabel(ball)
    local gui = ball:FindFirstChild("ReachGui") or Instance.new("BillboardGui", ball)
    gui.Name, gui.Size, gui.AlwaysOnTop, gui.StudsOffset = "ReachGui", UDim2.fromOffset(130,34), true, Vector3.new(0,ball.Size.Y/2+1.8,0)
    local lbl = gui:FindFirstChild("Lbl") or Instance.new("TextLabel", gui)
    lbl.Name, lbl.Size, lbl.BackgroundTransparency = "Lbl", UDim2.fromScale(1,1), 1
    lbl.Font, lbl.TextScaled, lbl.TextStrokeTransparency = Enum.Font.GothamBold, true, 0.7
    return lbl
end

--============================================================
-- 3) UI Olayları -------------------------------------------
--============================================================
ringToggle.MouseButton1Click:Connect(function()
    ringEnabled = not ringEnabled
    ringToggle.Text = "Ring: "..(ringEnabled and "ON" or "OFF")
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then (ringEnabled and buildRing or clearRing)(hrp) end
end)

applyBtn.MouseButton1Click:Connect(function()
    local v = tonumber(rangeInput.Text); if v and v>0 then currentRange=v end
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then buildRing(hrp) end
end)

audToggle.MouseButton1Click:Connect(function()
    soundEnabled = not soundEnabled
    audToggle.Text = "Sound: "..(soundEnabled and "ON" or "OFF")
end)

resetBtn.MouseButton1Click:Connect(function()
    ringEnabled, currentRange, ringColor, soundEnabled =
        true, DEFAULT_RANGE, DEFAULT_RING_COLOR, true
    ringToggle.Text, audToggle.Text, rangeInput.Text = "Ring: ON","Sound: ON",tostring(currentRange)
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then buildRing(hrp) end
end)

--============================================================
-- 4) Karakter & Top Takibi ----------------------------------
--============================================================
local function onChar(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    buildRing(hrp)
    local beep = getSound(hrp); local prev=false
    task.spawn(function()
        local ball repeat
            ball = workspace:FindFirstChild(BALL_MODEL,true); ball = ball and ball:FindFirstChild(BALL_PART,true)
            task.wait(0.2)
        until ball and ball:IsA("BasePart")
        local lbl = getLabel(ball)

        RunService.Heartbeat:Connect(function()
            local inside = (ball.Position-hrp.Position).Magnitude<=currentRange
            if inside and not prev and soundEnabled then beep:Play() end
            prev = inside
            lbl.Text, lbl.TextColor3 = inside and "Reachable" or "Unreachable!",
                inside and Color3.new(0,1,0) or Color3.new(1,0,0)
        end)
    end)
end
if lp.Character then onChar(lp.Character) end
lp.CharacterAdded:Connect(onChar)
