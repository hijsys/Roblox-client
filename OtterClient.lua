--[[
    ╔═══════════════════════════════════════╗
    ║        OTTER CLIENT v2.0             ║
    ║    Professional BedWars Client        ║
    ╚═══════════════════════════════════════╝
]]--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Client Configuration
local OtterClient = {
    Version = "2.0",
    Enabled = true,
    
    -- Feature States
    Features = {
        Combat = {
            KillAura = {Enabled = false, Range = 20, Speed = 0.1, TargetTeammates = false},
            Velocity = {Enabled = false, Horizontal = 0, Vertical = 100},
            Reach = {Enabled = false, Distance = 18},
            AutoBlock = {Enabled = false},
            Criticals = {Enabled = false},
        },
        Movement = {
            Speed = {Enabled = false, Amount = 23},
            Fly = {Enabled = false, Speed = 50},
            NoFall = {Enabled = false},
            Spider = {Enabled = false, Speed = 20},
            LongJump = {Enabled = false, Power = 100},
        },
        Utility = {
            AutoCollect = {Enabled = false, Range = 20},
            ChestStealer = {Enabled = false, Speed = 0.1},
            Nuker = {Enabled = false, Range = 25},
            Scaffold = {Enabled = false},
            ESP = {Enabled = false, ShowPlayers = true, ShowBeds = true},
            Tracers = {Enabled = false},
            AntiVoid = {Enabled = false, Height = 10},
        },
        World = {
            Fullbright = {Enabled = false},
            NoWeather = {Enabled = false},
            Zoom = {Enabled = false, Amount = 1000},
        }
    },
    
    -- Connection Storage
    Connections = {},
    ESPObjects = {},
    OriginalValues = {},
    
    -- Remote Cache
    Remotes = {},
    
    -- BedWars Specific
    KnockbackTable = nil,
    ClientHandler = nil,
}

-- Utility Functions
local Utils = {}

function Utils:FindRemote(name, searchDepth)
    searchDepth = searchDepth or 3
    
    local function search(parent, depth)
        if depth > searchDepth then return nil end
        
        for _, child in ipairs(parent:GetDescendants()) do
            if child.Name == name or child.Name:lower():find(name:lower()) then
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    return child
                end
            end
        end
        return nil
    end
    
    -- Check cache first
    if OtterClient.Remotes[name] then
        return OtterClient.Remotes[name]
    end
    
    -- Search in ReplicatedStorage
    local remote = search(ReplicatedStorage, searchDepth)
    
    if not remote then
        -- Search in other common locations
        if Workspace:FindFirstChild("Remotes") then
            remote = search(Workspace.Remotes, searchDepth)
        end
    end
    
    if remote then
        OtterClient.Remotes[name] = remote
    end
    
    return remote
end

function Utils:GetBedWarsRemotes()
    -- Find the BedWars client handler
    local clientHandler = ReplicatedStorage:FindFirstChild("rbxts_include")
    if clientHandler then
        OtterClient.ClientHandler = clientHandler
        
        -- Cache important remotes
        for _, remote in ipairs(clientHandler:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                OtterClient.Remotes[remote.Name] = remote
            end
        end
    end
    
    return OtterClient.ClientHandler ~= nil
end

function Utils:GetCharacter()
    return LocalPlayer.Character
end

function Utils:GetRootPart()
    local char = self:GetCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

function Utils:GetHumanoid()
    local char = self:GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils:IsAlive()
    local humanoid = self:GetHumanoid()
    local root = self:GetRootPart()
    return humanoid and humanoid.Health > 0 and root ~= nil
end

function Utils:GetPlayers()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player)
        end
    end
    return players
end

function Utils:GetTeam(player)
    return player and player.Team
end

function Utils:IsTeammate(player)
    return self:GetTeam(player) == self:GetTeam(LocalPlayer)
end

function Utils:GetDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

function Utils:GetTool(toolType)
    local char = self:GetCharacter()
    if not char then return nil end
    
    -- Check equipped tool
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.Name:lower():find(toolType:lower()) then
        return currentTool
    end
    
    -- Check backpack
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find(toolType:lower()) then
            return tool
        end
    end
    
    return nil
