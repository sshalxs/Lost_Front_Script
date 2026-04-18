-- ==========================================
-- 🍅 TOMATO LOST FRONT 2.0 RELEASE 🍅
-- Автор: LuckyCore
-- Ключи: FREE | EFGSAGD (1 день)
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- === ДИНАМИК ISLAND ===
local function DynamicIsland(Message, Type)
    local gui = Instance.new("ScreenGui")
    gui.Name = "DynamicIsland"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(0.5, -150, 0, -60)
    frame.BackgroundColor3 = Type == "kill" and Color3.fromRGB(40, 40, 45) or (Type == "function" and Color3.fromRGB(30, 30, 35))
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.Text = Type == "kill" and "⚔️ УБИЙСТВО" or (Type == "death" and "💀 СМЕРТЬ" or "🔧 ФУНКЦИЯ")
    title.TextColor3 = Type == "kill" and Color3.fromRGB(255, 50, 50) or (Type == "death" and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(100, 200, 100))
    title.BackgroundTransparency = 1
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 25)
    msg.Position = UDim2.new(0, 0, 0, 30)
    msg.Text = Message
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.BackgroundTransparency = 1
    msg.TextSize = 12
    msg.Font = Enum.Font.Gotham
    msg.Parent = frame
    
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -150, 0, 10)})
    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, 0, 0, 3), {Position = UDim2.new(0.5, -150, 0, -60)})
    tweenIn:Play()
    tweenOut:Play()
    tweenOut.Completed:Connect(function() gui:Destroy() end)
end

-- === ЗВУК НАЖАТИЯ ===
local function PlayClick()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9120383632"
    sound.Volume = 0.3
    sound.Parent = LocalPlayer.Character or Workspace
    sound:Play()
    task.wait(0.5)
    sound:Destroy()
end

-- === HWID ===
local function GetHWID()
    local id = game:GetService("RbxAnalyticsService"):GetClientId()
    if not id or id == "" then
        id = tostring(game:GetService("Workspace"):GetServerTimeNow()) .. tostring(LocalPlayer.UserId)
    end
    return id
end

local HWID = GetHWID()
local AccessLevel = nil
local PremiumExpire = nil

-- === ПРОВЕРКА КЛЮЧЕЙ ===
local function CheckKey(inputKey)
    if inputKey == "EFGSAGD" then
        local savedHWID = getgenv().TomatoPremiumHWID
        local expire = getgenv().TomatoPremiumExpire
        if savedHWID and savedHWID == HWID and expire and expire > os.time() then
            AccessLevel = "premium"
            return true
        elseif not savedHWID then
            getgenv().TomatoPremiumHWID = HWID
            getgenv().TomatoPremiumExpire = os.time() + 86400
            AccessLevel = "premium"
            return true
        else
            DynamicIsland("❌ Премиум-ключ уже привязан к другому HWID или истёк!", "error")
            return false
        end
    elseif inputKey == "FREE" then
        AccessLevel = "free"
        return true
    end
    return false
end

-- === НАСТРОЙКИ И CFG ===
local settings = {
    Theme = "Dark",
    ESPEnabled = false,
    AimbotEnabled = false,
    BigHeadsEnabled = false,
    BigHeadsForTeam = "All",
    BunnyHopEnabled = false,
    SpeedHackEnabled = false,
    SpeedValue = 50,
    aimbotTargetTeam = "Red",
    aimbotCheckWalls = true,
    aimbotTargetPart = "Head"
}

local function LoadConfig()
    local success, data = pcall(function() return readfile("TomatoLostFront.cfg") end)
    if success and data then
        local cfg = HttpService:JSONDecode(data)
        for k, v in pairs(cfg) do settings[k] = v end
    end
end

local function SaveConfig()
    local cfg = {}
    for k, v in pairs(settings) do cfg[k] = v end
    pcall(function() writefile("TomatoLostFront.cfg", HttpService:JSONEncode(cfg)) end)
end

LoadConfig()

local function SaveSetting(name, value)
    settings[name] = value
    SaveConfig()
end

-- === ОПРЕДЕЛЕНИЕ КОМАНДЫ ===
local function GetPlayerTeam(player)
    local char = player.Character
    if not char then return "Unknown" end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") and (child.Name:lower():find("arm") or child.Name:lower():find("band")) then
            local color = child.Color
            if color then
                if color.b > 0.7 and color.r < 0.4 then return "Blue" end
                if color.r > 0.7 and color.g < 0.4 then return "Red" end
            end
        end
    end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if torso then
        local color = torso.Color
        if color and color.b > 0.6 and color.r < 0.4 then return "Blue" end
        if color and color.r > 0.6 and color.g < 0.4 then return "Red" end
    end
    return "Unknown"
