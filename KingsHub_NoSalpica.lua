--[[
    KingsHub — NO SALPICA (Don't Splash)
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
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local ScriptName = "KingsHub"
local minimizeUI = Enum.KeyCode.RightAlt
local DiscordInvite = "https://discord.gg/EQM2KZZKTC"

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "KingsHub",
    SubTitle = "NO SALPICA — thiagxjzu3",
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

-- state
local WalkOnWater = false
local AntiDrown = false
local AntiSplash = false
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
local FullBright = false
local NoFog = false
local AntiAfk = true
local AutoWin = false
local AutoWinConn = nil
local AutoWinSpeed = 40

local noclipConn, flyConn, waterConn, espFolder, fogConn, brightConn, afkConn, infJumpConn

local function clearEsp()
    if espFolder then
        pcall(function() espFolder:Destroy() end)
        espFolder = nil
    end
end

local function ensureEspFolder()
    if espFolder and espFolder.Parent then return espFolder end
    local parent = gethui and gethui() or CoreGui
    local f = Instance.new("Folder")
    f.Name = "KingsHub_ESP"
    f.Parent = parent
    espFolder = f
    return f
end

local function addHighlight(model, color)
    if not model or model:FindFirstChild("KH_HL") then return end
    local h = Instance.new("Highlight")
    h.Name = "KH_HL"
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.55
    h.OutlineTransparency = 0.2
    h.Adornee = model
    h.Parent = model
end

local function refreshEsp()
    if not ESPPlayers and not ESPMonster then
        clearEsp()
        return
    end
    ensureEspFolder()
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
                if not Players:GetPlayerFromCharacter(obj) then
                    local n = string.lower(obj.Name)
                    if n:find("monster") or n:find("boss") or n:find("enemy")
                        or n:find("creature") or n:find("killer") or n:find("demon")
                        or n:find("entity") or n:find("npc") then
                        addHighlight(obj, Color3.fromRGB(255, 60, 60))
                    end
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

local function isWaterPart(part)
    if not part or not part:IsA("BasePart") then return false end
    local n = string.lower(part.Name)
    if n:find("water") or n:find("pool") or n:find("ocean") or n:find("sea") or n:find("splash") then
        return true
    end
    if part.Material == Enum.Material.Water then return true end
    return false
end

local function applyWalkOnWater()
    if waterConn then waterConn:Disconnect() waterConn = nil end
    if not WalkOnWater and not AntiDrown and not AntiSplash then return end
    waterConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end

        if AntiDrown then
            if hum.Health < hum.MaxHealth * 0.15 or hum:GetState() == Enum.HumanoidStateType.Swimming then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 40, hrp.AssemblyLinearVelocity.Z)
                end)
            end
        end

        if WalkOnWater or AntiSplash then
            local origin = hrp.Position
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = { getChar() }
            local hit = workspace:Raycast(origin, Vector3.new(0, -8, 0), rayParams)
            if hit and isWaterPart(hit.Instance) then
                if WalkOnWater then
                    local y = hit.Position.Y + 2.2
                    if hrp.Position.Y < y then
                        hrp.CFrame = CFrame.new(hrp.Position.X, y, hrp.Position.Z)
                        local v = hrp.AssemblyLinearVelocity
                        hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
                    end
                end
                if AntiSplash then
                    pcall(function()
                        for _, p in ipairs(getChar():GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanTouch = false
                            end
                        end
                    end)
                end
            elseif AntiSplash and getChar() then
                pcall(function()
                    for _, p in ipairs(getChar():GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanTouch = true
                        end
                    end
                end)
            end
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


local function findWinTargets()
    local targets = {}
    local keywords = {
        "finish", "win", "end", "goal", "checkpoint", "trophy",
        "meta", "salida", "llegada", "final", "safe", "spawnend",
        "door", "exit", "complete",
    }
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = string.lower(obj.Name)
            for _, k in ipairs(keywords) do
                if n:find(k, 1, true) then
                    local pos
                    if obj:IsA("Model") then
                        pos = obj:GetPivot().Position
                    else
                        pos = obj.Position
                    end
                    table.insert(targets, { inst = obj, pos = pos, name = obj.Name })
                    break
                end
            end
        end
    end
    -- prefer farthest from origin / highest score by distance from player
    local hrp = getHRP()
    if hrp and #targets > 0 then
        table.sort(targets, function(a, b)
            return (a.pos - hrp.Position).Magnitude > (b.pos - hrp.Position).Magnitude
        end)
    end
    return targets
end

local function tweenTo(pos, speed)
    local hrp = getHRP()
    if not hrp then return false end
    local dist = (pos - hrp.Position).Magnitude
    if dist < 3 then return true end
    local t = math.clamp(dist / math.max(speed, 10), 0.15, 4)
    local ok = pcall(function()
        local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)),
        })
        tw:Play()
        tw.Completed:Wait()
    end)
    return ok
end

