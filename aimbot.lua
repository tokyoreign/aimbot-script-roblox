local cameraToggle = false
local cameraTarget = nil
local espToggle = false
local espHighlights = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- Clean old GUI
local old = localPlayer.PlayerGui:FindFirstChild("MainGui")
if old then old:Destroy() end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 110)
frame.Position = UDim2.new(0.5, -90, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local function makeToggle(labelText, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = labelText .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local aimbotBtn = makeToggle("Aimbot", 32)
local espBtn    = makeToggle("ESP",    72)

-- =====================
-- TEAM CHECK
-- =====================
local function isEnemy(player)
    if player == localPlayer then return false end
    local myTeam    = localPlayer.Team
    local otherTeam = player.Team
    if not myTeam or not otherTeam then return true end
    return myTeam ~= otherTeam
end

-- =====================
-- DISTANCE CHECK (studs)
-- =====================
local function getDistanceTo(player)
    local myChar    = localPlayer.Character
    local myRoot    = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local theirChar = player.Character
    local theirRoot = theirChar and theirChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not theirRoot then return math.huge end
    return (myRoot.Position - theirRoot.Position).Magnitude
end

-- =====================
-- AIMBOT — always locks closest enemy by stud distance
-- =====================
local function findClosestPlayerByDistance()
    local closestPlayer = nil
    local minDistance   = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local dist = getDistanceTo(player)
            if dist < minDistance then
                minDistance   = dist
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local function aimCameraAtPlayer(player)
    if player then
        local head = player.Character and player.Character:FindFirstChild("Head")
        if head then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
        end
    end
end

local function displaySystemMessage(text, color)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = text,
        Color = color,
        FontSize = Enum.FontSize.Size24,
    })
end

local function toggleCameraAim()
    cameraToggle = not cameraToggle
    if cameraToggle then
        cameraTarget = findClosestPlayerByDistance()
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
        aimbotBtn.Text = "Aimbot: ON"
        displaySystemMessage("Aimbot toggled on", Color3.new(0, 1, 0))
    else
        cameraTarget = nil
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        aimbotBtn.Text = "Aimbot: OFF"
        displaySystemMessage("Aimbot toggled off", Color3.new(1, 0, 0))
    end
end

-- =====================
-- ESP — full character, visible through walls
-- =====================
local function addESP(player)
    if not isEnemy(player) then return end

    local function applyHighlight()
        local character = player.Character
        if not character then return end
        if espHighlights[player] then
            espHighlights[player]:Destroy()
        end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  -- shows through walls
        highlight.Parent = character
        espHighlights[player] = highlight
    end

    applyHighlight()
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espToggle then applyHighlight() end
    end)
end

local function removeESP(player)
    if espHighlights[player] then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
end

local function enableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        addESP(player)
    end
    Players.PlayerAdded:Connect(function(player)
        if espToggle then addESP(player) end
    end)
end

local function disableESP()
    for player, _ in pairs(espHighlights) do
        removeESP(player)
    end
end

local function toggleESP()
    espToggle = not espToggle
    if espToggle then
        espBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
        espBtn.Text = "ESP: ON"
        enableESP()
        displaySystemMessage("ESP toggled on", Color3.new(0, 1, 0))
    else
        espBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        espBtn.Text = "ESP: OFF"
        disableESP()
        displaySystemMessage("ESP toggled off", Color3.new(1, 0, 0))
    end
end

-- Button clicks
aimbotBtn.MouseButton1Click:Connect(toggleCameraAim)
espBtn.MouseButton1Click:Connect(toggleESP)

-- E key toggle
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.E then
        toggleCameraAim()
    end
end)

-- RenderStepped — always retargets closest enemy every frame
RunService.RenderStepped:Connect(function()
    if cameraToggle then
        cameraTarget = findClosestPlayerByDistance()
        if cameraTarget then
            aimCameraAtPlayer(cameraTarget)
        end
    end
end)
aaww
