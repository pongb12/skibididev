-- Pongb Hub - Fisch Rework V3.0 Enhanced

local PongbHub = {
    _VERSION = "3.0",
    _BUILD = "ENHANCED",
    _SECURE_MODE = true,
    _DEBUG = false
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function SecureLoad(url, fallback)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("Failed to load: " .. url)
        return fallback
    end
    return result
end

local function SafeGetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

-- Load UI Libraries
local Fluent = SecureLoad("https://raw.githubusercontent.com/Knuxy92/Ui-linoria/main/Fluent/Fluent.lua")
local SaveManager = SecureLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
local InterfaceManager = SecureLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")

if not (Fluent and SaveManager and InterfaceManager) then
    game:GetService("Players").LocalPlayer:Kick("Hub: Failed to load dependencies")
    return
end

-- ============================================
-- SERVICES INITIALIZATION
-- ============================================

local Services = {
    Players = SafeGetService("Players"),
    ReplicatedStorage = SafeGetService("ReplicatedStorage"),
    RunService = SafeGetService("RunService"),
    VirtualInputManager = SafeGetService("VirtualInputManager"),
    CollectionService = SafeGetService("CollectionService"),
    CoreGui = SafeGetService("CoreGui"),
    HttpService = SafeGetService("HttpService"),
    TeleportService = SafeGetService("TeleportService"),
    UserInputService = SafeGetService("UserInputService"),
    VirtualUser = SafeGetService("VirtualUser"),
    Lighting = SafeGetService("Lighting")
}

local LocalPlayer = Services.Players.LocalPlayer or Services.Players.PlayerAdded:Wait()
local Backpack = LocalPlayer.Backpack
local PlayerGui = LocalPlayer.PlayerGui

-- ============================================
-- ADVANCED ANTI-DETECTION SYSTEM
-- ============================================

local AntiDetection = {
    Patterns = {
        castDelays = {0.8, 1.0, 1.2, 1.5, 1.8, 2.0, 2.3, 2.5},
        reelDelays = {0.05, 0.08, 0.10, 0.12, 0.15, 0.18},
        movePatterns = {"linear", "smooth", "pause", "zigzag"},
        actionDelays = {0.1, 0.15, 0.2, 0.25, 0.3}
    },
    ActionHistory = {},
    LastActionTime = 0,
    SessionVariance = math.random(80, 120) / 100,
    
    -- Enhanced HWID Spoofing
    FakeHWID = string.format("%06d-%06d-%06d", 
        math.random(100000, 999999),
        math.random(100000, 999999),
        math.random(100000, 999999)
    )
}

function AntiDetection:Initialize()
    getgenv().FakeHWID = self.FakeHWID
    
    -- Advanced Metamethod Hook
    local gameMeta = getrawmetatable(game)
    if gameMeta and gameMeta.__namecall then
        local oldNamecall = gameMeta.__namecall
        setreadonly(gameMeta, false)
        
        gameMeta.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Add random delays to suspicious calls
            if method == "FireServer" or method == "InvokeServer" then
                local chance = math.random(1, 100)
                if chance <= 5 then
                    task.wait(math.random(1, 50) / 1000)
                end
            end
            
            -- Obfuscate JSON operations
            if method == "JSONEncode" or method == "JSONDecode" then
                local rand = math.random(1, 100)
                if rand <= 10 then
                    task.wait(0.01)
                end
            end
            
            return oldNamecall(self, unpack(args))
        end)
        
        setreadonly(gameMeta, true)
    end
    
    -- Hook Character Added for persistence
    if LocalPlayer.Character then
        self:HookCharacter(LocalPlayer.Character)
    end
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        self:HookCharacter(char)
    end)
end

function AntiDetection:HookCharacter(character)
    -- Add subtle humanoid behavior modifications
    task.spawn(function()
        repeat task.wait() until character:FindFirstChild("Humanoid")
        local humanoid = character.Humanoid
        
        -- Random walk speed variance
        local baseSpeed = humanoid.WalkSpeed
        task.spawn(function()
            while character.Parent and humanoid.Parent do
                if not Config["Toggle Walk Speed"] then
                    local variance = math.random(-2, 2)
                    humanoid.WalkSpeed = baseSpeed + variance
                end
                task.wait(math.random(5, 15))
            end
        end)
    end)
end

function AntiDetection:GetRandomDelay(baseDelay)
    baseDelay = baseDelay or 0.1
    local variance = math.random(80, 120) / 100
    return baseDelay * variance * self.SessionVariance
end

function AntiDetection:RecordAction(actionType)
    table.insert(self.ActionHistory, {
        type = actionType,
        time = tick(),
        variance = math.random(90, 110) / 100
    })
    
    -- Keep only last 100 actions
    if #self.ActionHistory > 100 then
        table.remove(self.ActionHistory, 1)
    end
end

function AntiDetection:HumanLikeAction(actionType)
    local currentTime = tick()
    local timeSinceLastAction = currentTime - self.LastActionTime
    
    -- Ensure minimum delay between actions
    if timeSinceLastAction < 0.05 then
        task.wait(self:GetRandomDelay(0.1))
    end
    
    self.LastActionTime = currentTime
    self:RecordAction(actionType or "generic")
end

function AntiDetection:SmoothTeleport(targetCFrame, options)
    options = options or {}
    local steps = options.steps or math.random(3, 6)
    local delayRange = options.delayRange or {0.05, 0.15}
    local addOffset = options.addOffset ~= false
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local hrp = character.HumanoidRootPart
    local startPos = hrp.Position
    local targetPos = targetCFrame.Position
    
    for i = 1, steps do
        local alpha = i / steps
        local newPos = startPos:Lerp(targetPos, alpha)
        
        -- Add random offset for natural movement
        if addOffset then
            newPos = newPos + Vector3.new(
                math.random(-10, 10) / 10,
                math.random(-5, 5) / 10,
                math.random(-10, 10) / 10
            )
        end
        
        hrp.CFrame = CFrame.new(newPos)
        task.wait(math.random(delayRange[1] * 100, delayRange[2] * 100) / 100)
    end
    
    return true
end

