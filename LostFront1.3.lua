-- ==========================================
-- 🍅 Tomato LostFront Script (Ultimate) 🍅
-- Автор: LuckyCore
-- Ключ: LostMy
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- === НАСТРОЙКИ (СОХРАНЕНИЕ) ===
local settings = {
    ESPEnabled = false,
    AimbotEnabled = false,
    KillTeammates = false,
    WallbangEnabled = false,
    NoRecoilEnabled = false,
    BigHeadsEnabled = false,
    GodModeEnabled = false,
    aimbotFOV = 200,
    aimbotTargetTeam = "Red",
    aimbotTargetPart = "Head",
    aimbotCheckWalls = true
}

for k, v in pairs(settings) do
    local saved = getgenv()["Tomato_" .. k]
    if saved ~= nil then settings[k] = saved end
end

local function SaveSetting(name, value)
    settings[name] = value
    getgenv()["Tomato_" .. name] = value
end

local function Notify(Title, Text)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = Title, Text = Text, Duration = 2})
end

local Key = "LostMy"
local MenuCreated = false
local ESPEnabled = settings.ESPEnabled
local ESPObjects = {}
local DronesESP = {}
local menuFrame = nil
local menuGui = nil
local aimbotFOV = settings.aimbotFOV

-- Настройки Aimbot
local AimbotEnabled = settings.AimbotEnabled
local aimbotTargetTeam = settings.aimbotTargetTeam
local aimbotTargetPart = settings.aimbotTargetPart
local aimbotCheckWalls = settings.aimbotCheckWalls

-- Функции
local KillTeammates = settings.KillTeammates
local WallbangEnabled = settings.WallbangEnabled
local NoRecoilEnabled = settings.NoRecoilEnabled
local BigHeadsEnabled = settings.BigHeadsEnabled
local GodModeEnabled = settings.GodModeEnabled
local originalRecoil = nil
local bigHeadObjects = {}

-- === ВИЗУАЛЬНЫЙ FOV ===
local fovCircle = nil
local function CreateFOVCircle()
    if fovCircle then fovCircle:Destroy() end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVCircle"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local circle = Instance.new("ImageLabel")
    circle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
    circle.Position = UDim2.new(0.5, -aimbotFOV, 0.5, -aimbotFOV)
    circle.BackgroundTransparency = 1
    circle.Image = "rbxassetid://266811775"
    circle.ImageColor3 = Color3.fromRGB(255, 50, 50)
    circle.ImageTransparency = 0.6
    circle.Parent = screenGui
    fovCircle = circle
end

local function UpdateFOVCircle()
    if not fovCircle then return end
    fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
    fovCircle.Position = UDim2.new(0.5, -aimbotFOV, 0.5, -aimbotFOV)
end

local function ToggleFOVCircle(visible)
    if fovCircle then
        fovCircle.Parent = visible and LocalPlayer:WaitForChild("PlayerGui") or nil
    end
end

-- === ОПРЕДЕЛЕНИЕ КОМАНДЫ ПО ПОВЯЗКЕ ===
local function GetPlayerTeam(player)
    local char = player.Character
    if not char then return "Unknown" end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Clothing") or child.Name:lower():find("arm") or child.Name:lower():find("band") then
            local color = child.Color
            if color then
                if (color.b > 0.7 and color.r < 0.4) or (color.g > 0.6 and color.r < 0.4) then
                    return "Blue"
                end
                if (color.r > 0.7 and color.g < 0.4) or (color.r > 0.8 and color.g > 0.8 and color.b > 0.8) then
                    return "Red"
                end
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
local function GetESPColor(player)
    local team = GetPlayerTeam(player)
    if team == "Red" then return Color3.fromRGB(255, 0, 0)
    elseif team == "Blue" then return Color3.fromRGB(0, 0, 255)
    else return Color3.fromRGB(255, 255, 255) end
end

local function IsDrone(model)
    local name = model.Name:lower()
    return name:find("drone") or name:find("дрон") or name:find("fpv") or (model:IsA("Model") and model:FindFirstChild("DroneScript"))
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    if IsDrone(player.Character) then
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        DronesESP[player.Name] = highlight
    else
        highlight.FillColor = GetESPColor(player)
    end
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = player.Character
    ESPObjects[player.Name] = highlight
end

local function RemoveESP(player)
    if ESPObjects[player.Name] then ESPObjects[player.Name]:Destroy() ESPObjects[player.Name] = nil end
    if DronesESP[player.Name] then DronesESP[player.Name]:Destroy() DronesESP[player.Name] = nil end
end

