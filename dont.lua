--[[
    KingsHub — No te vuelvas oscuro
    Creator: thiagxjzu3
    UI: Obsidian
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

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local ScriptName = "KingsHub"
local DiscordInvite = "https://discord.gg/EQM2KZZKTC"

local function safeLoad(url)
    local ok, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(src) ~= "string" then return nil end
    local fn = (loadstring or load)(src)
    if not fn then return nil end
    local ok2, res = pcall(fn)
    if ok2 then return res end
    return nil
end

local Library = safeLoad("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua")
if not Library then
    warn("[KingsHub] Obsidian failed to load")
    return
end
local ThemeManager = safeLoad("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua")
local SaveManager = safeLoad("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua")

Library.ForceCheckbox = false
pcall(function() Library:SetNotifySide("Left") end)

local function notify(msg, t)
    pcall(function()
        Library:Notify({ Title = ScriptName, Description = tostring(msg), Time = t or 4 })
    end)
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
local AntiDark = false
local BypassDark = false
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

local noclipConn, flyConn, lightConn, fogConn, brightConn, afkConn, infJumpConn, darkConn
local lightPart

local function clearEsp()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("KH_HL")
            if h then h:Destroy() end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local h = obj:FindFirstChild("KH_HL")
            if h then h:Destroy() end
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
        pcall(function()
            local char = getChar()
            if not char then return end
            for _, d in ipairs(char:GetDescendants()) do
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
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { char }
            local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -12, 0), params)
            if hit and isDarkPart(hit.Instance) then
                local y = hit.Position.Y + 3
                if hrp.Position.Y < y + 1.5 then
                    hrp.CFrame = CFrame.new(hrp.Position.X, y, hrp.Position.Z)
                    local v = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
                end
            end
            if hrp.Position.Y < -50 then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 80, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end

local Window = Library:CreateWindow({
    Title = ScriptName,
    Footer = "No te vuelvas oscuro — thiagxjzu3",
    NotifySide = "Left",
    ShowCustomCursor = false,
})

local TabsUI = {
    Main = Window:AddTab("Main", "home"),
    Player = Window:AddTab("Player", "user"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Misc = Window:AddTab("Misc", "settings"),
}

local MainLeft = TabsUI.Main:AddLeftGroupbox("Light")
local MainRight = TabsUI.Main:AddRightGroupbox("Anti Dark")

MainLeft:AddToggle("FullBright", {
    Text = "Full Bright",
    Default = false,
    Callback = function(v)
        FullBright = v
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
    end,
})

MainLeft:AddToggle("AlwaysLight", {
    Text = "Always Light",
    Default = false,
    Callback = function(v)
        setAlwaysLight(v)
        notify("Always Light " .. (v and "ON" or "OFF"), 3)
    end,
})

MainLeft:AddToggle("NoFog", {
    Text = "No Fog",
    Default = false,
    Callback = function(v)
        NoFog = v
        if fogConn then fogConn:Disconnect() fogConn = nil end
        if NoFog then
            fogConn = RunService.Heartbeat:Connect(function()
                Lighting.FogEnd = 1e6
                Lighting.FogStart = 0
                local atm = Lighting:FindFirstChildOfClass("Atmosphere")
                if atm then atm.Density = 0 atm.Haze = 0 end
            end)
        end
    end,
})

MainLeft:AddButton("TP Up", function()
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
        notify("TP Up", 2)
    end
end)

MainLeft:AddButton("Reset Character", function()
    local hum = getHum()
    if hum then hum.Health = 0 end
end)

MainRight:AddToggle("AntiDark", {
    Text = "Anti Fall Dark",
    Default = false,
    Callback = function(v)
        AntiDark = v
        applyAntiDark()
        notify("Anti Fall Dark " .. (v and "ON" or "OFF"), 3)
    end,
})

MainRight:AddToggle("BypassDark", {
    Text = "Bypass Action (No Touch Dark)",
    Default = false,
    Callback = function(v)
        BypassDark = v
        applyAntiDark()
        if not BypassDark then setCharCanTouch(true) end
        notify("Bypass Dark " .. (v and "ON" or "OFF"), 3)
    end,
})

local PlayerLeft = TabsUI.Player:AddLeftGroupbox("Movement")
local PlayerRight = TabsUI.Player:AddRightGroupbox("Stats")

PlayerLeft:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(v) setNoclip(v) end,
})

