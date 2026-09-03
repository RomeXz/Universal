local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = workspace
local UserInputService = game:GetService("UserInputService")

local position
if not UserInputService.TouchEnabled then
	if not UserInputService.KeyboardEnabled then
		position = UDim2.new(0, 399.871, 0, 161)
	else
		position = UDim2.new(0.5, 0, 0.5, 0)
	end
else
	position = UDim2.new(0, 399.871, 0, 161)
end
repeat
	task.wait()
until game:IsLoaded()
if _G.NokixHub_Rivals_Aimbot_Initialized ~= false and _G.NokixHub_Rivals_Aimbot_Initialized ~= nil then
	return
end
_G.NokixHub_Rivals_Aimbot_Initialized = true

local UserId = LocalPlayer.UserId
local LocalPlayerName = LocalPlayer.Name
local image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. UserId .. "&width=150&height=150&format=png"

local Theme = {
	Primary  = Color3.fromRGB(26, 115, 232),
	Background = Color3.fromRGB(10, 14, 28),
	Gradient = Color3.fromRGB(20, 60, 120),
	Darker = Color3.fromRGB(15, 30, 60),
	Text     = Color3.fromRGB(210, 230, 255),
	Muted    = Color3.fromRGB(120, 160, 200),
	Red = Color3.fromRGB(255, 60, 60),
	Green = Color3.fromRGB(60, 255, 120)
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

local State = {
	AimbotEnabled = false,
	LockTeammates = false,
	DisableWallLock = false,
	AimbotFOV = 150,
	AimbotTargetPart = "Head",
	ShowFOV = false,
	FOVColor = Color3.fromRGB(0, 255, 0)
}

local FOVCircle
pcall(function()
	FOVCircle = Drawing.new("Circle")
	FOVCircle.Color = State.FOVColor
	FOVCircle.Thickness = 1.5
	FOVCircle.NumSides = 64
	FOVCircle.Filled = false
	FOVCircle.Visible = false
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "NokixHub_Rivals_Aimbot"
Gui.Parent = CoreGui
Gui.ResetOnSpawn = false

local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "NokixHub_FloatBtn"
FloatGui.Parent = CoreGui
FloatGui.ResetOnSpawn = false
FloatGui.Enabled = false

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 130, 0, 36)
FloatBtn.Position = UDim2.new(1, -140, 0, 12)
FloatBtn.Text = "OPEN NOKIX"
FloatBtn.BackgroundColor3 = Theme.Primary
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 13
FloatBtn.Parent = FloatGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 8)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 320)
Main.Position = position
Main.BackgroundColor3 = Theme.Background
Main.Active = true
Main.Draggable = true
Main.ZIndex = 1
Main.Visible = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Primary
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5
mainStroke.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Theme.Gradient
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Nokix Hub Aimbot (RIVALS)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -65, 0, 3)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Theme.Gradient
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Theme.Red
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -10, 1, -45)
Content.Position = UDim2.new(0, 5, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local ROW = 28

local function toggle(parent, text, y, default, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, ROW - 4)
	b.Position = UDim2.new(0, 2, 0, y)
	b.Text = text .. "    " .. (default and "ON" or "OFF")
	b.BackgroundColor3 = default and Theme.Primary or Theme.Darker
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.Gotham
	b.TextSize = 11
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 12, 0, 12)
	dot.Position = UDim2.new(1, -18, 0.5, -6)
	dot.BackgroundColor3 = default and Theme.Green or Theme.Red
	dot.Parent = b
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 1)
	local s = default
	b.MouseButton1Click:Connect(function()
		s = not s
		b.Text = text .. "    " .. (s and "ON" or "OFF")
		b.BackgroundColor3 = s and Theme.Primary or Theme.Darker
		dot.BackgroundColor3 = s and Theme.Green or Theme.Red
		cb(s)
	end)
end

