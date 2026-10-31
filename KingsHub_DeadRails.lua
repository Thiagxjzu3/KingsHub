--[[
    KingsHub — Dead Rails
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
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local ScriptName = "KingsHub"
local ScriptVersion = "1.0"
local DiscordInvite = "https://discord.gg/EQM2KZZKTC"
local HUTAO_BASE = "https://raw.githubusercontent.com/Shade-vex/Hutao-hub-code-pro-mode/refs/heads/main/"
local minimizeUI = Enum.KeyCode.RightAlt

local function safeHttpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(res) == "string" and #res > 20 then
        return res
    end
    return nil
end

local function safeLoad(url)
    local src = safeHttpGet(url)
    if not src then return nil end
    local fn = (loadstring or load)(src)
    if not fn then return nil end
    local ok, res = pcall(fn)
    if ok then return res end
    return nil
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "KingsHub",
    SubTitle = "Dead Rails — thiagxjzu3",
    TabWidth = 160,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = minimizeUI,
})

local Tabs = {
    FarT = Window:AddTab({ Title = "Farm", Icon = "rbxassetid://121302760641013" }),
    Ma = Window:AddTab({ Title = "Main", Icon = "rbxassetid://121302760641013" }),
    Ite = Window:AddTab({ Title = "Items", Icon = "rbxassetid://121302760641013" }),
    TpT = Window:AddTab({ Title = "Teleport", Icon = "rbxassetid://121302760641013" }),
    Player = Window:AddTab({ Title = "Player", Icon = "rbxassetid://121302760641013" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "rbxassetid://121302760641013" }),
    Settings = Window:AddTab({ Title = "Setting", Icon = "rbxassetid://121302760641013" }),
}

local function notify(content, duration)
    Fluent:Notify({
        Title = ScriptName,
        Content = tostring(content),
        Duration = duration or 4,
    })
end

local Config, Utilities, ESP, Aimbot
pcall(function()
    Config = safeLoad(HUTAO_BASE .. "Config.lua.txt")
    Utilities = safeLoad(HUTAO_BASE .. "Util.lua.txt")
    if Config and Utilities then
        local espFactory = safeLoad(HUTAO_BASE .. "ESP.lua.txt")
        if type(espFactory) == "function" then
            ESP = espFactory(Config, Utilities)
        end
        Aimbot = safeLoad(HUTAO_BASE .. "Aimbot.lua.txt")
    end
end)

local HitboxEnabled = false
local HitboxSize = 15
local HitboxTransparency = 0.85
local HitboxColor = Color3.fromRGB(255, 0, 0)
local originalHitbox = {}
local NoclipEnabled = false
local NoclipConn = nil
local FlyEnabled = false
local FlySpeed = 50
local FlyConn = nil
local WalkSpeedEnabled = false
local WalkSpeedValue = 20
local JumpEnabled = false
local JumpValue = 50
local GunKillAura = false
local GunAuraRange = 80
local MeleeAura = false
local MeleeRange = 25
local AutoHeal = false
local HealThreshold = 50
local ReloadBypass = false
local FireBypass = false
local SkipHold = false
local BandageBypass = false
local NoFog = false
local FullBrightNight = false
local AntiAfk = true
local fogConn, brightConn, afkConn, holdConn
local originalReload, originalFire = {}, {}

local targetNPCs = {
    Vampire = true, Werewolf = true, Wolf = true, Runner = true, Walker = true,
    Banner = true, ["Nikola Tesla"] = true, ["Lab Zombie"] = true,
    ["Captain Prescott"] = true, ["Zombie Soldier"] = true, Banker = true,
    Outlaw = true, RifleOutlaw = true, ShotgunOutlaw = true, RevolverOutlaw = true,
    TurretOutlaw = true, ["Scientist Zombies"] = true, Scientist = true,
    Soldier = true, ZombieMiner = true, SkeletonMiner = true,
}

local teleportLocations = {
    ["Start"] = Vector3.new(0, 5, 0),
    ["Castle"] = Vector3.new(-300, 10, 0),
    ["Fort"] = Vector3.new(400, 10, 0),
    ["Town"] = Vector3.new(200, 10, 100),
    ["End"] = Vector3.new(1000, 10, 0),
}

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