end

-- === ESP ===
local espObjects = {}
local function GetESPColor(player)
    local team = GetPlayerTeam(player)
    if team == "Red" then return Color3.fromRGB(255, 0, 0)
    elseif team == "Blue" then return Color3.fromRGB(0, 0, 255)
    else return Color3.fromRGB(255, 255, 255) end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = GetESPColor(player)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = player.Character
    espObjects[player.Name] = highlight
end

local function RemoveESP(player)
    if espObjects[player.Name] then espObjects[player.Name]:Destroy() espObjects[player.Name] = nil end
end

local function ToggleESP()
    if AccessLevel == nil then DynamicIsland("❌ Сначала введите ключ!", "error") return end
    settings.ESPEnabled = not settings.ESPEnabled
    SaveSetting("ESPEnabled", settings.ESPEnabled)
    if settings.ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then CreateESP(player) end
        end
        Players.PlayerAdded:Connect(CreateESP)
        Players.PlayerRemoving:Connect(RemoveESP)
        DynamicIsland("🔧 ВЫ ВКЛЮЧИЛИ ФУНКЦИЮ ESP", "function")
    else
        for _, player in ipairs(Players:GetPlayers()) do RemoveESP(player) end
        DynamicIsland("🔧 ВЫ ВЫКЛЮЧИЛИ ФУНКЦИЮ ESP", "function")
    end
end

-- === AIMBOT ===
local function GetTargetPartPosition(character)
    if AccessLevel == "free" then
        return (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart"))?.Position
    else
        local part = character:FindFirstChild(settings.aimbotTargetPart)
        if part then return part.Position end
        return (character:FindFirstChild("HumanoidRootPart"))?.Position
    end
end

local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    local team = GetPlayerTeam(player)
    if settings.aimbotTargetTeam == "Red" and team ~= "Red" then return false end
    if settings.aimbotTargetTeam == "Blue" and team ~= "Blue" then return false end
    if settings.aimbotTargetTeam == "All" then return true end
    return true
end

local function IsVisible(targetPos)
    if not settings.aimbotCheckWalls then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPos - origin).Unit
    local ray = Ray.new(origin, dir * (targetPos - origin).Magnitude)
    local hit, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit then
        return (pos - origin).Magnitude >= (targetPos - origin).Magnitude - 1
    end
    return true
end

local function UpdateAimbot()
    if not settings.AimbotEnabled then return end
    local closest = nil
    local shortestDist = 300
    local mouseLoc = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) and player.Character then
            local targetPos = GetTargetPartPosition(player.Character)
            if targetPos and IsVisible(targetPos) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouseLoc.X, mouseLoc.Y)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    if closest and closest.Character then
        local aimPos = GetTargetPartPosition(closest.Character)
        if aimPos then Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPos) end
    end
end

