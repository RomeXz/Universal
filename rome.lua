local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Teams = game:GetService("Teams")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = workspace

local ESP_UPDATE_INTERVAL = 0.08
local AIMBOT_UPDATE_INTERVAL = 0.03
local espTick = 0
local aimTick = 0
local cachedTargets = {}

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
    }
}

local Theme = {
    Primary = Color3.fromRGB(26, 115, 232),
    Background = Color3.fromRGB(10, 14, 28),
    Gradient = Color3.fromRGB(20, 60, 120),
    Text = Color3.fromRGB(210, 230, 255),
    Muted = Color3.fromRGB(120, 160, 200),
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

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "NokixHub_GUI"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 350, 0, 260)
Main.Position = UDim2.new(0.5, -175, 0.5, -130)
Main.BackgroundColor3 = Theme.Background
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -40, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Text = "Nokix Hub - UNIVERSAL"
Title.TextColor3 = Theme.Primary
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 24, 0, 20)
CloseBtn.Position = UDim2.new(1, -30, 0, 6)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(15, 70, 140)
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

local btnA = Instance.new("TextButton", Main)
btnA.Size = UDim2.new(0, 165, 0, 25)
btnA.Position = UDim2.new(0, 5, 0, 35)
btnA.Text = "Aimbot"
btnA.BackgroundColor3 = Theme.Gradient
btnA.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", btnA).CornerRadius = UDim.new(0, 8)

local btnE = Instance.new("TextButton", Main)
btnE.Size = UDim2.new(0, 165, 0, 25)
btnE.Position = UDim2.new(0, 175, 0, 35)
btnE.Text = "Visuals"
btnE.BackgroundColor3 = Theme.Gradient
btnE.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", btnE).CornerRadius = UDim.new(0, 8)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 70)
Content.BackgroundTransparency = 1

local AimbotFrame = Instance.new("Frame", Content)
AimbotFrame.Size = UDim2.new(1, 0, 1, 0)
AimbotFrame.BackgroundTransparency = 1

local ESPFrame = Instance.new("Frame", Content)
ESPFrame.Size = UDim2.new(1, 0, 1, 0)
ESPFrame.BackgroundTransparency = 1
ESPFrame.Visible = false

btnA.MouseButton1Click:Connect(function()
    AimbotFrame.Visible = true
    ESPFrame.Visible = false
end)

btnE.MouseButton1Click:Connect(function()
    AimbotFrame.Visible = false
    ESPFrame.Visible = true
end)

local function toggle(parent, text, y, default, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 24)
    b.Position = UDim2.new(0, 0, 0, y)
    b.Text = text..": "..(default and "ON" or "OFF")
    b.BackgroundColor3 = default and Theme.Primary or Color3.fromRGB(15, 30, 60)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local s = default
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = text..": "..(s and "ON" or "OFF")
        b.BackgroundColor3 = s and Theme.Primary or Color3.fromRGB(15, 30, 60)
        cb(s)
    end)
end

toggle(AimbotFrame, "Enable Aimbot", 0, false, function(v) State.AimbotEnabled = v end)
toggle(AimbotFrame, "Lock Teammates", 30, true, function(v) State.LockTeammates = v end)
toggle(AimbotFrame, "Disable Wall Lock", 60, true, function(v) State.DisableWallLock = v end)
toggle(AimbotFrame, "Show FOV", 90, true, function(v) State.ShowFOV = v end)

local FOVLabel = Instance.new("TextLabel", AimbotFrame)
FOVLabel.Position = UDim2.new(0, 0, 0, 125)
FOVLabel.Size = UDim2.new(0, 100, 0, 20)
FOVLabel.Text = "FOV: 50"
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 12

local function fovBtn(x, text, delta)
    local b = Instance.new("TextButton", AimbotFrame)
    b.Size = UDim2.new(0, 30, 0, 20)
    b.Position = UDim2.new(0, x, 0, 125)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(25, 75, 140)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        State.AimbotFOV = math.clamp(State.AimbotFOV + delta, 10, 500)
        FOVLabel.Text = "FOV: "..State.AimbotFOV
    end)
end
fovBtn(110, "+", 10)
fovBtn(145, "-", -10)