function AntiDetection:RandomBehavior()
    local behaviors = {
        function()
            task.wait(self:GetRandomDelay(1))
        end,
        function()
            if LocalPlayer.Character then
                local cam = workspace.CurrentCamera
                local currentCF = cam.CFrame
                local randomAngle = math.rad(math.random(-30, 30))
                cam.CFrame = currentCF * CFrame.Angles(0, randomAngle, 0)
                task.wait(0.1)
                cam.CFrame = currentCF
            end
        end,
        function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local randomDir = Vector3.new(
                    math.random(-3, 3),
                    0,
                    math.random(-3, 3)
                )
                hrp.CFrame = hrp.CFrame + randomDir
            end
        end
    }
    
    local behavior = behaviors[math.random(1, #behaviors)]
    pcall(behavior)
end

-- ============================================
-- MEMORY MANAGEMENT SYSTEM
-- ============================================

local MemoryManager = {
    Connections = {},
    Threads = {},
    CleanupFunctions = {},
    TrackedObjects = {}
}

function MemoryManager:AddConnection(connection)
    table.insert(self.Connections, connection)
    return connection
end

function MemoryManager:AddThread(thread)
    table.insert(self.Threads, thread)
    return thread
end

function MemoryManager:AddCleanup(func)
    table.insert(self.CleanupFunctions, func)
end

function MemoryManager:TrackObject(object)
    table.insert(self.TrackedObjects, object)
    return object
end

function MemoryManager:Cleanup()
    for _, conn in pairs(self.Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    for _, thread in pairs(self.Threads) do
        if thread and coroutine.status(thread) ~= "dead" then
            pcall(function() task.cancel(thread) end)
        end
    end
    
    for _, func in pairs(self.CleanupFunctions) do
        pcall(func)
    end
    
    for _, obj in pairs(self.TrackedObjects) do
        if obj and obj.Destroy then
            pcall(function() obj:Destroy() end)
        end
    end
    
    table.clear(self.Connections)
    table.clear(self.Threads)
    table.clear(self.CleanupFunctions)
    table.clear(self.TrackedObjects)
    
    collectgarbage("collect")
end

-- ============================================
-- ADVANCED ENCRYPTION SYSTEM
-- ============================================

local EncryptionManager = {
    Key = "PH_" .. tostring(LocalPlayer.UserId),
    Salt = tostring(os.time())
}

function EncryptionManager:Base64Encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function EncryptionManager:Base64Decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function EncryptionManager:XOREncrypt(data, key)
    local result = ""
    for i = 1, #data do
        local byte = string.byte(data, i)
        local keyByte = string.byte(key, ((i - 1) % #key) + 1)
        result = result .. string.char(bit32.bxor(byte, keyByte))
    end
    return result
end

function EncryptionManager:Encrypt(data)
    if not Services.HttpService then return data end
    
    local json = Services.HttpService:JSONEncode(data)
    local xorEncrypted = self:XOREncrypt(json, self.Key .. self.Salt)
    local base64Encrypted = self:Base64Encode(xorEncrypted)
    local checksum = self:GenerateChecksum(base64Encrypted)
    
    return base64Encrypted .. "|" .. checksum .. "|" .. os.time()
end

function EncryptionManager:Decrypt(data)
    if not Services.HttpService then return {} end
    
    local parts = string.split(data, "|")
    if #parts < 2 then return {} end
    
    local encrypted = parts[1]
    local checksum = parts[2]
    
    if self:GenerateChecksum(encrypted) ~= checksum then
        warn("Checksum verification failed")
        return {}
    end
    
    local base64Decrypted = self:Base64Decode(encrypted)
    local xorDecrypted = self:XOREncrypt(base64Decrypted, self.Key .. self.Salt)
    
    local success, result = pcall(function()
        return Services.HttpService:JSONDecode(xorDecrypted)
    end)
    
    return success and result or {}
end

function EncryptionManager:GenerateChecksum(data)
    local sum = 0
    for i = 1, #data do
        sum = sum + string.byte(data, i)
    end
    return tostring(sum % 65536)
end

-- ============================================
-- CONFIGURATION MANAGER
-- ============================================

local Config = {}
local ConfigKeys = {}

local ConfigManager = {
    Path = "PongbHub/fisch_v3",
    Defaults = {
        ["Farm Fish"] = false,
        ["Sell Fish"] = false,
        ["Auto Sell Value"] = 10000,
        ["Smart Sell"] = false,
        ["Set Walk Speed"] = 16,
        ["Set Jump Power"] = 50,
        ["Toggle Walk Speed"] = false,
        ["Toggle Jump Power"] = false,
        ["Toggle Noclip"] = false,
        ["Infinite Oxygen"] = false,
        ["Reel Speed"] = 5,
        ["Cast Delay"] = 1,
        ["Human Behavior"] = true,
        ["Smooth Teleport"] = true,
        ["Bypass Radar"] = false,
        ["TeleportToPosition"] = false,
        ["WebHook URL"] = "",
        ["Webhook Enabled"] = false,
        ["Stats Tracking"] = true
    }
}

function ConfigManager:Load()
    if not isfolder(self.Path) then
        makefolder(self.Path)
    end
    
    local configPath = self.Path .. "/" .. LocalPlayer.UserId .. "_config.dat"
    
    if isfile(configPath) then
        local encryptedData = readfile(configPath)
        local success, result = pcall(function()
            return EncryptionManager:Decrypt(encryptedData)
        end)
        
        if success and type(result) == "table" then
            for k, v in pairs(result) do
                Config[k] = v
                ConfigKeys[k] = true
            end
        end
    end
    
    for k, v in pairs(self.Defaults) do
        if Config[k] == nil then
            Config[k] = v
            ConfigKeys[k] = true
        end
    end
end

function ConfigManager:Save()
    if not isfolder(self.Path) then
        makefolder(self.Path)
    end
    
    local configPath = self.Path .. "/" .. LocalPlayer.UserId .. "_config.dat"
    local dataToSave = {}
    
    for k in pairs(ConfigKeys) do
        if Config[k] ~= nil then
            dataToSave[k] = Config[k]
        end
    end
    
    local success, encryptedData = pcall(function()
        return EncryptionManager:Encrypt(dataToSave)
    end)
    
    if success then
        writefile(configPath, encryptedData)
        return true
    else
        warn("Failed to save config")
        return false
    end
end

ConfigManager:Load()

-- ============================================
-- STATISTICS TRACKING
-- ============================================

local Statistics = {
    Session = {
        FishCaught = 0,
        MoneyEarned = 0,
        StartTime = os.time(),
        RareFish = {},
        FailedAttempts = 0,
        SuccessfulCasts = 0,
        LastFish = nil
    }
}

function Statistics:Update(event, data)
    if event == "fish_caught" then
        self.Session.FishCaught = self.Session.FishCaught + 1
        self.Session.SuccessfulCasts = self.Session.SuccessfulCasts + 1
        self.Session.LastFish = data
    elseif event == "money_earned" then
        self.Session.MoneyEarned = self.Session.MoneyEarned + (data or 0)
    elseif event == "failed_attempt" then
        self.Session.FailedAttempts = self.Session.FailedAttempts + 1
    elseif event == "rare_fish" then
        table.insert(self.Session.RareFish, {
            name = data.name,
            time = os.time(),
            value = data.value
        })
    end
end

function Statistics:GetReport()
    local duration = os.time() - self.Session.StartTime
    local fishPerHour = duration > 0 and (self.Session.FishCaught / duration) * 3600 or 0
    local moneyPerHour = duration > 0 and (self.Session.MoneyEarned / duration) * 3600 or 0
    local totalAttempts = self.Session.SuccessfulCasts + self.Session.FailedAttempts
    local successRate = totalAttempts > 0 and (self.Session.SuccessfulCasts / totalAttempts) * 100 or 0
    
    return {
        duration = duration,
        totalFish = self.Session.FishCaught,
        totalMoney = self.Session.MoneyEarned,
        fishPerHour = fishPerHour,
        moneyPerHour = moneyPerHour,
        rareFish = #self.Session.RareFish,
        successRate = successRate,
        lastFish = self.Session.LastFish
    }
end

function Statistics:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function Statistics:Reset()
    self.Session = {
        FishCaught = 0,
        MoneyEarned = 0,
        StartTime = os.time(),
        RareFish = {},
        FailedAttempts = 0,
        SuccessfulCasts = 0,
        LastFish = nil
    }
end

-- ============================================
-- ADVANCED FISHING MANAGER
-- ============================================

local FishingManager = {
    State = "IDLE",
    LastReelTime = 0,
    ReelCooldown = 0.1,
    BiteHistory = {},
    SuccessRate = 0,
    LastCastTime = 0,
    CurrentRod = nil,
    FailCount = 0,
    MaxFails = 5
}

function FishingManager:GetBestRod()
    local rodPriority = {
        "Mythical Rod", "Kings Rod", "Trident Rod",
        "Rod of the Depths", "Destiny Rod",
        "No-Life Rod", "Rapid Rod", "Steady Rod",
        "Lucky Rod", "FishingRod"
    }
    
    for _, rodName in ipairs(rodPriority) do
        if Backpack:FindFirstChild(rodName) or 
           (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rodName)) then
            return rodName
        end
    end
    
    local success, rodName = pcall(function()
        return Services.ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
    end)
    
    return success and rodName or "FishingRod"
end

function FishingManager:EquipRod(rodName, retries)
    retries = retries or 3
    
    for attempt = 1, retries do
        local character = LocalPlayer.Character
        if not character then return false end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        
        if character:FindFirstChild(rodName) then
            return true
        end
        
        local rodInBackpack = Backpack:FindFirstChild(rodName)
        if rodInBackpack then
            humanoid:EquipTool(rodInBackpack)
            task.wait(0.3)
            
            if character:FindFirstChild(rodName) then
                return true
            end
        end
        
        task.wait(0.5)
    end
    
    return false
end

function FishingManager:GetFishingState()
    local character = LocalPlayer.Character
    if not character then return "ERROR" end
    
    local rod = character:FindFirstChildOfClass("Tool")
    if not rod then return "NO_ROD" end
    
    local values = rod:FindFirstChild("values")
    if not values then return "ERROR" end
    
    local lureValue = values:FindFirstChild("lure")
    local biteValue = values:FindFirstChild("bite")
    
    if not (lureValue and biteValue) then return "ERROR" end
    
    if biteValue.Value then
        return "BITE"
    elseif rod:FindFirstChild("bobber") and lureValue.Value > 0 then
        return "WAITING"
    else
        return "READY"
    end
end

function FishingManager:CastLine(rod)
    if not rod then return false end
    
    local castDelay = Config["Cast Delay"] or 1
    local timeSinceLastCast = tick() - self.LastCastTime
    
    if timeSinceLastCast < castDelay then
        return false
    end
    
    local success = pcall(function()
        if rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
            rod.events.cast:FireServer(1000000000000000000000000)
        end
    end)
    
    if success then
        self.LastCastTime = tick()
        AntiDetection:RecordAction("cast")
        
        if Config["Human Behavior"] then
            task.delay(math.random(5, 10), function()
                AntiDetection:RandomBehavior()
            end)
        end
    end
    
    return success
end

function FishingManager:SmartReel()
    local currentTime = tick()
    if currentTime - self.LastReelTime < self.ReelCooldown then
        return false
    end
    
    self.LastReelTime = currentTime
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local rod = character:FindFirstChildOfClass("Tool")
    if not rod then return false end
    
    local biteValue = rod:FindFirstChild("values") and rod.values:FindFirstChild("bite")
    if not biteValue or not biteValue.Value then return false end
    
    local reelSpeed = Config["Reel Speed"] or 5
    local attempts = math.max(1, math.floor(reelSpeed / 2))
    
    for i = 1, attempts do
        pcall(function()
            Services.ReplicatedStorage.events.reelfinished:FireServer(1000000000000000000000000, true)
        end)
        
        if i < attempts then
            task.wait(0.05)
        end
    end
    
    AntiDetection:RecordAction("reel")
    Statistics:Update("fish_caught", {time = os.time()})
    
    self.FailCount = 0
    return true
end

function FishingManager:UpdateLureDisplay(rod)
    if not PlayerGui:FindFirstChild("hud") then return end
    
    local backpack = PlayerGui.hud.safezone.backpack
    local lureDisplay = backpack:FindFirstChild("LureDisplay")
    
    if not lureDisplay then
        lureDisplay = Instance.new("TextLabel")
        lureDisplay.Name = "LureDisplay"
        lureDisplay.Parent = backpack
        lureDisplay.Text = "Lure: 0%"
        lureDisplay.TextColor3 = Color3.fromRGB(255, 73, 73)
        lureDisplay.BackgroundTransparency = 1
        lureDisplay.Size = UDim2.new(0, 120, 0, 25)
        lureDisplay.Position = UDim2.new(0, 10, 0, 10)
        lureDisplay.Font = Enum.Font.GothamBold
        lureDisplay.TextSize = 14
        lureDisplay.TextXAlignment = Enum.TextXAlignment.Left
        
        MemoryManager:TrackObject(lureDisplay)
    end
    
    local values = rod:FindFirstChild("values")
    if values and values:FindFirstChild("lure") then
        local lurePercent = values.lure.Value
        lureDisplay.Text = string.format("Lure: %.1f%%", lurePercent)
        
        if lurePercent < 30 then
            lureDisplay.TextColor3 = Color3.fromRGB(255, 50, 50)
        elseif lurePercent < 70 then
            lureDisplay.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            lureDisplay.TextColor3 = Color3.fromRGB(50, 255, 50)
        end
    end
end

function FishingManager:AutoFarm()
    while Config["Farm Fish"] do
        local success, error = pcall(function()
            local character = LocalPlayer.Character
            if not character then 
                task.wait(1)
                return 
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then 
                task.wait(2)
                return 
            end
            
            local rodName = self:GetBestRod()
            
            if not self:EquipRod(rodName) then
                self.FailCount = self.FailCount + 1
                task.wait(1)
                return
            end
            
            local rod = character:FindFirstChild(rodName)
            if not rod then 
                task.wait(0.5)
                return 
            end
            
            local state = self:GetFishingState()
            self.State = state
            
            if state == "READY" then
                self:CastLine(rod)
                task.wait(AntiDetection:GetRandomDelay(Config["Cast Delay"] or 1))
                
            elseif state == "WAITING" then
                self:UpdateLureDisplay(rod)
                task.wait(0.1)
                
            elseif state == "BITE" then
                if self:SmartReel() then
                    task.wait(AntiDetection:GetRandomDelay(0.5))
                else
                    self.FailCount = self.FailCount + 1
                    Statistics:Update("failed_attempt")
                end
                
            elseif state == "ERROR" or state == "NO_ROD" then
                self.FailCount = self.FailCount + 1
                task.wait(1)
            end
            
            if self.FailCount >= self.MaxFails then
                Notify("Multiple failures detected, pausing...", 3, "Warning")
                task.wait(10)
                self.FailCount = 0
            end
        end)
        
        if not success then
            warn("Fishing error:", error)
            task.wait(2)
        end
        
        task.wait(0.05)
    end
    
    self.State = "IDLE"
end

function FishingManager:AutoSell()
    while Config["Sell Fish"] do
        task.wait(5)
        
        local shouldSell = false
        
        if Config["Smart Sell"] then
            local inventoryValue = self:GetInventoryValue()
            if inventoryValue >= (Config["Auto Sell Value"] or 10000) then
                shouldSell = true
            end
        else
            shouldSell = true
        end
        
        if shouldSell then
            local beforeMoney = self:GetCurrentMoney()
            
            pcall(function()
                Services.ReplicatedStorage.events.selleverything:InvokeServer()
            end)
            
            task.wait(1)
            
            local afterMoney = self:GetCurrentMoney()
            local earned = afterMoney - beforeMoney
            
            if earned > 0 then
                Statistics:Update("money_earned", earned)
                Notify(string.format("Sold fish for $%d", earned), 2)
            end
        end
    end
end

function FishingManager:GetInventoryValue()
    local totalValue = 0
    
    pcall(function()
        for _, item in pairs(PlayerGui.hud.safezone.backpack.hotbar:GetChildren()) do
            if item:FindFirstChild("tool") and item:FindFirstChild("weight") then
                -- Estimate value based on weight
                local weight = tonumber(item.weight.Text:match("%d+%.?%d*")) or 0
                totalValue = totalValue + (weight * 10)
            end
        end
        
        for _, item in pairs(PlayerGui.hud.safezone.backpack.inventory.scroll.safezone:GetChildren()) do
            if item:IsA("Frame") and item:FindFirstChild("weight") then
                local weight = tonumber(item.weight.Text:match("%d+%.?%d*")) or 0
                totalValue = totalValue + (weight * 10)
            end
        end
    end)
    
    return totalValue
end

function FishingManager:GetCurrentMoney()
    local money = 0
    pcall(function()
        local moneyText = PlayerGui.hud.safezone.coins.Text
        money = tonumber(moneyText:match("%d+")) or 0
    end)
    return money
end

function FishingManager:IsInventoryFull()
    local count = 0
    local maxSlots = 50
    
    pcall(function()
        for _, item in pairs(PlayerGui.hud.safezone.backpack.hotbar:GetChildren()) do
            if item:FindFirstChild("tool") then
                count = count + 1
            end
        end
        
        for _, item in pairs(PlayerGui.hud.safezone.backpack.inventory.scroll.safezone:GetChildren()) do
            if item:IsA("Frame") then
                count = count + 1
            end
        end
    end)
    
    return count >= maxSlots
end

-- ============================================
-- ERROR HANDLER & RECOVERY
-- ============================================

local ErrorHandler = {
    Errors = {},
    MaxErrors = 10,
    RecoveryAttempts = {}
}

function ErrorHandler:Log(errorType, message)
    table.insert(self.Errors, {
        type = errorType,
        message = message,
        time = os.time()
    })
    
    if #self.Errors > self.MaxErrors then
        table.remove(self.Errors, 1)
    end
    
    local recentSameErrors = 0
    for i = math.max(1, #self.Errors - 4), #self.Errors do
        if self.Errors[i].type == errorType then
            recentSameErrors = recentSameErrors + 1
        end
    end
    
    if recentSameErrors >= 3 then
        self:AttemptRecovery(errorType)
    end
end

function ErrorHandler:AttemptRecovery(errorType)
    if self.RecoveryAttempts[errorType] and 
       os.time() - self.RecoveryAttempts[errorType] < 60 then
        return
    end
    
    self.RecoveryAttempts[errorType] = os.time()
    
    Notify("Attempting auto-recovery...", 3, "System")
    
    if errorType == "FISHING_STUCK" then
        Config["Farm Fish"] = false
        task.wait(2)
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
        
        task.wait(1)
        Config["Farm Fish"] = true
        
    elseif errorType == "TELEPORT_FAILED" then
        if Config["SelectedPosition"] then
            for i = 1, 3 do
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = Config["SelectedPosition"]
                end)
                task.wait(1)
            end
        end
        
    elseif errorType == "INVENTORY_ERROR" then
        pcall(function()
            Services.ReplicatedStorage.events.selleverything:InvokeServer()
        end)
    end
    
    table.clear(self.Errors)
end

-- ============================================
-- WEBHOOK SYSTEM
-- ============================================

local WebhookManager = {
    LastSendTime = 0,
    SendCooldown = 60
}

function WebhookManager:Send(title, description, color)
    if not Config["Webhook Enabled"] or Config["WebHook URL"] == "" then
        return false
    end
    
    local currentTime = os.time()
    if currentTime - self.LastSendTime < self.SendCooldown then
        return false
    end
    
    self.LastSendTime = currentTime
    
    local success = pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = title or "Fisch Enhanced",
                ["description"] = description or "",
                ["color"] = color or 8646911,
                ["fields"] = {
                    {
                        ["name"] = "Player",
                        ["value"] = LocalPlayer.Name,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Time",
                        ["value"] = os.date("%H:%M:%S"),
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = "Pongb Hub v3.0",
                    ["icon_url"] = "https://cdn.discordapp.com/attachments/1306627401664692265/1306646029080465469/--_.._.png"
                }
            }}
        }
        
        if request then
            request({
                Url = Config["WebHook URL"],
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Services.HttpService:JSONEncode(data)
            })
        end
    end)
    
    return success
end

function WebhookManager:SendStats()
    local report = Statistics:GetReport()
    local description = string.format([[
**Session Duration:** %s
**Fish Caught:** %d (%.1f/hour)
**Money Earned:** $%d ($%.1f/hour)
**Success Rate:** %.1f%%
**Rare Fish:** %d
    ]],
        Statistics:FormatTime(report.duration),
        report.totalFish,
        report.fishPerHour,
        report.totalMoney,
        report.moneyPerHour,
        report.successRate,
        report.rareFish
    )
    
    return self:Send("Session Statistics", description, 3447003)
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================

function Notify(description, duration, title)
    pcall(function()
        Fluent:Notify({
            Title = title or "Pongb Hub",
            Content = description,
            Duration = duration or 3
        })
    end)
end

-- ============================================
-- UI CREATION
-- ============================================

local Window = Fluent:CreateWindow({
    Title = "Pongb Hub v3.0 Enhanced",
    SubTitle = "🎣 Advanced Anti-Detection",
    TabWidth = 120,
    Size = UDim2.fromOffset(580, 380),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Mobile UI Support
if not (Services.UserInputService and Services.UserInputService:GetPlatform() == Enum.Platform.Windows) then
    if Services.CoreGui and not Services.CoreGui:FindFirstChild("PongbHubMobileUI") then
        local MobileUI = Instance.new("ScreenGui")
        MobileUI.Name = "PongbHubMobileUI"
        MobileUI.Parent = Services.CoreGui
        MobileUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local ToggleButton = Instance.new("ImageButton")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = MobileUI
        ToggleButton.Size = UDim2.new(0, 64, 0, 64)
        ToggleButton.Position = UDim2.new(0, 10, 0.5, -32)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleButton.Image = "rbxassetid://95601269496067"
        ToggleButton.Draggable = true
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = ToggleButton

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = Color3.fromRGB(100, 100, 255)
        UIStroke.Thickness = 2
        UIStroke.Parent = ToggleButton

        local isUIVisible = true
        
        ToggleButton.MouseButton1Click:Connect(function()
            isUIVisible = not isUIVisible
            Window:SetEnabled(isUIVisible)
            
            ToggleButton:TweenSize(
                UDim2.new(0, 60, 0, 60),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Quad,
                0.1,
                true,
                function()
                    ToggleButton:TweenSize(
                        UDim2.new(0, 64, 0, 64),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Quad,
                        0.1
                    )
                end
            )
        end)

        MemoryManager:TrackObject(MobileUI)
    end
end

-- Create Tabs
local Tabs = {
    Home = Window:AddTab({Title = "🏠 Home", Icon = "home"}),
    Farming = Window:AddTab({Title = "🎣 Farming", Icon = "fish"}),
    Player = Window:AddTab({Title = "👤 Player", Icon = "user"}),
    Teleport = Window:AddTab({Title = "📍 Teleport", Icon = "map-pin"}),
    Settings = Window:AddTab({Title = "⚙️ Settings", Icon = "settings"})
}

-- UI Helper Functions
local function CreateToggle(section, name, description, configKey, callback)
    configKey = configKey or name
    ConfigKeys[configKey] = true
    
    local toggle = section:AddToggle(name, {
        Title = name,
        Description = description,
        Default = Config[configKey] or false
    })
    
    toggle:OnChanged(function(value)
        AntiDetection:HumanLikeAction("toggle")
        Config[configKey] = value
        ConfigManager:Save()
        
        if callback then
            callback(value)
        end
    end)
    
    return toggle
end

local function CreateSlider(section, name, min, max, rounding, configKey, callback)
    configKey = configKey or name
    ConfigKeys[configKey] = true
    
    local slider = section:AddSlider(name, {
        Title = name,
        Description = string.format("Range: %d - %d", min, max),
        Min = min,
        Max = max,
        Default = Config[configKey] or min,
        Rounding = rounding or 0
    })
    
    slider:OnChanged(function(value)
        Config[configKey] = value
        ConfigManager:Save()
        
        if callback then
            callback(value)
        end
    end)
    
    return slider
end

-- ============================================
-- HOME TAB
-- ============================================

do
    local InfoSection = Tabs.Home:AddSection("Information")
    
    local StatusParagraph = InfoSection:AddParagraph({
        Title = "Status: Ready",
        Content = "System initialized successfully"
    })
    
    local StatsParagraph = InfoSection:AddParagraph({
        Title = "Statistics",
        Content = "Loading..."
    })
    
    MemoryManager:AddThread(task.spawn(function()
        while task.wait(2) do
            local report = Statistics:GetReport()
            
            StatusParagraph:SetTitle(string.format("Status: %s", FishingManager.State))
            StatusParagraph:SetDesc(string.format(
                "Running Time: %s | Success Rate: %.1f%%",
                Statistics:FormatTime(report.duration),
                report.successRate
            ))
            
            StatsParagraph:SetTitle("Session Statistics")
            StatsParagraph:SetDesc(string.format(
                "🐟 Fish: %d (%.1f/h)\n💰 Money: $%d ($%.1f/h)\n⭐ Rare: %d",
                report.totalFish,
                report.fishPerHour,
                report.totalMoney,
                report.moneyPerHour,
                report.rareFish
            ))
        end
    end))
    
    local QuickActions = Tabs.Home:AddSection("Quick Actions")
    
    QuickActions:AddButton({
        Title = "🛑 Emergency Stop",
        Description = "Stop all farming immediately",
        Callback = function()
            Config["Farm Fish"] = false
            Config["Sell Fish"] = false
            Config["TeleportToPosition"] = false
            FishingManager.State = "STOPPED"
            Notify("All activities stopped!", 2, "Emergency")
        end
    })
    
    QuickActions:AddButton({
        Title = "📊 View Detailed Stats",
        Description = "Show complete session statistics",
        Callback = function()
            local report = Statistics:GetReport()
            local message = string.format(
                "⏱️ Duration: %s\n🐟 Fish: %d (%.1f/h)\n💰 Money: $%d ($%.1f/h)\n⭐ Rare: %d\n✅ Success: %.1f%%",
                Statistics:FormatTime(report.duration),
                report.totalFish,
                report.fishPerHour,
                report.totalMoney,
                report.moneyPerHour,
                report.rareFish,
                report.successRate
            )
            Notify(message, 8, "Statistics")
        end
    })
    
    QuickActions:AddButton({
        Title = "🔄 Reset Statistics",
        Description = "Clear session statistics",
        Callback = function()
            Statistics:Reset()
            Notify("Statistics reset", 2)
        end
    })
    
    QuickActions:AddButton({
        Title = "💾 Save Config",
        Description = "Manually save configuration",
        Callback = function()
            if ConfigManager:Save() then
                Notify("Configuration saved successfully", 2)
            else
                Notify("Failed to save configuration", 2, "Error")
            end
        end
    })
end

-- ============================================
-- FARMING TAB
-- ============================================

do
    local MainFarming = Tabs.Farming:AddSection("Main Farming")
    
    CreateToggle(MainFarming, "Auto Farm Fish", "Automatically fish and reel", "Farm Fish", function(enabled)
        if enabled then
            MemoryManager:AddThread(task.spawn(FishingManager.AutoFarm, FishingManager))
            Notify("Auto farming started", 2)
        else
            Notify("Auto farming stopped", 2)
        end
    end)
    
    CreateToggle(MainFarming, "Auto Sell Fish", "Automatically sell fish", "Sell Fish", function(enabled)
        if enabled then
            MemoryManager:AddThread(task.spawn(FishingManager.AutoSell, FishingManager))
            Notify("Auto selling started", 2)
        else
            Notify("Auto selling stopped", 2)
        end
    end)
    
    local AdvancedFarming = Tabs.Farming:AddSection("Advanced Settings")
    
    CreateSlider(AdvancedFarming, "Reel Speed", 1, 10, 0, "Reel Speed", function(value)
        FishingManager.ReelCooldown = 0.2 - (value * 0.015)
        Notify(string.format("Reel speed set to %d", value), 1)
    end)
    
    CreateSlider(AdvancedFarming, "Cast Delay", 0.5, 5, 1, "Cast Delay")
    
    CreateToggle(AdvancedFarming, "Human-Like Behavior", "Simulate human actions", "Human Behavior")
    
    local SmartSelling = Tabs.Farming:AddSection("Smart Selling")
    
    CreateToggle(SmartSelling, "Smart Sell", "Sell based on inventory value", "Smart Sell")
    CreateSlider(SmartSelling, "Sell Value Threshold", 5000, 100000, 0, "Auto Sell Value")
    
    SmartSelling:AddButton({
        Title = "Sell All Now",
        Description = "Manually sell all fish",
        Callback = function()
            pcall(function()
                Services.ReplicatedStorage.events.selleverything:InvokeServer()
            end)
            Notify("Sold all fish", 2)
        end
    })
    
    local PositionManagement = Tabs.Farming:AddSection("Position Management")
    local PositionDisplay = PositionManagement:AddParagraph({
        Title = "Position: Not set",
        Content = "Click 'Set Position' to save current location"
    })
    
    PositionManagement:AddButton({
        Title = "Set Current Position",
        Description = "Save your current position",
        Callback = function()
            AntiDetection:HumanLikeAction("set_position")
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                Config["SelectedPosition"] = character.HumanoidRootPart.CFrame
                ConfigKeys["SelectedPosition"] = true
                ConfigManager:Save()
                
                local pos = character.HumanoidRootPart.Position
                PositionDisplay:SetTitle(string.format(
                    "Position: %.0f, %.0f, %.0f",
                    pos.X, pos.Y, pos.Z
                ))
                PositionDisplay:SetDesc("Position saved successfully")
                Notify("Position saved", 2)
            end
        end
    })
    
    CreateToggle(PositionManagement, "Teleport to Position", "Return to saved position", "TeleportToPosition", function(enabled)
        if enabled and Config["SelectedPosition"] then
            MemoryManager:AddThread(task.spawn(function()
                while Config["TeleportToPosition"] do
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        if Config["Smooth Teleport"] then
                            AntiDetection:SmoothTeleport(Config["SelectedPosition"])
                        else
                            character.HumanoidRootPart.CFrame = Config["SelectedPosition"]
                        end
                    end
                    task.wait(0.5)
                end
            end))
        end
    end)
    
    CreateToggle(PositionManagement, "Smooth Teleport", "Use smooth movement", "Smooth Teleport")
end

-- ============================================
-- PLAYER TAB
-- ============================================

do
    local Movement = Tabs.Player:AddSection("Movement")
    
    CreateSlider(Movement, "Walk Speed", 16, 300, 0, "Set Walk Speed")
    CreateSlider(Movement, "Jump Power", 50, 300, 0, "Set Jump Power")
    
    CreateToggle(Movement, "Enable Walk Speed", "Apply walk speed", "Toggle Walk Speed", function(enabled)
        MemoryManager:AddThread(task.spawn(function()
            while Config["Toggle Walk Speed"] do
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = Config["Set Walk Speed"]
                    end
                end
                task.wait(0.1)
            end
        end))
    end)
    
    CreateToggle(Movement, "Enable Jump Power", "Apply jump power", "Toggle Jump Power", function(enabled)
        MemoryManager:AddThread(task.spawn(function()
            while Config["Toggle Jump Power"] do
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = Config["Set Jump Power"]
                    end
                end
                task.wait(0.1)
            end
        end))
    end)
    
    local Utility = Tabs.Player:AddSection("Utility")
    
    CreateToggle(Utility, "Noclip", "Walk through walls", "Toggle Noclip", function(enabled)
        MemoryManager:AddThread(task.spawn(function()
            while Config["Toggle Noclip"] do
                local character = LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                task.wait(0.1)
            end
        end))
    end)
    
    CreateToggle(Utility, "Infinite Oxygen", "Never run out of oxygen", "Infinite Oxygen", function(enabled)
        local character = LocalPlayer.Character
        if character then
            local oxygen = character:FindFirstChild("client") and character.client:FindFirstChild("oxygen")
            if oxygen then
                oxygen.Disabled = enabled
            end
        end
    end)
    
    CreateToggle(Utility, "Walk on Water", "Enable water walking", "Walk On Water", function(enabled)
        for _, zone in pairs(workspace.zones.fishing:GetChildren()) do
            if zone.Name == "Ocean" then
                zone.CanCollide = enabled
            end
        end
    end)
    
    local Visual = Tabs.Player:AddSection("Visual")
    
    CreateToggle(Visual, "Remove Fog", "Clear visibility", "Remove Fog", function(enabled)
        if enabled then
            if Services.Lighting:FindFirstChild("Sky") then
                Services.Lighting.Sky.Parent = Services.Lighting.Bloom or Services.Lighting
            end
        else
            if Services.Lighting.Bloom and Services.Lighting.Bloom:FindFirstChild("Sky") then
                Services.Lighting.Bloom.Sky.Parent = Services.Lighting
            end
        end
    end)
    
    CreateToggle(Visual, "Always Day", "Lock time to daytime", "Day Only", function(enabled)
        if enabled then
            MemoryManager:AddThread(task.spawn(function()
                while Config["Day Only"] do
                    Services.Lighting.TimeOfDay = "12:00:00"
                    task.wait(1)
                end
            end))
        end
    end)
    
    CreateToggle(Visual, "Bypass Radar", "Hide from radar", "Bypass Radar", function(enabled)
        for _, obj in pairs(Services.CollectionService:GetTagged("radarTag")) do
            if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                obj.Enabled = not enabled
            end
        end
    end)
end

-- ============================================
-- TELEPORT TAB
-- ============================================

do
    local MainLocations = Tabs.Teleport:AddSection("Main Locations")
    
    local locations = {
        {name = "Roslit Bay", pos = CFrame.new(-1501.68, 133, 416.21)},
        {name = "Moosewood", pos = CFrame.new(433.80, 147.07, 261.80)},
        {name = "Mushgrove Marsh", pos = CFrame.new(2442.81, 130.90, -686.16)},
        {name = "Sunstone Island", pos = CFrame.new(-913.63, 137.29, -1129.90)},
        {name = "Snowcap Island", pos = CFrame.new(2589.53, 134.92, 2333.10)},
        {name = "Terrapin Island", pos = CFrame.new(152.37, 154.91, 2000.92)},
        {name = "Aurora Island", pos = CFrame.new(-118.7, -515.3, 1142.3)},
        {name = "Best Fishing Spot", pos = CFrame.new(1447.85, 133.50, -7649.65)}
    }
    
    for _, location in ipairs(locations) do
        MainLocations:AddButton({
            Title = location.name,
            Callback = function()
                AntiDetection:HumanLikeAction("teleport")
                if Config["Smooth Teleport"] then
                    AntiDetection:SmoothTeleport(location.pos)
                else
                    LocalPlayer.Character.HumanoidRootPart.CFrame = location.pos
                end
                Notify("Teleported to " .. location.name, 2)
            end
        })
    end
    
    local NPCLocations = Tabs.Teleport:AddSection("NPCs")
    
    local npcs = {
        {name = "Marc Merchant", pos = CFrame.new(466.28, 150.63, 229.61)},
        {name = "Pierre (Tackle Shop)", pos = CFrame.new(391.55, 135.14, 201.79)},
        {name = "Shipwright", pos = CFrame.new(363.44, 133.29, 257.58)},
        {name = "Appraiser", pos = CFrame.new(447.59, 150.55, 207.45)},
        {name = "Inn Keeper", pos = CFrame.new(491.73, 150.70, 231.80)},
        {name = "Phineas (Witch)", pos = CFrame.new(471.82, 150.69, 274.18)}
    }
    
    for _, npc in ipairs(npcs) do
        NPCLocations:AddButton({
            Title = npc.name,
            Callback = function()
                AntiDetection:HumanLikeAction("teleport")
                if Config["Smooth Teleport"] then
                    AntiDetection:SmoothTeleport(npc.pos)
                else
                    LocalPlayer.Character.HumanoidRootPart.CFrame = npc.pos
                end
                Notify("Teleported to " .. npc.name, 2)
            end
        })
    end
end

-- ============================================
-- SETTINGS TAB
-- ============================================

do
    local AntiDetectSettings = Tabs.Settings:AddSection("Anti-Detection")
    
    local SecurityInfo = AntiDetectSettings:AddParagraph({
        Title = "Security Status: Active",
        Content = string.format("HWID: %s\nSession Variance: %.2f", 
            AntiDetection.FakeHWID:sub(1, 12) .. "...",
            AntiDetection.SessionVariance
        )
    })
    
    AntiDetectSettings:AddButton({
        Title = "Regenerate Security",
        Description = "Generate new fake HWID",
        Callback = function()
            AntiDetection.FakeHWID = string.format("%06d-%06d-%06d", 
                math.random(100000, 999999),
                math.random(100000, 999999),
                math.random(100000, 999999)
            )
            AntiDetection.SessionVariance = math.random(80, 120) / 100
            getgenv().FakeHWID = AntiDetection.FakeHWID
            
            SecurityInfo:SetDesc(string.format("HWID: %s\nSession Variance: %.2f", 
                AntiDetection.FakeHWID:sub(1, 12) .. "...",
                AntiDetection.SessionVariance
            ))
            Notify("Security parameters regenerated", 2)
        end
    })
    
    local WebhookSettings = Tabs.Settings:AddSection("Webhook")
    
    local WebhookInput = WebhookSettings:AddInput("WebhookURL", {
        Title = "Webhook URL",
        Placeholder = "discord.com/api/webhooks/...",
        Default = Config["WebHook URL"],
        Finished = true
    })
    
    WebhookInput:OnChanged(function(value)
        Config["WebHook URL"] = value
        ConfigKeys["WebHook URL"] = true
        ConfigManager:Save()
    end)
    
    CreateToggle(WebhookSettings, "Enable Webhook", "Send notifications to Discord", "Webhook Enabled")
    
    WebhookSettings:AddButton({
        Title = "Test Webhook",
        Description = "Send test notification",
        Callback = function()
            if WebhookManager:Send("Test Notification", "This is a test message from Pongb Hub v3.0", 65280) then
                Notify("Webhook test sent", 2)
            else
                Notify("Webhook test failed", 2, "Error")
            end
        end
    })
    
    WebhookSettings:AddButton({
        Title = "Send Statistics",
        Description = "Send current stats to webhook",
        Callback = function()
            if WebhookManager:SendStats() then
                Notify("Statistics sent to webhook", 2)
            else
                Notify("Failed to send statistics", 2, "Error")
            end
        end
    })
    
    local Performance = Tabs.Settings:AddSection("Performance")
    
    Performance:AddButton({
        Title = "Cleanup Memory",
        Description = "Free up memory and resources",
        Callback = function()
            MemoryManager:Cleanup()
            collectgarbage("collect")
            Notify("Memory cleaned successfully", 2)
        end
    })
    
    Performance:AddButton({
        Title = "Optimize Graphics",
        Description = "Reduce graphics for better FPS",
        Callback = function()
            pcall(function()
                if setfpscap then setfpscap(60) end
                if Settings then
                    Settings.RenderQuality = 0.5
                    Settings.Shadows = false
                end
            end)
            Notify("Graphics optimized", 2)
        end
    })
    
    local Misc = Tabs.Settings:AddSection("Miscellaneous")
    
    Misc:AddButton({
        Title = "Rejoin Server",
        Description = "Rejoin current server",
        Callback = function()
            Services.TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                LocalPlayer
            )
        end
    })
    
    Misc:AddButton({
        Title = "Join Discord",
        Description = "Copy Discord link",
        Callback = function()
            if setclipboard then
                setclipboard("https://discord.gg/Pku7kerP")
                Notify("Discord link copied to clipboard", 3)
            else
                Notify("Clipboard not supported", 2, "Error")
            end
        end
    })
    
    Misc:AddButton({
        Title = "Unload Script",
        Description = "Completely unload the hub",
        Callback = function()
            Notify("Unloading script...", 2)
            task.wait(1)
            MemoryManager:Cleanup()
            
            if Services.CoreGui:FindFirstChild("PongbHubMobileUI") then
                Services.CoreGui.PongbHubMobileUI:Destroy()
            end
            
            Window:Destroy()
            Notify("Script unloaded", 2)
        end
    })
end

-- ============================================
-- INITIALIZE SYSTEMS
-- ============================================

AntiDetection:Initialize()

-- Anti-AFK System
if Services.VirtualUser then
    MemoryManager:AddConnection(LocalPlayer.Idled:Connect(function()
        Services.VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        Services.VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end))
end

-- Performance Optimization
pcall(function()
    if setfpscap then
        setfpscap(60)
    end
    
    if Settings then
        Settings.RenderQuality = 0.75
    end
end)

-- Auto-save configuration every 5 minutes
MemoryManager:AddThread(task.spawn(function()
    while task.wait(300) do
        ConfigManager:Save()
    end
end))

-- Webhook periodic stats (if enabled)
MemoryManager:AddThread(task.spawn(function()
    while task.wait(600) do -- Every 10 minutes
        if Config["Webhook Enabled"] and Config["Stats Tracking"] then
            WebhookManager:SendStats()
        end
    end
end))

-- Character respawn handler
MemoryManager:AddConnection(LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    
    -- Reapply player modifications
    if Config["Infinite Oxygen"] then
        task.wait(2)
        local oxygen = character:FindFirstChild("client") and character.client:FindFirstChild("oxygen")
        if oxygen then
            oxygen.Disabled = true
        end
    end
    
    -- Resume fishing if it was active
    if Config["Farm Fish"] and FishingManager.State ~= "IDLE" then
        task.wait(2)
        Notify("Resuming auto-farming after respawn", 2)
    end
end))

-- Cleanup on game close
MemoryManager:AddConnection(game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "PongbHubMobileUI" or child.Name:find("Fluent") then
        MemoryManager:Cleanup()
    end
end))

