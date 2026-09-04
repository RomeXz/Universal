
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local State = {
    AimbotEnabled = false,
    AimKey = nil,
    AimKeyName = "Not Set",
    SettingKey = false,
    WallCheck = false,
    TeamCheck = true,
    FOV = 100,
    ShowFOV = false,
    RandomPart = false,
    SelectedPart = nil,
    TeleportEnabled = false,
    CtrlDown = false,
    GodMode = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Highlight = false,
    },
    TeleportPos = Vector3.new(65.69, 62, 2223.32),
}

local ESPData = {}
local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(41, 128, 185)
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
end)

local Window = Rayfield:CreateWindow({
    Name = "NOKIX HUB (Prison Life)",
    LoadingTitle = "Nokix Hub",
    LoadingSubtitle = "by NowmsDev",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "NOKIXHub",
        FileName = "PrisonLifeConfig"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local CombatTab    = Window:CreateTab("Combat", 4483362458)
local MovementTab  = Window:CreateTab("Movement", 4483362458)
local VisualsTab   = Window:CreateTab("Visuals", 4483362458)
local TeleportTab  = Window:CreateTab("Teleport", 4483362458)
local SpawnTab     = Window:CreateTab("Spawn", 4483362458)


local function SetPosition(Pos)
    local Char = LocalPlayer.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    for _, d in pairs(Char:GetDescendants()) do if d:IsA("BasePart") then d.CanCollide = false end end
    Root.CFrame = CFrame.new(Pos)
    Root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.03)
    for _, d in pairs(Char:GetDescendants()) do if d:IsA("BasePart") then d.CanCollide = true end end
end

local function SetInvisible(Char, Hide)
    for _, d in pairs(Char:GetDescendants()) do
        if d:IsA("BasePart") then d.Transparency = Hide and 1 or (d.Name == "Head" and 0 or 1) end
        if d:IsA("Decal") or d:IsA("FaceInstance") then d.Transparency = Hide and 1 or 0 end
    end
end

local function JumpChar(Char)
    local H = Char:FindFirstChildOfClass("Humanoid")
    if H then H:ChangeState(Enum.HumanoidStateType.Jumping) end
end

local function TeleportAndEquip(Pos)
    local Char = LocalPlayer.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    local Orig = Root.CFrame
    SetPosition(Pos)
    JumpChar(Char)
    SetInvisible(Char, true)
    task.wait(0.35)
    Root.CFrame = Orig
    Root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.03)
    for _, d in pairs(Char:GetDescendants()) do if d:IsA("BasePart") then d.CanCollide = true end end
    SetInvisible(Char, false)
    JumpChar(Char)
end

local function IsTeammate(P)
    return LocalPlayer.Team and P.Team == LocalPlayer.Team
end