toggle(Content, "Enable Aimbot", 0, false, function(v) State.AimbotEnabled = v end)
toggle(Content, "Team Check", 30, false, function(v) State.LockTeammates = v end)
toggle(Content, "Wall Check", 60, false, function(v) State.DisableWallLock = v end)
toggle(Content, "Show FOV Circle", 90, false, function(v)
	State.ShowFOV = v
	if FOVCircle then FOVCircle.Visible = v end
end)

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, -58, 0, 18)
FOVLabel.Position = UDim2.new(0, 2, 0, 125)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. State.AimbotFOV
FOVLabel.TextColor3 = Theme.Text
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 11
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = Content

local fovBarBg = Instance.new("Frame")
fovBarBg.Size = UDim2.new(1, -6, 0, 6)
fovBarBg.Position = UDim2.new(0, 2, 0, 145)
fovBarBg.BackgroundColor3 = Theme.Darker
fovBarBg.Parent = Content
Instance.new("UICorner", fovBarBg).CornerRadius = UDim.new(1, 0)

local fovBarFill = Instance.new("Frame")
fovBarFill.Size = UDim2.new((State.AimbotFOV - 10) / 490, 0, 1, 0)
fovBarFill.BackgroundColor3 = Theme.Primary
fovBarFill.Parent = fovBarBg
Instance.new("UICorner", fovBarFill).CornerRadius = UDim.new(1, 0)

local function fovBtn(xOff, text, delta)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 24, 0, 22)
	b.Position = UDim2.new(1, xOff, 0, 120)
	b.Text = text
	b.BackgroundColor3 = Theme.Gradient
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Parent = Content
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	b.MouseButton1Click:Connect(function()
		State.AimbotFOV = math.clamp(State.AimbotFOV + delta, 10, 500)
		FOVLabel.Text = "FOV: " .. State.AimbotFOV
		fovBarFill.Size = UDim2.new((State.AimbotFOV - 10) / 490, 0, 1, 0)
	end)
end
fovBtn(-52, "+", 10)
fovBtn(-26, "-", -10)

local PartLabel = Instance.new("TextLabel")
PartLabel.Size = UDim2.new(1, -6, 0, 18)
PartLabel.Position = UDim2.new(0, 2, 0, 160)
PartLabel.BackgroundTransparency = 1
PartLabel.Text = "Target Part"
PartLabel.TextColor3 = Theme.Text
PartLabel.Font = Enum.Font.Gotham
PartLabel.TextSize = 11
PartLabel.TextXAlignment = Enum.TextXAlignment.Left
PartLabel.Parent = Content

local PartContainer = Instance.new("Frame")
PartContainer.Size = UDim2.new(1, -6, 0, 30)
PartContainer.Position = UDim2.new(0, 2, 0, 180)
PartContainer.BackgroundTransparency = 1
PartContainer.Parent = Content

local PartBtnHead = Instance.new("TextButton")
PartBtnHead.Size = UDim2.new(0.32, -4, 0, 30)
PartBtnHead.Position = UDim2.new(0, 0, 0, 0)
PartBtnHead.Text = "HEAD"
PartBtnHead.BackgroundColor3 = Theme.Primary
PartBtnHead.TextColor3 = Color3.fromRGB(255, 255, 255)
PartBtnHead.Font = Enum.Font.GothamBold
PartBtnHead.TextSize = 10
PartBtnHead.Parent = PartContainer
Instance.new("UICorner", PartBtnHead).CornerRadius = UDim.new(0, 5)

local PartBtnChest = Instance.new("TextButton")
PartBtnChest.Size = UDim2.new(0.32, -4, 0, 30)
PartBtnChest.Position = UDim2.new(0.34, 0, 0, 0)
PartBtnChest.Text = "CHEST"
PartBtnChest.BackgroundColor3 = Theme.Darker
PartBtnChest.TextColor3 = Color3.fromRGB(255, 255, 255)
PartBtnChest.Font = Enum.Font.GothamBold
PartBtnChest.TextSize = 10
PartBtnChest.Parent = PartContainer
Instance.new("UICorner", PartBtnChest).CornerRadius = UDim.new(0, 5)