-- Cleanup when player leaves
MemoryManager:AddConnection(LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer.Parent then
        MemoryManager:Cleanup()
    end
end))

-- ============================================
-- FINALIZE UI
-- ============================================

InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("PongbHub_v3")
SaveManager:BuildConfigSection(Tabs.Settings)

-- Initialize window
Window:SelectTab(1)

-- Success notification
Notify("Pongb Hub v3.0 Enhanced Loaded!", 5, "Success")
Notify("All systems operational. Anti-detection active.", 3)

-- Log initialization
if PongbHub._DEBUG then
    warn("=================================")
    warn("Pongb Hub v3.0 Enhanced - Loaded")
    warn("Version: " .. PongbHub._VERSION)
    warn("Build: " .. PongbHub._BUILD)
    warn("Security: Active")
    warn("Anti-Detection: Enabled")
    warn("Player: " .. LocalPlayer.Name)
    warn("User ID: " .. LocalPlayer.UserId)
    warn("Fake HWID: " .. AntiDetection.FakeHWID)
    warn("=================================")
end

-- ============================================
-- ADVANCED FEATURES & EXTRAS
-- ============================================

-- Auto-equip best rod on spawn
MemoryManager:AddConnection(LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(2)
    if Config["Farm Fish"] then
        local bestRod = FishingManager:GetBestRod()
        FishingManager:EquipRod(bestRod)
    end
end))