local function ToggleESP()
    ESPEnabled = not ESPEnabled
    SaveSetting("ESPEnabled", ESPEnabled)
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then CreateESP(player) end
        end
        Players.PlayerAdded:Connect(CreateESP)
        Players.PlayerRemoving:Connect(RemoveESP)
        Notify("ESP", "Подсветка включена")
    else
        for _, player in ipairs(Players:GetPlayers()) do RemoveESP(player) end
        Notify("ESP", "Подсветка выключена")
    end
end

-- === AIMBOT ===
local function GetTargetPartPosition(character)
    local part = nil
    if aimbotTargetPart == "Head" then part = character:FindFirstChild("Head") end
    if aimbotTargetPart == "Torso" then part = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") end
    if not part then part = character:FindFirstChild("HumanoidRootPart") end
    return part and part.Position or nil
end

local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    
    if not KillTeammates then
        local team = GetPlayerTeam(player)
        if aimbotTargetTeam == "Red" and team ~= "Red" then return false end
        if aimbotTargetTeam == "Blue" and team ~= "Blue" then return false end
        if aimbotTargetTeam == "All" then return true end
    else
        return true
    end
    return true
end

local function IsVisible(targetPos)
    if not aimbotCheckWalls then return true end
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
    if not AimbotEnabled then return end
    local closest = nil
    local shortestDist = aimbotFOV
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

-- === ФУНКЦИИ ===
local function ToggleKillTeammates()
    KillTeammates = not KillTeammates
    SaveSetting("KillTeammates", KillTeammates)
    Notify("Убийство тиммейтов", KillTeammates and "Включено" or "Выключено")
end

local function ToggleWallbang()
    WallbangEnabled = not WallbangEnabled
    SaveSetting("WallbangEnabled", WallbangEnabled)
    Notify("Wallbang", WallbangEnabled and "Включена" or "Выключена")
end

local function ToggleNoRecoil()
    NoRecoilEnabled = not NoRecoilEnabled
    SaveSetting("NoRecoilEnabled", NoRecoilEnabled)
    if NoRecoilEnabled then
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildWhichIsA("Tool")
            if tool then
                local recoil = tool:FindFirstChild("Recoil")
                if recoil then
                    originalRecoil = recoil.Value
                    recoil.Value = 0
                end
            end
        end
        Notify("No Recoil", "Отдача убрана")
    else
        if originalRecoil then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool then
                    local recoil = tool:FindFirstChild("Recoil")
                    if recoil then recoil.Value = originalRecoil end
                end
            end
        end
        Notify("No Recoil", "Отдача возвращена")
    end
end

local function ToggleBigHeads()
    BigHeadsEnabled = not BigHeadsEnabled
    SaveSetting("BigHeadsEnabled", BigHeadsEnabled)
    if BigHeadsEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local originalSize = head.Size
                head.Size = Vector3.new(originalSize.X * 1.8, originalSize.Y * 1.8, originalSize.Z * 1.8)
                bigHeadObjects[player.Name] = {head = head, originalSize = originalSize}
            end
        end
        Notify("Big Heads", "Большие головы включены")
    else
        for name, data in pairs(bigHeadObjects) do
            if data.head then data.head.Size = data.originalSize end
        end
        bigHeadObjects = {}
        Notify("Big Heads", "Большие головы выключены")
    end
end

local function ToggleGodMode()
    GodModeEnabled = not GodModeEnabled
    SaveSetting("GodModeEnabled", GodModeEnabled)
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            if GodModeEnabled then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                humanoid.BreakJointsOnDeath = false
            else
                humanoid.MaxHealth = 100
                humanoid.Health = 100
                humanoid.BreakJointsOnDeath = true
            end
        end
    end
    Notify("Режим бога", GodModeEnabled and "Включён" or "Выключен")
end

-- === КНОПКА-ПОМИДОР (ИЗОБРАЖЕНИЕ) ===
local tomatoBtn = nil
local function CreateTomatoButton(onClick)
    local btnGui = Instance.new("ScreenGui")
    btnGui.Name = "TomatoButton"
    btnGui.ResetOnSpawn = false
    btnGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.85, 0, 0.85, 0)
    btn.BackgroundTransparency = 1
    btn.Image = "rbxassetid://1234567890"  -- Замени на ID своей картинки помидора
    btn.Parent = btnGui
    
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
    
    local tween = TweenService:Create(btn, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 80, 0, 80)})
    tween:Play()
    btn.MouseButton1Click:Connect(onClick)
    return btnGui, btn
end

