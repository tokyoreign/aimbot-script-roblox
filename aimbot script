local cameraToggle = false
local cameraTarget = nil
local maxDistance = 150  -- Maximum distance in studs

-- Function to find the closest player within 150 studs, excluding the local player and teammates
local function findClosestPlayer()
    local playerList = game.Players:GetPlayers()
    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    local localHead = localCharacter and localCharacter:FindFirstChild("Head")
    local localTeam = localPlayer.Team
    local closestPlayer = nil
    local minDistance = math.huge

    if not localHead then return nil end

    for _, player in ipairs(playerList) do
        local character = player.Character
        local head = character and character:FindFirstChild("Head")
        local playerTeam = player.Team

        -- Exclude the local player and players on the same team
        if player ~= localPlayer and head and playerTeam ~= localTeam then
            local distance = (localHead.Position - head.Position).Magnitude

            -- Only consider players within the 150-stud distance
            if distance <= maxDistance and distance < minDistance then
                minDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- Function to aim the camera at a specific player's head
local function aimCameraAtPlayer(player)
    if player then
        local head = player.Character and player.Character:FindFirstChild("Head")
        if head then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
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
        cameraTarget = findClosestPlayer()
        displaySystemMessage("Press 'E' to toggle the aimbot", Color3.new(1, 1, 0))  -- Yellow
    else
        cameraTarget = nil
        displaySystemMessage("Aimbot toggled off", Color3.new(1, 0, 0))  -- Red
    end
end

-- Function to check if the current target is still alive and within range
local function isTargetValid(player)
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    local head = player.Character and player.Character:FindFirstChild("Head")
    local localHead = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Head")
    
    if humanoid and humanoid.Health > 0 and head and localHead then
        local distance = (localHead.Position - head.Position).Magnitude
        return distance <= maxDistance  -- Ensure the target is still within 150 studs
    end
    return false
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
        if not cameraTarget or not isTargetValid(cameraTarget) then
            cameraTarget = findClosestPlayer()
        end

        -- Aim at the new target if it exists
        if cameraTarget then
            aimCameraAtPlayer(cameraTarget)
        end
    end
end)
