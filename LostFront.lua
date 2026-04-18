-- ==========================================
-- 🍅 Tomato LostFront Script (Full) 🍅
-- Автор: LuckyCore
-- Ключ: LostMy
-- ЧАСТЬ 1/2
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function Notify(Title, Text)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = Title, Text = Text, Duration = 2})
end

local Key = "LostMy"
local MenuCreated = false
local ESPEnabled = false
local ESPObjects = {}
local DronesESP = {}
local menuFrame = nil
local menuGui = nil
local currentMenuPage = 1
local totalPages = 2

-- Настройки Aimbot
local AimbotEnabled = false
local aimbotTargetTeam = "Red"
local aimbotTargetPart = "Head"
local aimbotCheckWalls = true

-- Опасные функции
local WallbangEnabled = false
local NoRecoilEnabled = false
local BigHeadsEnabled = false
local originalRecoil = nil
local bigHeadObjects = {}

-- === ОПРЕДЕЛЕНИЕ КОМАНДЫ ===
local function GetPlayerTeam(player)
    local char = player.Character
    if not char then return "Unknown" end
    local accessory = char:FindFirstChild("Flag") or char:FindFirstChild("Armband") or char:FindFirstChild("TeamColor")
    if accessory then
        local color = accessory.Color
        if color and color.r > 0.8 and color.g < 0.3 then return "Red" end
        if color and color.b > 0.8 and color.r < 0.3 then return "Blue" end
    end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if torso then
        local color = torso.Color
        if color and color.r > 0.8 and color.g < 0.3 then return "Red" end
        if color and color.b > 0.8 and color.r < 0.3 then return "Blue" end
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
    return name:find("drone") or name:find("дрон") or (model:IsA("Model") and model:FindFirstChild("DroneScript"))
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
    local team = GetPlayerTeam(player)
    if aimbotTargetTeam == "Red" and team ~= "Red" then return false end
    if aimbotTargetTeam == "Blue" and team ~= "Blue" then return false end
    if aimbotTargetTeam == "All" then return true end
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

-- === ОПАСНЫЕ ФУНКЦИИ ===
local function ToggleWallbang()
    WallbangEnabled = not WallbangEnabled
    Notify("Wallbang", WallbangEnabled and "Включена" or "Выключена")
end

local function ToggleNoRecoil()
    NoRecoilEnabled = not NoRecoilEnabled
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

-- === ПУЛЬСИРУЮЩАЯ КНОПКА-ПОМИДОР ===
local function CreateTomatoButton(onClick)
    local btnGui = Instance.new("ScreenGui")
    btnGui.Name = "TomatoButton"
    btnGui.ResetOnSpawn = false
    btnGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.85, 0, 0.85, 0)
    btn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    btn.BackgroundTransparency = 0.1
    btn.Text = "🍅"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 40
    btn.Font = Enum.Font.SourceSansBold
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
    
    local tween = TweenService:Create(btn, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 80, 0, 80), BackgroundTransparency = 0})
    tween:Play()
    btn.MouseButton1Click:Connect(onClick)
    return btnGui, btn
end

