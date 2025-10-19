--[[
    ╔═══════════════════════════════════════╗
    ║   OTTER CLIENT ADVANCED FEATURES     ║
    ║      Additional Enhancements          ║
    ╚═══════════════════════════════════════╝
]]--

local AdvancedFeatures = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Scaffold Feature
function AdvancedFeatures:Scaffold(enabled, settings)
    if not enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Check if player is falling or walking
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
        -- Find block in inventory
        local block = nil
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("block") then
                block = item
                break
            end
        end
        
        if block then
            -- Place block under player
            local placeRemote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
            if placeRemote then
                pcall(function()
                    placeRemote:FireServer({
                        blockType = block.Name,
                        position = root.Position - Vector3.new(0, 3, 0),
                        normal = Vector3.new(0, 1, 0)
                    })
                end)
            end
        end
    end
end

-- Auto Tool Feature
function AdvancedFeatures:AutoTool(enabled, targetType)
    if not enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = nil
    
    if targetType == "Sword" then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("sword") or item.Name:lower():find("blade")) then
                tool = item
                break
            end
        end
    elseif targetType == "Pickaxe" then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("pickaxe") then
                tool = item
                break
            end
        end
    elseif targetType == "Bow" then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("bow") then
                tool = item
                break
            end
        end
    end
    
    if tool and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid"):EquipTool(tool)
    end
end

-- Anti-AFK Feature
function AdvancedFeatures:AntiAFK(enabled)
    if not enabled then return end
    
    local VirtualUser = game:GetService("VirtualUser")
    
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- FastLoot Feature
function AdvancedFeatures:FastLoot(enabled, chestPosition)
    if not enabled or not chestPosition then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Find chest interface
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local chestGui = playerGui:FindFirstChild("ChestGui") or playerGui:FindFirstChild("InventoryGui")
        if chestGui and chestGui.Enabled then
            -- Rapidly take items
            local takeRemote = ReplicatedStorage:FindFirstChild("TakeItem", true)
            if takeRemote then
                for i = 1, 27 do
                    pcall(function()
                        takeRemote:FireServer({
                            chest = chestPosition,
                            slot = i
                        })
                    end)
                    task.wait(0.01)
                end
            end
        end
    end
end

-- Auto Respawn Feature
function AdvancedFeatures:AutoRespawn(enabled)
    if not enabled then return end
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            task.wait(0.5)
            
            -- Click respawn button
            local respawnRemote = ReplicatedStorage:FindFirstChild("Respawn", true)
            if respawnRemote then
                pcall(function()
                    respawnRemote:FireServer()
                end)
            end
        end)
    end)
end

-- Auto Armor Feature
function AdvancedFeatures:AutoArmor(enabled)
    if not enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Check for armor in inventory
    local armorPieces = {"Helmet", "Chestplate", "Leggings", "Boots"}
    
    for _, armorType in ipairs(armorPieces) do
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find(armorType:lower()) then
                local equipRemote = ReplicatedStorage:FindFirstChild("EquipArmor", true)
                if equipRemote then
                    pcall(function()
                        equipRemote:FireServer({
                            armor = item,
                            slot = armorType
                        })
                    end)
                end
                break
            end
        end
    end
end

-- Team Aura (Heal/Buff teammates)
function AdvancedFeatures:TeamAura(enabled, range)
    if not enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team == LocalPlayer.Team then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                local distance = (root.Position - targetRoot.Position).Magnitude
                
                if distance <= (range or 20) then
                    -- Use healing/buff items on teammate
                    local healRemote = ReplicatedStorage:FindFirstChild("HealPlayer", true)
                    if healRemote then
                        pcall(function()
                            healRemote:FireServer({
                                target = player
                            })
                        end)
                    end
                end
            end
        end
    end
end