local function GetClosestPlayer()
    local Target, MinDist
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local Parts = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

    for _, P in pairs(Players:GetPlayers()) do
        if P ~= LocalPlayer and P.Character then
            local H = P.Character:FindFirstChild("Humanoid")
            if H and H.Health > 0 and not (State.TeamCheck and IsTeammate(P)) then
                local PartName = State.RandomPart and (State.SelectedPart or Parts[math.random(#Parts)]) or "Head"
                local Part = P.Character:FindFirstChild(PartName)
                if State.RandomPart and not State.SelectedPart then State.SelectedPart = PartName end
                if Part then
                    local Visible = true
                    if State.WallCheck then
                        local Dir = (Part.Position - Camera.CFrame.Position).Unit * 1000
                        local R = Ray.new(Camera.CFrame.Position, Dir)
                        local Hit = Workspace:FindPartOnRayWithIgnoreList(R, {LocalPlayer.Character, Camera})
                        Visible = Hit and Hit:IsDescendantOf(P.Character)
                    end
                    if Visible then
                        local Sp, OnScr = Camera:WorldToViewportPoint(Part.Position)
                        if OnScr then
                            local Dist = (Vector2.new(Sp.X, Sp.Y) - Center).Magnitude
                            if Dist <= State.FOV and (not MinDist or Dist < MinDist) then
                                MinDist = Dist
                                Target = Part
                            end
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- ESP
local function ClearESP(P)
    if ESPData[P] then for _, v in pairs(ESPData[P]) do if typeof(v)=="Instance" then v:Destroy() end end ESPData[P]=nil end
end

local function RebuildESP()
    for P,_ in pairs(ESPData) do ClearESP(P) end
    if not State.ESP.Enabled then return end
    for _, P in pairs(Players:GetPlayers()) do if P~=LocalPlayer then
        local Char = P.Character
        if not Char then continue end
        local Root = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChild("Humanoid")
        if not Root or not Hum then continue end
        local Data = {}
        if State.ESP.Highlight then
            local HL = Instance.new("Highlight")
            HL.FillColor = Color3.fromRGB(255,50,50)
            HL.OutlineColor = Color3.new(1,1,1)
            HL.FillTransparency = 0.6
            HL.Parent = Char
            table.insert(Data, HL)
        end
        if State.ESP.Boxes then
            local B = Instance.new("BoxHandleAdornment")
            B.Adornee=Root; B.Size=Vector3.new(4,5,1); B.AlwaysOnTop=true; B.Color3=Color3.fromRGB(255,0,0); B.Transparency=0.7; B.Parent=Root
            table.insert(Data, B)
        end
        if State.ESP.Names or State.ESP.Health or State.ESP.Distance then
            local BG = Instance.new("BillboardGui")
            BG.Adornee=Root; BG.AlwaysOnTop=true; BG.Size=UDim2.new(0,160,0,80); BG.StudsOffset=Vector3.new(0,3,0)
            local Y=0
            if State.ESP.Names then
                local L=Instance.new("TextLabel",BG)
                L.Size=UDim2.new(1,0,0,18); L.Position=UDim2.new(0,0,0,Y); L.BackgroundTransparency=1
                L.Text=P.Name; L.TextColor3=Color3.new(1,1,1); L.Font=Enum.Font.SourceSansBold; L.TextSize=14; L.TextStrokeTransparency=0
                Y+=18
            end
            if State.ESP.Health then
                local L=Instance.new("TextLabel",BG)
                L.Size=UDim2.new(1,0,0,16); L.Position=UDim2.new(0,0,0,Y); L.BackgroundTransparency=1
                L.Font=Enum.Font.SourceSans; L.TextSize=12; L.TextStrokeTransparency=0
                task.spawn(function() while Hum do local HP=math.floor(Hum.Health/Hum.MaxHealth*100) L.Text="HP: "..HP.."%" L.TextColor3=Color3.fromRGB(255-HP*2.55,HP*2.55,0) task.wait(0.1) end end)
                Y+=16
            end
            if State.ESP.Distance then
                local L=Instance.new("TextLabel",BG)
                L.Size=UDim2.new(1,0,0,16); L.Position=UDim2.new(0,0,0,Y); L.BackgroundTransparency=1
                L.TextColor3=Color3.fromRGB(255,255,0); L.Font=Enum.Font.SourceSans; L.TextSize=12; L.TextStrokeTransparency=0
                task.spawn(function() while LocalPlayer.Character and Root do local D=math.floor((LocalPlayer.Character.HumanoidRootPart.Position-Root.Position).Magnitude) L.Text="["..D.."]" task.wait(0.1) end end)
            end
            BG.Parent=Root; table.insert(Data,BG)
        end
        ESPData[P]=Data
    end end
end

-- COMBAT TAB
CombatTab:CreateSection("Aimbot Settings")
CombatTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(v) State.AimbotEnabled = v end,
})
CombatTab:CreateToggle({
    Name = "Random Aim Part",
    CurrentValue = false,
    Callback = function(v) State.RandomPart = v; State.SelectedPart = nil end,
})
CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Callback = function(v) State.WallCheck = v end,
})
CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v) State.TeamCheck = v end,
})
CombatTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(v) State.ShowFOV = v end,
})
CombatTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(v) State.FOV = v end,
})
CombatTab:CreateKeybind({
    Name = "Aim Key",
    CurrentKeybind = "Q",
    HoldToInteract = true,
    Callback = function(Key) State.AimKey = Enum.KeyCode[Key] end,
})

MovementTab:CreateSection("Movement")
MovementTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(v)
        local C = LocalPlayer.Character; if not C then return end
        local H = C:FindFirstChild("Humanoid")
        if H then H.MaxHealth = v and 1e9 or 100; H.Health = v and 1e9 or 100 end
    end,
})
MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v) State.NoClip = v end,
})
MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        State.Fly = v
        local C = LocalPlayer.Character; if not C then return end
        local R = C:FindFirstChild("HumanoidRootPart")
        if not R then return end
        if v then
            local BV = Instance.new("BodyVelocity")
            BV.Name = "FlyVel"; BV.MaxForce = Vector3.new(9e9,9e9,9e9); BV.Parent = R
            local BG = Instance.new("BodyGyro")
            BG.Name = "FlyGyro"; BG.MaxTorque = Vector3.new(9e9,9e9,9e9); BG.P = 9e4; BG.Parent = R
        else
            if R:FindFirstChild("FlyVel") then R.FlyVel:Destroy() end
            if R:FindFirstChild("FlyGyro") then R.FlyGyro:Destroy() end
        end
    end,
})
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) State.FlySpeed = v end,
})
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        local C = LocalPlayer.Character; if C then
            local H = C:FindFirstChild("Humanoid")
            if H then H.WalkSpeed = v end
        end
    end,
})
MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        local C = LocalPlayer.Character; if C then
            local H = C:FindFirstChild("Humanoid")
            if H then H.JumpPower = v end
        end
    end,
})

VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(v) State.ESP.Enabled = v; RebuildESP() end,
})
VisualsTab:CreateToggle({
    Name = "Boxes",
    CurrentValue = false,
    Callback = function(v) State.ESP.Boxes = v; RebuildESP() end,
})
VisualsTab:CreateToggle({
    Name = "Health Bars",
    CurrentValue = false,
    Callback = function(v) State.ESP.Health = v; RebuildESP() end,
})
VisualsTab:CreateToggle({
    Name = "Player Names",
    CurrentValue = false,
    Callback = function(v) State.ESP.Names = v; RebuildESP() end,
})
VisualsTab:CreateToggle({
    Name = "Distance",
    CurrentValue = false,
    Callback = function(v) State.ESP.Distance = v; RebuildESP() end,
})
VisualsTab:CreateToggle({
    Name = "Highlight",
    CurrentValue = false,
    Callback = function(v) State.ESP.Highlight = v; RebuildESP() end,
})

-- TELEPORT TAB
TeleportTab:CreateSection("Teleport")
TeleportTab:CreateButton({
    Name = "Escape Prison",
    Callback = function()
        SetPosition(State.TeleportPos)
        task.wait(0.1)
        local C = LocalPlayer.Character; if C then
            local H = C:FindFirstChild("Humanoid")
            if H then H:Move(Vector3.new(0,0,-1)); task.wait(0.1); JumpChar(C); task.wait(0.2); H.Health = 0 end
        end
    end,
})
TeleportTab:CreateToggle({
    Name = "CTRL + Click Teleport",
    CurrentValue = false,
    Callback = function(v) State.TeleportEnabled = v end,
})

-- SPAWN TAB
SpawnTab:CreateSection("Spawn Weapons")
SpawnTab:CreateButton({
    Name = "Spawn MP5",
    Callback = function() TeleportAndEquip(Vector3.new(813.7, 100.88, 2229.06)) end,
})
SpawnTab:CreateButton({
    Name = "Spawn Remington 870",
    Callback = function() TeleportAndEquip(Vector3.new(820.4, 100.74, 2229.4)) end,
})
SpawnTab:CreateButton({
    Name = "Spawn Sniper Pack (GP)",
    Callback = function() TeleportAndEquip(Vector3.new(835.66, 100.8, 2229.55)) end,
})
SpawnTab:CreateButton({
    Name = "Spawn SWAT Pack (GP)",
    Callback = function() TeleportAndEquip(Vector3.new(847.83, 100.8, 2229.56)) end,
})


UserInputService.InputBegan:Connect(function(Input, GP)
    if GP then return end
    if Input.KeyCode == Enum.KeyCode.LeftControl then State.CtrlDown = true end
    if State.TeleportEnabled and State.CtrlDown and Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local Pos = UserInputService:GetMouseLocation()
        local Ray = Camera:ViewportPointToRay(Pos.X, Pos.Y)
        local Hit = Workspace:Raycast(Ray.Origin, Ray.Direction * 1000)
        if Hit then SetPosition(Hit.Position + Vector3.new(0, 2, 0)) end
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.LeftControl then State.CtrlDown = false end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    if FOVCircle then
        FOVCircle.Radius = State.FOV
        FOVCircle.Visible = State.ShowFOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end

    -- Aimbot
    if State.AimbotEnabled and State.AimKey then
        if UserInputService:IsKeyDown(State.AimKey) then
            local Target = GetClosestPlayer()
            if Target then
                local C = LocalPlayer.Character; if not C then return end
                local R = C:FindFirstChild("HumanoidRootPart"); if not R then return end
                R.CFrame = CFrame.new(R.Position, Vector3.new(Target.Position.X, R.Position.Y, Target.Position.Z))
            end
        end
    end

  
    if State.NoClip then
        local C = LocalPlayer.Character; if C then
            for _, d in pairs(C:GetChildren()) do if d:IsA("BasePart") then d.CanCollide = false end end
        end
    end


    if State.Fly then
        local C = LocalPlayer.Character; if not C then return end
        local R = C:FindFirstChild("HumanoidRootPart")
        local H = C:FindFirstChild("Humanoid")
        if not R or not H then return end
        local CF = Camera.CFrame; local Vel = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Vel += CF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Vel -= CF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Vel -= CF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Vel += CF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Vel += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Vel -= Vector3.new(0, 1, 0) end
        if Vel.Magnitude > 0 then Vel = Vel.Unit * State.FlySpeed end
        if R:FindFirstChild("FlyVel") then R.FlyVel.Velocity = Vel; R.FlyGyro.CFrame = CF end
        H.PlatformStand = true
    else
        local C = LocalPlayer.Character; if C then
            local H = C:FindFirstChild("Humanoid")
            if H then H.PlatformStand = false end
        end
    end
end)

Players.PlayerRemoving:Connect(function(P) ClearESP(P) end)