-- === МЕНЮ (часть 1) ===
local function CreateAimbotSettingsMenu()
    local settingsGui = Instance.new("ScreenGui")
    settingsGui.Name = "AimbotSettings"
    settingsGui.ResetOnSpawn = false
    settingsGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 280)
    frame.Position = UDim2.new(0.5, -125, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = settingsGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "Настройки Aimbot"
    title.TextColor3 = Color3.fromRGB(229, 57, 53)
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local teamLabel = Instance.new("TextLabel")
    teamLabel.Size = UDim2.new(0.9, 0, 0, 25)
    teamLabel.Position = UDim2.new(0.05, 0, 0.13, 0)
    teamLabel.Text = "Целиться в команду:"
    teamLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    teamLabel.BackgroundTransparency = 1
    teamLabel.Parent = frame
    
    local redBtn = Instance.new("TextButton")
    redBtn.Size = UDim2.new(0.28, 0, 0, 30)
    redBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
    redBtn.Text = "Красные"
    redBtn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    redBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    redBtn.Parent = frame
    redBtn.MouseButton1Click:Connect(function() aimbotTargetTeam = "Red" Notify("Aimbot", "Цель: Красные") end)
    
    local blueBtn = Instance.new("TextButton")
    blueBtn.Size = UDim2.new(0.28, 0, 0, 30)
    blueBtn.Position = UDim2.new(0.36, 0, 0.25, 0)
    blueBtn.Text = "Синие"
    blueBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    blueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    blueBtn.Parent = frame
    blueBtn.MouseButton1Click:Connect(function() aimbotTargetTeam = "Blue" Notify("Aimbot", "Цель: Синие") end)
    
    local allBtn = Instance.new("TextButton")
    allBtn.Size = UDim2.new(0.28, 0, 0, 30)
    allBtn.Position = UDim2.new(0.67, 0, 0.25, 0)
    allBtn.Text = "Все"
    allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    allBtn.Parent = frame
    allBtn.MouseButton1Click:Connect(function() aimbotTargetTeam = "All" Notify("Aimbot", "Цель: Все") end)
    
    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Size = UDim2.new(0.9, 0, 0, 25)
    bodyLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
    bodyLabel.Text = "Часть тела:"
    bodyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.Parent = frame
    
    local headBtn = Instance.new("TextButton")
    headBtn.Size = UDim2.new(0.28, 0, 0, 30)
    headBtn.Position = UDim2.new(0.05, 0, 0.52, 0)
    headBtn.Text = "Голова"
    headBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    headBtn.Parent = frame
    headBtn.MouseButton1Click:Connect(function() aimbotTargetPart = "Head" Notify("Aimbot", "Цель: Голова") end)
    
    local torsoBtn = Instance.new("TextButton")
    torsoBtn.Size = UDim2.new(0.28, 0, 0, 30)
    torsoBtn.Position = UDim2.new(0.36, 0, 0.52, 0)
    torsoBtn.Text = "Торс"
    torsoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    torsoBtn.Parent = frame
    torsoBtn.MouseButton1Click:Connect(function() aimbotTargetPart = "Torso" Notify("Aimbot", "Цель: Торс") end)
    
    local rootBtn = Instance.new("TextButton")
    rootBtn.Size = UDim2.new(0.28, 0, 0, 30)
    rootBtn.Position = UDim2.new(0.67, 0, 0.52, 0)
    rootBtn.Text = "Root"
    rootBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    rootBtn.Parent = frame
    rootBtn.MouseButton1Click:Connect(function() aimbotTargetPart = "HumanoidRootPart" Notify("Aimbot", "Цель: RootPart") end)
    
    local wallCheckBtn = Instance.new("TextButton")
    wallCheckBtn.Size = UDim2.new(0.9, 0, 0, 35)
    wallCheckBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
    wallCheckBtn.Text = "Проверка стен: ВКЛ"
    wallCheckBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    wallCheckBtn.Parent = frame
    wallCheckBtn.MouseButton1Click:Connect(function()
        aimbotCheckWalls = not aimbotCheckWalls
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
    menuFrame.Size = UDim2.new(0, 300, 0, 400)
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
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "🍅 Tomato LostFront"
    title.TextColor3 = Color3.fromRGB(229, 57, 53)
    title.BackgroundTransparency = 1
    title.Parent = menuFrame
    
    local leftArrow = Instance.new("TextButton")
    leftArrow.Size = UDim2.new(0, 40, 0, 30)
    leftArrow.Position = UDim2.new(0.02, 0, 0.03, 0)
    leftArrow.Text = "◀"
    leftArrow.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    leftArrow.Parent = menuFrame
    leftArrow.MouseButton1Click:Connect(function()
        if currentMenuPage > 1 then currentMenuPage = currentMenuPage - 1 UpdateMenuContent() end
    end)
    
    local pageText = Instance.new("TextLabel")
    pageText.Size = UDim2.new(0, 60, 0, 30)
    pageText.Position = UDim2.new(0.4, 0, 0.03, 0)
    pageText.Text = "1/2"
    pageText.TextColor3 = Color3.fromRGB(200, 200, 200)
    pageText.BackgroundTransparency = 1
    pageText.Parent = menuFrame
    
    local rightArrow = Instance.new("TextButton")
    rightArrow.Size = UDim2.new(0, 40, 0, 30)
    rightArrow.Position = UDim2.new(0.7, 0, 0.03, 0)
    rightArrow.Text = "▶"
    rightArrow.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    rightArrow.Parent = menuFrame
    rightArrow.MouseButton1Click:Connect(function()
        if currentMenuPage < totalPages then currentMenuPage = currentMenuPage + 1 UpdateMenuContent() end
    end)
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 0, 300)
    contentFrame.Position = UDim2.new(0.5, -140, 0.15, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = menuFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.8, 0, 0, 35)
    closeBtn.Position = UDim2.new(0.1, 0, 0.88, 0)
    closeBtn.Text = "Скрыть меню"
    closeBtn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
    closeBtn.Parent = menuFrame
    closeBtn.MouseButton1Click:Connect(function() menuFrame.Visible = false end)
    
    local function UpdateMenuContent()
        contentFrame:ClearAllChildren()
        pageText.Text = currentMenuPage .. "/" .. totalPages
        
        if currentMenuPage == 1 then
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, 0, 0, 30)
            sectionTitle.Text = "🟢 НЕ ОПАСНЫЕ"
            sectionTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Parent = contentFrame
            
            local espBtn = Instance.new("TextButton")
            espBtn.Size = UDim2.new(0.9, 0, 0, 40)
            espBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
            espBtn.Text = "ESP: ВЫКЛ"
            espBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            espBtn.Parent = contentFrame
            espBtn.MouseButton1Click:Connect(function()
                ToggleESP()
                espBtn.Text = "ESP: " .. (ESPEnabled and "ВКЛ" or "ВЫКЛ")
            end)
            
            local aimbotBtn = Instance.new("TextButton")
            aimbotBtn.Size = UDim2.new(0.7, 0, 0, 40)
            aimbotBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
            aimbotBtn.Text = "AIMBOT: ВЫКЛ"
            aimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            aimbotBtn.Parent = contentFrame
            aimbotBtn.MouseButton1Click:Connect(function()
                AimbotEnabled = not AimbotEnabled
                aimbotBtn.Text = "AIMBOT: " .. (AimbotEnabled and "ВКЛ" or "ВЫКЛ")
                Notify("Aimbot", AimbotEnabled and "Включён" or "Выключен")
            end)
            
            local settingsBtn = Instance.new("TextButton")
            settingsBtn.Size = UDim2.new(0.15, 0, 0, 40)
            settingsBtn.Position = UDim2.new(0.8, 0, 0.25, 0)
            settingsBtn.Text = "¡"
            settingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            settingsBtn.TextSize = 24
            settingsBtn.Parent = contentFrame
            settingsBtn.MouseButton1Click:Connect(CreateAimbotSettingsMenu)
        else
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, 0, 0, 30)
            sectionTitle.Text = "🔴 ОПАСНЫЕ"
            sectionTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Parent = contentFrame
            
   
