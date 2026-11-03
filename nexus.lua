local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local KeyRawURL = "https://raw.githubusercontent.com/nywertyy-dev/nexus-script/main/key.txt"
local TelegramLink = "https://t.me/+J45h5EG2mJY4ZDgy"

local function startScript()
    local Settings = {
        AimbotEnabled = false,
        SilentAimEnabled = false,
        WallShotEnabled = false,
        AutoReloadEnabled = false,
        HitSoundEnabled = false,
        TracersEnabled = false,
        ESPEnabled = false,
        ESPInfoEnabled = false,
        HitboxEnabled = false,
        SpinBotEnabled = false,
        ThirdPersonEnabled = false,
        CustomCrosshair = false,
        FOVCircle = false,
        WallCheck = true,
        GodModeEnabled = false,
        FlyEnabled = false,
        NoclipEnabled = false,
        FOVChanger = false,
        CustomFOV = 90,
        AntiAFKEnabled = false,
        AntiKickEnabled = false,
        KillSayEnabled = false
    }

    local TracersList = {}
    local ConfigFileName = "NEXUS_Config.json"
    local HttpService = game:GetService("HttpService")

    local function saveConfig()
        local success, encoded = pcall(function() return HttpService:JSONEncode(Settings) end)
        if success and writefile then writefile(ConfigFileName, encoded) end
    end

    local function loadConfig()
        if readfile and pcall(function() readfile(ConfigFileName) end) then
            local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFileName)) end)
            if success and type(decoded) == "table" then
                if decoded.CustomFOV ~= nil then Settings.CustomFOV = decoded.CustomFOV end
            end
        end
    end
    loadConfig()

    local BlurEffect = Instance.new("BlurEffect", Lighting)
    BlurEffect.Size = 0
    BlurEffect.Enabled = false

    local HUDGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    HUDGui.Name = "NEXUS_HUD"
    HUDGui.ResetOnSpawn = false

    local Watermark = Instance.new("TextLabel", HUDGui)
    Watermark.Size = UDim2.new(0, 230, 0, 32)
    Watermark.Position = UDim2.new(1, -240, 0, 15)
    Watermark.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Watermark.BackgroundTransparency = 0.3
    Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
    Watermark.TextSize = 12
    Watermark.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
    local WaterStroke = Instance.new("UIStroke", Watermark)
    WaterStroke.Color = Color3.fromRGB(255, 255, 255)
    WaterStroke.Thickness = 1.5

    RunService.RenderStepped:Connect(function()
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        Watermark.Text = string.format("  NEXUS | Deagle Duels | %d FPS | %dms", fps, ping)
    end)

    local FOVCircleDrawing = Drawing.new("Circle")
    FOVCircleDrawing.Visible = false
    FOVCircleDrawing.Thickness = 1.5
    FOVCircleDrawing.Color = Color3.fromRGB(255, 255, 255)
    FOVCircleDrawing.Filled = false
    FOVCircleDrawing.Radius = 100

    local CrosshairDrawing = Drawing.new("Circle")
    CrosshairDrawing.Visible = false
    CrosshairDrawing.Thickness = 2
    CrosshairDrawing.Color = Color3.fromRGB(255, 255, 255)
    CrosshairDrawing.Filled = true
    CrosshairDrawing.Radius = 3

    LocalPlayer.Idled:Connect(function()
        if Settings.AntiAFKEnabled then
            VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end
    end)

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if Settings.AntiKickEnabled and (method == "Kick" or method == "kick") and self == LocalPlayer then return nil end
        return oldNamecall(self, ...)
    end)

    local function isVisible(targetPart)
        if Settings.WallShotEnabled or Settings.SilentAimEnabled or not Settings.WallCheck then return true end
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("Head") then return false end
        local origin = character.Head.Position
        local direction = targetPart.Position - origin
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {character, Camera}
        raycastParams.IgnoreWater = true
        local result = workspace:Raycast(origin, direction, raycastParams)
        if result then
            local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
            if hitModel and hitModel == targetPart.Parent then return true end
            return false
        end
        return true
    end

    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mousePos = UserInputService:GetMouseLocation()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
                if player.Character.Humanoid.Health > 0 then
                    local head = player.Character.Head
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if Settings.WallShotEnabled or Settings.SilentAimEnabled or onScreen then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if (Settings.WallShotEnabled or Settings.SilentAimEnabled) or (screenDist < shortestDistance and isVisible(head)) then
                            shortestDistance = screenDist
                            closestPlayer = player
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircleDrawing.Visible = (Settings.FOVCircle and Settings.AimbotEnabled)
        FOVCircleDrawing.Position = mousePos
        CrosshairDrawing.Visible = Settings.CustomCrosshair
        CrosshairDrawing.Position = mousePos

        if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), 0.2)
            end
        end
        if Settings.FOVChanger then Camera.FieldOfView = Settings.CustomFOV end

        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if Settings.AutoReloadEnabled and tool then
                local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("Clip") or tool:FindFirstChild("CurrentAmmo")
                if ammo and ammo.Value <= 0 then
                    local reloadRemote = tool:FindFirstChild("Reload") or tool:FindFirstChild("ReloadRemote") or tool:FindFirstChildOfClass("RemoteEvent")
                    if reloadRemote and reloadRemote:IsA("RemoteEvent") then reloadRemote:FireServer() end
                end
            end
            if (Settings.WallShotEnabled or Settings.SilentAimEnabled) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("Head") and tool then
                    local remote = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot") or tool:FindFirstChildOfClass("RemoteEvent")
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer(target.Character.Head.Position)
                        if Settings.HitSoundEnabled then
                            task.spawn(function()
                                local sound = Instance.new("Sound", workspace)
                                sound.SoundId = "rbxassetid://9069176046" sound.Volume = 1 sound:Play()
                                task.wait(1) sound:Destroy()
                            end)
                        end
                        if Settings.KillSayEnabled and target.Character.Humanoid.Health <= 15 then
                            local msg = "NEXUS | " .. TelegramLink
                            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                                TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
                            else
                                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                            end
                        end
                    end
                end
            end
        end
    end)

    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        LocalPlayer.CameraMaxZoomDistance = Settings.ThirdPersonEnabled and 15 or 400
        LocalPlayer.CameraMinZoomDistance = Settings.ThirdPersonEnabled and 15 or 0.5
        if Settings.ThirdPersonEnabled then LocalPlayer.CameraMode = Enum.CameraMode.Classic end
        if Settings.SpinBotEnabled then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(50), 0) end
    end)

    local flyConnection
    local function toggleFly(state)
        if state then
            flyConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp, cam = char.HumanoidRootPart, workspace.CurrentCamera
                local moveDir = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                hrp.Velocity = moveDir * 50 + Vector3.new(0, 2, 0)
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
        end
    end

    local function setupPlayerVisuals(player)
        if player == LocalPlayer then return end
        local tracer = Drawing.new("Line")
        tracer.Visible = false tracer.Color = Color3.fromRGB(255, 255, 255) tracer.Thickness = 1.5 tracer.Transparency = 0.7
        TracersList[player] = tracer

        local function update(char)
            task.wait(0.4)
            local hl = char:FindFirstChild("NEXUS_ESP") or Instance.new("Highlight", char)
            hl.Name = "NEXUS_ESP" hl.FillColor = Color3.fromRGB(200, 200, 200) hl.OutlineColor = Color3.fromRGB(255, 255, 255) hl.FillTransparency = 0.4 hl.Enabled = Settings.ESPEnabled
            local head = char:FindFirstChild("Head")
            if head and not head:FindFirstChild("NEXUS_Info") then
                local billboard = Instance.new("BillboardGui", head)
                billboard.Name = "NEXUS_Info" billboard.Size = UDim2.new(0, 100, 0, 40) billboard.StudsOffset = Vector3.new(0, 2.5, 0) billboard.AlwaysOnTop = true
                local textLabel = Instance.new("TextLabel", billboard)
                textLabel.Name = "InfoText" textLabel.Size = UDim2.new(1, 0, 1, 0) textLabel.BackgroundTransparency = 1 textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) textLabel.TextSize = 12 textLabel.Font = Enum.Font.GothamBold
            end
        end
        if player.Character then update(player.Character) end
        player.CharacterAdded:Connect(update)
    end
    for _, p in ipairs(Players:GetPlayers()) do setupPlayerVisuals(p) end
    Players.PlayerAdded:Connect(setupPlayerVisuals)

    RunService.RenderStepped:Connect(function()
        for player, tracer in pairs(TracersList) do
            local char = player.Character
            local head, hum = char and char:FindFirstChild("Head"), char and char:FindFirstChildOfClass("Humanoid")
            local hl, info = char and char:FindFirstChild("NEXUS_ESP"), head and head:FindFirstChild("NEXUS_Info")
            if hl then hl.Enabled = Settings.ESPEnabled end
            if info then info.Enabled = Settings.ESPInfoEnabled end
            if hum and info and info:FindFirstChild("InfoText") then info:FindFirstChild("InfoText").Text = player.Name .. "\nHP: " .. math.floor(hum.Health) end
            if Settings.TracersEnabled and head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen or Settings.WallShotEnabled or Settings.SilentAimEnabled then
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    tracer.Visible = true
                else tracer.Visible = false end
            else tracer.Visible = false end
        end
    end)

    RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and Settings.GodModeEnabled then humanoid.Health = humanoid.MaxHealth end
        if Settings.NoclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                head.Size = Settings.HitboxEnabled and Vector3.new(3.5, 3.5, 3.5) or Vector3.new(2, 1, 1)
                head.Transparency = Settings.HitboxEnabled and 0.5 or 0
                head.CanCollide = not Settings.HitboxEnabled
            end
        end
    end)

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    if PlayerGui:FindFirstChild("NEXUS_TabMenu") then PlayerGui.NEXUS_TabMenu:Destroy() end

    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = "NEXUS_TabMenu"
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 560, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true MainFrame.Draggable = true

    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 560, 0, 420), Position = UDim2.new(0.5, -280, 0.5, -210)
    }):Play()

    BlurEffect.Enabled = true
    TweenService:Create(BlurEffect, TweenInfo.new(0.4), {Size = 16}):Play()

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Color3.fromRGB(240, 240, 240) UIStroke.Thickness = 1.5

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 40) TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(0, 200, 1, 0) Title.Position = UDim2.new(0.03, 0, 0, 0) Title.Text = "NEXUS" Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.TextSize = 14 Title.Font = Enum.Font.GothamBold Title.BackgroundTransparency = 1 Title.TextXAlignment = Enum.TextXAlignment.Left

    local Author = Instance.new("TextLabel", TopBar)
    Author.Size = UDim2.new(0, 250, 1, 0) Author.Position = UDim2.new(0.52, 0, 0, 0) Author.Text = TelegramLink Author.TextColor3 = Color3.fromRGB(150, 150, 160) Author.TextSize = 10 Author.Font = Enum.Font.GothamMedium Author.BackgroundTransparency = 1 Author.TextXAlignment = Enum.TextXAlignment.Right

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 130, 1, -45) Sidebar.Position = UDim2.new(0, 0, 0, 45) Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20) Sidebar.BorderSizePixel = 0
    local SidebarList = Instance.new("UIListLayout", Sidebar) SidebarList.SortOrder = Enum.SortOrder.LayoutOrder SidebarList.Padding = UDim.new(0, 5)

    local ContainerHolder = Instance.new("Frame", MainFrame)
    ContainerHolder.Size = UDim2.new(1, -135, 1, -50) ContainerHolder.Position = UDim2.new(0, 135, 0, 48) ContainerHolder.BackgroundTransparency = 1 ContainerHolder.ClipsDescendants = true
    local TabButtons = {}

    local function createTab(name)
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(1, -10, 0, 38) tabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30) tabBtn.TextColor3 = Color3.fromRGB(160, 160, 175) tabBtn.TextSize = 13 tabBtn.Font = Enum.Font.GothamBold tabBtn.Text = name
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        local page = Instance.new("ScrollingFrame", ContainerHolder)
        page.Size = UDim2.new(1, 0, 1, 0) page.BackgroundTransparency = 1 page.Visible = false page.CanvasSize = UDim2.new(0, 0, 0, 550) page.ScrollBarThickness = 4
        local pageLayout = Instance.new("UIListLayout", page) pageLayout.SortOrder = Enum.SortOrder.LayoutOrder pageLayout.Padding = UDim.new(0, 6)
        table.insert(TabButtons, {Btn = tabBtn, Page = page})
        return page
    end

    local CombatPage = createTab("Combat")
    local VisualsPage = createTab("Visuals")
    local MovementPage = createTab("Movement")
    local MiscPage = createTab("Misc")
    local SettingsPage = createTab("Settings")

    local function selectTab(targetPage)
        for _, item in ipairs(TabButtons) do
            if item.Page == targetPage then
                item.Page.Visible = true item.Page.Position = UDim2.new(0, 0, 0, 15)
                TweenService:Create(item.Page, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
                item.Btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240) item.Btn.TextColor3 = Color3.fromRGB(12, 12, 16)
            else
                item.Page.Visible = false item.Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30) item.Btn.TextColor3 = Color3.fromRGB(160, 160, 175)
            end
        end
    end
    selectTab(CombatPage)
    for _, item in ipairs(TabButtons) do item.Btn.MouseButton1Click:Connect(function() selectTab(item.Page) end) end

    local function createToggle(parentPage, name, settingKey)
        local btn = Instance.new("TextButton", parentPage)
        btn.Size = UDim2.new(1, -10, 0, 36) btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28) btn.TextColor3 = Color3.fromRGB(230, 230, 240) btn.TextSize = 12 btn.Font = Enum.Font.GothamSemibold btn.TextXAlignment = Enum.TextXAlignment.Left btn.Text = "  " .. name
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local indicator = Instance.new("Frame", btn)
        indicator.Size = UDim2.new(0, 14, 0, 14) indicator.Position = UDim2.new(0.9, 0, 0.5, -7) indicator.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 75)
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
        btn.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 75)}):Play()
            if settingKey == "FlyEnabled" then toggleFly(Settings[settingKey])
            elseif settingKey == "FOVChanger" and not Settings[settingKey] then Camera.FieldOfView = 70 end
            saveConfig()
        end)
    end

    local function createButton(parentPage, name, callback)
        local btn = Instance.new("TextButton", parentPage)
        btn.Size = UDim2.new(1, -10, 0, 36) btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40) btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.TextSize = 12 btn.Font = Enum.Font.GothamBold btn.Text = name
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(callback)
    end

    createToggle(CombatPage, "Aimbot", "AimbotEnabled")
    createToggle(CombatPage, "Silent Aim", "SilentAimEnabled")
    createToggle(CombatPage, "WallShot", "WallShotEnabled")
    createToggle(CombatPage, "Auto-Reload", "AutoReloadEnabled")
    createToggle(CombatPage, "Hit Sound", "HitSoundEnabled")
    createToggle(CombatPage, "KillSay", "KillSayEnabled")
    createToggle(CombatPage, "Hitbox Extender", "HitboxEnabled")
    createToggle(CombatPage, "SpinBot", "SpinBotEnabled")

    createToggle(VisualsPage, "ESP Highlight", "ESPEnabled")
    createToggle(VisualsPage, "ESP Info", "ESPInfoEnabled")
    createToggle(VisualsPage, "Tracers", "TracersEnabled")
    createToggle(VisualsPage, "Custom Crosshair", "CustomCrosshair")
    createToggle(VisualsPage, "FOV Circle", "FOVCircle")
    createToggle(VisualsPage, "FOV Changer", "FOVChanger")

    createToggle(MovementPage, "Fly Mode", "FlyEnabled")
    createToggle(MovementPage, "Noclip", "NoclipEnabled")
    createToggle(MovementPage, "ThirdPerson", "ThirdPersonEnabled")

    createToggle(MiscPage, "GodMode", "GodModeEnabled")
    createToggle(MiscPage, "WallCheck", "WallCheck")
    createToggle(MiscPage, "Anti-AFK", "AntiAFKEnabled")
    createToggle(MiscPage, "Anti-Kick", "AntiKickEnabled")

    createButton(SettingsPage, "Save Config", function() saveConfig() end)
    createButton(SettingsPage, "Load Config", function() loadConfig() end)
    createButton(SettingsPage, "Open Telegram", function() if setclipboard then setclipboard(TelegramLink) end end)

    local menuVisible = true
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            menuVisible = not menuVisible
            if menuVisible then
                MainFrame.Visible = true BlurEffect.Enabled = true
                TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 16}):Play()
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 560, 0, 420), Position = UDim2.new(0.5, -280, 0.5, -210)
                }):Play()
            else
                TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
                local tw = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)
                })
                tw:Play()
                tw.Completed:Connect(function()
                    if not menuVisible then MainFrame.Visible = false BlurEffect.Enabled = false end
                end)
            end
        end
    end)