local function ShowAimbotSettings()
    local settingsGui = Instance.new("ScreenGui")
    settingsGui.Name = "AimbotSettings"
    settingsGui.ResetOnSpawn = false
    settingsGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 300)
    frame.Position = UDim2.new(0.5, -125, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.Parent = settingsGui
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function() settingsGui:Destroy() end)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "Настройки Aimbot"
    title.TextColor3 = Color3.fromRGB(229, 57, 53)
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local redBtn = Instance.new("TextButton")
    redBtn.Size = UDim2.new(0.28, 0, 0, 30)
    redBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
    redBtn.Text = "Красные"
    redBtn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    redBtn.Parent = frame
    redBtn.MouseButton1Click:Connect(function() settings.aimbotTargetTeam = "Red" SaveSetting("aimbotTargetTeam", "Red") DynamicIsland("🎯 Цель: Красные", "function") end)
    
    local blueBtn = Instance.new("TextButton")
    blueBtn.Size = UDim2.new(0.28, 0, 0, 30)
    blueBtn.Position = UDim2.new(0.36, 0, 0.15, 0)
    blueBtn.Text = "Синие"
    blueBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    blueBtn.Parent = frame
    blueBtn.MouseButton1Click:Connect(function() settings.aimbotTargetTeam = "Blue" SaveSetting("aimbotTargetTeam", "Blue") DynamicIsland("🎯 Цель: Синие", "function") end)
    
    local allBtn = Instance.new("TextButton")
    allBtn.Size = UDim2.new(0.28, 0, 0, 30)
    allBtn.Position = UDim2.new(0.67, 0, 0.15, 0)
    allBtn.Text = "Все"
    allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    allBtn.Parent = frame
    allBtn.MouseButton1Click:Connect(function() settings.aimbotTargetTeam = "All" SaveSetting("aimbotTargetTeam", "All") DynamicIsland("🎯 Цель: Все", "function") end)
    
    local headBtn = Instance.new("TextButton")
    headBtn.Size = UDim2.new(0.28, 0, 0, 30)
    headBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
    headBtn.Text = "Голова"
    headBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    headBtn.Parent = frame
    headBtn.MouseButton1Click:Connect(function() settings.aimbotTargetPart = "Head" SaveSetting("aimbotTargetPart", "Head") DynamicIsland("🎯 Часть: Голова", "function") end)
    
    local torsoBtn = Instance.new("TextButton")
    torsoBtn.Size = UDim2.new(0.28, 0, 0, 30)
    torsoBtn.Position = UDim2.new(0.36, 0, 0.35, 0)
    torsoBtn.Text = "Торс"
    torsoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    torsoBtn.Parent = frame
    torsoBtn.MouseButton1Click:Connect(function() settings.aimbotTargetPart = "Torso" SaveSetting("aimbotTargetPart", "Torso") DynamicIsland("🎯 Часть: Торс", "function") end)
    
    local wallCheckBtn = Instance.new("TextButton")
    wallCheckBtn.Size = UDim2.new(0.9, 0, 0, 35)
    wallCheckBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
    wallCheckBtn.Text = "Проверка стен: " .. (settings.aimbotCheckWalls and "ВКЛ" or "ВЫКЛ")
    wallCheckBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    wallCheckBtn.Parent = frame
    wallCheckBtn.MouseButton1Click:Connect(function()
        settings.aimbotCheckWalls = not settings.aimbotCheckWalls
        SaveSetting("aimbotCheckWalls", settings.aimbotCheckWalls)
        wallCheckBtn.Text = "Проверка стен: " .. (settings.aimbotCheckWalls and "ВКЛ" or "ВЫКЛ")
        DynamicIsland("🔍 Проверка стен " .. (settings.aimbotCheckWalls and "включена" or "выключена"), "function")
    end)
    
    local closeBtn2 = Instance.new("TextButton")
    closeBtn2.Size = UDim2.new(0.8, 0, 0, 35)
    closeBtn2.Position = UDim2.new(0.1, 0, 0.85, 0)
    closeBtn2.Text = "Закрыть"
    closeBtn2.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    closeBtn2.Parent = frame
    closeBtn2.MouseButton1Click:Connect(function() settingsGui:Destroy() end)
end

-- === БОЛЬШИЕ ГОЛОВЫ ===
local bigHeadObjects = {}
local function ToggleBigHeads()
    if AccessLevel ~= "premium" then DynamicIsland("❌ Доступно только в PREMIUM", "error") return end
    settings.BigHeadsEnabled = not settings.BigHeadsEnabled
    SaveSetting("BigHeadsEnabled", settings.BigHeadsEnabled)
    if settings.BigHeadsEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local originalSize = head.Size
                head.Size = Vector3.new(originalSize.X * 1.8, originalSize.Y * 1.8, originalSize.Z * 1.8)
                bigHeadObjects[player.Name] = {head = head, originalSize = originalSize}
            end
        end
        DynamicIsland("🔧 ВЫ ВКЛЮЧИЛИ ФУНКЦИЮ BIG HEADS", "function")
    else
        for name, data in pairs(bigHeadObjects) do
            if data.head then data.head.Size = data.originalSize end
        end
        bigHeadObjects = {}
        DynamicIsland("🔧 ВЫ ВЫКЛЮЧИЛИ ФУНКЦИЮ BIG HEADS", "function")
    end
end

-- === BUNNY HOP ===
local function ToggleBunnyHop()
    if AccessLevel ~= "premium" then DynamicIsland("❌ Доступно только в PREMIUM", "error") return end
    settings.BunnyHopEnabled = not settings.BunnyHopEnabled
    SaveSetting("BunnyHopEnabled", settings.BunnyHopEnabled)
    DynamicIsland("🔧 ВЫ " .. (settings.BunnyHopEnabled and "ВКЛЮЧИЛИ" or "ВЫКЛЮЧИЛИ") .. " ФУНКЦИЮ BUNNY HOP", "function")
end

local function UpdateBunnyHop()
    if not settings.BunnyHopEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Jumping then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- === SPEEDHACK ===