PlayerLeft:AddToggle("Fly", {
    Text = "Fly (WASD + Space/Ctrl)",
    Default = false,
    Callback = function(v) setFly(v) end,
})

PlayerLeft:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 20,
    Max = 150,
    Rounding = 0,
    Callback = function(v) FlySpeed = v end,
})

PlayerLeft:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(v)
        InfJump = v
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
        if InfJump then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = getHum()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end,
})

PlayerRight:AddToggle("SpeedToggle", {
    Text = "WalkSpeed",
    Default = false,
    Callback = function(v)
        SpeedOn = v
        if SpeedOn then
            applySpeedJump()
        else
            local h = getHum()
            if h then h.WalkSpeed = 16 end
        end
    end,
})

PlayerRight:AddSlider("SpeedVal", {
    Text = "Speed",
    Default = 24,
    Min = 16,
    Max = 80,
    Rounding = 0,
    Callback = function(v)
        SpeedVal = v
        if SpeedOn then applySpeedJump() end
    end,
})

PlayerRight:AddToggle("JumpToggle", {
    Text = "Jump Power",
    Default = false,
    Callback = function(v)
        JumpOn = v
        if JumpOn then applySpeedJump() end
    end,
})

PlayerRight:AddSlider("JumpVal", {
    Text = "Jump Power",
    Default = 60,
    Min = 50,
    Max = 150,
    Rounding = 0,
    Callback = function(v)
        JumpVal = v
        if JumpOn then applySpeedJump() end
    end,
})

local VisLeft = TabsUI.Visuals:AddLeftGroupbox("ESP")

VisLeft:AddToggle("ESPPlayers", {
    Text = "Player ESP",
    Default = false,
    Callback = function(v)
        ESPPlayers = v
        if not ESPPlayers and not ESPMonster then clearEsp() else refreshEsp() end
    end,
})

VisLeft:AddToggle("ESPMonster", {
    Text = "Monster / Entity ESP",
    Default = false,
    Callback = function(v)
        ESPMonster = v
        if not ESPPlayers and not ESPMonster then clearEsp() else refreshEsp() end
    end,
})

local MiscLeft = TabsUI.Misc:AddLeftGroupbox("Server")
local MiscRight = TabsUI.Misc:AddRightGroupbox("Info")

MiscLeft:AddButton("Rejoin", function()
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end)

MiscLeft:AddButton("Server Hop", function()
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
end)

MiscLeft:AddToggle("AntiAfk", {
    Text = "Anti Idle",
    Default = true,
    Callback = function(v)
        AntiAfk = v
        if afkConn then afkConn:Disconnect() afkConn = nil end
        if AntiAfk then
            afkConn = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
        end
    end,
})

MiscRight:AddButton("Copy Discord", function()
    local ok = pcall(function()
        if setclipboard then setclipboard(DiscordInvite)
        elseif toclipboard then toclipboard(DiscordInvite)
        else error("no") end
    end)
    notify(ok and "Discord copied" or "Clipboard fail", 3)
end)

MiscRight:AddLabel("Creator: thiagxjzu3")

if ThemeManager and SaveManager then
    pcall(function()
        ThemeManager:SetLibrary(Library)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        ThemeManager:SetFolder("KingsHub")
        SaveManager:SetFolder("KingsHub/NoTeVuelvasOscuro")
        SaveManager:BuildConfigSection(TabsUI.Misc)
        ThemeManager:ApplyToTab(TabsUI.Misc)
    end)
end

notify("No te vuelvas oscuro loaded", 5)

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

print("[KingsHub] No te vuelvas oscuro (Obsidian) loaded — thiagxjzu3")
