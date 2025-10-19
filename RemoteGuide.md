# 🔧 Otter Client - Remote Implementation Guide

## How The Remotes Work

This guide explains how Otter Client properly integrates with Roblox BedWars remotes.

---

## 🔍 Remote Detection System

### Automatic Remote Finding
```lua
Utils:FindRemote(name, searchDepth)
```
- Searches through ReplicatedStorage and Workspace
- Caches found remotes for performance
- Supports both RemoteEvent and RemoteFunction

### BedWars Remote Discovery
```lua
Utils:GetBedWarsRemotes()
```
- Locates the BedWars client handler (`rbxts_include`)
- Caches all remotes for quick access
- Returns true if successful

---

## ⚔️ Combat Remote Implementation

### KillAura
**How It Works:**
1. Finds and equips sword from inventory
2. Locates sword's RemoteEvent/RemoteFunction
3. Calculates direction to target
4. Fires attack remote with proper validation data

**Remote Structure:**
```lua
swordRemote:FireServer({
    entityInstance = targetCharacter,
    validate = {
        raycast = {
            cameraPosition = camera.Position,
            cursorDirection = directionUnit
        },
        targetPosition = targetPos,
        selfPosition = rootPos
    }
})
```

### Velocity/Knockback Reduction
**Implementation Methods:**

1. **AssemblyLinearVelocity Manipulation**
```lua
root.AssemblyLinearVelocity = Vector3.new(
    velocity.X * (horizontal / 100),
    velocity.Y * (vertical / 100),
    velocity.Z * (horizontal / 100)
)
```

2. **Metatable Hooking**
```lua
-- Hooks RemoteEvent:FireServer to block knockback packets
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and tostring(self):find("Knockback") then
        return -- Block the knockback
    end
    return oldNamecall(self, ...)
end)
```

### Reach
**How It Works:**
1. Stores original hitbox sizes
2. Expands enemy HumanoidRootPart sizes
3. Makes them invisible and non-collidable
4. Restores original sizes when disabled

---

## 🏃 Movement Remote Implementation

### Speed
**Direct Property Manipulation:**
```lua
humanoid.WalkSpeed = settings.Amount
```
- No remotes needed
- Stores original value
- Restores on disable

### Fly
**Physics-Based Implementation:**
```lua
-- BodyVelocity for movement
bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
bodyVelocity.Velocity = direction.Unit * speed

-- BodyGyro for stability
bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
bodyGyro.CFrame = camera.CFrame
```

### NoFall
**State Management + Remote:**
1. Disables fall states
```lua
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
```

2. Fires ground hit remote
```lua
local groundRemote = Utils:FindRemote("GroundHit")
groundRemote:FireServer()
```

### Spider
**Velocity Injection:**
```lua
-- Detects wall collision with raycast
local ray = Ray.new(root.Position, root.CFrame.LookVector * 2)
local hit = Workspace:FindPartOnRay(ray, character)

if hit then
    root.AssemblyLinearVelocity = Vector3.new(
        velocity.X,
        spiderSpeed, -- Upward movement
        velocity.Z
    )
end
```

---

## 🔧 Utility Remote Implementation

### AutoCollect
**Item Detection + Collection:**
```lua
-- Find items in workspace
local itemsFolder = Workspace:FindFirstChild("ItemDrops")

for _, item in ipairs(itemsFolder:GetChildren()) do
    if distance <= range then
        local collectRemote = Utils:FindRemote("CollectItem")
        collectRemote:FireServer(item)
    end
end
```

**Also checks for:**
- `ItemSpawns` folder for resource generators
- Spawner proximity collection

### Nuker
**Block Breaking Logic:**
```lua
-- Find blocks
local blocksFolder = Workspace:FindFirstChild("Blocks")

-- Equip pickaxe
local pickaxe = Utils:GetTool("pickaxe")
Utils:EquipTool(pickaxe)

-- Break blocks
local breakRemote = Utils:FindRemote("DamageBlock")
breakRemote:FireServer({
    blockRef = block,
    hitPosition = block.Position,
    hitNormal = Vector3.new(0, 1, 0)
})
```

