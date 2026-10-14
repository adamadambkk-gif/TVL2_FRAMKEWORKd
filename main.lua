-- main.lua
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Framework = {
    IsRunning = false,
    State = {
        -- Feature Checkbox Variables
        AntiScreenEffects = true,
        ESP_Enabled = true,
        RenderDistance = 1000,
        ExcludeFriends = true,
        ExtendHitboxes = true,
        HitboxSize = 15,
        LockAmbience = true,
        FPS_Booster = false,
        CustomCursor = true,
        CursorAsset = 9945538562,
        ShowWatermark = true
    },
    Connections = {}
}

-- Require ALL SIX structural module sheets into system cache paths
local AntiEffectsModule = require(script.Parent.modules.anti_effects)
local CombatModule      = require(script.Parent.modules.combat)
local ESPModule         = require(script.Parent.modules.esp)
local AmbienceModule    = require(script.Parent.modules.ambience)
local EssentialsModule  = require(script.Parent.modules.essentials)
local ConfigModule      = require(script.Parent.modules.config)

function Framework:Start()
    if self.IsRunning then return end
    self.IsRunning = true
    
    -- 1. Run Config Auto-Load immediately to grab your saved settings
    self.State = ConfigModule:LoadProfile(self.State)
    
    print("[Framework] Bootstrapping TVL2 Core with loaded configurations...")
    
    local fpsTimeBuffer = 0
    local frameCounter = 0
    local currentFps = 60
    
    local coreLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.IsRunning then return end
        
        -- High-frequency performance calculations
        frameCounter = frameCounter + 1
        fpsTimeBuffer = fpsTimeBuffer + deltaTime
        if fpsTimeBuffer >= 1 then
            currentFps = frameCounter
            frameCounter = 0
            fpsTimeBuffer = 0
        end
        
        local currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        
        -- Route Live Engine States
        pcall(function()
            if self.State.AntiScreenEffects then AntiEffectsModule:RunCleanse() end
            if self.State.ExtendHitboxes      then CombatModule:ExtendHitboxes(self.State.HitboxSize, self.State.ExcludeFriends) end
            if self.State.ESP_Enabled         then ESPModule:ProcessAwareness(self.State.ExcludeFriends, self.State.RenderDistance) end
            if self.State.LockAmbience        then AmbienceModule:MaintainEnvironment() end
            if self.State.FPS_Booster         then EssentialsModule:BoostFPS(true) end
            
            EssentialsModule:SetCursor(self.State.CustomCursor, self.State.CursorAsset)
            
            if self.State.ShowWatermark then
                EssentialsModule:UpdateWatermark(currentFps, currentPing)
            end
        end)
    end)
    
    table.insert(self.Connections, coreLoop)
end

function Framework:Unload()
    if not self.IsRunning then return end
    
    -- Auto-Save settings one final time before turning off features
    pcall(function() ConfigModule:SaveProfile(self.State) end)
    
    self.IsRunning = false
    
    -- Terminate thread listeners instantly
    for _, connection in pairs(self.Connections) do
        if connection then connection:Disconnect() end
    end
    table.clear(self.Connections)
    
    -- Full cleanup routines
    pcall(function() CombatModule:ResetAllHitboxes() end)
    pcall(function() ESPModule:ClearAllDrawings() end)
    pcall(function() AmbienceModule:ResetEnvironment() end)
    pcall(function() EssentialsModule:CleanUp() end)
    
    print("[Framework] Teardown execution finalized. Safe system detach complete.")
end

return Framework