end

function Utils:EquipTool(tool)
    if tool and tool.Parent == LocalPlayer.Backpack then
        local humanoid = self:GetHumanoid()
        if humanoid then
            humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

function Utils:Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

function Utils:GetInventory()
    local inventory = {}
    
    -- Get equipped items
    local char = self:GetCharacter()
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") or item:IsA("Accessory") then
                table.insert(inventory, item)
            end
        end
    end
    
    -- Get backpack items
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        table.insert(inventory, item)
    end
    
    return inventory
end

-- Combat Features with Real Logic
local Combat = {}

function Combat:KillAura()
    local settings = OtterClient.Features.Combat.KillAura
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    if not root then return end
    
    local sword = Utils:GetTool("sword")
    if not sword then return end
    
    -- Make sure sword is equipped
    if sword.Parent ~= Utils:GetCharacter() then
        Utils:EquipTool(sword)
        task.wait(0.1)
        return
    end
    
    -- Find targets
    for _, player in ipairs(Utils:GetPlayers()) do
        if player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = Utils:GetDistance(root, targetRoot)
                
                if distance <= settings.Range then
                    if not settings.TargetTeammates and Utils:IsTeammate(player) then
                        continue
                    end
                    
                    -- Attack logic
                    local swordRemote = sword:FindFirstChild("RemoteEvent") or 
                                       sword:FindFirstChild("RemoteFunction") or
                                       Utils:FindRemote("SwordHit")
                    
                    if swordRemote then
                        -- Face the target
                        local lookCFrame = CFrame.new(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                        root.CFrame = lookCFrame
                        
                        -- Fire attack
                        pcall(function()
                            if swordRemote:IsA("RemoteEvent") then
                                swordRemote:FireServer({
                                    ["entityInstance"] = player.Character,
                                    ["validate"] = {
                                        ["raycast"] = {
                                            ["cameraPosition"] = game.Workspace.CurrentCamera.CFrame.Position,
                                            ["cursorDirection"] = (targetRoot.Position - root.Position).Unit
                                        },
                                        ["targetPosition"] = targetRoot.Position,
                                        ["selfPosition"] = root.Position
                                    }
                                })
                            else
                                swordRemote:InvokeServer({
                                    target = player.Character,
                                    position = targetRoot.Position
                                })
                            end
                        end)
                        
                        task.wait(settings.Speed)
                    end
                end
            end
        end
    end
end

function Combat:Velocity()
    local settings = OtterClient.Features.Combat.Velocity
    if not settings.Enabled then 
        if OtterClient.Connections["Velocity"] then
            OtterClient.Connections["Velocity"]:Disconnect()
            OtterClient.Connections["Velocity"] = nil
        end
        return 
    end
    
    -- Hook into knockback
    if not OtterClient.Connections["Velocity"] then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Hook velocity changes
            if method == "FireServer" and tostring(self):find("Knockback") then
                return
            end
            
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
        
        -- Also hook AssemblyLinearVelocity
        OtterClient.Connections["Velocity"] = RunService.Heartbeat:Connect(function()
            local root = Utils:GetRootPart()
            if root and root:IsA("BasePart") then
                local velocity = root.AssemblyLinearVelocity
                if velocity.Magnitude > 0 then
                    root.AssemblyLinearVelocity = Vector3.new(
                        velocity.X * (settings.Horizontal / 100),
                        velocity.Y * (settings.Vertical / 100),
                        velocity.Z * (settings.Horizontal / 100)
                    )
                end
            end
        end)
    end
end

function Combat:Reach()
    local settings = OtterClient.Features.Combat.Reach
    if not settings.Enabled then
        -- Reset sizes
        for _, player in ipairs(Utils:GetPlayers()) do
            if player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:GetAttribute("OriginalSize") then
                    hrp.Size = hrp:GetAttribute("OriginalSize")
                    hrp.Transparency = 1
                end
            end
        end
        return
    end
    
    -- Modify hitboxes
    for _, player in ipairs(Utils:GetPlayers()) do
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:IsA("BasePart") then
                if not hrp:GetAttribute("OriginalSize") then
                    hrp:SetAttribute("OriginalSize", hrp.Size)
                end
                
                local expandSize = (settings.Distance - 3) / 2
                hrp.Size = Vector3.new(expandSize, expandSize, expandSize)
                hrp.Transparency = 1
                hrp.CanCollide = false
            end
        end
    end
end

-- Movement Features with Real Physics
local Movement = {}

function Movement:Speed()
    local settings = OtterClient.Features.Movement.Speed
    
    if not settings.Enabled then
        local humanoid = Utils:GetHumanoid()
        if humanoid and OtterClient.OriginalValues.WalkSpeed then
            humanoid.WalkSpeed = OtterClient.OriginalValues.WalkSpeed
        end
        return
    end
    
    if not Utils:IsAlive() then return end
    
    local humanoid = Utils:GetHumanoid()
    if humanoid then
        if not OtterClient.OriginalValues.WalkSpeed then
            OtterClient.OriginalValues.WalkSpeed = humanoid.WalkSpeed
        end
        humanoid.WalkSpeed = settings.Amount
    end
end

function Movement:Fly()
    local settings = OtterClient.Features.Movement.Fly
    
    if not settings.Enabled then
        local root = Utils:GetRootPart()
        if root then
            local bodyVel = root:FindFirstChild("OtterFly")
            if bodyVel then bodyVel:Destroy() end
            local bodyGyro = root:FindFirstChild("OtterGyro")
            if bodyGyro then bodyGyro:Destroy() end
        end
        return
    end
    
    if not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    local humanoid = Utils:GetHumanoid()
    if not root or not humanoid then return end
    
    -- Create BodyVelocity
    local bodyVelocity = root:FindFirstChild("OtterFly")
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "OtterFly"
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.P = 10000
        bodyVelocity.Parent = root
    end
    
    -- Create BodyGyro for stability
    local bodyGyro = root:FindFirstChild("OtterGyro")
    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "OtterGyro"
        bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
        bodyGyro.P = 10000
        bodyGyro.Parent = root
    end
    
    -- Calculate movement direction
    local camera = Workspace.CurrentCamera
    local direction = Vector3.zero
    
    local moveVector = humanoid.MoveVector
    if moveVector.Magnitude > 0 then
        direction = direction + (camera.CFrame.RightVector * moveVector.X)
        direction = direction + (camera.CFrame.LookVector * -moveVector.Z)
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction + Vector3.new(0, -1, 0)
    end
    
    if direction.Magnitude > 0 then
        bodyVelocity.Velocity = direction.Unit * settings.Speed
    else
        bodyVelocity.Velocity = Vector3.zero
    end
    
    bodyGyro.CFrame = camera.CFrame
end

function Movement:NoFall()
    local settings = OtterClient.Features.Movement.NoFall
    if not settings.Enabled then
        if OtterClient.Connections["NoFall"] then
            OtterClient.Connections["NoFall"]:Disconnect()
            OtterClient.Connections["NoFall"] = nil
        end
        return
    end
    
    if not OtterClient.Connections["NoFall"] then
        OtterClient.Connections["NoFall"] = RunService.Heartbeat:Connect(function()
            local root = Utils:GetRootPart()
            local humanoid = Utils:GetHumanoid()
            
            if root and humanoid then
                -- Check if falling fast
                if root.AssemblyLinearVelocity.Y < -20 then
                    -- Reset fall damage by setting state
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                    
                    -- Find and fire ground hit remote
                    local groundRemote = Utils:FindRemote("GroundHit")
                    if groundRemote then
                        pcall(function()
                            groundRemote:FireServer()
                        end)
                    end
                end
            end
        end)
    end
end

function Movement:Spider()
    local settings = OtterClient.Features.Movement.Spider
    if not settings.Enabled then
        if OtterClient.Connections["Spider"] then
            OtterClient.Connections["Spider"]:Disconnect()
            OtterClient.Connections["Spider"] = nil
        end
        return
    end
    
    if not OtterClient.Connections["Spider"] then
        OtterClient.Connections["Spider"] = RunService.Heartbeat:Connect(function()
            local root = Utils:GetRootPart()
            local humanoid = Utils:GetHumanoid()
            
            if root and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                -- Check if touching wall
                local ray = Ray.new(root.Position, root.CFrame.LookVector * 2)
                local hit = Workspace:FindPartOnRay(ray, Utils:GetCharacter())
                
                if hit then
                    root.AssemblyLinearVelocity = Vector3.new(
                        root.AssemblyLinearVelocity.X,
                        settings.Speed,
                        root.AssemblyLinearVelocity.Z
                    )
                end
            end
        end)
    end
end

function Movement:LongJump()
    local settings = OtterClient.Features.Movement.LongJump
    if not settings.Enabled then
        if OtterClient.Connections["LongJump"] then
            OtterClient.Connections["LongJump"]:Disconnect()
            OtterClient.Connections["LongJump"] = nil
        end
        return
    end
    
    if not OtterClient.Connections["LongJump"] then
        OtterClient.Connections["LongJump"] = UserInputService.JumpRequest:Connect(function()
            local root = Utils:GetRootPart()
            local humanoid = Utils:GetHumanoid()
            
            if root and humanoid then
                local camera = Workspace.CurrentCamera
                local boost = camera.CFrame.LookVector * (settings.Power / 2)
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + boost
            end
        end)
    end
end

-- Utility Features with Real Game Logic
local Utility = {}

function Utility:AutoCollect()
    local settings = OtterClient.Features.Utility.AutoCollect
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    if not root then return end
    
    -- Find item drops in workspace
    local itemsFolder = Workspace:FindFirstChild("ItemDrops") or 
                       Workspace:FindFirstChild("Items") or
                       Workspace:FindFirstChild("Drops")
    
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            if item:IsA("Part") or item:IsA("MeshPart") or item:IsA("Model") then
                local itemPos = item:IsA("Model") and item:GetPrimaryPartCFrame().Position or item.Position
                local distance = (root.Position - itemPos).Magnitude
                
                if distance <= settings.Range then
                    -- Try to collect
                    local collectRemote = Utils:FindRemote("CollectItem") or 
                                         Utils:FindRemote("PickupItem") or
                                         Utils:FindRemote("ItemPickup")
                    
                    if collectRemote then
                        pcall(function()
                            if collectRemote:IsA("RemoteEvent") then
                                collectRemote:FireServer(item)
                            else
                                collectRemote:InvokeServer(item)
                            end
                        end)
                    end
                end
            end
        end
    end
    
    -- Also check for resource spawners
    local spawners = Workspace:FindFirstChild("ItemSpawns")
    if spawners then
        for _, spawner in ipairs(spawners:GetChildren()) do
            if spawner:FindFirstChild("Spawn") then
                local spawnPart = spawner.Spawn
                local distance = (root.Position - spawnPart.Position).Magnitude
                
                if distance <= settings.Range then
                    -- Collect from spawner
                    local collectRemote = Utils:FindRemote("CollectResource")
                    if collectRemote then
                        pcall(function()
                            collectRemote:FireServer(spawner)
                        end)
                    end
                end
            end
        end
    end
end

function Utility:Nuker()
    local settings = OtterClient.Features.Utility.Nuker
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    if not root then return end
    
    -- Find blocks to break
    local blocksFolder = Workspace:FindFirstChild("Blocks") or
                        Workspace:FindFirstChild("Map") or
                        Workspace:FindFirstChild("BlocksInGame")
    
    if blocksFolder then
        local pickaxe = Utils:GetTool("pickaxe") or Utils:GetTool("axe")
        
        -- Equip pickaxe if available
        if pickaxe and pickaxe.Parent ~= Utils:GetCharacter() then
            Utils:EquipTool(pickaxe)
            task.wait(0.1)
            return
        end
        
        for _, block in ipairs(blocksFolder:GetDescendants()) do
            if block:IsA("Part") and block.Name ~= "Baseplate" and block.Parent and block.Parent.Name ~= "SpawnPlatform" then
                local distance = Utils:GetDistance(root, block)
                
                if distance <= settings.Range then
                    -- Break the block
                    local breakRemote = Utils:FindRemote("DamageBlock") or
                                       Utils:FindRemote("BreakBlock") or
                                       Utils:FindRemote("BlockBreak")
                    
                    if breakRemote then
                        pcall(function()
                            if breakRemote:IsA("RemoteEvent") then
                                breakRemote:FireServer({
                                    blockRef = block,
                                    hitPosition = block.Position,
                                    hitNormal = Vector3.new(0, 1, 0)
                                })
                            else
                                breakRemote:InvokeServer(block, block.Position)
                            end
                        end)
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end

function Utility:ESP()
    local settings = OtterClient.Features.Utility.ESP
    
    if not settings.Enabled then
        -- Clear all ESP
        for _, esp in pairs(OtterClient.ESPObjects) do
            if esp and esp.Parent then
                esp:Destroy()
            end
        end
        OtterClient.ESPObjects = {}
        return
    end
    
    -- Update player ESP
    if settings.ShowPlayers then
        for _, player in ipairs(Utils:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local espId = "ESP_" .. player.UserId
                
                -- Check if ESP already exists
                if not OtterClient.ESPObjects[espId] or not OtterClient.ESPObjects[espId].Parent then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = espId
                    billboard.Parent = hrp
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    
                    local frame = Instance.new("Frame")
                    frame.Parent = billboard
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundTransparency = 0.5
                    frame.BackgroundColor3 = Utils:IsTeammate(player) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    frame.BorderSizePixel = 0
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 8)
                    corner.Parent = frame
                    
                    local label = Instance.new("TextLabel")
                    label.Parent = frame
                    label.Size = UDim2.new(1, 0, 0.6, 0)
                    label.BackgroundTransparency = 1
                    label.Text = player.Name
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    
                    local distance = Instance.new("TextLabel")
                    distance.Parent = frame
                    distance.Size = UDim2.new(1, 0, 0.4, 0)
                    distance.Position = UDim2.new(0, 0, 0.6, 0)
                    distance.BackgroundTransparency = 1
                    distance.TextColor3 = Color3.new(1, 1, 1)
                    distance.TextScaled = true
                    distance.Font = Enum.Font.Gotham
                    
                    OtterClient.ESPObjects[espId] = billboard
                end
                
                -- Update distance
                local root = Utils:GetRootPart()
                if root then
                    local dist = math.floor(Utils:GetDistance(root, hrp))
                    local billboard = OtterClient.ESPObjects[espId]
                    if billboard and billboard:FindFirstChild("Frame") then
                        local distLabel = billboard.Frame:FindFirstChild("TextLabel", true)
                        if distLabel and distLabel ~= billboard.Frame:FindFirstChildOfClass("TextLabel") then
                            distLabel.Text = dist .. "m"
                        end
                    end
                end
            end
        end
    end
    
    -- Update bed ESP
    if settings.ShowBeds then
        local bedsFolder = Workspace:FindFirstChild("Beds")
        if bedsFolder then
            for _, bed in ipairs(bedsFolder:GetChildren()) do
                if bed:IsA("Model") or bed:IsA("BasePart") then
                    local bedPart = bed:IsA("Model") and bed.PrimaryPart or bed
                    if bedPart then
                        local espId = "BedESP_" .. bed.Name
                        
                        if not OtterClient.ESPObjects[espId] or not OtterClient.ESPObjects[espId].Parent then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = espId
                            billboard.Parent = bedPart
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 100, 0, 40)
                            
                            local frame = Instance.new("Frame")
                            frame.Parent = billboard
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundTransparency = 0.5
                            frame.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                            frame.BorderSizePixel = 0
                            
                            local corner = Instance.new("UICorner")
                            corner.CornerRadius = UDim.new(0, 8)
                            corner.Parent = frame
                            
                            local label = Instance.new("TextLabel")
                            label.Parent = frame
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = "🛏️ BED"
                            label.TextColor3 = Color3.new(1, 1, 1)
                            label.TextScaled = true
                            label.Font = Enum.Font.GothamBold
                            
                            OtterClient.ESPObjects[espId] = billboard
                        end
                    end
                end
            end
        end
    end