-- === МЕНЮ ===
local function CreateAimbotSettingsMenu()
    local settingsGui = Instance.new("ScreenGui")
    settingsGui.Name = "AimbotSettings"
    settingsGui.ResetOnSpawn = false
    settingsGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 350)
    frame.Position = UDim2.new(0.5, -140, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = settingsGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "Настройки Aimbot"
    title.TextColor3 = Color3.fromRGB(229, 57, 53)
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    -- FOV
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0.9, 0, 0, 25)
    fovLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    fovLabel.Text = "FOV: " .. aimbotFOV
    fovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Parent = frame
    
    local fovSlider = Instance.new("TextBox")
    fovSlider.Size = UDim2.new(0.4, 0, 0, 30)
    fovSlider.Position = UDim2.new(0.55, 0, 0.1, 0)
    fovSlider.Text = tostring(aimbotFOV)
    fovSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    fovSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovSlider.Parent = frame
    fovSlider.FocusLost:Connect(function()
        local new = tonumber(fovSlider.Text)
        if new and new > 0 then
            aimbotFOV = math.clamp(new, 50, 500)
            SaveSetting("aimbotFOV", aimbotFOV)
            fovLabel.Text = "FOV: " .. aimbotFOV
            fovSlider.Text = tostring(aimbotFOV)
            UpdateFOVCircle()
            Notify("FOV", "Установлен " .. aimbotFOV)
        else
            fovSlider.Text = tostring(aimbotFOV)
        end
    end)
    
    -- Выбор команды
    local teamLabel = Instance.new("TextLabel")
    teamLabel.Size = UDim2.new(0.9, 0, 0, 25)
    teamLabel.Position = UDim2.new(0.05, 0, 0.22, 0)
    teamLabel.Text = "Цель:"
    teamLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    teamLabel.BackgroundTransparency = 1
    teamLabel.Parent = frame
    
    local redBtn = Instance.new("TextButton")
    redBtn.Size = UDim2.new(0.28, 0, 0, 30)
    redBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
    redBtn.Text = "Красные"
    redBtn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    redBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    redBtn.Parent = frame
    redBtn.MouseButton1Click:Connect(function() aimbotTargetTeam = "Red" SaveSetting("aimbotTargetTeam", "Red") Notify("Aimbot", "Цель: Красные") end)
    
    local blueBtn = Instance.new("TextButton")
    blueBtn.Size = UDim2.new(0.28, 0, 0, 30)
    blueBtn.Position = UDim2.new(0.36, 0, 0.3, 0)
    blueBtn.Text = "Синие"
    blueBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    blueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    blueBtn.Parent = frame
    blueBtn.MouseButton1Click:Connect(function() aimbotTargetTeam = "Blue" SaveSetting("aimbotTargetTeam", "Blue") Notify("Aimbot", "Цель: Синие") end)
    
    local allBtn = Instance.new("TextButton")
    allBtn.Size = UDim2.new(0.28, 0, 0, 30)
    allBtn.Position = UDim2.new(0.67, 0, 0.3, 0)
    allBtn.Text = "Все"
    allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    allBtn.Parent = frame
    allBtn.MouseButton1Click:Connect(function() aimbotTargetTeam = "All" SaveSetting("aimbotTargetTeam", "All") Notify("Aimbot", "Цель: Все") end)
    
    -- Часть тела
    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Size = UDim2.new(0.9, 0, 0, 25)
    bodyLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
    bodyLabel.Text = "Часть тела:"
    bodyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.Parent = frame
    
    local headBtn = Instance.new("TextButton")
    headBtn.Size = UDim2.new(0.28, 0, 0, 30)
    headBtn.Position = UDim2.new(0.05, 0, 0.53, 0)
    headBtn.Text = "Голова"
    headBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    headBtn.Parent = frame
    headBtn.MouseButton1Click:Connect(function() aimbotTargetPart = "Head" SaveSetting("aimbotTargetPart", "Head") Notify("Aimbot", "Цель: Голова") end)
    
    local torsoBtn = Instance.new("TextButton")
    torsoBtn.Size = UDim2.new(0.28, 0, 0, 30)
    torsoBtn.Position = UDim2.new(0.36, 0, 0.53, 0)
    torsoBtn.Text = "Торс"
    torsoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    torsoBtn.Parent = frame
    torsoBtn.MouseButton1Click:Connect(function() aimbotTargetPart = "Torso" SaveSetting("aimbotTargetPart", "Torso") Notify("Aimbot", "Цель: Торс") end)
    
    local rootBtn = Instance.new("TextButton")
    rootBtn.Size = UDim2.new(0.28, 0, 0, 30)
    rootBtn.Position = UDim2.new(0.67, 0, 0.53, 0)
    rootBtn.Text = "Root"
    rootBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    rootBtn.Parent = frame
    rootBtn.MouseButton1Click:Connect(function() aimbotTargetPart = "HumanoidRootPart" SaveSetting("aimbotTargetPart", "HumanoidRootPart") Notify("Aimbot", "Цель: RootPart") end)
    
    -- Проверка стен
    local wallCheckBtn = Instance.new("TextButton")
    wallCheckBtn.Size = UDim2.new(0.9, 0, 0, 35)
    wallCheckBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
    wallCheckBtn.Text = "Проверка стен: " .. (aimbotCheckWalls and "ВКЛ" or "ВЫКЛ")
    wallCheckBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    wallCheckBtn.Parent = frame
    wallCheckBtn.MouseButton1Click:Connect(function()
        aimbotCheckWalls = not aimbotCheckWalls
        SaveSetting("aimbotCheckWalls", aimbotCheckWalls)
        wallCheckBtn.Text = "Проверка стен: " .. (aimbotCheckWalls and "ВКЛ" or "ВЫКЛ")
        Notify("Aimbot", aimbotCheckWalls and "Проверка стен включена" or "Проверка стен выключена")
    end)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.8, 0, 0, 35)
    closeBtn.Position = UDim2.new(0.1, 0, 0.86, 0)
    closeBtn.Text = "Закрыть"
    closeBtn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function() settingsGui:Destroy() end)