local function isNPC(model)
    if not model or not model:IsA("Model") then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    return true
end

local function fireClass(name)
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Shared", 5)
            :WaitForChild("RemotePromise", 5)
            :WaitForChild("Remotes", 5)
        remotes:WaitForChild("C_BuyClass"):FireServer(name)
        task.wait(0.8)
        remotes:WaitForChild("C_EquipClass"):FireServer(name)
    end)
end

local function applyHitbox(npc)
    if not isNPC(npc) then return end
    for _, partName in ipairs({ "HumanoidRootPart", "Head" }) do
        local part = npc:FindFirstChild(partName)
        local hum = npc:FindFirstChildOfClass("Humanoid")
        if part and hum and hum.Health > 0 then
            originalHitbox[npc] = originalHitbox[npc] or {}
            if not originalHitbox[npc][partName] then
                originalHitbox[npc][partName] = {
                    Size = part.Size,
                    Transparency = part.Transparency,
                    CanCollide = part.CanCollide,
                }
            end
            part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
            part.Transparency = HitboxTransparency
            part.Color = HitboxColor
            part.CanCollide = false
            part.Massless = true
        end
    end
end

local function restoreHitboxes()
    for npc, parts in pairs(originalHitbox) do
        if npc and npc.Parent then
            for name, props in pairs(parts) do
                local p = npc:FindFirstChild(name)
                if p then
                    pcall(function()
                        p.Size = props.Size
                        p.Transparency = props.Transparency
                        p.CanCollide = props.CanCollide
                    end)
                end
            end
        end
    end
    originalHitbox = {}
end

local function hitboxLoop()
    while HitboxEnabled do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and isNPC(obj) then
                pcall(applyHitbox, obj)
            end
        end
        task.wait(0.35)
    end
end

local function gunAuraTick()
    if not GunKillAura then return end
    local char = getChar()
    local hrp = getHRP()
    if not char or not hrp then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, npc in ipairs(workspace:GetDescendants()) do
        if isNPC(npc) then
            local root = npc:FindFirstChild("HumanoidRootPart")
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                if (root.Position - hrp.Position).Magnitude <= GunAuraRange then
                    pcall(function()
                        local shoot = tool:FindFirstChild("Shoot") or tool:FindFirstChild("Fire") or tool:FindFirstChild("Remote")
                        if shoot and shoot:IsA("RemoteEvent") then
                            shoot:FireServer(root.Position, root)
                        else
                            tool:Activate()
                        end
                    end)
                end
            end
        end
    end
end

local function meleeAuraTick()
    if not MeleeAura then return end
    local char = getChar()
    local hrp = getHRP()
    if not char or not hrp then return end
    local tool = char:FindFirstChildOfClass("Tool")
    for _, npc in ipairs(workspace:GetDescendants()) do
        if isNPC(npc) then
            local root = npc:FindFirstChild("HumanoidRootPart")
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                if (root.Position - hrp.Position).Magnitude <= MeleeRange then
                    pcall(function()
                        if tool then tool:Activate() end
                    end)
                end
            end
        end
    end
end