-- Auto Buy Feature
function AdvancedFeatures:AutoBuy(enabled, itemList)
    if not enabled or not itemList then return end
    
    -- Check if player is near shop
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Find shop NPC
    local shop = Workspace:FindFirstChild("Shop", true) or Workspace:FindFirstChild("ItemShop", true)
    if shop then
        local shopPosition = shop:IsA("Model") and shop.PrimaryPart and shop.PrimaryPart.Position or shop.Position
        local distance = (root.Position - shopPosition).Magnitude
        
        if distance <= 20 then
            local buyRemote = ReplicatedStorage:FindFirstChild("BuyItem", true)
            if buyRemote then
                for _, itemName in ipairs(itemList) do
                    pcall(function()
                        buyRemote:FireServer({
                            shop = shop,
                            item = itemName
                        })
                    end)
                    task.wait(0.1)
                end
            end
        end
    end
end

-- Bed Nuker (Target enemy beds)
function AdvancedFeatures:BedNuker(enabled, range)
    if not enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Find beds
    local beds = Workspace:FindFirstChild("Beds")
    if beds then
        for _, bed in ipairs(beds:GetChildren()) do
            if bed:IsA("Model") or bed:IsA("Part") then
                local bedPart = bed:IsA("Model") and bed.PrimaryPart or bed
                if bedPart then
                    local distance = (root.Position - bedPart.Position).Magnitude
                    
                    if distance <= (range or 30) then
                        -- Check if it's enemy bed
                        local bedTeam = bed:GetAttribute("Team") or bed.Name
                        if bedTeam ~= LocalPlayer.Team.Name then
                            local breakRemote = ReplicatedStorage:FindFirstChild("DamageBlock", true)
                            if breakRemote then
                                pcall(function()
                                    breakRemote:FireServer({
                                        blockRef = bedPart,
                                        hitPosition = bedPart.Position,
                                        hitNormal = Vector3.new(0, 1, 0)
                                    })
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Custom Tracers
function AdvancedFeatures:CreateTracers(enabled, targets)
    if not enabled then return end
    
    local camera = Workspace.CurrentCamera
    
    -- Clear old tracers
    for _, tracer in ipairs(camera:GetChildren()) do
        if tracer.Name == "OtterTracer" then
            tracer:Destroy()
        end
    end
    
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local beam = Instance.new("Beam")
            beam.Name = "OtterTracer"
            beam.FaceCamera = true
            beam.Width0 = 0.1
            beam.Width1 = 0.1
            beam.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
            
            local attach0 = Instance.new("Attachment")
            attach0.Parent = camera
            attach0.Position = Vector3.zero
            
            local attach1 = Instance.new("Attachment")
            attach1.Parent = target.Character.HumanoidRootPart
            
            beam.Attachment0 = attach0
            beam.Attachment1 = attach1
            beam.Parent = camera
        end
    end
end

-- Killaura Improvements
function AdvancedFeatures:SmartKillAura(enabled, settings)
    if not enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Find closest enemy
    local closestEnemy = nil
    local closestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                local distance = (root.Position - targetRoot.Position).Magnitude
                
                if distance < closestDistance and distance <= (settings.Range or 20) then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        closestDistance = distance
                        closestEnemy = player
                    end
                end
            end
        end
    end
    
    -- Attack closest enemy
    if closestEnemy then
        local targetRoot = closestEnemy.Character.HumanoidRootPart
        
        -- Face enemy
        root.CFrame = CFrame.new(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
        
        -- Attack
        local swordRemote = ReplicatedStorage:FindFirstChild("SwordHit", true)
        if swordRemote then
            pcall(function()
                swordRemote:FireServer({
                    weapon = char:FindFirstChildOfClass("Tool"),
                    entityInstance = closestEnemy.Character,
                    validate = {
                        raycast = {
                            cursorDirection = (targetRoot.Position - root.Position).Unit,
                            cameraPosition = root.Position
                        },
                        targetPosition = targetRoot.Position,
                        selfPosition = root.Position
                    }
                })
            end)
        end
    end
end

return AdvancedFeatures