end

local KeyGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
KeyGui.Name = "NEXUS_KeySystem"
KeyGui.ResetOnSpawn = false

local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.new(0, 340, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -170, 0.5, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)

local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Color = Color3.fromRGB(240, 240, 240)
KeyStroke.Thickness = 1.5

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "NEXUS | Key System"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 15
KeyTitle.Font = Enum.Font.GothamBold

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(0.85, 0, 0, 36)
KeyBox.Position = UDim2.new(0.075, 0, 0, 50)
KeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "Paste key here..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.GothamMedium
KeyBox.TextSize = 12
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)

local CheckBtn = Instance.new("TextButton", KeyFrame)
CheckBtn.Size = UDim2.new(0.85, 0, 0, 36)
CheckBtn.Position = UDim2.new(0.075, 0, 0, 95)
CheckBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
CheckBtn.TextColor3 = Color3.fromRGB(12, 12, 16)
CheckBtn.Text = "Check Key"
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 13
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 6)

local GetKeyBtn = Instance.new("TextButton", KeyFrame)
GetKeyBtn.Size = UDim2.new(0.85, 0, 0, 30)
GetKeyBtn.Position = UDim2.new(0.075, 0, 0, 140)
GetKeyBtn.BackgroundTransparency = 1
GetKeyBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
GetKeyBtn.Text = "Get Key (Copy GitHub Link)"
GetKeyBtn.Font = Enum.Font.GothamMedium
GetKeyBtn.TextSize = 11

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KeyRawURL)
        GetKeyBtn.Text = "Copied GitHub Key Link!"
        task.wait(2)
        GetKeyBtn.Text = "Get Key (Copy GitHub Link)"
    end
end)

CheckBtn.MouseButton1Click:Connect(function()
    CheckBtn.Text = "Checking..."
    local success, currentKey = pcall(function()
        return game:HttpGet(KeyRawURL)
    end)
    
    if success and currentKey then
        currentKey = currentKey:gsub("%s+", "")
        local userKey = KeyBox.Text:gsub("%s+", "")
        
        if userKey == currentKey and userKey ~= "" then
            KeyGui:Destroy()
            startScript()
        else
            CheckBtn.Text = "Invalid Key!"
            KeyBox.Text = ""
            task.wait(1.5)
            CheckBtn.Text = "Check Key"
        end
    else
        CheckBtn.Text = "Connection Error!"
        task.wait(1.5)
        CheckBtn.Text = "Check Key"
    end
end)
