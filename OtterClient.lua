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
    
    -- Remote Cache
    Remotes = {
        SwordRemote = nil,
        DamageBlock = nil,
        PickupRemote = nil,
        PlaceBlock = nil,
        BreakBlock = nil,
    }
}

-- Utility Functions
local Utils = {}

function Utils:GetRemote(name)
    if OtterClient.Remotes[name] then
        return OtterClient.Remotes[name]
    end
    
    -- Common remote paths for BedWars
    local possiblePaths = {
        ReplicatedStorage:FindFirstChild("rbxts_include"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Events"),
    }
    
    for _, path in ipairs(possiblePaths) do
        if path then
            local remote = path:FindFirstChild(name, true)
            if remote then
                OtterClient.Remotes[name] = remote
                return remote
            end
        end
    end
    
    return nil
end

function Utils:GetCharacter()
    return LocalPlayer.Character
end

function Utils:GetRootPart()
    local char = self:GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils:GetHumanoid()
    local char = self:GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils:IsAlive()
    local humanoid = self:GetHumanoid()
    return humanoid and humanoid.Health > 0
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

function Utils:Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
    })
end

-- Combat Features
local Combat = {}

function Combat:KillAura()
    local settings = OtterClient.Features.Combat.KillAura
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    if not root then return end
    
    local sword = LocalPlayer.Character:FindFirstChild("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
    
    for _, player in ipairs(Utils:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local distance = Utils:GetDistance(root, targetRoot)
            
            if distance <= settings.Range then
                if not settings.TargetTeammates and Utils:IsTeammate(player) then
                    continue
                end
                
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    -- Fire sword remote
                    local swordRemote = Utils:GetRemote("SwordHit")
                    if swordRemote then
                        pcall(function()
                            swordRemote:FireServer({
                                weapon = sword,
                                entityInstance = player.Character,
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
                    
                    task.wait(settings.Speed)
                end
            end
        end
    end
end

function Combat:Velocity()
    local settings = OtterClient.Features.Combat.Velocity
    if not settings.Enabled then return end
    
    local humanoid = Utils:GetHumanoid()
    if humanoid then
        local oldVelocity = nil
        
        OtterClient.Connections["Velocity"] = humanoid:GetPropertyChangedSignal("Velocity"):Connect(function()
            if humanoid.Velocity.Y < 0 then
                humanoid.Velocity = Vector3.new(
                    humanoid.Velocity.X * (settings.Horizontal / 100),
                    humanoid.Velocity.Y * (settings.Vertical / 100),
                    humanoid.Velocity.Z * (settings.Horizontal / 100)
                )
            end
        end)
    end
end

function Combat:Reach()
    local settings = OtterClient.Features.Combat.Reach
    if not settings.Enabled then return end
    
    -- Modify hitbox sizes
    for _, player in ipairs(Utils:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if hrp:IsA("BasePart") then
                hrp.Size = Vector3.new(settings.Distance, settings.Distance, settings.Distance)
                hrp.Transparency = 1
            end
        end
    end
end

-- Movement Features
local Movement = {}

function Movement:Speed()
    local settings = OtterClient.Features.Movement.Speed
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local humanoid = Utils:GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = settings.Amount
    end
end

function Movement:Fly()
    local settings = OtterClient.Features.Movement.Fly
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    if not root then return end
    
    local bodyVelocity = root:FindFirstChild("OtterFly") or Instance.new("BodyVelocity")
    bodyVelocity.Name = "OtterFly"
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Parent = root
    
    local direction = Vector3.zero
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction = direction + (Workspace.CurrentCamera.CFrame.LookVector)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction = direction - (Workspace.CurrentCamera.CFrame.LookVector)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction = direction - (Workspace.CurrentCamera.CFrame.RightVector)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction = direction + (Workspace.CurrentCamera.CFrame.RightVector)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end
    
    bodyVelocity.Velocity = direction.Unit * settings.Speed
end

function Movement:NoFall()
    local settings = OtterClient.Features.Movement.NoFall
    if not settings.Enabled then return end
    
    local root = Utils:GetRootPart()
    if root and root.Velocity.Y < -50 then
        local fallRemote = Utils:GetRemote("GroundHit")
        if fallRemote then
            pcall(function()
                fallRemote:FireServer()
            end)
        end
    end
end

-- Utility Features
local Utility = {}

function Utility:AutoCollect()
    local settings = OtterClient.Features.Utility.AutoCollect
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    if not root then return end
    
    -- Look for collectible items
    local items = Workspace:FindFirstChild("Items") or Workspace:FindFirstChild("ItemSpawns")
    if items then
        for _, item in ipairs(items:GetChildren()) do
            if item:IsA("Model") or item:IsA("Part") then
                local distance = Utils:GetDistance(root, item:FindFirstChildWhichIsA("BasePart") or item)
                if distance <= settings.Range then
                    local pickupRemote = Utils:GetRemote("CollectItem") or Utils:GetRemote("PickupItem")
                    if pickupRemote then
                        pcall(function()
                            pickupRemote:FireServer(item)
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
    local blocks = Workspace:FindFirstChild("Blocks") or Workspace:FindFirstChild("Map")
    if blocks then
        for _, block in ipairs(blocks:GetDescendants()) do
            if block:IsA("BasePart") and block.Name ~= "Baseplate" then
                local distance = Utils:GetDistance(root, block)
                if distance <= settings.Range then
                    local breakRemote = Utils:GetRemote("DamageBlock") or Utils:GetRemote("BreakBlock")
                    if breakRemote then
                        pcall(function()
                            breakRemote:FireServer({
                                blockRef = block,
                                hitPosition = block.Position,
                                hitNormal = Vector3.new(0, 1, 0)
                            })
                        end)
                    end
                    task.wait(0.01)
                end
            end
        end
    end
end

function Utility:ESP()
    local settings = OtterClient.Features.Utility.ESP
    if not settings.Enabled then return end
    
    -- Clear old ESP
    for _, esp in pairs(OtterClient.ESPObjects) do
        if esp then
            esp:Destroy()
        end
    end
    OtterClient.ESPObjects = {}
    
    if settings.ShowPlayers then
        for _, player in ipairs(Utils:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                
                local billboard = Instance.new("BillboardGui")
                billboard.Parent = hrp
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                
                local frame = Instance.new("Frame")
                frame.Parent = billboard
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 0.5
                frame.BackgroundColor3 = Utils:IsTeammate(player) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                
                local label = Instance.new("TextLabel")
                label.Parent = frame
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = player.Name
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextScaled = true
                
                table.insert(OtterClient.ESPObjects, billboard)
            end
        end
    end
    
    if settings.ShowBeds then
        local beds = Workspace:FindFirstChild("Beds")
        if beds then
            for _, bed in ipairs(beds:GetChildren()) do
                if bed:IsA("Model") or bed:IsA("Part") then
                    local part = bed:IsA("Model") and bed.PrimaryPart or bed
                    if part then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Parent = part
                        billboard.AlwaysOnTop = true
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        
                        local label = Instance.new("TextLabel")
                        label.Parent = billboard
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 0.5
                        label.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                        label.Text = "BED"
                        label.TextColor3 = Color3.new(1, 1, 1)
                        label.TextScaled = true
                        
                        table.insert(OtterClient.ESPObjects, billboard)
                    end
                end
            end
        end
    end
end

function Utility:AntiVoid()
    local settings = OtterClient.Features.Utility.AntiVoid
    if not settings.Enabled or not Utils:IsAlive() then return end
    
    local root = Utils:GetRootPart()
    if root and root.Position.Y < settings.Height then
        root.CFrame = root.CFrame + Vector3.new(0, 50, 0)
    end
end

-- World Features
local World = {}

function World:Fullbright()
    local settings = OtterClient.Features.World.Fullbright
    local lighting = game:GetService("Lighting")
    
    if settings.Enabled then
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        lighting.Brightness = 1
        lighting.ClockTime = 12
        lighting.FogEnd = 100000
        lighting.GlobalShadows = true
    end
end

function World:Zoom()
    local settings = OtterClient.Features.World.Zoom
    if settings.Enabled then
        LocalPlayer.CameraMaxZoomDistance = settings.Amount
    else
        LocalPlayer.CameraMaxZoomDistance = 128
    end
end

-- Main Loop
local function MainLoop()
    RunService.Heartbeat:Connect(function()
        if not OtterClient.Enabled then return end
        
        -- Combat
        pcall(Combat.KillAura, Combat)
        pcall(Combat.Velocity, Combat)
        pcall(Combat.Reach, Combat)
        
        -- Movement
        pcall(Movement.Speed, Movement)
        pcall(Movement.Fly, Movement)
        pcall(Movement.NoFall, Movement)
        
        -- Utility
        pcall(Utility.AutoCollect, Utility)
        pcall(Utility.Nuker, Utility)
        pcall(Utility.ESP, Utility)
        pcall(Utility.AntiVoid, Utility)
    end)
end

-- GUI System
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
        screenGui:Destroy()
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
    
    Utils:Notify("Otter Client", "Loaded successfully! Press RightShift to toggle GUI.", 5)
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
    
    -- Create GUI
    GUI:Create()
    
    -- Start main loop
    MainLoop()
    
    -- Handle character respawn
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if OtterClient.Enabled then
            Utils:Notify("Otter Client", "Character respawned, reloading features...", 2)
        end
    end)
end

-- Start the client
Initialize()

return OtterClient