-- Detect and notify rare events
if workspace:FindFirstChild("active") then
    MemoryManager:AddConnection(workspace.active.ChildAdded:Connect(function(child)
        if child.Name == "Whirlpool" or child.Name == "Meteor" then
            Notify("Rare event detected: " .. child.Name, 5, "Event Alert")
            
            if Config["Webhook Enabled"] then
                local pos = child:GetPivot().Position
                WebhookManager:Send(
                    "🌟 Rare Event Detected!",
                    string.format("**%s** spawned at position\nX: %.0f, Y: %.0f, Z: %.0f",
                        child.Name, pos.X, pos.Y, pos.Z
                    ),
                    16776960
                )
            end
        end
    end))
end

-- Advanced error tracking
local originalError = error
getgenv().error = function(msg, level)
    ErrorHandler:Log("RUNTIME_ERROR", tostring(msg))
    return originalError(msg, level)
end

-- Performance monitoring
local LastFPS = 60
MemoryManager:AddThread(task.spawn(function()
    while task.wait(5) do
        local currentFPS = workspace:GetRealPhysicsFPS()
        
        if currentFPS < 30 and LastFPS >= 30 then
            Notify("Low FPS detected. Consider optimizing graphics.", 3, "Performance")
            
            -- Auto-optimize if FPS is too low
            pcall(function()
                if Settings then
                    Settings.RenderQuality = 0.5
                end
            end)
        end
        
        LastFPS = currentFPS
    end
end))

