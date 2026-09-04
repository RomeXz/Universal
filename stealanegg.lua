-- Nokix Hub Theme
local Theme = {
	Primary  = Color3.fromRGB(26, 115, 232),
	Background = Color3.fromRGB(10, 14, 28),
	Gradient = Color3.fromRGB(20, 60, 120),
	Darker = Color3.fromRGB(15, 30, 60),
	Text     = Color3.fromRGB(210, 230, 255),
	Muted    = Color3.fromRGB(120, 160, 200),
	Red = Color3.fromRGB(255, 60, 60),
	Green = Color3.fromRGB(60, 255, 120),
	Yellow = Color3.fromRGB(255, 200, 50)
}

-- Loading Screen
local Messages = {
	"Connecting to Nokix Hub...",
	"Loading modules...",
	"Preparing interface...",
	"Almost there...",
}
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

local CoreGui = game:GetService("CoreGui")
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
title.Text = "Nokix Hub (Steal an Egg)"
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

-- Server Hop UI
local function AddHover(btn, normal, hover)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normal}):Play()
	end)
end

local Text = {
	title = "Nokix Hub",
	maxLabel = "Hop if players in this server are MORE than:",
	hopBtn = "Hop Once",
	autoOff = "Auto Hop: OFF",
	autoOn = "Auto Hop: ON",
	nowPlayers = "Current Players: ",
	noHopNeeded = "This server only has %d players. No hop needed.",
	searching = "Searching for server with <= %d players...",
	fetchError = "Failed to fetch valid server list.",
	teleporting = "Teleporting to new server...",
	teleportErr = "Teleport Error: ",
	waiting = "%d players here. Waiting...",
	autoStopped = "Auto Hop stopped.",
	init = "Ready. Set player limit and press Hop."
}

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "NokixHub_ServerHop"
MainGui.ResetOnSpawn = false

if syn and syn.protect_gui then
	syn.protect_gui(MainGui)
	MainGui.Parent = CoreGui
elseif gethui then
	MainGui.Parent = gethui()
else
	MainGui.Parent = CoreGui
end

local Main = Instance.new("Frame")
Main.Parent = MainGui
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -165, 0.5, -130)
Main.Size = UDim2.new(0, 330, 0, 260)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Primary
MainStroke.Thickness = 2

local MainTitleBar = Instance.new("Frame", Main)
MainTitleBar.Size = UDim2.new(1, 0, 0, 44)
MainTitleBar.BackgroundColor3 = Theme.Gradient
MainTitleBar.BorderSizePixel = 0
Instance.new("UICorner", MainTitleBar).CornerRadius = UDim.new(0, 14)

local MainTitle = Instance.new("TextLabel", MainTitleBar)
MainTitle.Position = UDim2.new(0, 14, 0, 0)
MainTitle.Size = UDim2.new(1, -50, 1, 0)
MainTitle.BackgroundTransparency = 1
MainTitle.Font = Enum.Font.GothamBold
MainTitle.Text = Text.title
MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTitle.TextSize = 12
MainTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", MainTitleBar)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -36, 0, 7)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Red
CloseBtn.TextSize = 14
CloseBtn.MouseButton1Click:Connect(function()
	MainGui:Destroy()
end)

local StatusFrame = Instance.new("Frame", Main)
StatusFrame.Position = UDim2.new(0, 12, 0, 52)
StatusFrame.Size = UDim2.new(1, -24, 0, 70)
StatusFrame.BackgroundColor3 = Theme.Darker
StatusFrame.BorderSizePixel = 0
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 10)

local PlayerCount = Instance.new("TextLabel", StatusFrame)
PlayerCount.Position = UDim2.new(0, 10, 0, 8)
PlayerCount.Size = UDim2.new(1, -20, 0, 20)
PlayerCount.BackgroundTransparency = 1
PlayerCount.Font = Enum.Font.GothamBold
PlayerCount.TextXAlignment = Enum.TextXAlignment.Left
PlayerCount.TextColor3 = Theme.Green
PlayerCount.TextSize = 12

local StatusText = Instance.new("TextLabel", StatusFrame)
StatusText.Position = UDim2.new(0, 10, 0, 30)
StatusText.Size = UDim2.new(1, -20, 0, 32)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextColor3 = Theme.Muted
StatusText.TextSize = 11
StatusText.TextWrapped = true

local LimitFrame = Instance.new("Frame", Main)
LimitFrame.Position = UDim2.new(0, 12, 0, 130)
LimitFrame.Size = UDim2.new(1, -24, 0, 48)
LimitFrame.BackgroundColor3 = Theme.Darker
LimitFrame.BorderSizePixel = 0
Instance.new("UICorner", LimitFrame).CornerRadius = UDim.new(0, 10)

local LimitLabel = Instance.new("TextLabel", LimitFrame)
LimitLabel.Position = UDim2.new(0, 10, 0, 0)
LimitLabel.Size = UDim2.new(0.68, 0, 1, 0)
LimitLabel.BackgroundTransparency = 1
LimitLabel.Font = Enum.Font.GothamMedium
LimitLabel.TextXAlignment = Enum.TextXAlignment.Left
LimitLabel.TextColor3 = Theme.Text
LimitLabel.TextSize = 10.5
LimitLabel.TextWrapped = true
LimitLabel.Text = Text.maxLabel