end

local function CreateMenu()
    menuGui = Instance.new("ScreenGui")
    menuGui.Name = "TomatoMenu"
    menuGui.ResetOnSpawn = false
    menuGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, 300, 0, 420)
    menuFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    menuFrame.BorderSizePixel = 0
    menuFrame.BackgroundTransparency = 0.05
    menuFrame.Visible = false
    menuFrame.Parent = menuGui
    
    local dragStart, startPos
    menuFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = menuFrame.Position
        end
    end)
    menuFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragStart then
            local delta = input.Position - dragStart
            menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    menuFrame.InputEnded:Connect(function() dragStart = nil end)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "🍅 Tomato LostFront"
    title.TextColor3 = Color3.fromRGB(229, 57, 53)
    title.BackgroundTransparency = 1
    title.Parent = menuFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 0, 320)
    contentFrame.Position = UDim2.new(0.1, 0, 0.12, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = menuFrame
    
    local buttons = {
        {text = "ESP", callback = ToggleESP},
        {text = "AIMBOT", callback = function() AimbotEnabled = not AimbotEnabled SaveSetting("AimbotEnabled", AimbotEnabled) Notify("Aimbot", AimbotEnabled and "Включён" or "Выключен") ToggleFOVCircle(AimbotEnabled) end},
        {text = "Настройки Aimbot (¡)", callback = CreateAimbotSettingsMenu},
        {text = "Убийство тиммейтов", callback = ToggleKillTeammates},
        {text = "WALLBANG", callback = ToggleWallbang},
        {text = "NO RECOIL", callback = ToggleNoRecoil},
        {text = "BIG HEADS", callback = ToggleBigHeads},
        {text = "РЕЖИМ БОГА", callback = ToggleGodMode}
    }
    
    for i, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0.05 + (i-1) * 0.12, 0)
        btn.Text = btnData.text
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = contentFrame
        btn.MouseButton1Click:Connect(btnData.callback)
    end
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.8, 0, 0, 35)
    closeBtn.Position = UDim2.new(0.1, 0, 0.9, 0)
    closeBtn.Text = "Скрыть меню"
    closeBtn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = menuFrame
    closeBtn.MouseButton1Click:Connect(function() menuFrame.Visible = false end)
end

-- === ЗАЩИТА КЛЮЧОМ ===
local function ShowKeyPrompt()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeyPrompt"
    keyGui.ResetOnSpawn = false
    keyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = keyGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🍅 Tomato LostFront"
    title.TextColor3 = Color3.fromRGB(229, 57, 53)
    title.TextScaled = true
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
        if inputBox.Text == Key then
            keyGui:Destroy()
            Notify("Успех", "Ключ принят. Добро пожаловать, Никита!")
            if not MenuCreated then
                CreateMenu()
                CreateTomatoButton(function() if menuFrame then menuFrame.Visible = not menuFrame.Visible end end)
                CreateFOVCircle()
                ToggleFOVCircle(AimbotEnabled)
                MenuCreated = true
            end
        else
            Notify("Ошибка", "Неверный ключ!")
        end
    end)
end

RunService.RenderStepped:Connect(UpdateAimbot)
ShowKeyPrompt()