local PartBtnPelvis = Instance.new("TextButton")
PartBtnPelvis.Size = UDim2.new(0.32, -4, 0, 30)
PartBtnPelvis.Position = UDim2.new(0.68, 0, 0, 0)
PartBtnPelvis.Text = "PELVIS"
PartBtnPelvis.BackgroundColor3 = Theme.Darker
PartBtnPelvis.TextColor3 = Color3.fromRGB(255, 255, 255)
PartBtnPelvis.Font = Enum.Font.GothamBold
PartBtnPelvis.TextSize = 10
PartBtnPelvis.Parent = PartContainer
Instance.new("UICorner", PartBtnPelvis).CornerRadius = UDim.new(0, 5)

local function resetPartColors()
	PartBtnHead.BackgroundColor3 = Theme.Darker
	PartBtnChest.BackgroundColor3 = Theme.Darker
	PartBtnPelvis.BackgroundColor3 = Theme.Darker
end

PartBtnHead.MouseButton1Click:Connect(function()
	resetPartColors()
	PartBtnHead.BackgroundColor3 = Theme.Primary
	State.AimbotTargetPart = "Head"
end)
PartBtnChest.MouseButton1Click:Connect(function()
	resetPartColors()
	PartBtnChest.BackgroundColor3 = Theme.Primary
	State.AimbotTargetPart = "Chest"
end)
PartBtnPelvis.MouseButton1Click:Connect(function()
	resetPartColors()
	PartBtnPelvis.BackgroundColor3 = Theme.Primary
	State.AimbotTargetPart = "Pelvis"
end)

local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(1, -6, 0, 18)
ColorLabel.Position = UDim2.new(0, 2, 0, 220)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "FOV Color (RGB)"
ColorLabel.TextColor3 = Theme.Text
ColorLabel.Font = Enum.Font.Gotham
ColorLabel.TextSize = 11
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Parent = Content

local ColorBox = Instance.new("TextBox")
ColorBox.Size = UDim2.new(1, -6, 0, 30)
ColorBox.Position = UDim2.new(0, 2, 0, 240)
ColorBox.BackgroundColor3 = Theme.Darker
ColorBox.Text = "0, 255, 0"
ColorBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorBox.Font = Enum.Font.Gotham
ColorBox.TextSize = 11
ColorBox.PlaceholderText = "255, 0, 0"
ColorBox.Parent = Content
Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 5)

ColorBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local r, g, b = ColorBox.Text:match("(%d+)%s*,?%s*(%d+)%s*,?%s*(%d+)")
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		if r and g and b and r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
			State.FOVColor = Color3.fromRGB(r, g, b)
			if FOVCircle then FOVCircle.Color = State.FOVColor end
		end
	end
end)

MinBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
	FloatGui.Enabled = true
end)

FloatBtn.MouseButton1Click:Connect(function()
	Main.Visible = true
	FloatGui.Enabled = false
end)

CloseBtn.MouseButton1Click:Connect(function()
	_G.NokixHub_Rivals_Aimbot_Initialized = nil
	State.AimbotEnabled = false
	Gui:Destroy()
	FloatGui:Destroy()
end)

local function isPlayerValid(player)
	if not State.LockTeammates then
		return true
	end
	return player.Team ~= LocalPlayer.Team
end

local function isVisibleCheck(part)
	if State.DisableWallLock then
		return true
	end
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LocalPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local result = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
	return result and result.Instance:IsDescendantOf(part.Parent)
end

local function getTarget()
	local best = nil
	local closest = math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and isPlayerValid(p) and p.Character then
			local part
			if State.AimbotTargetPart == "Head" then
				part = p.Character:FindFirstChild("Head")
			elseif State.AimbotTargetPart == "Chest" then
				part = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
			elseif State.AimbotTargetPart == "Pelvis" then
				part = p.Character:FindFirstChild("LowerTorso") or p.Character:FindFirstChild("HumanoidRootPart")
			end
			if part then
				local pos, onScreen = Camera:WorldToScreenPoint(part.Position)
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
				if onScreen and dist <= State.AimbotFOV and dist < closest and isVisibleCheck(part) then
					closest = dist
					best = part
				end
			end
		end
	end
	return best
end

RunService.RenderStepped:Connect(function()
	if FOVCircle then
		FOVCircle.Radius = State.AimbotFOV
		FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
		FOVCircle.Visible = State.ShowFOV
	end
	if State.AimbotEnabled then
		local target = getTarget()
		if target then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
		end
	end
end)
