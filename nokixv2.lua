local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Teams = game:GetService("Teams")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = workspace
local UserInputService = game:GetService("UserInputService")

local ESP_UPDATE_INTERVAL = 0.08
local AIMBOT_UPDATE_INTERVAL = 0.03
local RAY_INTERVAL = 0.12
local espTick = 0
local aimTick = 0
local rayTick = 0
local cachedTargets = {}
local visibilityCache = {}

local PlayerCache = {}

local State = {
    AimbotEnabled = false,
    LockTeammates = true,
    DisableWallLock = true,
    AimbotFOV = 50,
    AimbotTargetPart = "Head",
    ShowFOV = true,
    ESP = {
        BoxESP = false,
        OutlineESP = false,
        NameESP = false,
        DistanceESP = false,
        ESPTeammates = false
    },
    FlyEnabled = false,
    FlySpeed = 50,
    NoClip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    SelectedPlayer = nil,
    ReturnPosition = nil
}

local Theme = {
    Primary  = Color3.fromRGB(26, 115, 232),
    Background = Color3.fromRGB(10, 14, 28),
    Gradient = Color3.fromRGB(20, 60, 120),
    Text     = Color3.fromRGB(210, 230, 255),
    Muted    = Color3.fromRGB(120, 160, 200),
}

local Messages = {
    "Connecting to Nokix Hub...",
    "Loading modules...",
    "Preparing interface...",
    "Almost there...",
}
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NokixHubLoader"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui
local container = Instance.new("Frame")
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.Size = UDim2.new(0, 0, 0, 0)
container.BackgroundColor3 = Theme.Background
container.BorderSizePixel = 0
container.Parent = screenGui
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 18)
local grad = Instance.new("UIGradient", container)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Background),
    ColorSequenceKeypoint.new(1, Theme.Gradient),
})
grad.Rotation = 100
local stroke = Instance.new("UIStroke", container)
stroke.Color = Theme.Primary
stroke.Thickness = 2
stroke.Transparency = 0.3
local glow = Instance.new("UIStroke", container)
glow.Color = Theme.Primary
glow.Thickness = 6
glow.Transparency = 1
glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local logo = Instance.new("Frame", container)
logo.AnchorPoint = Vector2.new(0.5, 0)
logo.Position = UDim2.new(0.5, 0, 0, 28)
logo.Size = UDim2.new(0, 64, 0, 64)
logo.BackgroundColor3 = Theme.Primary
logo.BorderSizePixel = 0
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 16)
local logoText = Instance.new("TextLabel", logo)
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "N"
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.TextSize = 32
logoText.Font = Enum.Font.GothamBold
local title = Instance.new("TextLabel", container)
title.Size = UDim2.new(1, -40, 0, 32)
title.Position = UDim2.new(0, 20, 0, 100)
title.BackgroundTransparency = 1
title.Text = "Nokix Hub"
title.TextColor3 = Theme.Text
title.TextSize = 24
title.Font = Enum.Font.GothamBold
local subtitle = Instance.new("TextLabel", container)
subtitle.Size = UDim2.new(1, -40, 0, 18)
subtitle.Position = UDim2.new(0, 20, 0, 132)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Created by Nokix"
subtitle.TextColor3 = Theme.Muted
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
local barBg = Instance.new("Frame", container)
barBg.Size = UDim2.new(1, -60, 0, 6)
barBg.Position = UDim2.new(0, 30, 0, 168)
barBg.BackgroundColor3 = Theme.Gradient
barBg.BorderSizePixel = 0
barBg.ClipsDescendants = true
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Theme.Primary
barFill.BorderSizePixel = 0
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
local barGrad = Instance.new("UIGradient", barFill)
barGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Primary),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 170, 255)),
})
local shine = Instance.new("Frame", barFill)
shine.Size = UDim2.new(0.3, 0, 1, 0)
shine.Position = UDim2.new(-0.3, 0, 0, 0)
shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shine.BackgroundTransparency = 0.5
shine.BorderSizePixel = 0
local statusText = Instance.new("TextLabel", container)
statusText.Size = UDim2.new(1, -40, 0, 18)
statusText.Position = UDim2.new(0, 20, 0, 190)
statusText.BackgroundTransparency = 1
statusText.Text = Messages[1]
statusText.TextColor3 = Theme.Muted
statusText.TextSize = 12
statusText.Font = Enum.Font.Code
local percentText = Instance.new("TextLabel", container)
percentText.Size = UDim2.new(1, -40, 0, 18)
percentText.Position = UDim2.new(0, 20, 0, 210)
percentText.BackgroundTransparency = 1
percentText.Text = "0%"
percentText.TextColor3 = Theme.Primary
percentText.TextSize = 14
percentText.Font = Enum.Font.GothamBold
percentText.TextTransparency = 1
for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") and c ~= percentText then c.TextTransparency = 1
    elseif c:IsA("Frame") and c ~= barFill and c ~= shine then c.BackgroundTransparency = 1
    elseif c:IsA("UIStroke") then c.Transparency = 1 end