local function setNoclip(on)
    NoclipEnabled = on
    if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
    if on then
        NoclipConn = RunService.Stepped:Connect(function()
            local char = getChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    end
end

local function setFly(on)
    FlyEnabled = on
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    local hrp = getHRP()
    local hum = getHum()
    if not on then
        if hrp then hrp.Anchored = false end
        if hum then hum.PlatformStand = false end
        return
    end
    if not hrp or not hum then return end
    FlyConn = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        hrp = getHRP()
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

local function applyWalkJump()
    local hum = getHum()
    if not hum then return end
    if WalkSpeedEnabled then hum.WalkSpeed = WalkSpeedValue end
    if JumpEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = JumpValue
    end
end

local function weaponBypassLoop()
    while ReloadBypass or FireBypass do
        local char = getChar()
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local cfg = tool:FindFirstChild("WeaponConfiguration")
                    if cfg then
                        local rd = cfg:FindFirstChild("ReloadDuration")
                        local fd = cfg:FindFirstChild("FireDelay")
                        if ReloadBypass and rd then
                            if not originalReload[tool] then originalReload[tool] = rd.Value end
                            rd.Value = 0
                        end
                        if FireBypass and fd then
                            if not originalFire[tool] then originalFire[tool] = fd.Value end
                            fd.Value = 0.12
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
end

local function restoreWeapons()
    local char = getChar()
    if not char then return end
    for tool, val in pairs(originalReload) do
        pcall(function()
            local rd = tool:FindFirstChild("WeaponConfiguration") and tool.WeaponConfiguration:FindFirstChild("ReloadDuration")
            if rd then rd.Value = val end
        end)
    end
    for tool, val in pairs(originalFire) do
        pcall(function()
            local fd = tool:FindFirstChild("WeaponConfiguration") and tool.WeaponConfiguration:FindFirstChild("FireDelay")
            if fd then fd.Value = val end
        end)
    end
    originalReload, originalFire = {}, {}
end

local function applySkipHold(prompt)
    if prompt and prompt:IsA("ProximityPrompt") and prompt.HoldDuration > 0 then
        if prompt:GetAttribute("KH_Hold") == nil then
            prompt:SetAttribute("KH_Hold", prompt.HoldDuration)
        end
        prompt.HoldDuration = 0
    end
end

local function enableSkipHold()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then applySkipHold(obj) end
    end
    if holdConn then holdConn:Disconnect() end
    holdConn = workspace.DescendantAdded:Connect(function(obj)
        if SkipHold and obj:IsA("ProximityPrompt") then
            task.wait(0.05)
            applySkipHold(obj)
        end
    end)
end

local function disableSkipHold()
    if holdConn then holdConn:Disconnect() holdConn = nil end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local o = obj:GetAttribute("KH_Hold")
            if o then obj.HoldDuration = o obj:SetAttribute("KH_Hold", nil) end
        end
    end
end

local function useBandage()
    local char = getChar()
    if not char then return end
    local bandage = char:FindFirstChild("Bandage")
    if bandage and bandage:IsA("Tool") then
        local use = bandage:FindFirstChild("Use")
        if use and use:IsA("RemoteEvent") then
            use:FireServer()
        else
            bandage:Activate()
        end
    end
end

local function removeFog()
    Lighting.FogEnd = 1e6
    Lighting.FogStart = 0
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then
        atm.Density = 0
        atm.Haze = 0
    end
end

local function fullBrightTick()
    if not FullBrightNight then return end
    local hour = Lighting:GetMinutesAfterMidnight() / 60
    if hour >= 18 or hour < 6 then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 8
        Lighting.GlobalShadows = false
    end
end

do
    Tabs.FarT:AddParagraph({
        Title = "Note",
        Content = "Toggles load external farm modules when available.",
    })

    Tabs.FarT:AddSection("Bonds")

    local AfBToggle = Tabs.FarT:AddToggle("AfBToggle", {
        Title = "Auto Farm Bonds",
        Description = "Normal bonds farm",
        Default = false,
    })
    AfBToggle:OnChanged(function(Value)
        if Value then
            getgenv().DeadRails = { Farm = { Enabled = true, Mode = "Normal" } }
            local ok = safeLoad(HUTAO_BASE .. "AutoBondsINF")
            notify(ok and "Bonds farm started" or "Farm module failed", 4)
        end
    end)

    local AfBToggle1 = Tabs.FarT:AddToggle("AfBToggle1", {
        Title = "Ultimate Auto Farm Bonds",
        Description = "Stronger bonds farm",
        Default = false,
    })
    AfBToggle1:OnChanged(function(Value)
        if Value then
            local ok = safeLoad(HUTAO_BASE .. "AutoBonds2.lua.txt")
            notify(ok and "Ultimate farm started" or "Ultimate farm failed", 4)
        end
    end)

    Tabs.FarT:AddSection("Win")

    local AfBToggle12 = Tabs.FarT:AddToggle("AfBToggle12", {
        Title = "Auto Farm Bonds & Win",
        Description = "Bonds farm + win path",
        Default = false,
    })
    AfBToggle12:OnChanged(function(Value)
        if Value then
            local ok = safeLoad(HUTAO_BASE .. "AutoBonds3.lua.txt")
            notify(ok and "Bonds + Win started" or "Win farm failed", 4)
        end
    end)

    Tabs.Ma:AddSection("Class")

    Tabs.Ma:AddButton({
        Title = "Get Horse Class",
        Callback = function()
            fireClass("Horse")
            notify("Horse class buy/equip sent", 4)
        end,
    })

    Tabs.Ma:AddSection("ESP")

    local EspToggle = Tabs.Ma:AddToggle("EspToggle", {
        Title = "ESP",
        Description = "Items / Mobs",
        Default = false,
    })
    EspToggle:OnChanged(function()
        if not ESP then
            notify("ESP module unavailable", 3)
            return
        end
        if EspToggle.Value then
            pcall(function() ESP.Initialize() ESP.Update() end)
            notify("ESP ON", 3)
        else
            pcall(function() ESP.Cleanup() end)
            notify("ESP OFF", 3)
        end
    end)

    Tabs.Ma:AddButton({
        Title = "Init Aimbot Module",
        Callback = function()
            if Aimbot and Aimbot.Initialize then
                pcall(Aimbot.Initialize)
                notify("Aimbot module ready", 3)
            else
                notify("Aimbot module unavailable", 3)
            end
        end,
    })

    Tabs.Ma:AddSection("Hitbox")

    local HitboxToggle = Tabs.Ma:AddToggle("HitboxToggle", {
        Title = "NPC Hitbox Expander",
        Default = false,
    })
    HitboxToggle:OnChanged(function()
        HitboxEnabled = HitboxToggle.Value
        if HitboxEnabled then
            task.spawn(hitboxLoop)
            notify("Hitbox ON", 3)
        else
            restoreHitboxes()
            notify("Hitbox OFF", 3)
        end
    end)

    Tabs.Ma:AddSlider("HitboxSize", {
        Title = "Hitbox Size",
        Default = 15,
        Min = 5,
        Max = 40,
        Rounding = 0,
        Callback = function(v) HitboxSize = v end,
    })

    Tabs.Ma:AddSection("Kill Aura")

    local GunKillAuraT = Tabs.Ma:AddToggle("GunKillAura", {
        Title = "Gun Kill Aura",
        Description = "Hold a gun",
        Default = false,
    })
    GunKillAuraT:OnChanged(function()
        GunKillAura = GunKillAuraT.Value
    end)

    Tabs.Ma:AddSlider("GunAuraRadius", {
        Title = "Gun Aura Range",
        Default = 80,
        Min = 20,
        Max = 200,
        Rounding = 0,
        Callback = function(v) GunAuraRange = v end,
    })

    local AuraToggle = Tabs.Ma:AddToggle("AuraToggle", {
        Title = "Melee Aura",
        Default = false,
    })
    AuraToggle:OnChanged(function()
        MeleeAura = AuraToggle.Value
    end)

    Tabs.Ma:AddSlider("MeleeRange", {
        Title = "Melee Range",
        Default = 25,
        Min = 8,
        Max = 60,
        Rounding = 0,
        Callback = function(v) MeleeRange = v end,
    })

    Tabs.Ma:AddSection("Auto Heal")

    Tabs.Ma:AddSlider("healSlider", {
        Title = "Heal Below HP%",
        Default = 50,
        Min = 10,
        Max = 90,
        Rounding = 0,
        Callback = function(v) HealThreshold = v end,
    })

    local HealToggle = Tabs.Ma:AddToggle("HealToggle", {
        Title = "Auto Heal",
        Default = false,
    })
    HealToggle:OnChanged(function()
        AutoHeal = HealToggle.Value
        if AutoHeal then
            task.spawn(function()
                while AutoHeal do
                    local hum = getHum()
                    if hum and hum.Health > 0 and hum.Health <= HealThreshold then
                        useBandage()
                    end
                    task.wait(0.4)
                end
            end)
        end
    end)

    Tabs.Ite:AddSection("Item")

    local MoneyToggle = Tabs.Ite:AddToggle("MoneyToggle", {
        Title = "Auto Collect Money / Bonds",
        Default = false,
    })
    MoneyToggle:OnChanged(function()
        getgenv().KH_AutoMoney = MoneyToggle.Value
        if MoneyToggle.Value then
            task.spawn(function()
                while getgenv().KH_AutoMoney do
                    pcall(function()
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") or obj:IsA("Model") then
                                local n = string.lower(obj.Name)
                                if n:find("bond") or n:find("money") or n:find("cash") or n:find("coin") then
                                    local hrp = getHRP()
                                    local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                                    if hrp and (pos - hrp.Position).Magnitude < 80 then
                                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                                            or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt"))
                                        if prompt and fireproximityprompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end)

    Tabs.Ite:AddSection("Tesla")

    Tabs.Ite:AddButton({
        Title = "TP Near Tesla Lab Generator",
        Callback = function()
            pcall(function()
                local lab = workspace:FindFirstChild("TeslaLab")
                local gen = lab and lab:FindFirstChild("Generator")
                local hrp = getHRP()
                if gen and hrp then
                    hrp.CFrame = CFrame.new(gen:GetPivot().Position + Vector3.new(0, 5, 0))
                    notify("Teleported to Tesla Lab", 3)
                else
                    notify("TeslaLab not found", 3)
                end
            end)
        end,
    })

    Tabs.TpT:AddSection("Bases")

    local dropdownValues = {}
    for locationName in pairs(teleportLocations) do
        table.insert(dropdownValues, locationName)
    end
    table.sort(dropdownValues)
    local selectedLocation = dropdownValues[1]

    local Dropdown = Tabs.TpT:AddDropdown("TeleportDropdown", {
        Title = "Select Base",
        Values = dropdownValues,
        Multi = false,
        Default = 1,
    })
    Dropdown:OnChanged(function(value)
        selectedLocation = value
    end)

    Tabs.TpT:AddButton({
        Title = "Teleport to Selected Base",
        Callback = function()
            local hrp = getHRP()
            local pos = teleportLocations[selectedLocation]
            if hrp and pos then
                hrp.CFrame = CFrame.new(pos)
                notify("TP: " .. tostring(selectedLocation), 3)
            end
        end,
    })

    Tabs.TpT:AddSection("Train")

    Tabs.TpT:AddButton({
        Title = "TP to Train",
        Callback = function()
            pcall(function()
                local train = workspace:FindFirstChild("Train") or workspace:FindFirstChild("TrainModel")
                local hrp = getHRP()
                if train and hrp then
                    hrp.CFrame = CFrame.new(train:GetPivot().Position + Vector3.new(0, 8, 0))
                    notify("TP Train", 3)
                else
                    notify("Train not found", 3)
                end
            end)
        end,
    })

    Tabs.TpT:AddButton({
        Title = "TP to Tesla Lab",
        Callback = function()
            pcall(function()
                local lab = workspace:FindFirstChild("TeslaLab")
                local hrp = getHRP()
                if lab and hrp then
                    hrp.CFrame = CFrame.new(lab:GetPivot().Position + Vector3.new(0, 6, 0))
                    notify("TP Tesla Lab", 3)
                else
                    notify("TeslaLab not found", 3)
                end
            end)
        end,
    })

    Tabs.Player:AddSection("Noclip")

    local NcToggle = Tabs.Player:AddToggle("NcToggle", {
        Title = "Noclip",
        Default = false,
    })
    NcToggle:OnChanged(function()
        setNoclip(NcToggle.Value)
    end)

    Tabs.Player:AddSection("Fly")

    local FlyToggle = Tabs.Player:AddToggle("FlyToggle", {
        Title = "Fly (WASD + Space/Ctrl)",
        Default = false,
    })
    FlyToggle:OnChanged(function()
        setFly(FlyToggle.Value)
    end)

    Tabs.Player:AddSlider("FlySpeedSlider", {
        Title = "Fly Speed",
        Default = 50,
        Min = 20,
        Max = 150,
        Rounding = 0,
        Callback = function(v) FlySpeed = v end,
    })

    Tabs.Player:AddSection("WalkSpeed")

    local WalkSpeedToggle = Tabs.Player:AddToggle("WalkSpeedToggle", {
        Title = "WalkSpeed",
        Default = false,
    })
    WalkSpeedToggle:OnChanged(function()
        WalkSpeedEnabled = WalkSpeedToggle.Value
        if WalkSpeedEnabled then
            applyWalkJump()
        else
            local h = getHum()
            if h then h.WalkSpeed = 16 end
        end
    end)

    Tabs.Player:AddSlider("WalkSpeedSlider", {
        Title = "Walk Speed",
        Default = 20,
        Min = 16,
        Max = 80,
        Rounding = 0,
        Callback = function(v)
            WalkSpeedValue = v
            if WalkSpeedEnabled then applyWalkJump() end
        end,
    })

    Tabs.Player:AddSection("JumpHeight")

    local JumpHeightToggle = Tabs.Player:AddToggle("JumpHeightToggle", {
        Title = "Jump Power",
        Default = false,
    })
    JumpHeightToggle:OnChanged(function()
        JumpEnabled = JumpHeightToggle.Value
        if JumpEnabled then applyWalkJump() end
    end)

    Tabs.Player:AddSlider("JumpHeightSlider", {
        Title = "Jump Power",
        Default = 50,
        Min = 50,
        Max = 120,
        Rounding = 0,
        Callback = function(v)
            JumpValue = v
            if JumpEnabled then applyWalkJump() end
        end,
    })

    Tabs.Misc:AddSection("Bypass")

    local BypassBandageT = Tabs.Misc:AddToggle("BypassBandageT", {
        Title = "Bypass Bandage Delay",
        Description = "Press R to use bandage",
        Default = false,
    })
    BypassBandageT:OnChanged(function()
        BandageBypass = BypassBandageT.Value
    end)

    local ReloadToggle = Tabs.Misc:AddToggle("ReloadToggle", {
        Title = "Bypass Reload Delay",
        Default = false,
    })
    ReloadToggle:OnChanged(function()
        ReloadBypass = ReloadToggle.Value
        if ReloadBypass then
            task.spawn(weaponBypassLoop)
        else
            restoreWeapons()
        end
    end)

    local FireDeToggle = Tabs.Misc:AddToggle("FireDeToggle", {
        Title = "Bypass Fire Delay",
        Default = false,
    })
    FireDeToggle:OnChanged(function()
        FireBypass = FireDeToggle.Value
        if FireBypass then
            task.spawn(weaponBypassLoop)
        else
            restoreWeapons()
        end
    end)

    local SkipHoldToggle = Tabs.Misc:AddToggle("SkipHoldToggle", {
        Title = "Bypass Hold Prompt",
        Default = false,
    })
    SkipHoldToggle:OnChanged(function()
        SkipHold = SkipHoldToggle.Value
        if SkipHold then enableSkipHold() else disableSkipHold() end
    end)

    Tabs.Misc:AddSection("Visual")

    local FbToggle1 = Tabs.Misc:AddToggle("FbToggle1", {
        Title = "Auto Full Bright",
        Description = "At night",
        Default = false,
    })
    FbToggle1:OnChanged(function()
        FullBrightNight = FbToggle1.Value
        if brightConn then brightConn:Disconnect() brightConn = nil end
        if FullBrightNight then
            fullBrightTick()
            brightConn = Lighting:GetPropertyChangedSignal("ClockTime"):Connect(fullBrightTick)
        end
    end)

    local NoFogToggle = Tabs.Misc:AddToggle("NoFogToggle", {
        Title = "Remove Fog",
        Default = false,
    })
    NoFogToggle:OnChanged(function()
        NoFog = NoFogToggle.Value
        if fogConn then fogConn:Disconnect() fogConn = nil end
        if NoFog then
            removeFog()
            fogConn = RunService.Heartbeat:Connect(removeFog)
        end
    end)

    Tabs.Misc:AddButton({
        Title = "Camera Unlocker",
        Description = "Third-person",
        Callback = function()
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 60
            notify("Camera unlocked", 3)
        end,
    })

    Tabs.Misc:AddSection("MISC")

    local FpsbfToggle1 = Tabs.Misc:AddToggle("FpsbfToggle1", {
        Title = "FPS Boost",
        Default = false,
    })
    FpsbfToggle1:OnChanged(function()
        if not FpsbfToggle1.Value then return end
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                end)
            end
        end
        notify("FPS boost applied", 3)
    end)

    local AntiAfkToggle = Tabs.Misc:AddToggle("AntiAfkToggle", {
        Title = "Anti Idle",
        Default = true,
    })
    AntiAfkToggle:OnChanged(function()
        AntiAfk = AntiAfkToggle.Value
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

    Tabs.Settings:AddParagraph({
        Title = ScriptName .. " v" .. ScriptVersion,
        Content = "Dead Rails — Creator: thiagxjzu3",
    })

    Tabs.Settings:AddButton({
        Title = "Copy Discord",
        Callback = function()
            local ok = pcall(function()
                if setclipboard then setclipboard(DiscordInvite)
                elseif toclipboard then toclipboard(DiscordInvite)
                else error("no clipboard") end
            end)
            notify(ok and "Discord copied" or "Clipboard unavailable", 3)
        end,
    })
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("KingsHub")
SaveManager:SetFolder("KingsHub/DeadRails")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({
    Title = "KingsHub",
    Content = "Dead Rails script loaded",
    Duration = 5,
})
SaveManager:LoadAutoloadConfig()

RunService.Heartbeat:Connect(function()
    if GunKillAura then pcall(gunAuraTick) end
    if MeleeAura then pcall(meleeAuraTick) end
    if WalkSpeedEnabled or JumpEnabled then pcall(applyWalkJump) end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if BandageBypass and input.KeyCode == Enum.KeyCode.R then
        useBandage()
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
    task.wait(0.5)
    if NoclipEnabled then setNoclip(true) end
    if WalkSpeedEnabled or JumpEnabled then applyWalkJump() end
end)

local ExistingUI = CoreGui:FindFirstChild("KingsHubMinimizeUI")
if ExistingUI then ExistingUI:Destroy() end

local DragUI = Instance.new("ScreenGui")
DragUI.Name = "KingsHubMinimizeUI"
DragUI.ResetOnSpawn = false
DragUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DragUI.Parent = CoreGui

local Button = Instance.new("ImageButton")
Button.Parent = DragUI
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Position = UDim2.new(0, 10, 1, -85)
Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Button.BackgroundTransparency = 0.3
Button.BorderSizePixel = 0
Button.ClipsDescendants = true
Button.Image = "rbxassetid://90508203972003"
Button.ScaleType = Enum.ScaleType.Fit
Button.Active = true
Button.ZIndex = 1000

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Button

local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local isDragging = false
local dragThreshold = 10
local dragging, dragStart, startPos

local function SimulateKeyPress()
    VirtualInputManager:SendKeyEvent(true, minimizeUI, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, minimizeUI, false, game)
end

Button.MouseButton1Click:Connect(function()
    if isDragging then return end
    local tween = TweenService:Create(Button, tweenInfo, {
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 45, 0, 45),
        Rotation = 5,
    })
    tween:Play()
    task.wait(0.1)
    TweenService:Create(Button, tweenInfo, {
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 50, 0, 50),
        Rotation = 0,
    }):Play()
    SimulateKeyPress()
end)

Button.MouseEnter:Connect(function()
    TweenService:Create(Button, tweenInfo, { Size = UDim2.new(0, 55, 0, 55) }):Play()
end)
Button.MouseLeave:Connect(function()
    TweenService:Create(Button, tweenInfo, { Size = UDim2.new(0, 50, 0, 50) }):Play()
end)

local function StartDrag(input)
    isDragging = false
    dragging = true
    dragStart = input.Position
    startPos = Button.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

local function OnDrag(input)
    if not dragging then return end
    local delta = (input.Position - dragStart).Magnitude
    if delta > dragThreshold then isDragging = true end
    Button.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + (input.Position.X - dragStart.X),
        startPos.Y.Scale,
        startPos.Y.Offset + (input.Position.Y - dragStart.Y)
    )
end

Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        StartDrag(input)
    end
end)

Button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        OnDrag(input)
    end
end)

print("[KingsHub] Dead Rails loaded — thiagxjzu3")