local function ToggleSpeedHack()
    if AccessLevel ~= "premium" then DynamicIsland("❌ Доступно только в PREMIUM", "error") return end
    settings.SpeedHackEnabled = not settings.SpeedHackEnabled
    SaveSetting("SpeedHackEnabled", settings.SpeedHackEnabled)
    DynamicIsland("🔧 ВЫ " .. (settings.SpeedHackEnabled and "ВКЛЮЧИЛИ" or "ВЫКЛЮЧИЛИ") .. " ФУНКЦИЮ SPEEDHACK", "function")
end

local function UpdateSpeedHack()
    if not settings.SpeedHackEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = settings.SpeedValue
    end
end

-- === ОТСЛЕЖИВАНИЕ УБИЙСТВ И СМЕРТЕЙ ===
local function TrackKills()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            DynamicIsland("💀 ВЫ БЫЛИ УБИТЫ", "death")
        end)
    end
end

-- === МЕНЮ ===
local menuGui = nil
local menuFrame = nil
local currentTheme = settings.Theme

local function ApplyTheme()
    if currentTheme == "Dark" then
        menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    elseif currentTheme == "Light" then
        menuFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    elseif currentTheme == "Red" then
        menuFrame.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
    end
end

local function CreateMenu()
    menuGui = Instance.new("ScreenGui")
    menuGui.Name = "TomatoLostFront2"
    menuGui.ResetOnSpawn = false
    menuGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    menuGui.Enabled = false
    
    menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, 380, 0, 550)
    menuFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
    menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    menuFrame.BorderSizePixel = 0
    menuFrame.Parent = menuGui
    ApplyTheme()
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Text = "🍅 TOMATO LOST FRONT 2.0"
    title.TextColor3 = Color3.fromRGB(229, 57, 53)
    title.BackgroundTransparency = 1
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = menuFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    closeBtn.Parent = menuFrame
    closeBtn.MouseButton1Click:Connect(function() menuGui.Enabled = false end)
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -100)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 550)
    content.ScrollBarThickness = 8
    content.Parent = menuFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content
    
    local function AddButton(text, callback, desc, hasSettings)
        local btnFrame = Instance.new("Frame")
        btnFrame.Size = UDim2.new(1, 0, 0, 45)
        btnFrame.BackgroundTransparency = 1
        btnFrame.Parent = content
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.7, 0, 1, 0)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = btnFrame
        btn.MouseButton1Click:Connect(function()
            PlayClick()
            callback()
        end)
        
        local infoBtn = Instance.new("TextButton")
        infoBtn.Size = UDim2.new(0.1, 0, 1, 0)
        infoBtn.Position = UDim2.new(0.72, 0, 0, 0)
        infoBtn.Text = "?"
        infoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoBtn.Parent = btnFrame
        infoBtn.MouseButton1Click:Connect(function()
            PlayClick()
            DynamicIsland("ℹ️ " .. desc, "function")
        end)
        
        if hasSettings then
            local settingsBtn = Instance.new("TextButton")
            settingsBtn.Size = UDim2.new(0.12, 0, 1, 0)
            settingsBtn.Position = UDim2.new(0.84, 0, 0, 0)
            settingsBtn.Text = "¡"
            settingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            settingsBtn.TextSize = 18
            settingsBtn.Parent = btnFrame
            settingsBtn.MouseButton1Click:Connect(function()
                PlayClick()
                ShowAimbotSettings()
            end)
        end
    end
    
    AddButton("ESP", ToggleESP, "Подсветка игроков (красные/синие)", false)
    AddButton("AIMBOT", function() settings.AimbotEnabled = not settings.AimbotEnabled SaveSetting("AimbotEnabled", settings.AimbotEnabled) DynamicIsland("🔧 ВЫ " .. (settings.AimbotEnabled and "ВКЛЮЧИЛИ" or "ВЫКЛЮЧИЛИ") .. " ФУНКЦИЮ AIMBOT", "function") end, "Автонаведение на цель", true)
    AddButton("BIG HEADS", ToggleBigHeads, "Увеличивает головы игроков", false)
    AddButton("BUNNY HOP", ToggleBunnyHop, "Автопрыжок", false)
    AddButton("SPEEDHACK", ToggleSpeedHack, "Увеличение скорости", false)
    
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, 0, 0, 45)
    speedFrame.BackgroundTransparency = 1
    speedFrame.Parent = content
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.4, 0, 1, 0)
    speedLabel.Text = "Скорость: " .. settings.SpeedValue
    speedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.Parent = speedFrame
    
    local speedSlider = Instance.new("TextBox")
    speedSlider.Size = UDim2.new(0.3, 0, 1, 0)
    speedSlider.Position = UDim2.new(0.45, 0, 0, 0)
    speedSlider.Text = tostring(settings.SpeedValue)
    speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedSlider.Parent = speedFrame
    speedSlider.FocusLost:Connect(function()
        local v = tonumber(speedSlider.Text)
        if v then
            settings.SpeedValue = v
            SaveSetting("SpeedValue", v)
            speedLabel.Text = "Скорость: " .. v
            DynamicIsland("⚡ Скорость установлена: " .. v, "function")
        else
            speedSlider.Text = tostring(settings.SpeedValue)
        end
    end)
    
    local themeFrame = Instance.new("Frame")
    themeFrame.Size = UDim2.new(1, 0, 0, 45)
    themeFrame.BackgroundTransparency = 1
    themeFrame.Parent = content
    
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(0.4, 0, 1, 0)
    themeLabel.Text = "Тема: " .. currentTheme
    themeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    themeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeLabel.Parent = themeFrame
    
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0.3, 0, 1, 0)
    themeBtn.Position = UDim2.new(0.45, 0, 0, 0)
    themeBtn.Text = "Сменить"
    themeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    themeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeBtn.Parent = themeFrame
    themeBtn.MouseButton1Click:Connect(function()
        local themes = {"Dark", "Light", "Red"}
        local idx = table.find(themes, currentTheme) or 1
        if not idx then idx = 1 end
        idx = idx % #themes + 1
        currentTheme = themes[idx]
        settings.Theme = currentTheme
        SaveSetting("Theme", currentTheme)
        themeLabel.Text = "Тема: " .. currentTheme
        ApplyTheme()
        DynamicIsland("🎨 Тема изменена на " .. currentTheme, "function")
    end)