end
local shineRunning = true
task.spawn(function()
    while shineRunning do
        shine.Position = UDim2.new(-0.3, 0, 0, 0)
        TweenService:Create(shine, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(1.3, 0, 0, 0) }):Play()
        task.wait(1.2)
    end
end)
TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = 16 }):Play()
local intro = TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 380, 0, 250) })
intro:Play()
intro.Completed:Wait()
for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
    elseif c:IsA("Frame") and c ~= shine then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
    elseif c:IsA("UIStroke") and c ~= glow then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.3 }):Play()
    end
    task.wait(0.015)
end
TweenService:Create(shine, TweenInfo.new(0.5), { BackgroundTransparency = 0.5 }):Play()
local currentProgress = 0
for i, msg in ipairs(Messages) do
    local textOut = TweenService:Create(statusText, TweenInfo.new(0.15), { TextTransparency = 1 })
    textOut:Play()
    textOut.Completed:Wait()
    statusText.Text = msg
    TweenService:Create(statusText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
    local targetProgress = ({0.25, 0.50, 0.75, 1.00})[i]
    local duration = 0.4
    local startProgress = currentProgress
    local stepAmount = targetProgress - startProgress
    for t = 0, 1, 0.02 do
        local eased = t * t * (3 - 2 * t)
        local progress = startProgress + (stepAmount * eased)
        barFill.Size = UDim2.new(progress, 0, 1, 0)
        percentText.Text = string.format("%.0f%%", progress * 100)
        task.wait(duration / 50)
    end
    currentProgress = targetProgress
    task.wait(0.15)
end
barFill.Size = UDim2.new(1, 0, 1, 0)
percentText.Text = "100%"
statusText.Text = "Complete!"
TweenService:Create(glow, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.5 }):Play()
task.wait(0.35)
shineRunning = false
TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Size = 0 }):Play()
local outro = TweenService:Create(container, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") then TweenService:Create(c, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
    elseif c:IsA("Frame") then TweenService:Create(c, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
    elseif c:IsA("UIStroke") then TweenService:Create(c, TweenInfo.new(0.3), { Transparency = 1 }):Play() end
end
outro:Play()
outro.Completed:Wait()
screenGui:Destroy()


local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Theme.Primary
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Visible = true
end)

local function isTeammate(p)
    return LocalPlayer.Team and p.Team == LocalPlayer.Team
end
local function isVisible(part)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local r = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
    return r and r.Instance:IsDescendantOf(part.Parent)
end
local function getESPColor(p)
    if #Teams:GetChildren() > 0 and p.TeamColor then
        return p.TeamColor.Color
    end
    return Theme.Primary
end
local function getDistance(pos1, pos2)
    return math.floor((pos1 - pos2).Magnitude)
end

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "NokixHub_GUI"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 320, 0, 310)  -- FIX: was 280, now 310
Main.Position = UDim2.new(0.5, -160, 0.5, -155)
Main.BackgroundColor3 = Theme.Background
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Theme.Primary
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -40, 0, 22)
Title.Position = UDim2.new(0, 10, 0, 4)
Title.Text = "Nokix Hub - UNIVERSAL V2"
Title.TextColor3 = Theme.Primary
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 24, 0, 20)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local FloatGui = Instance.new("ScreenGui", CoreGui)
FloatGui.Enabled = false
FloatGui.ResetOnSpawn = false
local FloatBtn = Instance.new("TextButton", FloatGui)
FloatBtn.Size = UDim2.new(0, 120, 0, 32)
FloatBtn.Position = UDim2.new(1, -130, 0, 10)
FloatBtn.Text = "OPEN NOKIX"
FloatBtn.BackgroundColor3 = Theme.Primary
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 14
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function()
    Gui.Enabled = false
    FloatGui.Enabled = true
