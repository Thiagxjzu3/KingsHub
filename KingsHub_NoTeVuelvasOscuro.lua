--[[
    KingsHub — No te vuelvas oscuro
    Creator: thiagxjzu3
    UI: Fluent
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(0.3)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local ScriptName = "KingsHub"
local DiscordInvite = "https://discord.gg/EQM2KZZKTC"
local minimizeUI = Enum.KeyCode.RightAlt

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "KingsHub",
    SubTitle = "No te vuelvas oscuro — thiagxjzu3",
    TabWidth = 160,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = minimizeUI,
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://121302760641013" }),
    Player = Window:AddTab({ Title = "Player", Icon = "rbxassetid://121302760641013" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "rbxassetid://121302760641013" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "rbxassetid://121302760641013" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://121302760641013" }),
}

local function notify(msg, t)
    Fluent:Notify({ Title = ScriptName, Content = tostring(msg), Duration = t or 4 })
end

local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local FullBright = false
local NoFog = false
local AlwaysLight = false
local Noclip = false
local Fly = false
local FlySpeed = 50
local SpeedOn = false
local SpeedVal = 24
local JumpOn = false
local JumpVal = 60
local InfJump = false
local ESPPlayers = false
local ESPMonster = false
local AntiAfk = true
local AntiDark = false
local BypassDark = false
local darkConn = nil

local noclipConn, flyConn, lightConn, fogConn, brightConn, afkConn, infJumpConn, espFolder
local lightPart

local function clearEsp()
    if espFolder then
        pcall(function() espFolder:Destroy() end)
        espFolder = nil
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("KH_HL")
            if h then h:Destroy() end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("KH_HL") then
            obj.KH_HL:Destroy()
        end
    end
end

local function addHighlight(model, color)
    if not model or model:FindFirstChild("KH_HL") then return end
    local h = Instance.new("Highlight")
    h.Name = "KH_HL"
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.55
    h.OutlineTransparency = 0.15
    h.Adornee = model
    h.Parent = model
end

local function isMonsterName(n)
    n = string.lower(tostring(n or ""))
    return n:find("monster") or n:find("entity") or n:find("killer")
        or n:find("dark") or n:find("shadow") or n:find("boss")
        or n:find("enemy") or n:find("creature") or n:find("demon")
        or n:find("angel") or n:find("wraith") or n:find("npc")
end

local function refreshEsp()
    if not ESPPlayers and not ESPMonster then
        clearEsp()
        return
    end
    if ESPPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                addHighlight(plr.Character, Color3.fromRGB(80, 180, 255))
            end
        end
    end
    if ESPMonster then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                if not Players:GetPlayerFromCharacter(obj) and isMonsterName(obj.Name) then
                    addHighlight(obj, Color3.fromRGB(255, 50, 50))
                end
            end
        end
    end
end

local function setNoclip(on)
    Noclip = on
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            local char = getChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end

local function setFly(on)
    Fly = on
    if flyConn then flyConn:Disconnect() flyConn = nil end
    local hum = getHum()
    if not on then
        if hum then hum.PlatformStand = false end
        return
    end
    flyConn = RunService.RenderStepped:Connect(function()
        if not Fly then return end
        local hrp = getHRP()
        hum = getHum()
        if not hrp or not hum then return end
        hum.PlatformStand = true
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = move.Unit * FlySpeed
        else
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function applySpeedJump()
    local hum = getHum()
    if not hum then return end
    if SpeedOn then hum.WalkSpeed = SpeedVal end
    if JumpOn then
        hum.UseJumpPower = true
        hum.JumpPower = JumpVal
    end
end

local function setAlwaysLight(on)
    AlwaysLight = on
    if lightConn then lightConn:Disconnect() lightConn = nil end
    if lightPart then
        pcall(function() lightPart:Destroy() end)
        lightPart = nil
    end
    if not on then return end
    lightConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP()
        if not hrp then return end
        if not lightPart or not lightPart.Parent then
            lightPart = Instance.new("Part")
            lightPart.Name = "KH_Light"
            lightPart.Size = Vector3.new(1, 1, 1)
            lightPart.Transparency = 1
            lightPart.CanCollide = false
            lightPart.Anchored = true
            lightPart.Parent = workspace
            local pl = Instance.new("PointLight")
            pl.Brightness = 4
            pl.Range = 40
            pl.Color = Color3.fromRGB(255, 255, 240)
            pl.Parent = lightPart
        end
        lightPart.CFrame = hrp.CFrame
        -- also force flashlight-like lights on character
        pcall(function()
            for _, d in ipairs(getChar():GetDescendants()) do
                if d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                    d.Enabled = true
                    if d.Brightness < 2 then d.Brightness = 3 end
                    if d.Range < 20 then d.Range = 30 end
                end
            end
        end)
    end)
end


local function isDarkPart(part)
    if not part or not part:IsA("BasePart") then return false end
    local n = string.lower(part.Name)
    if n:find("dark", 1, true) or n:find("oscuro", 1, true) or n:find("shadow", 1, true)
        or n:find("void", 1, true) or n:find("kill", 1, true) or n:find("danger", 1, true)
        or n:find("water", 1, true) or n:find("lava", 1, true) or n:find("hazard", 1, true) then
        return true
    end
    -- very dark colored large floors often used as death zones
    local c = part.Color
    if (c.R + c.G + c.B) < 0.25 and part.Size.X > 10 and part.Size.Z > 10 then
        return true
    end
    return false
end

local function setCharCanTouch(on)
    local char = getChar()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanTouch = on
        end
    end
end

local function applyAntiDark()
    if darkConn then
        darkConn:Disconnect()
        darkConn = nil
    end
    if not AntiDark and not BypassDark then
        setCharCanTouch(true)
        return
    end
    darkConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP()
        local hum = getHum()
        local char = getChar()
        if not hrp or not hum or not char then return end

        if BypassDark then
            setCharCanTouch(false)
        end

        if AntiDark then
            local origin = hrp.Position
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { char }
            local hit = workspace:Raycast(origin, Vector3.new(0, -12, 0), params)
            if hit and isDarkPart(hit.Instance) then
                local y = hit.Position.Y + 3
                if hrp.Position.Y < y + 1.5 then
                    hrp.CFrame = CFrame.new(hrp.Position.X, y, hrp.Position.Z)
                    local v = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
                end
            end
            -- also stop freefall into void-like y
            if hrp.Position.Y < -50 then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 80, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end

-- MAIN
Tabs.Main:AddParagraph({
    Title = "No te vuelvas oscuro",
    Content = "Light + survival helpers. Creator: thiagxjzu3",
})

Tabs.Main:AddSection("Light")

local fb = Tabs.Main:AddToggle("FullBright", { Title = "Full Bright", Default = false })
fb:OnChanged(function()
    FullBright = fb.Value
    if brightConn then brightConn:Disconnect() brightConn = nil end
    if FullBright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 6
        Lighting.GlobalShadows = false
        brightConn = RunService.Heartbeat:Connect(function()
            if not FullBright then return end
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 6
            Lighting.GlobalShadows = false
        end)
        notify("Full Bright ON", 3)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        notify("Full Bright OFF", 3)
    end
end)

local al = Tabs.Main:AddToggle("AlwaysLight", {
    Title = "Always Light (PointLight)",
    Description = "Light follows you + forces flashlight on",
    Default = false,
})
al:OnChanged(function()
    setAlwaysLight(al.Value)
    notify("Always Light " .. (al.Value and "ON" or "OFF"), 3)
end)

local nf = Tabs.Main:AddToggle("NoFog", { Title = "No Fog", Default = false })
nf:OnChanged(function()
    NoFog = nf.Value
    if fogConn then fogConn:Disconnect() fogConn = nil end
    if NoFog then
        fogConn = RunService.Heartbeat:Connect(function()
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 0
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then atm.Density = 0 atm.Haze = 0 end
        end)
    end
end)

Tabs.Main:AddSection("Anti Dark")

local ad = Tabs.Main:AddToggle("AntiDark", {
    Title = "Anti Fall Dark",
    Description = "Keeps you above dark / kill floors",
    Default = false,
})
ad:OnChanged(function()
    AntiDark = ad.Value
    applyAntiDark()
    notify("Anti Fall Dark " .. (AntiDark and "ON" or "OFF"), 3)
end)

local bd = Tabs.Main:AddToggle("BypassDark", {
    Title = "Bypass Action (No Touch Dark)",
    Description = "CanTouch off so dark zones do not register",
    Default = false,
})
bd:OnChanged(function()
    BypassDark = bd.Value
    applyAntiDark()
    if not BypassDark then setCharCanTouch(true) end
    notify("Bypass Dark " .. (BypassDark and "ON" or "OFF"), 3)
end)

Tabs.Main:AddSection("Quick")

Tabs.Main:AddButton({
    Title = "TP Up (Safe)",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
            notify("TP Up", 2)
        end
    end,
})

Tabs.Main:AddButton({
    Title = "Reset Character",
    Callback = function()
        local hum = getHum()
        if hum then hum.Health = 0 end
    end,
})

-- PLAYER
Tabs.Player:AddSection("Movement")

local nc = Tabs.Player:AddToggle("Noclip", { Title = "Noclip", Default = false })
nc:OnChanged(function() setNoclip(nc.Value) end)

local fl = Tabs.Player:AddToggle("Fly", { Title = "Fly (WASD + Space/Ctrl)", Default = false })
fl:OnChanged(function() setFly(fl.Value) end)

Tabs.Player:AddSlider("FlySpeed", {
    Title = "Fly Speed", Default = 50, Min = 20, Max = 150, Rounding = 0,
    Callback = function(v) FlySpeed = v end,
})

local sp = Tabs.Player:AddToggle("SpeedToggle", { Title = "WalkSpeed", Default = false })
sp:OnChanged(function()
    SpeedOn = sp.Value
    if SpeedOn then applySpeedJump() else local h = getHum() if h then h.WalkSpeed = 16 end end
end)

Tabs.Player:AddSlider("SpeedVal", {
    Title = "Speed", Default = 24, Min = 16, Max = 80, Rounding = 0,
    Callback = function(v) SpeedVal = v if SpeedOn then applySpeedJump() end end,
})

local jp = Tabs.Player:AddToggle("JumpToggle", { Title = "Jump Power", Default = false })
jp:OnChanged(function()
    JumpOn = jp.Value
    if JumpOn then applySpeedJump() end
end)

Tabs.Player:AddSlider("JumpVal", {
    Title = "Jump Power", Default = 60, Min = 50, Max = 150, Rounding = 0,
    Callback = function(v) JumpVal = v if JumpOn then applySpeedJump() end end,
})

local ij = Tabs.Player:AddToggle("InfJump", { Title = "Infinite Jump", Default = false })
ij:OnChanged(function()
    InfJump = ij.Value
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    if InfJump then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = getHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

-- VISUALS
Tabs.Visuals:AddSection("ESP")

local ep = Tabs.Visuals:AddToggle("ESPPlayers", { Title = "Player ESP", Default = false })
ep:OnChanged(function()
    ESPPlayers = ep.Value
    if not ESPPlayers and not ESPMonster then clearEsp() else refreshEsp() end
end)

local em = Tabs.Visuals:AddToggle("ESPMonster", { Title = "Monster / Entity ESP", Default = false })
em:OnChanged(function()
    ESPMonster = em.Value
    if not ESPPlayers and not ESPMonster then clearEsp() else refreshEsp() end
end)

-- MISC
Tabs.Misc:AddSection("Server")

Tabs.Misc:AddButton({
    Title = "Rejoin",
    Callback = function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end,
})

Tabs.Misc:AddButton({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            local Http = game:GetService("HttpService")
            local placeId = game.PlaceId
            local req = game:HttpGet(
                "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=25"
            )
            local data = Http:JSONDecode(req)
            for _, s in ipairs(data.data or {}) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                    return
                end
            end
            notify("No server found", 3)
        end)
    end,
})

local aa = Tabs.Misc:AddToggle("AntiAfk", { Title = "Anti Idle", Default = true })
aa:OnChanged(function()
    AntiAfk = aa.Value
    if afkConn then afkConn:Disconnect() afkConn = nil end
    if AntiAfk then
        afkConn = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
end)

Tabs.Misc:AddButton({
    Title = "Copy Discord",
    Callback = function()
        local ok = pcall(function()
            if setclipboard then setclipboard(DiscordInvite)
            elseif toclipboard then toclipboard(DiscordInvite)
            else error("no") end
        end)
        notify(ok and "Discord copied" or "Clipboard fail", 3)
    end,
})

Tabs.Settings:AddParagraph({
    Title = ScriptName,
    Content = "No te vuelvas oscuro\nCreator: thiagxjzu3",
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("KingsHub")
SaveManager:SetFolder("KingsHub/NoTeVuelvasOscuro")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({ Title = "KingsHub", Content = "No te vuelvas oscuro loaded", Duration = 5 })
SaveManager:LoadAutoloadConfig()

RunService.Heartbeat:Connect(function()
    if SpeedOn or JumpOn then pcall(applySpeedJump) end
    if (ESPPlayers or ESPMonster) and tick() % 1 < 0.05 then
        pcall(refreshEsp)
    end
end)

if AntiAfk then
    afkConn = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.4)
    if Noclip then setNoclip(true) end
    if Fly then setFly(true) end
    if SpeedOn or JumpOn then applySpeedJump() end
    if AlwaysLight then setAlwaysLight(true) end
    if AntiDark or BypassDark then applyAntiDark() end
end)

local old = CoreGui:FindFirstChild("KingsHubMinimizeUI")
if old then old:Destroy() end
local DragUI = Instance.new("ScreenGui")
DragUI.Name = "KingsHubMinimizeUI"
DragUI.ResetOnSpawn = false
DragUI.Parent = CoreGui
local Button = Instance.new("ImageButton")
Button.Parent = DragUI
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Position = UDim2.new(0, 10, 1, -85)
Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Button.BackgroundTransparency = 0.3
Button.BorderSizePixel = 0
Button.Image = "rbxassetid://90508203972003"
Button.ScaleType = Enum.ScaleType.Fit
Button.Active = true
Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)
local dragging, dragStart, startPos, moved
Button.MouseButton1Click:Connect(function()
    if moved then return end
    VirtualInputManager:SendKeyEvent(true, minimizeUI, false, game)
    task.wait(0.08)
    VirtualInputManager:SendKeyEvent(false, minimizeUI, false, game)
end)
Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        moved = false
        dragStart = input.Position
        startPos = Button.Position
    end
end)
Button.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - dragStart
        if d.Magnitude > 10 then moved = true end
        Button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("[KingsHub] No te vuelvas oscuro loaded — thiagxjzu3")