local function autoWinStep()
    if not AutoWin then return end
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum or hum.Health <= 0 then return end

    -- keep helpers on while farming
    if not WalkOnWater then
        WalkOnWater = true
        applyWalkOnWater()
    end

    local targets = findWinTargets()
    if #targets == 0 then
        -- fallback: keep moving forward + up slightly
        local look = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.LookVector or Vector3.new(0, 0, -1)
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.1 then flat = flat.Unit else flat = Vector3.new(0, 0, -1) end
        hrp.CFrame = hrp.CFrame + flat * 6 + Vector3.new(0, 1, 0)
        return
    end

    -- go to nearest checkpoint ahead, else farthest "finish"
    local best = targets[1]
    local minD = math.huge
    for _, t in ipairs(targets) do
        local d = (t.pos - hrp.Position).Magnitude
        local n = string.lower(t.name)
        if d > 8 and d < minD and (n:find("check") or n:find("finish") or n:find("win") or n:find("end") or n:find("goal")) then
            minD = d
            best = t
        end
    end
    if best then
        tweenTo(best.pos, AutoWinSpeed)
    end
end

local function setAutoWin(on)
    AutoWin = on
    if AutoWinConn then
        task.cancel(AutoWinConn)
        AutoWinConn = nil
    end
    if on then
        AutoWinConn = task.spawn(function()
            notify("Auto Win ON", 3)
            while AutoWin do
                pcall(autoWinStep)
                task.wait(0.35)
            end
        end)
    else
        notify("Auto Win OFF", 3)
    end
end

-- MAIN
Tabs.Main:AddParagraph({
    Title = "NO SALPICA",
    Content = "Anti splash / water helpers. Creator: thiagxjzu3",
})

Tabs.Main:AddSection("Water")

local t1 = Tabs.Main:AddToggle("WalkOnWater", { Title = "Walk on Water", Default = false })
t1:OnChanged(function()
    WalkOnWater = t1.Value
    applyWalkOnWater()
    notify("Walk on Water " .. (WalkOnWater and "ON" or "OFF"), 3)
end)

local t2 = Tabs.Main:AddToggle("AntiDrown", { Title = "Anti Drown", Default = false })
t2:OnChanged(function()
    AntiDrown = t2.Value
    applyWalkOnWater()
    notify("Anti Drown " .. (AntiDrown and "ON" or "OFF"), 3)
end)

local t3 = Tabs.Main:AddToggle("AntiSplash", {
    Title = "Anti Splash (No Touch Water)",
    Description = "Tries to stop water touch events",
    Default = false,
})
t3:OnChanged(function()
    AntiSplash = t3.Value
    applyWalkOnWater()
    notify("Anti Splash " .. (AntiSplash and "ON" or "OFF"), 3)
end)

Tabs.Main:AddSection("Quick")

Tabs.Main:AddButton({
    Title = "TP Up (Safe)",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 25, 0)
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

Tabs.Main:AddSection("Auto Farm")

local aw = Tabs.Main:AddToggle("AutoWin", {
    Title = "Auto Farm Win",
    Description = "Paths to finish / checkpoints (Moondiety-style)",
    Default = false,
})
aw:OnChanged(function()
    setAutoWin(aw.Value)
end)

Tabs.Main:AddSlider("AutoWinSpeed", {
    Title = "Auto Win Speed",
    Default = 40,
    Min = 15,
    Max = 80,
    Rounding = 0,
    Callback = function(v) AutoWinSpeed = v end,
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

local em = Tabs.Visuals:AddToggle("ESPMonster", { Title = "Monster / NPC ESP", Default = false })
em:OnChanged(function()
    ESPMonster = em.Value
    if not ESPPlayers and not ESPMonster then clearEsp() else refreshEsp() end
end)

Tabs.Visuals:AddSection("World")

local fb = Tabs.Visuals:AddToggle("FullBright", { Title = "Full Bright", Default = false })
fb:OnChanged(function()
    FullBright = fb.Value
    if brightConn then brightConn:Disconnect() brightConn = nil end
    if FullBright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 6
        Lighting.GlobalShadows = false
        brightConn = RunService.Heartbeat:Connect(function()
            if not FullBright then return end
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 6
        end)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

local nf = Tabs.Visuals:AddToggle("NoFog", { Title = "No Fog", Default = false })
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
        notify("Server hop requested", 3)
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
    Content = "NO SALPICA / Don't Splash\nCreator: thiagxjzu3",
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("KingsHub")
SaveManager:SetFolder("KingsHub/NoSalpica")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({ Title = "KingsHub", Content = "NO SALPICA loaded", Duration = 5 })
SaveManager:LoadAutoloadConfig()

RunService.Heartbeat:Connect(function()
    if SpeedOn or JumpOn then pcall(applySpeedJump) end
    if ESPPlayers or ESPMonster then
        if tick() % 1 < 0.05 then pcall(refreshEsp) end
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
    applyWalkOnWater()
end)

-- minimize button
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

print("[KingsHub] NO SALPICA loaded — thiagxjzu3")
