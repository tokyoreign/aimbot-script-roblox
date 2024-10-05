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

-- Silent aim function to modify the hit direction without moving the camera
local function silentAimAtPlayer(player)
    if player then
        local head = player.Character and player.Character:FindFirstChild("Head")
        if head then
            -- Modify the aim direction here
            -- Assuming the game's projectiles or hitscan system allows you to influence shot direction
            local camera = workspace.CurrentCamera
            local newAimDirection = (head.Position - camera.CFrame.Position).Unit
            -- Example of modifying the aim (this will depend on the game's shooting system)
            -- game.ReplicatedStorage.FireWeapon:FireServer(newAimDirection)  -- Example network event
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

-- Function to toggle the silent aim on/off
local function toggleSilentAim()
    cameraToggle = not cameraToggle
    if cameraToggle then
        cameraTarget = findClosestPlayer()
        displaySystemMessage("Press 'E' to toggle silent aim", Color3.new(1, 1, 0))  -- Yellow
    else
        cameraTarget = nil
        displaySystemMessage("Silent aim toggled off", Color3.new(1, 0, 0))  -- Red
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

-- Connect the toggleSilentAim function to the "E" key press
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.E then
        toggleSilentAim()
    end
end)

-- Continuously adjust the silent aim at the closest player's head if the cameraToggle is on
game:GetService("RunService").RenderStepped:Connect(function()
    if cameraToggle then
        -- Check if the current target is still valid, otherwise find a new one
        if not cameraTarget or not isTargetValid(cameraTarget) then
            cameraTarget = findClosestPlayer()
        end

        -- Aim silently at the new target if it exists
        if cameraTarget then
            silentAimAtPlayer(cameraTarget)
        end
    end
end)