end

function Utility:Tracers()
    local settings = OtterClient.Features.Utility.Tracers
    
    if not settings.Enabled then
        -- Clear tracers
        local camera = Workspace.CurrentCamera
        for _, obj in ipairs(camera:GetChildren()) do
            if obj.Name == "OtterTracer" then
                obj:Destroy()
            end
        end
        return
    end
    
    -- Create tracers to players
    local camera = Workspace.CurrentCamera
    local root = Utils:GetRootPart()
    
    if not root then return end
    
    -- Clear old tracers
    for _, obj in ipairs(camera:GetChildren()) do
        if obj.Name == "OtterTracer" then
            obj:Destroy()
        end
    end
    
    -- Create new tracers
    for _, player in ipairs(Utils:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            
            local attachment0 = Instance.new("Attachment")
            attachment0.Parent = camera
            
            local attachment1 = Instance.new("Attachment")
            attachment1.Parent = targetRoot
            
            local beam = Instance.new("Beam")
            beam.Name = "OtterTracer"
            beam.Attachment0 = attachment0
            beam.Attachment1 = attachment1
            beam.Width0 = 0.1
            beam.Width1 = 0.1
            beam.FaceCamera = true
            beam.Color = ColorSequence.new(Utils:IsTeammate(player) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            beam.Parent = camera
        end
    end
end

function Utility:AntiVoid()
    local settings = OtterClient.Features.Utility.AntiVoid
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    if root and root.Position.Y < settings.Height then
        -- Teleport up
        root.CFrame = root.CFrame + Vector3.new(0, 100, 0)
        Utils:Notify("Otter Client", "Anti-Void activated!", 2)
    end
end

function Utility:Scaffold()
    local settings = OtterClient.Features.Utility.Scaffold
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    local humanoid = Utils:GetHumanoid()
    if not root or not humanoid then return end
    
    -- Check if player is moving and in air
    if humanoid.MoveVector.Magnitude > 0 and humanoid.FloorMaterial == Enum.Material.Air then
        -- Find block in inventory
        local block = Utils:GetTool("wool") or Utils:GetTool("block")
        
        if block then
            -- Equip if needed
            if block.Parent ~= Utils:GetCharacter() then
                Utils:EquipTool(block)
                task.wait(0.1)
                return
            end
            
            -- Place block
            local placeRemote = Utils:FindRemote("PlaceBlock") or Utils:FindRemote("BlockPlace")
            if placeRemote then
                local placePos = root.Position - Vector3.new(0, 3, 0)
                pcall(function()
                    placeRemote:FireServer({
                        blockType = block.Name,
                        position = placePos,
                        normal = Vector3.new(0, 1, 0)
                    })
                end)
            end
        end
    end
end

-- World Features
local World = {}

function World:Fullbright()
    local settings = OtterClient.Features.World.Fullbright
    
    if settings.Enabled then
        if not OtterClient.OriginalValues.Brightness then
            OtterClient.OriginalValues.Brightness = Lighting.Brightness
            OtterClient.OriginalValues.ClockTime = Lighting.ClockTime
            OtterClient.OriginalValues.FogEnd = Lighting.FogEnd
            OtterClient.OriginalValues.GlobalShadows = Lighting.GlobalShadows
            OtterClient.OriginalValues.Ambient = Lighting.Ambient
        end
        
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    else
        if OtterClient.OriginalValues.Brightness then
            Lighting.Brightness = OtterClient.OriginalValues.Brightness
            Lighting.ClockTime = OtterClient.OriginalValues.ClockTime
            Lighting.FogEnd = OtterClient.OriginalValues.FogEnd
            Lighting.GlobalShadows = OtterClient.OriginalValues.GlobalShadows
            Lighting.Ambient = OtterClient.OriginalValues.Ambient
        end
    end
end

function World:Zoom()
    local settings = OtterClient.Features.World.Zoom
    
    if settings.Enabled then
        if not OtterClient.OriginalValues.CameraMaxZoom then
            OtterClient.OriginalValues.CameraMaxZoom = LocalPlayer.CameraMaxZoomDistance
        end
        LocalPlayer.CameraMaxZoomDistance = settings.Amount
    else
        if OtterClient.OriginalValues.CameraMaxZoom then
            LocalPlayer.CameraMaxZoomDistance = OtterClient.OriginalValues.CameraMaxZoom
        end
    end
end

-- Main Loop
local function MainLoop()
    -- Heartbeat loop for constant features
    OtterClient.Connections["MainLoop"] = RunService.Heartbeat:Connect(function()
        if not OtterClient.Enabled then return end
        
        pcall(Combat.KillAura, Combat)
        pcall(Combat.Reach, Combat)
        pcall(Movement.Speed, Movement)
        pcall(Movement.Fly, Movement)
    end)
    
    -- Stepped loop for physics-based features
    OtterClient.Connections["SteppedLoop"] = RunService.Stepped:Connect(function()
        if not OtterClient.Enabled then return end
        
        pcall(Combat.Velocity, Combat)
        pcall(Movement.NoFall, Movement)
        pcall(Movement.Spider, Movement)
        pcall(Utility.AntiVoid, Utility)
    end)
    
    -- Slower loop for less critical features
    task.spawn(function()
        while OtterClient.Enabled do
            pcall(Utility.AutoCollect, Utility)
            pcall(Utility.Nuker, Utility)
            pcall(Utility.ESP, Utility)
            pcall(Utility.Tracers, Utility)
            pcall(Utility.Scaffold, Utility)
            pcall(World.Fullbright, World)
            pcall(World.Zoom, World)
            
            task.wait(0.1)
        end
    end)
end

-- GUI System (keeping the same professional GUI from before)
local GUI = {}

function GUI:Create()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OtterClient"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Check if GUI already exists
    if LocalPlayer.PlayerGui:FindFirstChild("OtterClient") then
        LocalPlayer.PlayerGui:FindFirstChild("OtterClient"):Destroy()
    end
    
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Add shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = 0
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Fix bottom corners
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 12)
    headerFix.Position = UDim2.new(0, 0, 1, -12)
    headerFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🦦 OTTER CLIENT"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Version
    local version = Instance.new("TextLabel")
    version.Name = "Version"
    version.Size = UDim2.new(0, 100, 1, 0)
    version.Position = UDim2.new(0, 220, 0, 0)
    version.BackgroundTransparency = 1
    version.Text = "v" .. OtterClient.Version
    version.TextColor3 = Color3.fromRGB(150, 150, 150)
    version.TextSize = 14
    version.Font = Enum.Font.Gotham
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 140, 1, -60)
    tabContainer.Position = UDim2.new(0, 10, 0, 60)
    tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingLeft = UDim.new(0, 8)
    tabPadding.PaddingRight = UDim.new(0, 8)
    tabPadding.Parent = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(0, 430, 1, -60)
    contentContainer.Position = UDim2.new(0, 160, 0, 60)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Create Tabs
    local tabs = {"Combat", "Movement", "Utility", "World"}
    local currentTab = nil
    
    local function createTabButton(name, index)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "Tab"
        tabBtn.Size = UDim2.new(1, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.TextSize = 15
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.LayoutOrder = index
        tabBtn.Parent = tabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = tabBtn
        
        -- Hover effect
        tabBtn.MouseEnter:Connect(function()
            if currentTab ~= name then
                TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 58)}):Play()
            end
        end)
        
        tabBtn.MouseLeave:Connect(function()
            if currentTab ~= name then
                TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
            end
        end)
        
        return tabBtn
    end
    
    local function createContentPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 6
        page.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = contentContainer
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = page
        
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingTop = UDim.new(0, 5)
        pagePadding.PaddingLeft = UDim.new(0, 5)
        pagePadding.PaddingRight = UDim.new(0, 5)
        pagePadding.Parent = page
        
        return page
    end
    
    local function switchTab(name)
        currentTab = name
        
        -- Update buttons
        for _, btn in ipairs(tabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                if btn.Name == name .. "Tab" then
                    btn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
                    btn.TextColor3 = Color3.new(1, 1, 1)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
        end
        
        -- Update pages
        for _, page in ipairs(contentContainer:GetChildren()) do
            if page:IsA("ScrollingFrame") then
                page.Visible = (page.Name == name .. "Page")
            end
        end
    end
    
    -- Create tab buttons and pages
    local tabButtons = {}
    local pages = {}
    
    for i, tabName in ipairs(tabs) do
        tabButtons[tabName] = createTabButton(tabName, i)
        pages[tabName] = createContentPage(tabName)
        
        tabButtons[tabName].MouseButton1Click:Connect(function()
            switchTab(tabName)
        end)
    end
    
    -- Feature Creation Functions
    local function createFeatureModule(parent, featureName, category, subcategory)
        local module = Instance.new("Frame")
        module.Name = featureName
        module.Size = UDim2.new(1, -10, 0, 45)
        module.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        module.BorderSizePixel = 0
        module.Parent = parent
        
        local moduleCorner = Instance.new("UICorner")
        moduleCorner.CornerRadius = UDim.new(0, 8)
        moduleCorner.Parent = module
        
        local toggle = Instance.new("TextButton")
        toggle.Name = "Toggle"
        toggle.Size = UDim2.new(0, 70, 0, 30)
        toggle.Position = UDim2.new(1, -80, 0.5, -15)
        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        toggle.BorderSizePixel = 0
        toggle.Text = "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        toggle.TextSize = 13
        toggle.Font = Enum.Font.GothamBold
        toggle.Parent = module
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 6)
        toggleCorner.Parent = toggle
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 200, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = featureName
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 15
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = module
        
        toggle.MouseButton1Click:Connect(function()
            local feature = OtterClient.Features[category][subcategory]
            feature.Enabled = not feature.Enabled
            
            if feature.Enabled then
                toggle.Text = "ON"
                toggle.TextColor3 = Color3.fromRGB(100, 255, 100)
                toggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                Utils:Notify("Otter Client", featureName .. " enabled!", 2)
            else
                toggle.Text = "OFF"
                toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
                toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                Utils:Notify("Otter Client", featureName .. " disabled!", 2)
            end
        end)
        
        return module
    end
    
    -- Add Combat features
    for featureName, _ in pairs(OtterClient.Features.Combat) do
        createFeatureModule(pages.Combat, featureName, "Combat", featureName)
    end
    
    -- Add Movement features
    for featureName, _ in pairs(OtterClient.Features.Movement) do
        createFeatureModule(pages.Movement, featureName, "Movement", featureName)
    end
    
    -- Add Utility features
    for featureName, _ in pairs(OtterClient.Features.Utility) do
        createFeatureModule(pages.Utility, featureName, "Utility", featureName)
    end
    
    -- Add World features
    for featureName, _ in pairs(OtterClient.Features.World) do
        createFeatureModule(pages.World, featureName, "World", featureName)
    end
    
    -- Show first tab by default
    switchTab("Combat")
    
    Utils:Notify("Otter Client", "Loaded successfully! Press RightShift to toggle.", 5)
end

-- Toggle GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        local gui = LocalPlayer.PlayerGui:FindFirstChild("OtterClient")
        if gui then
            gui.Enabled = not gui.Enabled
        end
    end
end)

-- Initialize
local function Initialize()
    Utils:Notify("Otter Client", "Initializing...", 3)
    
    -- Find BedWars remotes
    Utils:GetBedWarsRemotes()
    
    -- Create GUI
    GUI:Create()
    
    -- Start main loop
    MainLoop()
    
    -- Handle character respawn
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if OtterClient.Enabled then
            Utils:Notify("Otter Client", "Respawned! Reloading features...", 2)
            
            -- Clear connections
            for name, connection in pairs(OtterClient.Connections) do
                if connection and typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                end
            end
            
            -- Restart main loop
            OtterClient.Connections = {}
            MainLoop()
        end
    end)
end

-- Start the client
Initialize()

return OtterClient