local PartBtn = Instance.new("TextButton", AimbotFrame)
PartBtn.Size = UDim2.new(1, 0, 0, 24)
PartBtn.Position = UDim2.new(0, 0, 0, 155)
PartBtn.Text = "Target: Head"
PartBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 60)
PartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PartBtn.Font = Enum.Font.Gotham
PartBtn.TextSize = 12
Instance.new("UICorner", PartBtn).CornerRadius = UDim.new(0, 6)
PartBtn.MouseButton1Click:Connect(function()
    State.AimbotTargetPart = State.AimbotTargetPart == "Head" and "Torso" or "Head"
    PartBtn.Text = "Target: "..State.AimbotTargetPart
end)

toggle(ESPFrame, "Box ESP", 0, false, function(v) State.ESP.BoxESP = v end)
toggle(ESPFrame, "Outline ESP", 30, false, function(v) State.ESP.OutlineESP = v end)
toggle(ESPFrame, "Name ESP", 60, false, function(v) State.ESP.NameESP = v end)
toggle(ESPFrame, "Distance ESP", 90, false, function(v) State.ESP.DistanceESP = v end)
toggle(ESPFrame, "Team ESP", 120, false, function(v) State.ESP.ESPTeammates = v end)

local ESPTable = {}
local function createESP(player)
    if player == LocalPlayer then return end
    local function onChar(char)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end
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

local PlayerCache = {}
local visibilityCache = {}
local rayTick = 0
local RAY_INTERVAL = 0.12

local function addPlayer(p)
    if p ~= LocalPlayer then
        PlayerCache[p] = true
        createESP(p)
    end
end

local function removePlayer(p)
    PlayerCache[p] = nil
    visibilityCache[p] = nil
    if ESPTable[p] then
        for _, v in pairs(ESPTable[p]) do
            if typeof(v) == "Instance" then v:Destroy() end
        end
        ESPTable[p] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do addPlayer(p) end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

local UserInputService = game:GetService("UserInputService")
local GUIVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        GUIVisible = not GUIVisible
        if Gui then Gui.Enabled = GUIVisible end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    rayTick = rayTick + dt
    espTick = espTick + dt
    aimTick = aimTick + dt
    local doRay = rayTick >= RAY_INTERVAL
    local doESP = espTick >= ESP_UPDATE_INTERVAL
    local doAimUpdate = aimTick >= AIMBOT_UPDATE_INTERVAL
    if doRay then rayTick = 0 end
    if doESP then espTick = 0 end
    if doAimUpdate then aimTick = 0 end

    local camPos = Camera.CFrame.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if doESP then
        for p, _ in pairs(PlayerCache) do
            local e = ESPTable[p]
            if e and e.Char and e.Root then
                local hum = e.Char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local teamOK = not isTeammate(p) or State.ESP.ESPTeammates
                    local color = getESPColor(p)
                    e.Box.Visible = State.ESP.BoxESP and teamOK
                    e.Box.Color3 = color
                    e.Outline.Enabled = State.ESP.OutlineESP and teamOK
                    e.Outline.OutlineColor = color
                    local bbEnabled = teamOK and (State.ESP.NameESP or State.ESP.DistanceESP)
                    e.BB.Enabled = bbEnabled
                    if bbEnabled then
                        local text = ""
                        if State.ESP.NameESP then text = p.Name end
                        if State.ESP.DistanceESP then
                            local d = math.floor((camPos - e.Root.Position).Magnitude)
                            text = text ~= "" and text.." ["..d.."]" or d.." studs"
                        end
                        e.TXT.Text = text
                        e.TXT.TextColor3 = color
                    end
                else
                    e.Box.Visible = false
                    e.Outline.Enabled = false
                    e.BB.Enabled = false
                end
            end
        end
    end

    if FOVCircle then
        FOVCircle.Visible = State.ShowFOV
        FOVCircle.Radius = State.AimbotFOV
        FOVCircle.Position = screenCenter
    end

    if doAimUpdate then
        cachedTargets = {}
        for p, _ in pairs(PlayerCache) do
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
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
        for i = 1, math.min(3, #cachedTargets) do
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