end)
FloatBtn.MouseButton1Click:Connect(function()
    Gui.Enabled = true
    FloatGui.Enabled = false
end)

-- Tab buttons
local TAB_H = 26
local btnA = Instance.new("TextButton", Main)
btnA.Size = UDim2.new(0, 95, 0, TAB_H)
btnA.Position = UDim2.new(0, 5, 0, 28)
btnA.Text = "Aimbot"
btnA.BackgroundColor3 = Theme.Primary
btnA.TextColor3 = Color3.fromRGB(255, 255, 255)
btnA.Font = Enum.Font.GothamBold
btnA.TextSize = 11
Instance.new("UICorner", btnA).CornerRadius = UDim.new(0, 6)

local btnE = Instance.new("TextButton", Main)
btnE.Size = UDim2.new(0, 95, 0, TAB_H)
btnE.Position = UDim2.new(0, 105, 0, 28)
btnE.Text = "ESP"
btnE.BackgroundColor3 = Theme.Gradient
btnE.TextColor3 = Color3.fromRGB(255, 255, 255)
btnE.Font = Enum.Font.GothamBold
btnE.TextSize = 11
Instance.new("UICorner", btnE).CornerRadius = UDim.new(0, 6)

local btnM = Instance.new("TextButton", Main)
btnM.Size = UDim2.new(0, 95, 0, TAB_H)
btnM.Position = UDim2.new(0, 205, 0, 28)
btnM.Text = "Movement"
btnM.BackgroundColor3 = Theme.Gradient
btnM.TextColor3 = Color3.fromRGB(255, 255, 255)
btnM.Font = Enum.Font.GothamBold
btnM.TextSize = 11
Instance.new("UICorner", btnM).CornerRadius = UDim.new(0, 6)

-- FIX: Use ScrollingFrame so content never gets clipped
local CONTENT_Y = 60
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -10, 1, -(CONTENT_Y + 4))
Content.Position = UDim2.new(0, 5, 0, CONTENT_Y)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Theme.Primary
Content.CanvasSize = UDim2.new(0, 0, 0, 0)  -- will be set per tab
Content.ClipsDescendants = true

local AimbotFrame = Instance.new("Frame", Content)
AimbotFrame.Size = UDim2.new(1, 0, 0, 200)
AimbotFrame.BackgroundTransparency = 1

local ESPFrame = Instance.new("Frame", Content)
ESPFrame.Size = UDim2.new(1, 0, 0, 130)
ESPFrame.BackgroundTransparency = 1
ESPFrame.Visible = false

local MovementFrame = Instance.new("Frame", Content)
MovementFrame.Size = UDim2.new(1, 0, 0, 260)  -- FIX: explicit height for scroll
MovementFrame.BackgroundTransparency = 1
MovementFrame.Visible = false

local function setTab(frame, height)
    AimbotFrame.Visible = false
    ESPFrame.Visible = false
    MovementFrame.Visible = false
    frame.Visible = true
    Content.CanvasSize = UDim2.new(0, 0, 0, height)
    Content.CanvasPosition = Vector2.new(0, 0)
end

btnA.MouseButton1Click:Connect(function()
    setTab(AimbotFrame, 200)
    btnA.BackgroundColor3 = Theme.Primary
    btnE.BackgroundColor3 = Theme.Gradient
    btnM.BackgroundColor3 = Theme.Gradient
end)
btnE.MouseButton1Click:Connect(function()
    setTab(ESPFrame, 130)
    btnA.BackgroundColor3 = Theme.Gradient
    btnE.BackgroundColor3 = Theme.Primary
    btnM.BackgroundColor3 = Theme.Gradient
end)
btnM.MouseButton1Click:Connect(function()
    setTab(MovementFrame, 260)
    btnA.BackgroundColor3 = Theme.Gradient
    btnE.BackgroundColor3 = Theme.Gradient
    btnM.BackgroundColor3 = Theme.Primary
end)

