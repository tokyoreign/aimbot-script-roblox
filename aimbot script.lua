local cameraToggle = false
local cameraTarget = nil
local smoothSpeed = 2 -- Speed at which the camera smoothly follows the target

-- Function to find the closest player to the center of the screen, excluding the local player and teammates
local function findClosestPlayerToScreenCenter()
    local playerList = game.Players:GetPlayers()
    local localPlayer = game.Players.LocalPlayer
    local localTeam = localPlayer.Team
    local camera = workspace.CurrentCamera
    local center = camera.ViewportSize / 2
    local closestPlayer = nil
    local minDistance = math.huge

    for _, player in ipairs(playerList) do
        local character = player.Character
        local head = character and character:FindFirstChild("Head")
        local playerTeam = player.Team

        -- Exclude the local player and players on the same team
        if player ~= localPlayer and head and playerTeam ~= localTeam then
            local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)

            if onScreen then
                local distance = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Function to smoothly aim the camera at a specific player's head
local function aimCameraAtPlayer(player)
    if player then
        local head = player.Character and player.Character:FindFirstChild("Head")
        if head then
            local camera = workspace.CurrentCamera
            -- Smoothly move the camera towards the target's head
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, head.Position), smoothSpeed)
        end
    end
end

-- Function to display system messages in the chat
local function displaySystemMessage(text, color)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = text,
        Color = color,
        FontSize = Enum.FontSize.Size24,
    })
end

-- Function to toggle the camera aim on/off
local function toggleCameraAim()
    cameraToggle = not cameraToggle
    if cameraToggle then
        cameraTarget = findClosestPlayerToScreenCenter()
        displaySystemMessage("Aimbot toggled ON. Press 'E' to toggle off.", Color3.new(1, 1, 0)) -- Yellow
    else
        cameraTarget = nil
        displaySystemMessage("Aimbot toggled OFF", Color3.new(1, 0, 0)) -- Red
    end
end

-- Function to check if the current target is still alive
local function isTargetAlive(player)
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Connect the toggleCameraAim function to the "E" key press
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.E then
        toggleCameraAim()
    end
end)

-- Continuously aim the camera at the closest player's head if the cameraToggle is on
game:GetService("RunService").RenderStepped:Connect(function()
    if cameraToggle then
        -- Check if the current target is still valid, otherwise find a new one
        if not cameraTarget or not isTargetAlive(cameraTarget) then
            cameraTarget = findClosestPlayerToScreenCenter()
        end

        -- Aim at the new target if it exists
        if cameraTarget then
            aimCameraAtPlayer(cameraTarget)
        end
    end
end)
