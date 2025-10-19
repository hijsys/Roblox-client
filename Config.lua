--[[
    ╔═══════════════════════════════════════╗
    ║     OTTER CLIENT CONFIGURATION       ║
    ║        Customize Your Settings        ║
    ╚═══════════════════════════════════════╝
]]--

local Config = {
    -- GUI Settings
    GUI = {
        Theme = {
            Primary = Color3.fromRGB(100, 200, 255),
            Secondary = Color3.fromRGB(20, 20, 25),
            Accent = Color3.fromRGB(30, 30, 38),
            Success = Color3.fromRGB(50, 150, 50),
            Error = Color3.fromRGB(150, 50, 50),
            Text = Color3.fromRGB(255, 255, 255),
        },
        
        Position = {
            X = 0.5,
            Y = 0.5,
        },
        
        Size = {
            Width = 600,
            Height = 450,
        },
        
        Animations = {
            Speed = 0.2,
            EasingStyle = Enum.EasingStyle.Quad,
            EasingDirection = Enum.EasingDirection.Out,
        },
        
        ToggleKey = Enum.KeyCode.RightShift,
    },
    
    -- Combat Settings
    Combat = {
        KillAura = {
            DefaultRange = 20,
            MinRange = 5,
            MaxRange = 30,
            DefaultSpeed = 0.1,
            MinSpeed = 0,
            MaxSpeed = 1,
            TargetTeammates = false,
        },
        
        Velocity = {
            DefaultHorizontal = 0,
            DefaultVertical = 100,
            MinPercent = 0,
            MaxPercent = 100,
        },
        
        Reach = {
            DefaultDistance = 18,
            MinDistance = 10,
            MaxDistance = 30,
        },
    },
    
    -- Movement Settings
    Movement = {
        Speed = {
            DefaultAmount = 23,
            MinAmount = 16,
            MaxAmount = 100,
        },
        
        Fly = {
            DefaultSpeed = 50,
            MinSpeed = 10,
            MaxSpeed = 200,
        },
        
        Spider = {
            DefaultSpeed = 20,
            MinSpeed = 5,
            MaxSpeed = 50,
        },
        
        LongJump = {
            DefaultPower = 100,
            MinPower = 50,
            MaxPower = 200,
        },
    },
    
    -- Utility Settings
    Utility = {
        AutoCollect = {
            DefaultRange = 20,
            MinRange = 5,
            MaxRange = 50,
        },
        
        ChestStealer = {
            DefaultSpeed = 0.1,
            MinSpeed = 0,
            MaxSpeed = 1,
        },
        
        Nuker = {
            DefaultRange = 25,
            MinRange = 5,
            MaxRange = 50,
        },
        
        AntiVoid = {
            DefaultHeight = 10,
            MinHeight = 0,
            MaxHeight = 50,
        },
        
        ESP = {
            PlayerColor = {
                Teammate = Color3.fromRGB(0, 255, 0),
                Enemy = Color3.fromRGB(255, 0, 0),
            },
            BedColor = Color3.fromRGB(255, 255, 0),
            TracerColor = Color3.fromRGB(255, 255, 255),
        },
    },
    
    -- World Settings
    World = {
        Zoom = {
            DefaultAmount = 1000,
            MinAmount = 128,
            MaxAmount = 10000,
        },
        
        Fullbright = {
            Brightness = 2,
            ClockTime = 14,
            FogEnd = 100000,
        },
    },
    
    -- Performance Settings
    Performance = {
        UpdateRate = 60, -- FPS cap for features
        RemoteCacheTime = 300, -- seconds
        ESPUpdateRate = 1, -- updates per second
    },
    
    -- Remote Names (customize for different BedWars versions)
    Remotes = {
        Combat = {
            SwordHit = "SwordHit",
            DamageBlock = "DamageBlock",
        },
        
        Movement = {
            GroundHit = "GroundHit",
        },
        
        Utility = {
            CollectItem = "CollectItem",
            PickupItem = "PickupItem",
            BreakBlock = "BreakBlock",
            PlaceBlock = "PlaceBlock",
        },
    },
    
    -- Notification Settings
    Notifications = {
        Enabled = true,
        Duration = 3,
        ShowFeatureToggle = true,
        ShowErrors = false, -- Set to true for debugging
    },
}

return Config