Content.CanvasSize = UDim2.new(0, 0, 0, 200)

local ROW = 26  -- compact row height

local function toggle(parent, text, y, default, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -4, 0, ROW - 4)
    b.Position = UDim2.new(0, 2, 0, y)
    b.Text = text .. ": " .. (default and "ON" or "OFF")
    b.BackgroundColor3 = default and Theme.Primary or Color3.fromRGB(15, 30, 60)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local s = default
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = text .. ": " .. (s and "ON" or "OFF")
        b.BackgroundColor3 = s and Theme.Primary or Color3.fromRGB(15, 30, 60)
        cb(s)
    end)
end

local function slider(parent, text, y, min, max, start, cb)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -58, 0, 16)
    lbl.Position = UDim2.new(0, 2, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. start
    lbl.TextColor3 = Color3.fromRGB(220, 235, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBg = Instance.new("Frame", parent)
    sliderBg.Size = UDim2.new(1, -66, 0, 5)
    sliderBg.Position = UDim2.new(0, 2, 0, y + 17)
    sliderBg.BackgroundColor3 = Color3.fromRGB(15, 30, 60)
    sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((start - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Primary
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local function update(v)
        v = math.clamp(v, min, max)
        lbl.Text = text .. ": " .. math.floor(v + 0.5)
        sliderFill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
        cb(math.floor(v + 0.5))
    end

    local btnDec = Instance.new("TextButton", parent)
    btnDec.Size = UDim2.new(0, 22, 0, 20)
    btnDec.Position = UDim2.new(1, -48, 0, y)
    btnDec.Text = "-"
    btnDec.BackgroundColor3 = Color3.fromRGB(25, 75, 140)
    btnDec.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnDec.Font = Enum.Font.GothamBold
    btnDec.TextSize = 13
    Instance.new("UICorner", btnDec).CornerRadius = UDim.new(0, 5)

    local btnInc = Instance.new("TextButton", parent)
    btnInc.Size = UDim2.new(0, 22, 0, 20)
    btnInc.Position = UDim2.new(1, -24, 0, y)
    btnInc.Text = "+"
    btnInc.BackgroundColor3 = Color3.fromRGB(25, 75, 140)
    btnInc.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnInc.Font = Enum.Font.GothamBold
    btnInc.TextSize = 13
    Instance.new("UICorner", btnInc).CornerRadius = UDim.new(0, 5)

    btnDec.MouseButton1Click:Connect(function()
        local cur = tonumber(lbl.Text:match("%d+$")) or start
        update(cur - 1)
    end)
    btnInc.MouseButton1Click:Connect(function()
        local cur = tonumber(lbl.Text:match("%d+$")) or start
        update(cur + 1)
    end)
    return update
end

local function btn(parent, text, y, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -4, 0, ROW - 2)
    b.Position = UDim2.new(0, 2, 0, y)
    b.Text = text
    b.BackgroundColor3 = Theme.Gradient
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(cb)
end

toggle(AimbotFrame, "Enable Aimbot",    0,  false, function(v) State.AimbotEnabled = v end)
toggle(AimbotFrame, "Lock Teammates",   26, true,  function(v) State.LockTeammates = v end)
toggle(AimbotFrame, "Disable Wall Lock",52, true,  function(v) State.DisableWallLock = v end)
toggle(AimbotFrame, "Show FOV",         78, true,  function(v) State.ShowFOV = v end)

local FOVLabel = Instance.new("TextLabel", AimbotFrame)
FOVLabel.Position = UDim2.new(0, 2, 0, 104)
FOVLabel.Size = UDim2.new(1, -58, 0, 16)
FOVLabel.Text = "FOV: 50"
FOVLabel.TextColor3 = Color3.fromRGB(220, 235, 255)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 11
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left

local fovBar = Instance.new("Frame", AimbotFrame)
fovBar.Size = UDim2.new(1, -66, 0, 5)
fovBar.Position = UDim2.new(0, 2, 0, 121)
fovBar.BackgroundColor3 = Color3.fromRGB(15, 30, 60)
Instance.new("UICorner", fovBar).CornerRadius = UDim.new(1, 0)
local fovFill = Instance.new("Frame", fovBar)
fovFill.Size = UDim2.new(50/500, 0, 1, 0)
fovFill.BackgroundColor3 = Theme.Primary
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(1, 0)

local function fovBtn(xOff, text, delta)
    local b = Instance.new("TextButton", AimbotFrame)
    b.Size = UDim2.new(0, 22, 0, 20)
    b.Position = UDim2.new(1, xOff, 0, 104)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(25, 75, 140)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function()
        State.AimbotFOV = math.clamp(State.AimbotFOV + delta, 10, 500)
        FOVLabel.Text = "FOV: " .. State.AimbotFOV
        fovFill.Size = UDim2.new((State.AimbotFOV - 10) / 490, 0, 1, 0)
    end)
end
fovBtn(-48, "+", 10)
fovBtn(-24, "-", -10)

local PartBtn = Instance.new("TextButton", AimbotFrame)
PartBtn.Size = UDim2.new(1, -4, 0, ROW - 2)
PartBtn.Position = UDim2.new(0, 2, 0, 130)
PartBtn.Text = "Target: Head"
PartBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 60)
PartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PartBtn.Font = Enum.Font.Gotham
PartBtn.TextSize = 11
Instance.new("UICorner", PartBtn).CornerRadius = UDim.new(0, 5)
PartBtn.MouseButton1Click:Connect(function()
    State.AimbotTargetPart = State.AimbotTargetPart == "Head" and "Torso" or "Head"
    PartBtn.Text = "Target: " .. State.AimbotTargetPart
end)

toggle(ESPFrame, "Box ESP",      0,   false, function(v) State.ESP.BoxESP = v end)
toggle(ESPFrame, "Outline ESP",  26,  false, function(v) State.ESP.OutlineESP = v end)
toggle(ESPFrame, "Name ESP",     52,  false, function(v) State.ESP.NameESP = v end)
toggle(ESPFrame, "Distance ESP", 78,  false, function(v) State.ESP.DistanceESP = v end)
toggle(ESPFrame, "Team ESP",     104, false, function(v) State.ESP.ESPTeammates = v end)
toggle(MovementFrame, "Enable Fly",     0,   false, function(v) State.FlyEnabled = v end)
slider(MovementFrame, "Fly Speed",      26,  16, 200, 50,  function(v) State.FlySpeed = v end)
toggle(MovementFrame, "No Clip",        56,  false, function(v) State.NoClip = v end)
slider(MovementFrame, "Walk Speed",     84,  16, 200, 16,  function(v)
    State.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)
slider(MovementFrame, "Jump Power",     114, 50, 200, 50,  function(v)
    State.JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)
toggle(MovementFrame, "Infinite Jump",  144, false, function(v) State.InfiniteJump = v end)
btn(MovementFrame, "TP To Nearest Player", 172, function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local nearest, dist = nil, math.huge
    for p, _ in pairs(PlayerCache) do  -- FIX: PlayerCache now valid here
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; nearest = p end
        end
    end
    if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
        State.ReturnPosition = root.CFrame
        root.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end)
btn(MovementFrame, "TP Back / Return", 200, function()
    if not State.ReturnPosition then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = State.ReturnPosition
    end
end)

local ESPTable = {}
local function createESP(player)
    if player == LocalPlayer then return end
    local function onChar(char)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end
        -- Clean up old ESP for this player first
        if ESPTable[player] then
            for _, v in pairs(ESPTable[player]) do
                if typeof(v) == "Instance" then pcall(function() v:Destroy() end) end
            end
        end
        local box = Instance.new("BoxHandleAdornment", Workspace)
        box.Adornee = char
        box.Size = Vector3.new(4, 6, 2)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.6
        local outline = Instance.new("Highlight", Workspace)
        outline.Adornee = char
        outline.FillTransparency = 1
        outline.OutlineTransparency = 0
        outline.OutlineColor = Theme.Primary
        outline.Enabled = false
        local bb = Instance.new("BillboardGui", Workspace)
        bb.Adornee = root
        bb.Size = UDim2.new(0, 120, 0, 40)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 12
        ESPTable[player] = {Box = box, Outline = outline, BB = bb, TXT = txt, Root = root, Char = char}
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end
local function addPlayer(p)
    if p ~= LocalPlayer then PlayerCache[p] = true; createESP(p) end
end
local function removePlayer(p)
    PlayerCache[p] = nil
    visibilityCache[p] = nil
    if ESPTable[p] then
        for _, v in pairs(ESPTable[p]) do
            if typeof(v) == "Instance" then pcall(function() v:Destroy() end) end
        end
        ESPTable[p] = nil
    end
end
for _, p in ipairs(Players:GetPlayers()) do addPlayer(p) end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(function()
    if State.FlyEnabled then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
        local root = char.HumanoidRootPart
        local hum = char.Humanoid
        hum.PlatformStand = true
        local camCF = Camera.CFrame
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
        root.AssemblyLinearVelocity = moveDir * State.FlySpeed
    else
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
        end
    end
    if State.NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    rayTick  = rayTick  + dt
    espTick  = espTick  + dt
    aimTick  = aimTick  + dt
    local doRay       = rayTick  >= RAY_INTERVAL
    local doESP       = espTick  >= ESP_UPDATE_INTERVAL
    local doAimUpdate = aimTick  >= AIMBOT_UPDATE_INTERVAL
    if doRay       then rayTick  = 0 end
    if doESP       then espTick  = 0 end
    if doAimUpdate then aimTick  = 0 end

    local camPos      = Camera.CFrame.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if doESP then
        for p, _ in pairs(PlayerCache) do
            local e = ESPTable[p]
            if e and e.Char and e.Root then
                local hum = e.Char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local teamOK = not isTeammate(p) or State.ESP.ESPTeammates
                    local color = getESPColor(p)
                    e.Box.Visible     = State.ESP.BoxESP     and teamOK
                    e.Box.Color3      = color
                    e.Outline.Enabled = State.ESP.OutlineESP and teamOK
                    e.Outline.OutlineColor = color
                    local bbEnabled   = teamOK and (State.ESP.NameESP or State.ESP.DistanceESP)
                    e.BB.Enabled      = bbEnabled
                    if bbEnabled then
                        local text = ""
                        if State.ESP.NameESP then text = p.Name end
                        if State.ESP.DistanceESP then
                            local d = getDistance(camPos, e.Root.Position)
                            text = text ~= "" and text .. " [" .. d .. "]" or d .. " studs"
                        end
                        e.TXT.Text       = text
                        e.TXT.TextColor3 = color
                    end
                else
                    e.Box.Visible     = false
                    e.Outline.Enabled = false
                    e.BB.Enabled      = false
                end
            end
        end
    end

    if FOVCircle then
        FOVCircle.Visible = State.ShowFOV
        FOVCircle.Radius  = State.AimbotFOV
        FOVCircle.Position = screenCenter
    end

    if doAimUpdate then
        cachedTargets = {}
        for p, _ in pairs(PlayerCache) do
            local char = p.Character
            if char then
                local hum  = char:FindFirstChild("Humanoid")
                local part = char:FindFirstChild(State.AimbotTargetPart == "Head" and "Head" or "HumanoidRootPart")
                if hum and hum.Health > 0 and part then
                    if not (State.LockTeammates and isTeammate(p)) then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            if dist <= State.AimbotFOV then
                                table.insert(cachedTargets, {part = part, dist = dist, player = p})
                            end
                        end
                    end
                end
            end
        end
        table.sort(cachedTargets, function(a, b) return a.dist < b.dist end)
    end

    if State.AimbotEnabled and #cachedTargets > 0 then
        for i = 1, #cachedTargets do
            local data = cachedTargets[i]
            if State.DisableWallLock then
                if doRay then visibilityCache[data.player] = isVisible(data.part) end
                if not visibilityCache[data.player] then continue end
            end
            Camera.CFrame = CFrame.lookAt(camPos, data.part.Position)
            break
        end
    end
end)