end

-- === ПЛАВАЮЩАЯ КНОПКА С ДЕКОРАЦИЯМИ ===
local function CreateToggleButton()
    local btnGui = Instance.new("ScreenGui")
    btnGui.Name = "TomatoButton"
    btnGui.ResetOnSpawn = false
    btnGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(1, -90, 0.5, -35)
    btn.Text = "🍅"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 36
    btn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    btn.CornerRadius = UDim.new(0, 25)
    btn.Parent = btnGui
    
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.2, 0, 1.2, 0)
    glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://266811775"
    glow.ImageColor3 = Color3.fromRGB(229, 57, 53)
    glow.ImageTransparency = 0.6
    glow.Parent = btn
    
    local tween = TweenService:Create(btn, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 80, 0, 80)})
    tween:Play()
    
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragStart then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    btn.InputEnded:Connect(function() dragStart = nil end)
    
    btn.MouseButton1Click:Connect(function()
        PlayClick()
        if menuGui then menuGui.Enabled = not menuGui.Enabled end
    end)
end

-- === ЗАПРОС КЛЮЧА ===
local function ShowKeyPrompt()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeyPrompt"
    keyGui.ResetOnSpawn = false
    keyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.Parent = keyGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "🍅 Введите ключ"
    title.TextColor3 = Color3.fromRGB(229, 57, 53)
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.8, 0, 0, 40)
    inputBox.Position = UDim2.new(0.1, 0, 0.3, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "Введите ключ..."
    inputBox.Parent = frame
    
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.5, 0, 0, 40)
    confirmBtn.Position = UDim2.new(0.25, 0, 0.7, 0)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    confirmBtn.Text = "Подтвердить"
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.Parent = frame
    
    confirmBtn.MouseButton1Click:Connect(function()
        if CheckKey(inputBox.Text) then
            keyGui:Destroy()
            DynamicIsland("✅ Доступ получен! Уровень: " .. (AccessLevel == "premium" and "ПРЕМИУМ" or "БЕСПЛАТНЫЙ"), "function")
            CreateMenu()
            CreateToggleButton()
            if AccessLevel == "premium" then
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0, 120, 0, 30)
                label.Position = UDim2.new(0, 10, 0, 10)
                label.Text = "🍅 PREMIUM"
                label.TextColor3 = Color3.fromRGB(255, 215, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamBold
                label.Parent = LocalPlayer.PlayerGui
            end
            TrackKills()
        else
            DynamicIsland("❌ Неверный ключ!", "error")
        end
    end)
end

-- === ОБХОД АНТИЧИТА ===
local function BypassAntiCheat()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and tostring(self):find("AntiCheat") then
            return nil
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
    DynamicIsland("🛡️ Античит обойдён", "function")
end

-- === ЗАПУСК ===
BypassAntiCheat()
ShowKeyPrompt()
RunService.RenderStepped:Connect(UpdateAimbot)
RunService.RenderStepped:Connect(UpdateBunnyHop)
RunService.RenderStepped:Connect(UpdateSpeedHack)