local LimitBox = Instance.new("TextBox", LimitFrame)
LimitBox.Position = UDim2.new(0.72, 0, 0.18, 0)
LimitBox.Size = UDim2.new(0.25, 0, 0.64, 0)
LimitBox.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
LimitBox.BorderSizePixel = 0
LimitBox.Font = Enum.Font.GothamBold
LimitBox.Text = "1"
LimitBox.TextColor3 = Color3.fromRGB(255, 255, 255)
LimitBox.TextSize = 13
LimitBox.ClearTextOnFocus = false
Instance.new("UICorner", LimitBox).CornerRadius = UDim.new(0, 8)

local HopBtn = Instance.new("TextButton", Main)
HopBtn.Position = UDim2.new(0, 12, 0, 188)
HopBtn.Size = UDim2.new(0, 146, 0, 56)
HopBtn.BackgroundColor3 = Theme.Primary
HopBtn.BorderSizePixel = 0
HopBtn.Font = Enum.Font.GothamBold
HopBtn.Text = Text.hopBtn
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.TextSize = 11.5
Instance.new("UICorner", HopBtn).CornerRadius = UDim.new(0, 10)
AddHover(HopBtn, Theme.Primary, Color3.fromRGB(70, 145, 240))

local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Position = UDim2.new(0, 168, 0, 188)
AutoBtn.Size = UDim2.new(0, 150, 0, 56)
AutoBtn.BackgroundColor3 = Color3.fromRGB(35, 140, 85)
AutoBtn.BorderSizePixel = 0
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.Text = Text.autoOff
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.TextSize = 10.5
AutoBtn.TextWrapped = true
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 10)

local AutoEnabled = false
local AutoTask = nil

task.spawn(function()
	while MainGui.Parent do
		local PlayerCountNow = #Players:GetPlayers()
		PlayerCount.Text = Text.nowPlayers .. PlayerCountNow
		task.wait(1)
	end
end)

local function FetchServer(TargetPlayers)
	local JobId = tostring(game.JobId)
	local Cursor = ""
	for Attempt = 1, 3 do
		local Url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		if Cursor ~= "" then
			Url ..= "&cursor=" .. Cursor
		end
		local Success, Result = pcall(function()
			return game:HttpGet(Url)
		end)
		if not Success or not Result or Result == "" then
			return nil
		end
		local DecodeSuccess, Data = pcall(function()
			return HttpService:JSONDecode(Result)
		end)
		if not DecodeSuccess or not Data or not Data.data then
			return nil
		end
		for _, Server in ipairs(Data.data) do
			if Server.id and tostring(Server.id) ~= JobId and Server.playing and tonumber(Server.playing) <= TargetPlayers then
				return tostring(Server.id)
			end
		end
		if Data.nextPageCursor then
			Cursor = Data.nextPageCursor
		else
			break
		end
	end
	return nil
end

local function HopOnce()
	local Limit = math.max(1, math.floor(tonumber(LimitBox.Text) or 1))
	local CurrentPlayers = #Players:GetPlayers()
	if CurrentPlayers <= Limit then
		StatusText.Text = string.format(Text.noHopNeeded, CurrentPlayers)
		StatusText.TextColor3 = Theme.Green
		return false
	end
	StatusText.Text = string.format(Text.searching, Limit)
	StatusText.TextColor3 = Theme.Yellow
	task.wait(0.5)
	local ServerId = FetchServer(Limit)
	if not ServerId then
		StatusText.Text = Text.fetchError
		StatusText.TextColor3 = Theme.Red
		return false
	end
	StatusText.Text = Text.teleporting
	StatusText.TextColor3 = Theme.Primary
	task.wait(0.5)
	local Success, Error = pcall(function()
		TeleportService:TeleportToPlaceInstance(PlaceId, ServerId, LocalPlayer)
	end)
	if not Success then
		StatusText.Text = Text.teleportErr .. tostring(Error):sub(1, 60)
		StatusText.TextColor3 = Theme.Red
		return false
	end
	return true
end

HopBtn.MouseButton1Click:Connect(function()
	HopBtn.Active = false
	HopOnce()
	task.wait(2)
	HopBtn.Active = true
end)

AutoBtn.MouseButton1Click:Connect(function()
	AutoEnabled = not AutoEnabled
	if AutoEnabled then
		AutoBtn.Text = Text.autoOn
		TweenService:Create(AutoBtn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Red}):Play()
		AutoTask = task.spawn(function()
			while AutoEnabled and MainGui.Parent do
				local Limit = math.max(1, math.floor(tonumber(LimitBox.Text) or 1))
				local CurrentPlayers = #Players:GetPlayers()
				if CurrentPlayers <= Limit then
					StatusText.Text = string.format(Text.waiting, CurrentPlayers)
					StatusText.TextColor3 = Theme.Green
					task.wait(3)
				else
					HopOnce()
					task.wait(5)
				end
			end
		end)
		return
	end
	AutoBtn.Text = Text.autoOff
	TweenService:Create(AutoBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 140, 85)}):Play()
	if AutoTask then
		task.cancel(AutoTask)
	end
	StatusText.Text = Text.autoStopped
	StatusText.TextColor3 = Theme.Muted
end)

StatusText.Text = Text.init
StatusText.TextColor3 = Theme.Muted