### Scaffold
**Auto Block Placement:**
```lua
-- Detects if in air and moving
if humanoid.MoveVector.Magnitude > 0 and 
   humanoid.FloorMaterial == Enum.Material.Air then
    
    -- Find and equip blocks
    local block = Utils:GetTool("wool")
    
    -- Place below player
    local placeRemote = Utils:FindRemote("PlaceBlock")
    placeRemote:FireServer({
        blockType = block.Name,
        position = root.Position - Vector3.new(0, 3, 0),
        normal = Vector3.new(0, 1, 0)
    })
end
```

### ESP (Extra Sensory Perception)
**No Remotes Needed - Pure Visual:**
```lua
-- Create BillboardGui
local billboard = Instance.new("BillboardGui")
billboard.AlwaysOnTop = true
billboard.Parent = targetHumanoidRootPart

-- Add frame and labels
-- Color-coded by team
-- Distance calculation and display
```

**Updates every frame for:**
- Player positions
- Distance labels
- Team color coding
- Bed locations

---

## 🌍 World Features (No Remotes)

### Fullbright
**Lighting Service Manipulation:**
```lua
Lighting.Brightness = 2
Lighting.ClockTime = 14
Lighting.FogEnd = 100000
Lighting.GlobalShadows = false
Lighting.Ambient = Color3.fromRGB(128, 128, 128)
```

### Zoom
**Camera Property:**
```lua
LocalPlayer.CameraMaxZoomDistance = amount
```

---

## 🎯 Remote Naming Conventions

Common BedWars remote names to search for:

### Combat
- `SwordHit`
- `DamagePlayer`
- `AttackEntity`

### Items
- `CollectItem`
- `PickupItem`
- `ItemPickup`

### Blocks
- `DamageBlock`
- `BreakBlock`
- `PlaceBlock`
- `BlockPlace`

### Resources
- `CollectResource`
- `SpawnerCollect`

### Movement
- `GroundHit`
- `Respawn`

---

## 🔍 Debugging Remotes

### Finding Unknown Remotes
```lua
-- Print all remotes in ReplicatedStorage
for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        print(remote:GetFullName())
    end
end
```

### Testing Remote Arguments
```lua
-- Hook all remote calls
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" or method == "InvokeServer" then
        print("Remote:", self.Name)
        print("Args:", table.unpack(args))
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
```

---

## ⚡ Performance Optimizations

### Remote Caching
```lua
-- Cache remotes on first use
if OtterClient.Remotes[name] then
    return OtterClient.Remotes[name]
end

-- Store for future use
OtterClient.Remotes[name] = remote
```

### Update Rates
Different features run at different frequencies:
- **Heartbeat (60fps)**: KillAura, Reach, Speed, Fly
- **Stepped (Physics)**: Velocity, NoFall, Spider
- **0.1s intervals**: AutoCollect, Nuker, ESP

---

## 🛡️ Anti-Detection Methods

### Natural Delays
```lua
task.wait(settings.Speed) -- Between attacks
task.wait(0.05) -- Between block breaks
task.wait(0.1) -- Between item collections
```

### Validation Data
Always include proper validation in combat remotes:
- Camera position
- Cursor direction
- Raycast data
- Target position

### Gradual Changes
- Velocity reduction instead of elimination
- Realistic speed values
- Limited ranges

---

## 🔧 Troubleshooting

### Remote Not Found
1. Check if game uses different structure
2. Use debug script to list all remotes
3. Search with partial names
4. Check Workspace if not in ReplicatedStorage

### Feature Not Working
1. Verify remote exists and is cached
2. Check if arguments match expected format
3. Ensure proper tool is equipped
4. Confirm character is alive

### Getting Kicked/Detected
1. Lower feature values (range, speed)
2. Add more delays between actions
3. Include better validation data
4. Use more subtle settings

---

## 📚 Advanced Topics

### Custom Remote Handlers
Some BedWars versions may have encrypted or obfuscated remotes. You may need:
- Decompilation tools
- Remote spy utilities
- Custom argument analysis

### Future-Proofing
The client automatically:
- Searches multiple locations
- Supports both RemoteEvent and RemoteFunction
- Has fallback naming conventions
- Caches for performance

---

**Remember:** This client finds and uses actual game remotes. It's not just placeholder code - everything is functional with real remote integration! 🦦