-- Network latency monitor
MemoryManager:AddThread(task.spawn(function()
    while task.wait(10) do
        local ping = LocalPlayer:GetNetworkPing() * 1000
        
        if ping > 500 then
            Notify("High ping detected: " .. math.floor(ping) .. "ms", 2, "Network")
        end
    end
end))

-- Auto-recovery from common issues
MemoryManager:AddThread(task.spawn(function()
    while task.wait(30) do
        -- Check if character is stuck
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local velocity = humanoid.RootPart and humanoid.RootPart.AssemblyLinearVelocity
                
                if velocity and velocity.Magnitude < 0.1 and humanoid.MoveDirection.Magnitude > 0 then
                    -- Character might be stuck
                    ErrorHandler:Log("CHARACTER_STUCK", "Player appears to be stuck")
                end
            end
        end
        
        -- Check if farming is stalled
        if Config["Farm Fish"] and FishingManager.State == "WAITING" then
            local timeSinceLastFish = os.time() - (Statistics.Session.LastFish and Statistics.Session.LastFish.time or os.time())
            
            if timeSinceLastFish > 120 then -- 2 minutes without catching
                ErrorHandler:Log("FISHING_STUCK", "No fish caught in 2 minutes")
            end
        end
    end
end))

-- Smart inventory management
local function ManageInventory()
    if FishingManager:IsInventoryFull() and Config["Farm Fish"] then
        Notify("Inventory full, auto-selling...", 2)
        
        pcall(function()
            Services.ReplicatedStorage.events.selleverything:InvokeServer()
        end)
        
        task.wait(2)
    end
