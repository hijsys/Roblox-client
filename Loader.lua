--[[
    ╔═══════════════════════════════════════╗
    ║      OTTER CLIENT LOADER             ║
    ║      Quick Load Script                ║
    ╚═══════════════════════════════════════╝
    
    This is a simple loader script that you can use
    to quickly load Otter Client into any game.
]]--

-- Configuration
local LOAD_CONFIG = true
local LOAD_ADVANCED_FEATURES = true

-- Notification function
local function notify(text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Otter Client Loader",
        Text = text,
        Duration = 3,
    })
end

-- Main loader
notify("Loading Otter Client...")

-- Load configuration (optional)
local Config
if LOAD_CONFIG then
    local configSuccess, configResult = pcall(function()
        return loadfile("Config.lua")()
    end)
    
    if configSuccess then
        Config = configResult
        notify("Configuration loaded!")
    else
        notify("Using default configuration")
    end
end

-- Load advanced features (optional)
local AdvancedFeatures
if LOAD_ADVANCED_FEATURES then
    local advSuccess, advResult = pcall(function()
        return loadfile("AdvancedFeatures.lua")()
    end)
    
    if advSuccess then
        AdvancedFeatures = advResult
        notify("Advanced features loaded!")
    end
end

-- Load main client
local clientSuccess, clientError = pcall(function()
    return loadfile("OtterClient.lua")()
end)

if clientSuccess then
    notify("✅ Otter Client loaded successfully!")
else
    warn("Failed to load Otter Client:", clientError)
    notify("❌ Failed to load client!")
end

-- Alternative: Load from URL (if you host the files online)
--[[
local HttpService = game:GetService("HttpService")

local function loadFromURL(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        return loadstring(result)()
    else
        return nil
    end
end

-- Example URLs (replace with your actual URLs)
local BASE_URL = "https://yourwebsite.com/otter/"
loadFromURL(BASE_URL .. "OtterClient.lua")
]]--