-- ==========================================
-- 🍅 Tomato LostFront Script (Full) 🍅
-- Автор: LuckyCore
-- Ключ: LostMy
-- ЧАСТЬ 2/2
-- ==========================================

            local wallbangBtn = Instance.new("TextButton")
            wallbangBtn.Size = UDim2.new(0.9, 0, 0, 40)
            wallbangBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
            wallbangBtn.Text = "WALLBANG: ВЫКЛ"
            wallbangBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            wallbangBtn.Parent = contentFrame
            wallbangBtn.MouseButton1Click:Connect(function()
                ToggleWallbang()
                wallbangBtn.Text = "WALLBANG: " .. (WallbangEnabled and "ВКЛ" or "ВЫКЛ")
            end)
            
            local norecoilBtn = Instance.new("TextButton")
            norecoilBtn.Size = UDim2.new(0.9, 0, 0, 40)
            norecoilBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
            norecoilBtn.Text = "NO RECOIL: ВЫКЛ"
            norecoilBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            norecoilBtn.Parent = contentFrame
            norecoilBtn.MouseButton1Click:Connect(function()
                ToggleNoRecoil()
                norecoilBtn.Text = "NO RECOIL: " .. (NoRecoilEnabled and "ВКЛ" or "ВЫКЛ")
            end)
            
            local bigheadsBtn = Instance.new("TextButton")
            bigheadsBtn.Size = UDim2.new(0.9, 0, 0, 40)
            bigheadsBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
            bigheadsBtn.Text = "BIG HEADS: ВЫКЛ"
            bigheadsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            bigheadsBtn.Parent = contentFrame
            bigheadsBtn.MouseButton1Click:Connect(function()
                ToggleBigHeads()
                bigheadsBtn.Text = "BIG HEADS: " .. (BigHeadsEnabled and "ВКЛ" or "ВЫКЛ")
            end)
        end
    end
    
    UpdateMenuContent()
end

-- === ЗАЩИТА КЛЮЧОМ И ЗАПУСК ===
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
                MenuCreated = true
            end
        else
            Notify("Ошибка", "Неверный ключ!")
        end
    end)
end

RunService.RenderStepped:Connect(UpdateAimbot)
ShowKeyPrompt()