end

MemoryManager:AddThread(task.spawn(function()
    while task.wait(15) do
        if Config["Farm Fish"] and Config["Smart Sell"] then
            ManageInventory()
        end
    end
end))

-- Achievement/milestone notifications
local Milestones = {
    {fish = 100, notified = false},
    {fish = 500, notified = false},
    {fish = 1000, notified = false},
    {fish = 5000, notified = false}
}

MemoryManager:AddThread(task.spawn(function()
    while task.wait(10) do
        local totalFish = Statistics.Session.FishCaught
        
        for _, milestone in ipairs(Milestones) do
            if totalFish >= milestone.fish and not milestone.notified then
                milestone.notified = true
                Notify(
                    string.format("🎉 Milestone: %d fish caught!", milestone.fish),
                    5,
                    "Achievement"
                )
                
                if Config["Webhook Enabled"] then
                    WebhookManager:Send(
                        "🎉 Milestone Achieved!",
                        string.format("**%d fish** caught this session!", milestone.fish),
                        65280
                    )
                end
            end
        end
    end
end))

-- Backup save system
MemoryManager:AddThread(task.spawn(function()
    while task.wait(600) do -- Every 10 minutes
        local backupPath = ConfigManager.Path .. "/" .. LocalPlayer.UserId .. "_backup.dat"
        
        pcall(function()
            local currentConfig = readfile(ConfigManager.Path .. "/" .. LocalPlayer.UserId .. "_config.dat")
            writefile(backupPath, currentConfig)
        end)
    end
end))

