-- main.lua
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Framework = {
    IsRunning = false,
    State = {
        AntiScreenEffects = true,
        ESP_Enabled = true,
        RenderDistance = 1000,
        ExcludeFriends = true,
        ExtendHitboxes = true,
        HitboxSize = 15,
        FPS_Booster = false,
        CustomCursor = true,
        CursorAsset = 9945538562,
        ShowWatermark = true
    },
    Connections = {},
    MenuWindow = nil
}

-- Safe Web Loading Utility Engine
local function GetWebModule(url)
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    if success and content then
        local runCode, compileError = loadstring(content)
        if runCode then
            return runCode()
        else
            warn("[Framework Build Error] Failed to compile web file: " .. tostring(compileError))
        end
    else
        warn("[Framework Build Error] HTTP Network Fetch failed for URL: " .. tostring(url))
    end
    return nil
end

print("[Framework] Connecting to GitHub repository...")

-- Core Raw Web Targets (Pointed directly to your clean GitHub profile paths)
local AntiEffectsModule = GetWebModule("https://githubusercontent.com")
local CombatModule      = GetWebModule("https://githubusercontent.com")
local ESPModule         = GetWebModule("https://githubusercontent.com")
local EssentialsModule  = GetWebModule("https://githubusercontent.com")
local InterfaceModule   = GetWebModule("https://githubusercontent.com")

function Framework:Start()
    if self.IsRunning then return end
    
    -- Verify assets downloaded perfectly before engaging loops
    if not (AntiEffectsModule and CombatModule and ESPModule and EssentialsModule and InterfaceModule) then
        warn("[Framework Critical] One or more core feature modules failed to download. Execution halted.")
        return
    end
    
    self.IsRunning = true
    
    -- Construct UI Menu Layout
    self.MenuWindow = InterfaceModule.CreateWindow("TVL2 Pro Suite Hub", 14241031306)
    
    self.MenuWindow:AddToggle("Clear Screen Effects / Spells", "AntiScreenEffects", self)
    self.MenuWindow:AddToggle("Expand Combat Target Hitboxes", "ExtendHitboxes", self)
    self.MenuWindow:AddToggle("Undetectable Player ESP", "ESP_Enabled", self)
    self.MenuWindow:AddToggle("Activate Graphics Frame Booster", "FPS_Booster", self)
    self.MenuWindow:AddToggle("Render Performance Watermark", "ShowWatermark", self)
    
    print("[Framework] Core Suite active! GUI menu drawn successfully.")
    
    local fpsTimeBuffer = 0
    local frameCounter = 0
    local currentFps = 60
    
    local coreLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.IsRunning then return end
        
        frameCounter = frameCounter + 1
        fpsTimeBuffer = fpsTimeBuffer + deltaTime
        if fpsTimeBuffer >= 1 then
            currentFps = frameCounter
            frameCounter = 0
            fpsTimeBuffer = 0
        end
        
        local currentPing = 0
        pcall(function()
            currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        
        -- Route Active Checked States Frame-by-Frame
        pcall(function()
            if self.State.AntiScreenEffects then AntiEffectsModule:RunCleanse() end
            if self.State.ExtendHitboxes      then CombatModule:ExtendHitboxes(self.State.HitboxSize, self.State.ExcludeFriends) end
            if self.State.ESP_Enabled         then ESPModule:ProcessAwareness(self.State.ExcludeFriends, self.State.RenderDistance) end
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
    self.IsRunning = false
    
    for _, connection in pairs(self.Connections) do
        if connection then connection:Disconnect() end
    end
    table.clear(self.Connections)
    
    if self.MenuWindow then
        pcall(function() self.MenuWindow:DestroyUI() end)
    end
    
    pcall(function() CombatModule:ResetAllHitboxes() end)
    pcall(function() ESPModule:ClearAllDrawings() end)
    pcall(function() EssentialsModule:CleanUp() end)
    
    print("[Framework] Memory purged cleanly.")
end

return Framework