-- Session summary on exit
local function GenerateSessionSummary()
    local report = Statistics:GetReport()
    
    return string.format([[
╔════════════════════════════════════╗
║     SESSION SUMMARY - Pongb Hub    ║
╠════════════════════════════════════╣
║ Duration: %s
║ Fish Caught: %d (%.1f/hour)
║ Money Earned: $%d ($%.1f/hour)
║ Rare Fish: %d
║ Success Rate: %.1f%%
║ Status: Completed
╚════════════════════════════════════╝
    ]],
        Statistics:FormatTime(report.duration),
        report.totalFish,
        report.fishPerHour,
        report.totalMoney,
        report.moneyPerHour,
        report.rareFish,
        report.successRate
    )
end

-- Enhanced webhook on session end
game:BindToClose(function()
    if Config["Webhook Enabled"] and Statistics.Session.FishCaught > 0 then
        pcall(function()
            WebhookManager:Send(
                "📊 Session Ended",
                GenerateSessionSummary(),
                16711680
            )
        end)
    end
    
    ConfigManager:Save()
    MemoryManager:Cleanup()
end)

-- ============================================
-- DEVELOPER UTILITIES (DEBUG MODE)
-- ============================================

if PongbHub._DEBUG then
    local DevSection = Tabs.Settings:AddSection("🔧 Developer Tools")
    
    DevSection:AddButton({
        Title = "Print Config",
        Description = "Print current configuration",
        Callback = function()
            print("=== Current Configuration ===")
            for k, v in pairs(Config) do
                print(string.format("%s: %s", k, tostring(v)))
            end
            print("============================")
            Notify("Config printed to console", 2)
        end
    })
    
    DevSection:AddButton({
        Title = "Print Statistics",
        Description = "Print detailed statistics",
        Callback = function()
            local report = Statistics:GetReport()
            print("=== Statistics Report ===")
            for k, v in pairs(report) do
                print(string.format("%s: %s", k, tostring(v)))
            end
            print("=========================")
            Notify("Stats printed to console", 2)
        end
    })
    
    DevSection:AddButton({
        Title = "Test Error Handler",
        Description = "Trigger error recovery test",
        Callback = function()
            ErrorHandler:Log("TEST_ERROR", "This is a test error")
            Notify("Test error logged", 2)
        end
    })
    
    DevSection:AddButton({
        Title = "Force Garbage Collection",
        Description = "Manually trigger GC",
        Callback = function()
            local before = collectgarbage("count")
            collectgarbage("collect")
            local after = collectgarbage("count")
            Notify(string.format("GC: %.2f KB freed", before - after), 3)
        end
    })
end

-- ============================================
-- SPECIAL FEATURES
-- ============================================

-- Auto-update checker (placeholder - implement with your update server)
MemoryManager:AddThread(task.spawn(function()
    task.wait(5)
    
    -- This would normally check against your version server
    local latestVersion = "3.0"
    
    if PongbHub._VERSION ~= latestVersion then
        Notify(
            "New version available: v" .. latestVersion,
            10,
            "Update Available"
        )
    end
end))

-- Easter egg / achievement system
local EasterEggs = {
    checked = false,
    unlocked = {}
}

function EasterEggs:Check()
    if not self.checked then
        self.checked = true
        
        -- Check for special dates
        local date = os.date("*t")
        if date.month == 4 and date.day == 1 then
            Notify("🎣 Happy April Fools! Fish wisely!", 5, "Special Event")
            table.insert(self.unlocked, "APRIL_FOOLS")
        end
        
        -- Check for play time achievement
        if Statistics.Session.FishCaught >= 1000 then
            Notify("🏆 Master Angler achievement unlocked!", 5, "Achievement")
            table.insert(self.unlocked, "MASTER_ANGLER")
        end
    end
end

MemoryManager:AddThread(task.spawn(function()
    while task.wait(60) do
        EasterEggs:Check()
    end
end))

-- ============================================
-- FINAL MESSAGE
-- ============================================

task.spawn(function()
    task.wait(2)
    
    local tips = {
        "💡 Tip: Enable 'Human Behavior' for better anti-detection",
        "💡 Tip: Use 'Smart Sell' to optimize inventory management",
        "💡 Tip: Save your favorite fishing spot with 'Set Position'",
        "💡 Tip: Check statistics regularly to track your progress",
        "💡 Tip: Enable webhooks to get notified of rare events"
    }
    
    Notify(tips[math.random(1, #tips)], 5, "Pro Tip")
end)

warn([[
╔═══════════════════════════════════════╗
║   Pongb Hub v3.0 Enhanced - Loaded    ║
╚═══════════════════════════════════════╝
]])

return PongbHub
