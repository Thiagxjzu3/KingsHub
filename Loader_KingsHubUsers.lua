if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local ScriptVersion = "5"
local ScriptName = "KingsHub"
-- Live users API (Cloudflare Worker). Leave "" to disable.
-- Example: "https://kingshub-api.xxxxx.workers.dev"
local KingsOnlineApiUrl = "https://kingshub-api.thiagodamianff.workers.dev"
local KingsOnlineEnabled = true
local KingsOnlineCount = 0
local KingsOnlineSession = nil
local KingsOnlineLabel = nil
local lastOnlineHeartbeat = 0

local LastUpdated = "10-21-2026"

-- LANGUAGE
local CurrentLang = "en"
local Locales = {
    en = {
        tab_main = "Main",
        tab_boost = "Boost",
        tab_visuals = "Visuals",
        tab_rollback = "Rollback",
        tab_settings = "Settings",
        group_combat = "Combat",
        group_aim_serve = "Aim & Serve",
        group_jump = "Jump",
        group_spike = "Spike",
        group_effects = "Effects",
        group_perf = "Performance",
        group_rollback = "Data Rollback",
        group_info = "Info",
        group_actions = "Actions",
        hitbox = "Ball Hitbox",
        hitbox_size = "Hitbox Size",
        hitbox_trans = "Hitbox Transparency",
        hitbox_color = "Hitbox Color",
        directional = "Directional Hit",
        official_path = "Official Move Path",
        perfect_spike = "Perfect Spike Assist",
        max_power = "Max Power Spike (TSH)",
        max_power_tip = "Tiny movement while idle keeps spike meter full",
        silent_spike = "Silent Spike",
        silent_spike_tip = "DoMove Spike + mute anim/SFX. Grounded, camera aim. Pico / keybind.",
        silent_spike_key = "Silent Spike Key",
        lock_pico = "Lock Pico Button",
        lock_pico_tip = "Prevent dragging the on-screen Pico button",
        desync = "Desync",
        desync_tip = "FurHub-style: hide combat anims + network flags. Rejoin to fully reverse.",
        anti_mod = "Anti-Moderator",
        anti_mod_tip = "Leave if a moderator joins",
        corner = "Corner Aimbot",
        corner_tip = "Corner Aimbot by RNCRAZY",
        corner_by = "Corner Aimbot by RNCRAZY",
        camera_jump = "Camera Jump",
        camera_jump_tip = "Face camera direction when jumping",
        auto_serve = "Auto Strong Serve (UI)",
        force_serve = "Force Strong Serve",
        serve_power = "Serve Boost Power",
        jump_boost = "Jump Boost",
        jump_mult = "Jump Multiplier",
        spike_boost = "Spike Boost",
        spike_charge = "Spike Charge",
        no_cd = "No Cooldown",
        no_cd_tip = "Reduce action cooldowns (pick which actions below)",
        no_cd_spike = "No CD: Spike",
        no_cd_serve = "No CD: Serve",
        no_cd_block = "No CD: Block",
        no_cd_dive = "No CD: Dive",
        no_cd_set = "No CD: Set",
        no_cd_receive = "No CD: Receive",
        no_cd_ability = "No CD: Ability",
        score_select = "Select Score Effect",
        score_toggle = "ScoreEffect Changer",
        predict = "Predict Aim",
        predict_tip = "Show prediction lines on enemies",
        predict_len = "Prediction Length",
        predict_color = "Predict Color",
        optimal_spot = "Optimal Spot",
        optimal_spot_tip = "Marks where to stand based on the ball",
        optimal_on = "Optimal Spot ON",
        optimal_off = "Optimal Spot OFF",
        fps = "FPS Counter",
        fps_tip = "Fixed FPS counter at the top of the screen",
        potato = "Performance Mode",
        potato_tip = "Reduce local graphics (levels below)",
        perf_level = "Performance Level",
        perf_light = "Light",
        perf_bal = "Balanced",
        perf_max = "Maximum",
        bar_tsh = "TSH Bar Lock",
        bar_tsh_tip = "Keep Timeskip special bar full (local)",
        bar_ronin = "Ronin Bar Lock",
        bar_ronin_tip = "Keep Samurai/Ronin special bar full (local)",
        bar_kazana = "Kazana Bar Lock",
        bar_kazana_tip = "Keep Kazana charge ready (local)",
        streamer = "Streamer Mode",
        streamer_tip = "Hide other player names",
        unlock_all = "Unlock All (Visual)",
        unlock_all_tip = "Local inventory: cards, score effects, balls, titles, jerseys. NOT styles/gems/yen/spins. Others see your real cosmetics.",
        unlock_on = "Unlock All ON — cosmetics local",
        unlock_off = "Unlock All OFF",
        last_updated = "Last Updated: ",
        creator = "Creator: thiagxjzu3",
        ui_lib = "UI Library: Obsidian",
        enjoy = "Enjoy the script!",
        rb_l1 = "Two rollbacks: Classic + BETA",
        rb_l2 = "Sends UpdateKeybind payload then rejoins",
        rb_l3 = "Use right after spending. ~3 spins typical",
        rb_run = "Rollback Classic",
        rb_tip = "Original KingsHub rollback payload + rejoin",
        rb_run_beta = "Rollback (BETA)",
        rb_tip_beta = "BETA: SettingsService UpdateKeybind + teleport",
        rb_l4 = "You will be teleported automatically",
        menu_bind = "Menu bind",
        online_users = "Users online",
        online_tip = "Anonymous heartbeat to your API",
        online_toggle = "Live User Counter",
        online_off = "Counter off / no API URL",
        online_err = "Online API unreachable",
        unload = "Unload Script",
        welcome = "Welcome to KingsHub by thiagxjzu3. Enjoy!",
        loaded = " loaded | ",
        pick_title = "Choose your language",
        pick_sub = "Select language / Elige el idioma",
        pick_en = "English",
        pick_es = "Español",
        on = "ON",
        off = "OFF",
        studs = " studs",
        pico = "Pico",
        pico_locked = "Pico button locked",
        pico_unlocked = "Pico button unlocked",
        desync_on = "Desync ON (FurHub-style) — rejoin to fully reverse",
        desync_off = "Desync OFF (rejoin if still weird)",
        silent_on = "Silent Spike ON — DoMove Spike (Pico / key)",
        silent_off = "Silent Spike OFF",
        unloading = "Unloading",
        rb_sending = "Rollback: sending payload...",
        rb_fail = "Rollback failed",
        rb_ok = "Rollback sent. Rejoining...",
        mod_detect = "Moderator detected: ",
        mod_leave = " — leaving",
        mod_join = "Moderator joined: ",
    },
    es = {
        tab_main = "Principal",
        tab_boost = "Boost",
        tab_visuals = "Visuales",
        tab_rollback = "Rollback",
        tab_settings = "Ajustes",
        group_combat = "Combate",
        group_aim_serve = "Aim y Saque",
        group_jump = "Salto",
        group_spike = "Remate",
        group_effects = "Efectos",
        group_perf = "Rendimiento",
        group_rollback = "Rollback de Datos",
        group_info = "Info",
        group_actions = "Acciones",
        hitbox = "Hitbox de Pelota",
        hitbox_size = "Tamaño Hitbox",
        hitbox_trans = "Transparencia Hitbox",
        hitbox_color = "Color Hitbox",
        directional = "Golpe Direccional",
        official_path = "Ruta Oficial de Movimiento",
        perfect_spike = "Asistencia Spike Perfecto",
        max_power = "Max Power Spike (TSH)",
        max_power_tip = "Movimiento mínimo en idle mantiene la barra llena",
        silent_spike = "Silent Spike",
        silent_spike_tip = "DoMove Spike + mute anim/SFX. En suelo, mira cámara. Pico / tecla.",
        silent_spike_key = "Tecla Silent Spike",
        lock_pico = "Bloquear botón Pico",
        lock_pico_tip = "Evita arrastrar el botón Pico en pantalla",
        desync = "Desync",
        desync_tip = "Estilo FurHub: oculta anims de combate + flags de red. Rejoin para revertir del todo.",
        anti_mod = "Anti-Moderador",
        anti_mod_tip = "Sale si entra un moderador",
        corner = "Corner Aimbot",
        corner_tip = "Corner Aimbot by RNCRAZY",
        corner_by = "Corner Aimbot by RNCRAZY",
        camera_jump = "Camera Jump",
        camera_jump_tip = "Mira hacia la cámara al saltar",
        auto_serve = "Auto Strong Serve (UI)",
        force_serve = "Forzar Strong Serve",
        serve_power = "Potencia de Saque",
        jump_boost = "Boost de Salto",
        jump_mult = "Multiplicador de Salto",
        spike_boost = "Boost de Spike",
        spike_charge = "Carga de Spike",
        no_cd = "Sin Cooldown",
        no_cd_tip = "Reduce cooldowns (elegí qué acciones abajo)",
        no_cd_spike = "Sin CD: Spike",
        no_cd_serve = "Sin CD: Serve",
        no_cd_block = "Sin CD: Block",
        no_cd_dive = "Sin CD: Dive",
        no_cd_set = "Sin CD: Set",
        no_cd_receive = "Sin CD: Receive",
        no_cd_ability = "Sin CD: Ability",
        score_select = "Elegir Score Effect",
        score_toggle = "Cambiar ScoreEffect",
        predict = "Predict Aim",
        predict_tip = "Líneas de predicción en enemigos",
        predict_len = "Largo de Predicción",
        predict_color = "Color Predict",
        optimal_spot = "Posición Óptima",
        optimal_spot_tip = "Marca dónde pararte según la pelota",
        optimal_on = "Posición Óptima ON",
        optimal_off = "Posición Óptima OFF",
        fps = "Contador FPS",
        fps_tip = "FPS fijo arriba de la pantalla",
        potato = "Modo Rendimiento",
        potato_tip = "Baja gráficos locales (niveles abajo)",
        perf_level = "Nivel de Rendimiento",
        perf_light = "Ligero",
        perf_bal = "Equilibrado",
        perf_max = "Máximo",
        bar_tsh = "Lock Barra TSH",
        bar_tsh_tip = "Mantiene la barra especial Timeskip llena (local)",
        bar_ronin = "Lock Barra Ronin",
        bar_ronin_tip = "Mantiene la barra Samurai/Ronin llena (local)",
        bar_kazana = "Lock Barra Kazana",
        bar_kazana_tip = "Mantiene la carga Kazana lista (local)",
        streamer = "Modo Streamer",
        streamer_tip = "Oculta nombres de otros jugadores",
        unlock_all = "Desbloquear Todo (Visual)",
        unlock_all_tip = "Inventario local: cartas, score effects, pelotas, títulos, jerseys. NO estilos/gemas/yen/giros. Los demás ven tus cosméticos reales.",
        unlock_on = "Unlock All ON — cosméticos locales",
        unlock_off = "Unlock All OFF",
        last_updated = "Actualizado: ",
        creator = "Creador: thiagxjzu3",
        ui_lib = "UI: Obsidian",
        enjoy = "¡Disfruta el script!",
        rb_l1 = "Dos rollbacks: Clásico + BETA",
        rb_l2 = "Envía payload UpdateKeybind y hace rejoin",
        rb_l3 = "Usar justo después de gastar. ~3 giros típico",
        rb_run = "Rollback Clásico",
        rb_tip = "Rollback original de KingsHub + rejoin",
        rb_run_beta = "Rollback (BETA)",
        rb_tip_beta = "BETA: SettingsService UpdateKeybind + teleport",
        rb_l4 = "Serás teletransportado automáticamente",
        menu_bind = "Tecla del menú",
        online_users = "Usuarios en línea",
        online_tip = "Heartbeat anónimo a tu API",
        online_toggle = "Contador en vivo",
        online_off = "Contador off / sin URL de API",
        online_err = "API de online no responde",
        unload = "Descargar Script",
        welcome = "Bienvenido a KingsHub by thiagxjzu3. ¡Disfruta!",
        loaded = " cargado | ",
        pick_title = "Elige tu idioma",
        pick_sub = "Select language / Elige el idioma",
        pick_en = "English",
        pick_es = "Español",
        on = "ON",
        off = "OFF",
        studs = " studs",
        pico = "Pico",
        pico_locked = "Botón Pico bloqueado",
        pico_unlocked = "Botón Pico desbloqueado",
        desync_on = "Desync ON (estilo FurHub) — rejoin para revertir del todo",
        desync_off = "Desync OFF (rejoin si sigue raro)",
        silent_on = "Silent Spike ON — DoMove Spike (Pico / tecla)",
        silent_off = "Silent Spike OFF",
        unloading = "Descargando",
        rb_sending = "Rollback: enviando payload...",
        rb_fail = "Rollback falló",
        rb_ok = "Rollback enviado. Rejoin...",
        mod_detect = "Moderador detectado: ",
        mod_leave = " — saliendo",
        mod_join = "Moderador entró: ",
    },
}

local function L(key)
    local pack = Locales[CurrentLang] or Locales.en
    return pack[key] or Locales.en[key] or key
end





local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library, ThemeManager, SaveManager

local function safeLoad(url)
    local ok, src = pcall(function() return game:HttpGet(url) end)
    if not ok or type(src) ~= "string" or #src < 100 then return nil end
    local ok2, res = pcall(function() return loadstring(src)() end)
    if ok2 then return res end
    return nil
end

Library = safeLoad(repo .. "Library.lua")
task.wait(0.15)
if Library then
    ThemeManager = safeLoad(repo .. "addons/ThemeManager.lua")
    task.wait(0.1)
    SaveManager = safeLoad(repo .. "addons/SaveManager.lua")
end
if not Library then
    warn("[KingsHub] Failed to load UI library")
    return
end

local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = false
pcall(function() Library:SetNotifySide("Left") end)


-- LIVE USER COUNTER (own API)
local function kingsOnlineEnsureSession()
    if KingsOnlineSession then return KingsOnlineSession end
    local id = nil
    pcall(function()
        if type(generateGUID) == "function" then
            id = tostring(generateGUID()):gsub("%W", ""):sub(1, 24)
        end
    end)
    if not id or id == "" then
        id = tostring(math.random(100000, 999999)) .. tostring(os.clock()):gsub("%W", "")
        id = id:sub(1, 24)
    end
    KingsOnlineSession = id
    return id
end

local function kingsOnlineUpdateLabel()
    pcall(function()
        if KingsOnlineLabel and KingsOnlineLabel.SetText then
            local base = L("online_users")
            if not KingsOnlineApiUrl or KingsOnlineApiUrl == "" or not KingsOnlineEnabled then
                KingsOnlineLabel:SetText(base .. ": —")
            else
                KingsOnlineLabel:SetText(base .. ": " .. tostring(KingsOnlineCount))
            end
        end
    end)
end

local function kingsOnlineHeartbeat()
    if not KingsOnlineEnabled then return end
    if type(KingsOnlineApiUrl) ~= "string" or KingsOnlineApiUrl == "" then return end
    if type(game.HttpGet) ~= "function" and type(request) ~= "function" and type(http_request) ~= "function" then
        return
    end
    local id = kingsOnlineEnsureSession()
    local url = KingsOnlineApiUrl:gsub("/+$", "") .. "/heartbeat"
    local body = game:GetService("HttpService"):JSONEncode({ id = id })
    local ok, res = pcall(function()
        if type(request) == "function" then
            local r = request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body,
            })
            return r and (r.Body or r.body)
        elseif type(http_request) == "function" then
            local r = http_request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body,
            })
            return r and (r.Body or r.body)
        end
        -- fallback: some executors only have HttpGet
        return game:HttpGet(KingsOnlineApiUrl:gsub("/+$", "") .. "/count")
    end)
    if ok and type(res) == "string" and res ~= "" then
        local data = nil
        pcall(function()
            data = game:GetService("HttpService"):JSONDecode(res)
        end)
        if type(data) == "table" and tonumber(data.online) then
            KingsOnlineCount = math.floor(tonumber(data.online))
            kingsOnlineUpdateLabel()
        end
    end
end


local function notify(msg, t)
    pcall(function()
        Library:Notify({ Title = ScriptName, Description = tostring(msg), Time = t or 6 })
    end)
end

-- STATE
local HitboxEnabled = false
local HitboxSize = 10
local HitboxColor = Color3.fromRGB(0, 255, 0)
local HitboxTransparency = 0.8
local PerfLevel = "Balanced" -- Light | Balanced | Maximum
local TSHBarLockEnabled = false
local RoninBarLockEnabled = false
local KazanaBarLockEnabled = false
local AutoStrongServeEnabled = false
local AutoStrongServeEveryServeEnabled = false
local ServeBoostPower = 1
local DirectionalHitEnabled = false
local AimbotCornerEnabled = false
local CameraJumpEnabled = false
local MaxPowerSpikeEnabled = false
local SilentSpikeEnabled = false
local lastSilentSpike = 0
local SilentSpikeLockBtn = false
local ShowFpsCounter = true
local fpsGui = nil
local DesyncEnabled = false
local desyncConns = {}
local AntiModEnabled = false
local StreamerModeEnabled = false
local PredictAimEnabled = false
local PredictAimColor = Color3.fromRGB(255, 255, 0)
local PredictAimLength = 25
local OptimalSpotEnabled = false
local optimalSpotPart = nil
local JumpBoostEnabled = false
local JumpBoostMult = 1.35
local SpikeBoostEnabled = false
local SpikeBoostCharge = 1
local PerfectSpikeAssistEnabled = true
local NoCooldownEnabled = false
local NoCooldownActions = {
    Spike = true,
    Serve = false,
    Block = false,
    Dive = false,
    Set = false,
    Receive = false,
    Ability = false,
}
local OfficialPathEnabled = true
local ScoreEffectEnabled = false
local PotatoModeEnabled = false
local UnlockAllVisualEnabled = false
local unlockAllConns = {}
local ballJumpRemote, ballInteractRemote
local maxPowerPhase = 0
local PredictAimObjects = {}
local silentSpikeGui = nil
local streamerOriginalDisplay = {}
local moderatorList = {
    "ROBLOX", "Roblox", "Admin", "Moderator", "VolleyballLegends",
}

local function cacheBallRemotes()
    pcall(function()
        local services = ReplicatedStorage:FindFirstChild("Packages")
        if not services then return end
        services = services:FindFirstChild("_Index")
        if not services then return end
        services = services:FindFirstChild("sleitnick_knit@1.7.0")
        if not services then return end
        services = services:FindFirstChild("knit")
        if not services then return end
        services = services:FindFirstChild("Services")
        if not services then return end
        local bs = services:FindFirstChild("BallService")
        local rf = bs and bs:FindFirstChild("RF")
        if rf then
            ballJumpRemote = rf:FindFirstChild("Jump") or ballJumpRemote
            ballInteractRemote = rf:FindFirstChild("Interact") or ballInteractRemote
        end
    end)
end
cacheBallRemotes()
task.spawn(function()
    for _ = 1, 8 do
        if ballJumpRemote and ballInteractRemote then break end
        task.wait(1)
        cacheBallRemotes()
    end
end)

-- HITBOX
local function modifyBallHitbox()
    local size = HitboxSize
    if size <= 0 then return end
    for _, v in pairs(workspace:GetChildren()) do
        local n = tostring(v.Name or "")
        if (n:find("CLIENT_BALL") or n:find("BALL")) and v:IsA("Model") then
            local ball = v:FindFirstChildWhichIsA("BasePart")
            if ball then
                local hb = v:FindFirstChild("ExtendedHitbox")
                if hb and hb:IsA("BasePart") then
                    hb.Size = Vector3.new(size, size, size)
                    hb.Color = HitboxColor
                    hb.Transparency = HitboxTransparency
                    hb.CFrame = ball.CFrame
                else
                    local part = Instance.new("Part")
                    part.Name = "ExtendedHitbox"
                    part.Size = Vector3.new(size, size, size)
                    part.Transparency = HitboxTransparency
                    part.Color = HitboxColor
                    part.Material = Enum.Material.ForceField
                    part.CanCollide = false
                    part.CanTouch = true
                    part.Massless = true
                    part.Shape = Enum.PartType.Ball
                    part.CFrame = ball.CFrame
                    part.Parent = v
                    local w = Instance.new("WeldConstraint")
                    w.Part0 = ball
                    w.Part1 = part
                    w.Parent = part
                end
            end
        end
    end
end

local function removeHitboxes()
    for _, v in pairs(workspace:GetChildren()) do
        if tostring(v.Name):find("CLIENT_BALL") and v:IsA("Model") then
            local hb = v:FindFirstChild("ExtendedHitbox")
            if hb then hb:Destroy() end
        end
    end
end

-- COMBAT
local function getBallId(model)
    if not model then return nil end
    local name = tostring(model.Name or "")
    local id = tonumber(name:match("(%d+)"))
    if id then return id end
    for _, attr in ipairs({ "BallId", "Id", "ballId", "ID", "NetId" }) do
        local v = model:GetAttribute(attr)
        if v ~= nil then
            local n = tonumber(v)
            if n then return n end
        end
    end
    local val = model:FindFirstChild("BallId") or model:FindFirstChild("Id")
    if val and val:IsA("ValueBase") then
        return tonumber(val.Value)
    end
    return nil
end

local doMoveRemote = nil
local function cacheDoMove()
    pcall(function()
        if doMoveRemote and doMoveRemote.Parent then return end
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        local index = packages and packages:FindFirstChild("_Index")
        local knitPkg = index and index:FindFirstChild("sleitnick_knit@1.7.0")
        local knit = knitPkg and knitPkg:FindFirstChild("knit")
        local services = knit and knit:FindFirstChild("Services")
        local bs = services and services:FindFirstChild("BallService")
        local re = bs and bs:FindFirstChild("RE")
        doMoveRemote = re and re:FindFirstChild("DoMove")
    end)
end

local function getFireSignal()
    local candidates = {}
    pcall(function() table.insert(candidates, firesignal) end)
    pcall(function() if getgenv then table.insert(candidates, getgenv().firesignal) end end)
    pcall(function() if getrenv then table.insert(candidates, getrenv().firesignal) end end)
    pcall(function() if getfenv then table.insert(candidates, getfenv().firesignal) end end)
    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then return fn end
    end
    return nil
end

local function getSpikeAim()
    local cam = workspace.CurrentCamera
    local look = (cam and cam.CFrame.LookVector) or Vector3.new(0, -0.05, -1)
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < 0.05 then
        flat = Vector3.new(0, 0, -1)
    else
        flat = flat.Unit
    end
    -- mostly forward, only a light downward angle (ball was going too low)
    local y = -0.06
    look = Vector3.new(flat.X, y, flat.Z).Unit
    return look, flat
end

local function fireSpikePayload(root, model)
    cacheBallRemotes()
    cacheDoMove()
    local look, flat = getSpikeAim()
    local id = getBallId(model)

    -- Method used by Silent Spike hubs: firesignal(DoMove.OnClientEvent, "Spike", ...)
    local fs = getFireSignal()
    if fs and doMoveRemote then
        pcall(function() fs(doMoveRemote.OnClientEvent, "Spike", false, false, look) end)
        pcall(function() fs(doMoveRemote.OnClientEvent, "Spike", false, false) end)
    elseif doMoveRemote and type(getconnections) == "function" then
        pcall(function()
            for _, conn in ipairs(getconnections(doMoveRemote.OnClientEvent)) do
                pcall(function()
                    if conn.Fire then
                        conn:Fire("Spike", false, false, look)
                    elseif conn.Function then
                        conn.Function("Spike", false, false, look)
                    end
                end)
            end
        end)
    end

    -- Server Interact with Move = "Spike"
    if ballInteractRemote then
        local payload = {
            Charge = 1,
            Move = "Spike",
            Action = "Spike",
            SpecialCharge = 0,
            TiltDirection = Vector3.new(flat.X, 0.08, flat.Z),
            LookVector = look,
            Direction = look,
            MoveDirection = Vector3.new(0, 0, 0),
            ClientCanRunSpecial = false,
            From = "Client",
            Timestamp = tick(),
            CustomClient = {},
        }
        if id then payload.BallId = id end
        pcall(function()
            if ballInteractRemote:IsA("RemoteFunction") then
                ballInteractRemote:InvokeServer(payload)
            else
                ballInteractRemote:FireServer(payload)
            end
        end)
    end
    return true
end

local function getAimLook(root)
    local look = root.CFrame.LookVector
    local cam = workspace.CurrentCamera
    if DirectionalHitEnabled and cam then look = cam.CFrame.LookVector end
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < 0.05 then flat = Vector3.new(0, 0, -1) else flat = flat.Unit end
    return look.Unit, flat
end


local function actionHasNoCD(act)
    if not NoCooldownEnabled then return false end
    act = tostring(act or ""):lower()
    if act:find("spike") then return NoCooldownActions.Spike end
    if act:find("serve") then return NoCooldownActions.Serve end
    if act:find("block") then return NoCooldownActions.Block end
    if act:find("dive") then return NoCooldownActions.Dive end
    if act == "set" or act:find("jumpset") then return NoCooldownActions.Set end
    if act:find("receive") or act:find("bump") then return NoCooldownActions.Receive end
    if act:find("ability") or act:find("special") or act:find("ult") then return NoCooldownActions.Ability end
    return false
end

local function applyNoCooldownToPayload(data)
    if type(data) ~= "table" then return end
    local act = data.Action or data.Move or data.action or data.move
    if not actionHasNoCD(act) then return end
    data.Cooldown = 0
    data.cooldown = 0
    data.Debounce = 0
    data.debounce = 0
    data.NoCooldown = true
    if data.Charge == nil then data.Charge = 1 end
end

local function runNoCooldownClear()
    if not NoCooldownEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for name, val in pairs(char:GetAttributes()) do
        local lower = tostring(name):lower()
        local isCd = lower:find("cooldown", 1, true) or lower:find("debounce", 1, true)
            or lower:find("_cd", 1, true) or lower:find("cd_", 1, true)
        if isCd then
            local should = false
            if NoCooldownActions.Spike and (lower:find("spike") or lower:find("hit")) then should = true end
            if NoCooldownActions.Serve and lower:find("serve") then should = true end
            if NoCooldownActions.Block and lower:find("block") then should = true end
            if NoCooldownActions.Dive and lower:find("dive") then should = true end
            if NoCooldownActions.Set and (lower:find("set") or lower:find("toss")) then should = true end
            if NoCooldownActions.Receive and (lower:find("receive") or lower:find("bump")) then should = true end
            if NoCooldownActions.Ability and (lower:find("ability") or lower:find("special") or lower:find("ult")) then should = true end
            -- generic CD attrs if any selected action is on
            if not should and (NoCooldownActions.Spike or NoCooldownActions.Serve) then
                if lower == "cooldown" or lower == "actioncooldown" or lower == "globalcooldown" then
                    should = true
                end
            end
            if should then
                pcall(function()
                    if type(val) == "number" then char:SetAttribute(name, 0)
                    elseif type(val) == "boolean" then char:SetAttribute(name, false) end
                end)
            end
        end
    end
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("NumberValue") or inst:IsA("IntValue") or inst:IsA("BoolValue") then
            local n = inst.Name:lower()
            if n:find("cooldown") or n:find("debounce") or n:find("_cd") then
                pcall(function()
                    if inst:IsA("BoolValue") then inst.Value = false
                    else inst.Value = 0 end
                end)
            end
        end
    end
end

local function fireMove(action, root, model, ball, hb)
    if not OfficialPathEnabled or not ballInteractRemote then return false end
    return pcall(function()
        local look, tilt = getAimLook(root)
        local charge = 1
        if (action == "Spike" or action == "spike") then
            if SpikeBoostEnabled then charge = math.clamp(tonumber(SpikeBoostCharge) or 1, 0, 1) end
            if PerfectSpikeAssistEnabled then charge = 1 end
        end
        local payload = {
            Action = action, Charge = charge, LookVector = look,
            TiltDirection = tilt, MoveDirection = tilt, From = "Client", SpecialCharge = 0.000001,
        }
        local id = getBallId(model)
        if id then payload.BallId = id end
        applyNoCooldownToPayload(payload)
        if ballInteractRemote:IsA("RemoteFunction") then
            ballInteractRemote:InvokeServer(payload)
        else
            ballInteractRemote:FireServer(payload)
        end
    end)
end

local function fireJump()
    cacheBallRemotes()
    pcall(function()
        if not ballJumpRemote then return end
        if ballJumpRemote:IsA("RemoteFunction") then
            ballJumpRemote:InvokeServer()
        else
            ballJumpRemote:FireServer()
        end
    end)
end

local function findBallNear(maxDist)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestD, bestModel, bestBall, bestHb = nil, maxDist or 22, nil, nil, nil
    for _, v in pairs(workspace:GetChildren()) do
        local n = tostring(v.Name or "")
        if (n:find("CLIENT_BALL") or n:find("BALL")) and v:IsA("Model") then
            local ball = v:FindFirstChildWhichIsA("BasePart")
            if ball then
                local hb = v:FindFirstChild("ExtendedHitbox")
                local aim = hb or ball
                local d = (root.Position - aim.Position).Magnitude
                if d < bestD then
                    bestD, best, bestModel, bestBall, bestHb = d, aim, v, ball, hb
                end
            end
        end
    end
    return best, bestModel, bestBall, bestHb
end

local function stopSpikeAnims(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local ok, n = pcall(function()
            local a = track.Animation
            if a then return (tostring(a.AnimationId or "") .. " " .. tostring(a.Name or "")):lower() end
            return tostring(track.Name or ""):lower()
        end)
        n = (ok and n) or ""
        if n:find("spike") or n:find("attack") or n:find("swing") or n:find("hit")
            or n:find("set") or n:find("bump") or n:find("receive") then
            pcall(function() track:Stop(0) end)
            pcall(function() track:AdjustSpeed(0) end)
        end
    end
end

-- Temporary combat-anim + SFX mute (session for silent spike)
local silentMute = { active = false, conns = {}, untilT = 0 }

local function silentMuteStart(duration)
    duration = duration or 0.35
    silentMute.active = true
    silentMute.untilT = os.clock() + duration
    local char = LocalPlayer.Character
    if char then
        stopSpikeAnims(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if animator then
            table.insert(silentMute.conns, animator.AnimationPlayed:Connect(function(track)
                if not silentMute.active or os.clock() > silentMute.untilT then return end
                pcall(function() track:Stop(0) end)
            end))
        end
    end
    -- damp loud sounds briefly
    pcall(function()
        for _, s in ipairs(workspace:GetDescendants()) do
            if s:IsA("Sound") and s.IsPlaying then
                local n = string.lower(s.Name)
                if n:find("spike") or n:find("hit") or n:find("swing") then
                    pcall(function() s.Volume = 0 end)
                end
            end
        end
    end)
end

local function silentMuteStop()
    silentMute.active = false
    for _, c in ipairs(silentMute.conns) do
        pcall(function() c:Disconnect() end)
    end
    silentMute.conns = {}
end

local function getDoMoveRemote()
    local ok, remote = pcall(function()
        return ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BallService.RE.DoMove
    end)
    if ok and remote then return remote end
    return nil
end

local function doSilentSpike()
    if not SilentSpikeEnabled then return end
    if tick() - lastSilentSpike < 0.12 then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    lastSilentSpike = tick()

    local cam = workspace.CurrentCamera
    local look = cam and cam.CFrame.LookVector or root.CFrame.LookVector
    -- face camera horizontally (stay grounded — no jump)
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude > 0.01 then
        pcall(function()
            root.CFrame = CFrame.lookAt(root.Position, root.Position + flat.Unit)
        end)
    end

    silentMuteStart(0.4)

    local fired = false
    -- Primary path: fire DoMove client event (same idea as popular hubs)
    pcall(function()
        local doMove = getDoMoveRemote()
        if doMove and type(firesignal) == "function" then
            firesignal(doMove.OnClientEvent, "Spike", false, false, look)
            fired = true
        elseif doMove and type(getconnections) == "function" then
            for _, conn in ipairs(getconnections(doMove.OnClientEvent)) do
                pcall(function()
                    if conn.Fire then
                        conn:Fire("Spike", false, false, look)
                    elseif conn.Function then
                        conn.Function("Spike", false, false, look)
                    end
                end)
            end
            fired = true
        end
    end)

    -- Fallback: Interact path if DoMove signal path failed
    if not fired then
        pcall(function()
            cacheBallRemotes()
            local aim, model, ball, hb = findBallNear(28)
            if model then
                fireMove("Spike", root, model, ball, hb)
            end
        end)
    end

    task.delay(0.05, function() stopSpikeAnims(LocalPlayer.Character) end)
    task.delay(0.15, function() stopSpikeAnims(LocalPlayer.Character) end)
    task.delay(0.35, function()
        silentMuteStop()
        stopSpikeAnims(LocalPlayer.Character)
    end)
end

local function onSilentSpikeKey()
    if not SilentSpikeEnabled then return end
    doSilentSpike()
end

local function destroySilentSpikeButton()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local old = pg:FindFirstChild("KingsHub_SilentSpike")
    if old then old:Destroy() end
end

local function createSilentSpikeButton()
    destroySilentSpikeButton()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "KingsHub_SilentSpike"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) end
    end)
    gui.Parent = pg

    local btn = Instance.new("TextButton")
    btn.Name = "Pico"
    btn.Size = UDim2.new(0, 64, 0, 64)
    btn.Position = UDim2.new(0.82, 0, 0.72, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
    btn.BackgroundTransparency = 0.15
    btn.Text = L("pico")
    btn.TextColor3 = Color3.fromRGB(80, 255, 160)
    btn.TextSize = 17
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = true
    btn.ZIndex = 10
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 255, 160)
    stroke.Thickness = 2.5
    stroke.Transparency = 0.2
    stroke.Parent = btn

    local dragging = false
    local moved = false
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                doSilentSpike()
            end
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragStart then return end
        if SilentSpikeLockBtn then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if delta.Magnitude > 12 then moved = true end
            if moved then
                btn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

local function autoStrongServe()
    local pg = LocalPlayer.PlayerGui
    local power = pg and pg:FindFirstChild("Interface") and pg.Interface:FindFirstChild("Game") and pg.Interface.Game:FindFirstChild("Power")
    if not power or not power.Visible then return end
    local arrow, extra = power:FindFirstChild("Arrow"), power:FindFirstChild("ExtraPower")
    if not arrow or not extra then return end
    local ax = arrow.AbsolutePosition.X + arrow.AbsoluteSize.X / 2
    local left, right = extra.AbsolutePosition.X, extra.AbsolutePosition.X + extra.AbsoluteSize.X
    local overlapY = arrow.AbsolutePosition.Y < extra.AbsolutePosition.Y + extra.AbsoluteSize.Y
        and arrow.AbsolutePosition.Y + arrow.AbsoluteSize.Y > extra.AbsolutePosition.Y
    if ax >= left and ax <= right and overlapY then
        local VIM = game:GetService("VirtualInputManager")
        local cy = arrow.AbsolutePosition.Y + arrow.AbsoluteSize.Y / 2
        VIM:SendMouseButtonEvent(ax, cy, 0, true, game, 1)
        task.wait(0.04)
        VIM:SendMouseButtonEvent(ax, cy, 0, false, game, 1)
    end
end

-- light namecall hook
pcall(function()
    local originalNamecall
    local handler = function(self, ...)
        local method = getnamecallmethod()
        local n = select("#", ...)
        local args = { ... }
        if method == "InvokeServer" or method == "FireServer" then
            local name = ""
            pcall(function() name = tostring(self.Name or "") end)
            if name == "Interact" and type(args[1]) == "table" then
                local data = args[1]
                if DirectionalHitEnabled then
                    local cam = workspace.CurrentCamera
                    if cam and data.LookVector ~= nil then
                        local look = cam.CFrame.LookVector
                        local y = (typeof(data.LookVector) == "Vector3") and data.LookVector.Y or 0
                        local lv = Vector3.new(look.X, y, look.Z)
                        if lv.Magnitude > 0.001 then data.LookVector = lv.Unit end
                    end
                end
                local act = tostring(data.Action or "")
                if act == "Spike" or act == "spike" then
                    if SpikeBoostEnabled then data.Charge = math.clamp(tonumber(SpikeBoostCharge) or 1, 0, 1) end
                    if PerfectSpikeAssistEnabled then
                        data.Charge = 1
                        if not data.SpecialCharge or (tonumber(data.SpecialCharge) or 0) < 0.000001 then
                            data.SpecialCharge = 0.000001
                        end
                    end
                end
                applyNoCooldownToPayload(data)
            end
            if AutoStrongServeEveryServeEnabled and name == "Serve" and args[2] ~= nil then
                args[2] = ServeBoostPower
            end
        end
        return originalNamecall(self, unpack(args, 1, n))
    end
    task.defer(function()
        task.wait(1)
        pcall(function()
            if type(newcclosure) == "function" then
                originalNamecall = hookmetamethod(game, "__namecall", newcclosure(handler))
            else
                originalNamecall = hookmetamethod(game, "__namecall", handler)
            end
        end)
    end)
end)

-- CORNER AIMBOT (RNCRAZY)
local cam = workspace.CurrentCamera
local courtCenter = Vector3.new(-393, -24.2, -1356.6)
local courtW, courtL = 52, 102
local netZ, floorY = -1356.6, -24.2
local CornerFOV = 250
local cornerMySide, cornerCurrent, cornerPinning = nil, nil, false
local cornerPts = { Left = Vector3.zero, Right = Vector3.zero }
local cornerLastJump, cornerWasAir = 0, false
local cornerFolder = Instance.new("Folder")
cornerFolder.Name = "CornerAimVFX"
cornerFolder.Parent = workspace

local function makeMark(name, pos)
    local p = Instance.new("Part")
    p.Name, p.Anchored, p.CanCollide = name, true, false
    p.CanQuery, p.CanTouch = false, false
    p.Material = Enum.Material.SmoothPlastic
    p.Color = Color3.fromRGB(25, 28, 30)
    p.Shape = Enum.PartType.Ball
    p.Size = Vector3.new(3, 1.6, 3)
    p.Position, p.Transparency = pos, 0.35
    p.Parent = cornerFolder
    return p
end

local function findCourt()
    local map = workspace:FindFirstChild("Map")
    local court = map and map:FindFirstChild("Court")
    if court and court:IsA("BasePart") then
        courtCenter, courtW, courtL = court.Position, court.Size.X, court.Size.Z
        netZ, floorY = court.Position.Z, court.Position.Y
    end
end
findCourt()

local function getSide()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return cornerMySide end
    local d = hrp.Position.Z - netZ
    if math.abs(d) < 6 then return cornerMySide end
    return d > 0 and 1 or -1
end

local function corners()
    local s = getSide()
    if s then cornerMySide = s end
    if not cornerMySide then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        cornerMySide = (hrp and hrp.CFrame.LookVector.Z > 0) and -1 or 1
    end
    local enemy = -cornerMySide
    local deepZ = courtCenter.Z + enemy * (courtL / 2 - 3)
    return {
        Right = Vector3.new(courtCenter.X + (courtW / 2 - 2.5), floorY + 1, deepZ),
        Left = Vector3.new(courtCenter.X - (courtW / 2 - 2.5), floorY + 1, deepZ),
    }
end

cornerPts = corners()
local leftMark = makeMark("LeftHalf", Vector3.new(cornerPts.Left.X, floorY + 0.8, cornerPts.Left.Z))
local rightMark = makeMark("RightHalf", Vector3.new(cornerPts.Right.X, floorY + 0.8, cornerPts.Right.Z))

local function refreshMarks()
    cornerPts = corners()
    leftMark.Position = Vector3.new(cornerPts.Left.X, floorY + 0.8, cornerPts.Left.Z)
    rightMark.Position = Vector3.new(cornerPts.Right.X, floorY + 0.8, cornerPts.Right.Z)
end

local function pickCorner()
    local m = UserInputService:GetMouseLocation()
    local inset = GuiService:GetGuiInset()
    local mp = Vector2.new(m.X, m.Y - inset.Y)
    local best, bestD = nil, CornerFOV
    for name, pos in pairs(cornerPts) do
        local sp, vis = cam:WorldToViewportPoint(pos + Vector3.new(0, 2, 0))
        if vis then
            local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
            if d < bestD then bestD, best = d, name end
        end
    end
    return best
end

local function snapTo(pos)
    if cornerPinning then return end
    cornerPinning = true
    task.spawn(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hrp then cornerPinning = false return end
        local oldAuto = hum and hum.AutoRotate
        if hum then hum.AutoRotate = false end
        local start = os.clock()
        while os.clock() - start < 1.2 do
            if not AimbotCornerEnabled or not cornerPinning then break end
            hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then break end
            hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local st = hum:GetState()
                if (st == Enum.HumanoidStateType.Landed or st == Enum.HumanoidStateType.Running)
                    and (hrp.Position.Y - floorY) < 4 and os.clock() - start > 0.3 then break end
            end
            local hp = hrp.Position
            hrp.CFrame = CFrame.lookAt(hp, Vector3.new(pos.X, hp.Y, pos.Z))
            task.wait()
        end
        if hum and oldAuto ~= nil then hum.AutoRotate = oldAuto end
        cornerPinning = false
    end)
end

local function doJumpAim()
    if not AimbotCornerEnabled or cornerPinning then return end
    local pick = pickCorner() or cornerCurrent
    if pick and cornerPts[pick] then
        cornerCurrent = pick
        cornerLastJump = os.clock()
        snapTo(cornerPts[pick])
    end
end

local function applyJumpBoost()
    if not JumpBoostEnabled then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        if hum.UseJumpPower then hum.JumpPower = 50 * JumpBoostMult
        else hum.JumpHeight = 7.2 * JumpBoostMult end
    end)
end

-- DESYNC (animation + light network break; full reverse = rejoin)
local DESYNC_ANIM_KEYWORDS = {
    "spike", "set", "bump", "receive", "attack", "hit", "swing", "dig",
}

local function isDesyncAnim(track)
    if not track then return false end
    local ok, name = pcall(function()
        local a = track.Animation
        if a then
            local id = tostring(a.AnimationId or "")
            local n = tostring(a.Name or "")
            return (id .. " " .. n):lower()
        end
        return tostring(track.Name or ""):lower()
    end)
    if not ok or not name then return false end
    -- keep pure locomotion; strip combat anims (FurHub-style)
    local keys = {
        "spike", "set", "bump", "receive", "dive", "block", "hit", "attack",
        "smash", "kill", "toss", "serve", "special", "ability", "ult",
        "action", "swing", "arm",
    }
    for _, k in ipairs(keys) do
        if name:find(k, 1, true) then return true end
    end
    return false
end

local function stripCharacterAnims(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if isDesyncAnim(track) then
            pcall(function() track:Stop(0) end)
            pcall(function() track:AdjustSpeed(0) end)
            pcall(function() track:AdjustWeight(0, 0) end)
        end
    end
end

local function disableDesync()
    for _, c in pairs(desyncConns) do
        pcall(function() c:Disconnect() end)
    end
    desyncConns = {}
    DesyncEnabled = false
    -- best-effort FFlag restore (may not apply on all executors)
    pcall(function()
        if type(setfflag) == "function" then
            setfflag("DFIntS2PhysicsSenderRate", "60")
            setfflag("DFIntMaxInterpolationDistance", "150")
        end
    end)
end

local function enableDesync()
    if DesyncEnabled and #desyncConns > 0 then return end
    disableDesync()
    DesyncEnabled = true

    local function hookChar(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end

        table.insert(desyncConns, animator.AnimationPlayed:Connect(function(track)
            if not DesyncEnabled then return end
            if isDesyncAnim(track) then
                pcall(function()
                    track:Stop(0)
                    track:AdjustSpeed(0)
                    track:AdjustWeight(0, 0)
                end)
            end
        end))

        -- also stop tracks that were already playing
        stripCharacterAnims(char)

        -- try AnimationController PlayAnimation intercept (FurHub path)
        pcall(function()
            local rf = game:GetService("ReplicatedFirst")
            local ctrl = rf:FindFirstChild("Controllers")
            local ac = ctrl and ctrl:FindFirstChild("AnimationController")
            if ac then
                local mod = require(ac)
                if type(mod) == "table" and type(mod.PlayAnimation) == "function" and not mod.__kh_hooked then
                    local oldPlay = mod.PlayAnimation
                    mod.PlayAnimation = function(self, name, ...)
                        if DesyncEnabled and type(name) == "string" then
                            local l = name:lower()
                            if l:find("spike") or l:find("set") or l:find("bump")
                                or l:find("receive") or l:find("dive") or l:find("block")
                                or l:find("serve") or l:find("special") then
                                return nil
                            end
                        end
                        return oldPlay(self, name, ...)
                    end
                    mod.__kh_hooked = true
                end
            end
        end)
    end

    if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
    table.insert(desyncConns, LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.15)
        if DesyncEnabled then hookChar(char) end
    end))

    -- Network-ish desync flags (same idea many hubs use)
    pcall(function()
        if type(setfflag) == "function" then
            setfflag("DFIntTimestepArbiterThresholdCappedMaxFrameMs", "999")
            setfflag("DFIntTimestepArbiterThresholdCappedMinFrameMs", "999")
            setfflag("DFIntS2PhysicsSenderRate", "10")
            setfflag("DFIntMaxInterpolationDistance", "0")
            setfflag("DFIntMaxFramesBuffer", "1")
        end
    end)
end

-- CAMERA JUMP
UserInputService.JumpRequest:Connect(function()
    if AimbotCornerEnabled then return end
    if not CameraJumpEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local c = workspace.CurrentCamera
    if not c then return end
    local look = c.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude > 0 then
        root.CFrame = CFrame.lookAt(root.Position, root.Position + flat.Unit)
    end
end)


-- BAR LOCKS (local SpecialController / charge hooks)
local barLockState = { tshPatched = false, roninPatched = false, kazanaPatched = false, specialCtrl = nil }

local function getSpecialController()
    if barLockState.specialCtrl then return barLockState.specialCtrl end
    local ok, ctrl = pcall(function()
        local c = game:GetService("ReplicatedFirst"):FindFirstChild("Controllers")
        local m = c and c:FindFirstChild("SpecialController")
        if m then return require(m) end
        return nil
    end)
    if ok and type(ctrl) == "table" then
        barLockState.specialCtrl = ctrl
        return ctrl
    end
    return nil
end

local function patchTSHBarLock()
    if barLockState.tshPatched then return end
    local sc = getSpecialController()
    if not sc or type(sc.ChargeSpring) ~= "table" then return end
    local spring = sc.ChargeSpring
    local realGet = spring.get
    if type(realGet) ~= "function" then return end
    local tshStyles = {
        TimeskipShoyo = true, TimeskipShoyo2 = true, TimeskipShoyo3 = true, TimeskipShoyo4 = true,
    }
    rawset(spring, "get", function(self, asDependency)
        local ok, real = pcall(realGet, self, asDependency)
        if TSHBarLockEnabled then
            local style = tostring(LocalPlayer:GetAttribute("Gameplay_Style") or "")
            if tshStyles[style] then
                return 1
            end
        end
        return ok and real or 0
    end)
    barLockState.tshPatched = true
end

local function patchRoninBarLock()
    if barLockState.roninPatched then return end
    local sc = getSpecialController()
    if not sc then return end
    -- Force attribute / spring if present
    pcall(function()
        if type(sc.ChargeSpring) == "table" and type(sc.ChargeSpring.get) == "function" and not barLockState.tshPatched then
            -- shared spring already handled in TSH patch path when both on
        end
    end)
    barLockState.roninPatched = true
end

local function applyBarLocksTick()
    if TSHBarLockEnabled then
        pcall(patchTSHBarLock)
        pcall(function()
            local style = tostring(LocalPlayer:GetAttribute("Gameplay_Style") or "")
            if style:find("Timeskip") or style:find("Shoyo") then
                LocalPlayer:SetAttribute("SpecialCharge", 1)
            end
        end)
    end
    if RoninBarLockEnabled then
        pcall(patchRoninBarLock)
        pcall(function()
            local style = tostring(LocalPlayer:GetAttribute("Gameplay_Style") or "")
            if style:find("Samurai") or style:find("Ronin") then
                LocalPlayer:SetAttribute("SpecialCharge", 1)
            end
        end)
    end
    if KazanaBarLockEnabled then
        pcall(function()
            local style = tostring(LocalPlayer:GetAttribute("Gameplay_Style") or "")
            if style:find("Kazana") then
                LocalPlayer:SetAttribute("SpecialCharge", 1)
            end
            -- try SpecialController fields
            local sc = getSpecialController()
            if sc and type(sc.ChargeSpring) == "table" and type(sc.ChargeSpring.set) == "function" then
                pcall(function() sc.ChargeSpring:set(1) end)
            end
        end)
    end
end

local function runMaxPowerSpike()
    if not MaxPowerSpikeEnabled then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall then return end
    if hum.MoveDirection.Magnitude > 0.05 then return end
    maxPowerPhase = maxPowerPhase + 0.22
    hum:Move(Vector3.new(math.sin(maxPowerPhase), 0, math.cos(maxPowerPhase)), true)
end

-- ANTI-MOD
local function isModerator(name)
    local lower = string.lower(tostring(name or ""))
    for _, m in ipairs(moderatorList) do
        if lower:find(string.lower(m), 1, true) then return true end
    end
    return false
end

local function checkForModerators()
    if not AntiModEnabled then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isModerator(plr.Name) then
            notify("Moderator detected: " .. plr.Name .. " — leaving", 5)
            pcall(function() LocalPlayer:Kick("Anti-Mod: " .. plr.Name) end)
            return
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if AntiModEnabled and isModerator(plr.Name) then
        notify("Moderator joined: " .. plr.Name, 5)
        pcall(function() LocalPlayer:Kick("Anti-Mod: " .. plr.Name) end)
    end
end)

-- STREAMER MODE
local function hidePlayerName(p)
    if not p or p == LocalPlayer then return end
    pcall(function()
        if streamerOriginalDisplay[p] == nil then
            streamerOriginalDisplay[p] = {
                DisplayName = p.DisplayName,
                Name = p.Name,
            }
        end
    end)
    local char = p.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            if streamerOriginalDisplay[p] and streamerOriginalDisplay[p].DisplayDistanceType == nil then
                streamerOriginalDisplay[p].DisplayDistanceType = hum.DisplayDistanceType
                streamerOriginalDisplay[p].NameDisplayDistance = hum.NameDisplayDistance
                streamerOriginalDisplay[p].HealthDisplayDistance = hum.HealthDisplayDistance
            end
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            hum.NameDisplayDistance = 0
            hum.HealthDisplayDistance = 0
        end)
    end
    -- hide nametag billboards / overhead text
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BillboardGui") then
            pcall(function()
                if not streamerOriginalDisplay[d] then
                    streamerOriginalDisplay[d] = d.Enabled
                end
                d.Enabled = false
            end)
        elseif d:IsA("TextLabel") or d:IsA("TextBox") then
            local parent = d.Parent
            if parent and (parent:IsA("BillboardGui") or parent:IsA("SurfaceGui")) then
                pcall(function()
                    if streamerOriginalDisplay[d] == nil then
                        streamerOriginalDisplay[d] = d.Text
                    end
                    d.Text = ""
                end)
            end
        end
    end
end

local function restorePlayerName(p)
    if not p then return end
    local char = p.Character
    if not char then return end
    local data = streamerOriginalDisplay[p]
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and type(data) == "table" then
        pcall(function()
            if data.DisplayDistanceType ~= nil then
                hum.DisplayDistanceType = data.DisplayDistanceType
            end
            if data.NameDisplayDistance ~= nil then
                hum.NameDisplayDistance = data.NameDisplayDistance
            end
            if data.HealthDisplayDistance ~= nil then
                hum.HealthDisplayDistance = data.HealthDisplayDistance
            end
        end)
    end
    for _, d in ipairs(char:GetDescendants()) do
        if streamerOriginalDisplay[d] ~= nil then
            pcall(function()
                if d:IsA("BillboardGui") then
                    d.Enabled = streamerOriginalDisplay[d] and true or false
                elseif d:IsA("TextLabel") or d:IsA("TextBox") then
                    d.Text = tostring(streamerOriginalDisplay[d])
                end
            end)
        end
    end
end

local function applyStreamerMode()
    for _, p in pairs(Players:GetPlayers()) do
        hidePlayerName(p)
    end
end

local function disableStreamerMode()
    for _, p in pairs(Players:GetPlayers()) do
        restorePlayerName(p)
    end
    streamerOriginalDisplay = {}
end

-- keep streamer applied on new characters
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if StreamerModeEnabled then
            task.defer(function() hidePlayerName(p) end)
        end
    end)
end)
for _, p in pairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function()
        if StreamerModeEnabled then
            task.defer(function() hidePlayerName(p) end)
        end
    end)
end

-- PREDICT AIM
local function clearPredictAim()
    for plr, obj in pairs(PredictAimObjects) do
        pcall(function() if obj then obj:Destroy() end end)
        PredictAimObjects[plr] = nil
    end
end

local function updatePredictAim()
    if not PredictAimEnabled then return end
    local len = math.max(5, PredictAimLength or 25)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                if PredictAimObjects[plr] then
                    PredictAimObjects[plr]:Destroy()
                    PredictAimObjects[plr] = nil
                end
            else
                local dir = root.CFrame.LookVector
                local start = root.Position + Vector3.new(0, 1.5, 0)
                local finish = start + dir * len
                local line = PredictAimObjects[plr]
                if not line or not line.Parent then
                    line = Instance.new("Part")
                    line.Name = "PredictAimLine"
                    line.Anchored = true
                    line.CanCollide = false
                    line.CanQuery = false
                    line.Material = Enum.Material.Neon
                    line.Color = PredictAimColor
                    line.Transparency = 0.35
                    line.Parent = workspace
                    PredictAimObjects[plr] = line
                end
                local mid = (start + finish) / 2
                local dist = (finish - start).Magnitude
                line.Size = Vector3.new(0.2, 0.2, dist)
                line.CFrame = CFrame.lookAt(mid, finish)
                line.Color = PredictAimColor
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    if PredictAimObjects[plr] then
        PredictAimObjects[plr]:Destroy()
        PredictAimObjects[plr] = nil
    end
end)


-- OPTIMAL SPOT (where to stand for the ball)
local function destroyOptimalSpot()
    if optimalSpotPart then
        pcall(function() optimalSpotPart:Destroy() end)
        optimalSpotPart = nil
    end
end

local function getBallPhysics()
    for _, v in pairs(workspace:GetChildren()) do
        local n = tostring(v.Name or "")
        if (n:find("CLIENT_BALL") or n:find("BALL")) and v:IsA("Model") then
            local ball = v:FindFirstChildWhichIsA("BasePart")
            if ball then
                return ball, ball.AssemblyLinearVelocity
            end
        end
    end
    return nil, nil
end

local function estimateLanding(ball, vel)
    local pos = ball.Position
    local groundY = pos.Y
    -- try court height
    pcall(function()
        local map = workspace:FindFirstChild("Map")
        local court = map and map:FindFirstChild("Court")
        if court then groundY = court.Position.Y + (court.Size.Y / 2) + 0.5 end
    end)
    if not vel or vel.Magnitude < 0.5 then
        return Vector3.new(pos.X, groundY, pos.Z)
    end
    local g = workspace.Gravity
    if g < 1 then g = 196.2 end
    local y0 = pos.Y
    local vy = vel.Y
    -- time to reach groundY: y0 + vy*t - 0.5*g*t^2 = groundY
    local a = -0.5 * g
    local b = vy
    local c = y0 - groundY
    local disc = b * b - 4 * a * c
    local t = nil
    if disc >= 0 and math.abs(a) > 1e-6 then
        local s = math.sqrt(disc)
        local t1 = (-b + s) / (2 * a)
        local t2 = (-b - s) / (2 * a)
        if t1 > 0.05 and t2 > 0.05 then t = math.min(t1, t2)
        elseif t1 > 0.05 then t = t1
        elseif t2 > 0.05 then t = t2
        end
    end
    if not t or t > 4 then
        return Vector3.new(pos.X + vel.X * 0.35, groundY, pos.Z + vel.Z * 0.35)
    end
    local land = Vector3.new(pos.X + vel.X * t, groundY, pos.Z + vel.Z * t)
    -- stand slightly behind the ball path (toward your current position)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local away = Vector3.new(land.X - root.Position.X, 0, land.Z - root.Position.Z)
        if away.Magnitude > 0.1 then
            land = land - away.Unit * 1.2 -- one step behind contact point
            land = Vector3.new(land.X, groundY, land.Z)
        end
    end
    return land
end

local function updateOptimalSpot()
    if not OptimalSpotEnabled then return end
    local ball, vel = getBallPhysics()
    if not ball then
        if optimalSpotPart then optimalSpotPart.Transparency = 1 end
        return
    end
    local land = estimateLanding(ball, vel)
    if not optimalSpotPart or not optimalSpotPart.Parent then
        local p = Instance.new("Part")
        p.Name = "KingsHub_OptimalSpot"
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(80, 220, 255)
        p.Size = Vector3.new(3.2, 0.2, 3.2)
        p.Transparency = 0.35
        p.Shape = Enum.PartType.Cylinder
        p.Parent = workspace
        optimalSpotPart = p
        -- cylinder default is Y-aligned wrong; orient flat
        -- Use a flat disc via size + orientation
        p.Size = Vector3.new(0.25, 3.4, 3.4)
    end
    optimalSpotPart.Transparency = 0.3
    optimalSpotPart.CFrame = CFrame.new(land) * CFrame.Angles(0, 0, math.rad(90))
end


-- SCORE EFFECT
local scoreEffect = "SupernovaScoreEffect"
local scoreEffectList = {}
local scoreEffectConns = {}
local scoreBusy, scoreScored = false, false

local function buildScoreEffectList()
    scoreEffectList = {}
    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        if not assets then return end
        local se = assets:FindFirstChild("ScoreEffect")
        if se then
            for _, c in ipairs(se:GetChildren()) do
                if c:IsA("ModuleScript") then table.insert(scoreEffectList, c.Name) end
            end
        end
        local fx = assets:FindFirstChild("Effects")
        if fx then
            for _, n in ipairs({"GroundHit1", "GroundHit2"}) do
                if fx:FindFirstChild(n) then table.insert(scoreEffectList, n) end
            end
        end
    end)
    table.sort(scoreEffectList)
    if #scoreEffectList == 0 then table.insert(scoreEffectList, "SupernovaScoreEffect") end
end
buildScoreEffectList()

local function disableScoreEffect()
    for _, c in pairs(scoreEffectConns) do pcall(function() c:Disconnect() end) end
    scoreEffectConns = {}
    scoreBusy, scoreScored = false, false
end

local function enableScoreEffect()
    if #scoreEffectConns > 0 then return end
    local hitGround
    pcall(function()
        hitGround = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BallService.RE.HitGround
    end)
    if not hitGround then return end
    table.insert(scoreEffectConns, hitGround.OnClientEvent:Connect(function(...)
        for _, v in pairs({...}) do
            if tostring(v) == LocalPlayer.Name then scoreScored = true break end
        end
    end))
    local function fireFx(pos)
        if scoreBusy or not scoreScored or not ScoreEffectEnabled then return end
        scoreBusy = true
        local effectName, useAlt = scoreEffect, true
        if effectName == "GroundHit1" or effectName == "GroundHit2" then
            useAlt = effectName == "GroundHit2"
            effectName = nil
        end
        if firesignal then
            pcall(function()
                firesignal(hitGround.OnClientEvent, table.unpack({
                    pos, useAlt, false, 5, effectName,
                    workspace:FindFirstChild(LocalPlayer.Name),
                    Vector3.new(-0.0000020885916001134, 1, -0.000004710930170404),
                }, 1, 7))
            end)
        end
        task.wait(0.5)
        scoreBusy, scoreScored = false, false
    end
    table.insert(scoreEffectConns, workspace.ChildAdded:Connect(function(c)
        if c.Name == "HitIndicator" and c.Color == Color3.fromRGB(0, 255, 0) then fireFx(c.Position) end
    end))
end

-- POTATO MODE
local potatoSaved = {}
local function potatoSet(obj, prop, val)
    if not obj then return end
    local key = tostring(obj) .. "." .. prop
    if potatoSaved[key] == nil then
        local ok, v = pcall(function() return obj[prop] end)
        if ok then potatoSaved[key] = { obj = obj, prop = prop, val = v } end
    end
    pcall(function() obj[prop] = val end)
end


-- UNLOCK ALL COSMETICS (local inventory only — not styles/gems/yen/spins)
local unlockAllSavedInventory = nil
local UNLOCK_COSMETIC_TYPES = {
    Title = true,
    ScoreEffect = true,
    Ball = true,
    Jersey = true,
    PlayerCard = true,
    ProfileArt = true,
    Card = true,
    Emote = true,
    Banner = true,
    NameTag = true,
}

local function getInventoryController()
    local ok, knit = pcall(function()
        return require(ReplicatedStorage.Packages.Knit)
    end)
    if not ok or type(knit) ~= "table" or type(knit.GetController) ~= "function" then
        return nil
    end
    local ok2, inv = pcall(function() return knit.GetController("InventoryController") end)
    if ok2 and type(inv) == "table" then return inv end
    return nil
end

local function getItemType(moduleScript)
    local ok, data = pcall(require, moduleScript)
    if ok and type(data) == "table" and data.Type then
        return tostring(data.Type), data
    end
    return nil, nil
end

local function applyUnlockAllVisual(root)
    if not root then return end
    for _, gui in ipairs(root:GetDescendants()) do
        if gui:IsA("GuiObject") then
        local n = string.lower(tostring(gui.Name or ""))
        if n:find("lock", 1, true) or n:find("padlock", 1, true) or n:find("blocked", 1, true) then
            if gui:IsA("ImageLabel") or gui:IsA("ImageButton") or gui:IsA("Frame") or gui:IsA("TextLabel") then
                pcall(function() gui.Visible = false end)
            end
        end
        if gui:IsA("GuiButton") or gui:IsA("TextButton") or gui:IsA("ImageButton") then
            pcall(function()
                gui.Active = true
                gui.Selectable = true
            end)
        end
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local t = string.lower(tostring(gui.Text or ""))
            if t:find("locked") or t:find("bloqueado") or t:find("not owned") or t:find("own this") then
                pcall(function() gui.Visible = false end)
            end
        end
        end
    end
end

local function injectCosmeticInventory()
    local invCtrl = getInventoryController()
    if not invCtrl or not invCtrl.Inventory then return false, "no InventoryController" end

    local okGet, current = pcall(function() return invCtrl.Inventory:get() end)
    if not okGet or type(current) ~= "table" then return false, "inventory get failed" end

    if not unlockAllSavedInventory then
        local copy = {}
        for k, v in pairs(current) do copy[k] = v end
        unlockAllSavedInventory = copy
    end

    local expanded = {}
    for k, v in pairs(unlockAllSavedInventory) do
        expanded[k] = v
    end

    local entities = ReplicatedStorage:FindFirstChild("Content")
    entities = entities and entities:FindFirstChild("Item")
    entities = entities and entities:FindFirstChild("Entities")
    if not entities then return false, "no Item.Entities" end

    local added = 0
    for _, mod in ipairs(entities:GetChildren()) do
        if mod:IsA("ModuleScript") and not expanded[mod.Name] then
            local typ = getItemType(mod)
            if typ and UNLOCK_COSMETIC_TYPES[typ] then
                expanded[mod.Name] = 1
                added = added + 1
            end
        end
    end

    local okSet = pcall(function() invCtrl.Inventory:set(expanded) end)
    if not okSet then return false, "inventory set failed" end
    return true, added
end

local function restoreCosmeticInventory()
    if not unlockAllSavedInventory then return end
    local invCtrl = getInventoryController()
    if invCtrl and invCtrl.Inventory then
        pcall(function() invCtrl.Inventory:set(unlockAllSavedInventory) end)
    end
    unlockAllSavedInventory = nil
end

local function disableUnlockAllVisual()
    for _, c in pairs(unlockAllConns) do
        pcall(function() c:Disconnect() end)
    end
    unlockAllConns = {}
    UnlockAllVisualEnabled = false
    pcall(restoreCosmeticInventory)
    pcall(function() LocalPlayer:SetAttribute("KH_UnlockAllVisual", nil) end)
end

local function enableUnlockAllVisual()
    disableUnlockAllVisual()
    UnlockAllVisualEnabled = true

    local ok, info = injectCosmeticInventory()
    if ok then
        notify(L("unlock_on") .. " (+" .. tostring(info) .. ")", 5)
    else
        notify(L("unlock_on") .. " (UI only)", 5)
    end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        applyUnlockAllVisual(pg)
        table.insert(unlockAllConns, pg.DescendantAdded:Connect(function()
            if not UnlockAllVisualEnabled then return end
            task.defer(function()
                if UnlockAllVisualEnabled and pg then applyUnlockAllVisual(pg) end
            end)
        end))
    end

    -- periodic re-inject (some UIs refresh inventory)
    table.insert(unlockAllConns, RunService.Heartbeat:Connect(function()
        -- throttled outside; handled in main loop
    end))

    pcall(function() LocalPlayer:SetAttribute("KH_UnlockAllVisual", true) end)
end

local function enablePotatoMode()
    -- restore previous first so level switches cleanly
    for _, data in pairs(potatoSaved) do
        if type(data) == "table" and data.obj and data.prop then
            pcall(function() data.obj[data.prop] = data.val end)
        end
    end
    potatoSaved = {}

    local level = PerfLevel or "Balanced"
    -- Light: particles / trails only
    local function stripParticles(folder)
        if not folder then return end
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
                or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                potatoSet(d, "Enabled", false)
            end
        end
    end
    stripParticles(workspace:FindFirstChild("Map"))
    for _, plr in pairs(Players:GetPlayers()) do
        stripParticles(plr.Character)
    end

    if level == "Light" then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level05 end)
        return
    end

    -- Balanced: + lights, post effects, softer lighting
    potatoSet(Lighting, "GlobalShadows", false)
    potatoSet(Lighting, "EnvironmentDiffuseScale", 0)
    potatoSet(Lighting, "EnvironmentSpecularScale", 0)
    for _, c in ipairs(Lighting:GetChildren()) do
        if c:IsA("BloomEffect") or c:IsA("BlurEffect") or c:IsA("SunRaysEffect")
            or c:IsA("ColorCorrectionEffect") or c:IsA("DepthOfFieldEffect") then
            potatoSet(c, "Enabled", false)
        end
    end
    local function stripLights(folder)
        if not folder then return end
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                potatoSet(d, "Enabled", false)
            end
        end
    end
    stripLights(workspace:FindFirstChild("Map"))
    for _, plr in pairs(Players:GetPlayers()) do
        stripLights(plr.Character)
    end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level03 end)

    if level ~= "Maximum" then return end

    -- Maximum: sky/atmosphere/terrain + lowest quality
    potatoSet(Lighting, "FogEnd", 1e9)
    potatoSet(Lighting, "Brightness", 1)
    pcall(function() Lighting.Technology = Enum.Technology.Compatibility end)
    pcall(function() Lighting.Ambient = Color3.fromRGB(120, 120, 120) end)
    pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120) end)
    for _, c in ipairs(Lighting:GetChildren()) do
        if c:IsA("Sky") then
            potatoSet(c, "StarCount", 0)
            potatoSet(c, "CelestialBodiesShown", false)
        elseif c:IsA("Atmosphere") then
            potatoSet(c, "Density", 0)
            potatoSet(c, "Haze", 0)
        elseif c:IsA("Clouds") then
            potatoSet(c, "Cover", 0)
        end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        potatoSet(terrain, "Decoration", false)
        potatoSet(terrain, "WaterWaveSize", 0)
    end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end

local function disablePotatoMode()
    for _, data in pairs(potatoSaved) do
        if type(data) == "table" and data.obj and data.prop then
            pcall(function() data.obj[data.prop] = data.val end)
        end
    end
    potatoSaved = {}
end


local function doDataRollbackClassic()
    notify(L("rb_sending"), 4)
    local ok = pcall(function()
        local rf = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.SettingsService.RF
        rf.UpdateKeybind:InvokeServer("MouseButton1", true, "Spike\143")
    end)
    if not ok then notify(L("rb_fail"), 5) return end
    notify(L("rb_ok"), 4)
    task.wait(0.35)
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end

local function doDataRollbackBeta()
    -- BETA: Data Rollback
    notify(L("rb_sending"), 4)
    local ok = pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages", 5)
        local index = packages:WaitForChild("_Index", 5)
        local knitPkg = index:WaitForChild("sleitnick_knit@1.7.0", 5)
        local knit = knitPkg:WaitForChild("knit", 5)
        local services = knit:WaitForChild("Services", 5)
        local settings = services:WaitForChild("SettingsService", 5)
        local rfFolder = settings:WaitForChild("RF", 5)
        local update = rfFolder:WaitForChild("UpdateKeybind", 5)

        local zwsp = utf8.char(0x200B)
        local payloads = {
            { "MouseButton1", true, "Spike\143" },
            { "MouseButton1", true, "Spike" .. zwsp .. "\143" },
            { "MouseButton1", true, "Spike" },
        }
        for _, args in ipairs(payloads) do
            pcall(function()
                if update:IsA("RemoteFunction") then
                    update:InvokeServer(args[1], args[2], args[3])
                else
                    update:FireServer(args[1], args[2], args[3])
                end
            end)
            task.wait(0.05)
        end
    end)
    if not ok then
        notify(L("rb_fail"), 5)
        return
    end
    notify(L("rb_ok"), 4)
    task.wait(0.4)
    -- Teleport(placeId) only
    local teleported = pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
    if not teleported then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end



-- SINGLE THROTTLED LOOP
local tickCount = 0
local cornerMarksDimmed = false
local GREEN = Color3.fromRGB(0, 255, 170)
local DARK = Color3.fromRGB(25, 28, 30)

RunService.Heartbeat:Connect(function()
    tickCount = tickCount + 1

    -- Max power needs frequent updates when on
    if MaxPowerSpikeEnabled then
        pcall(runMaxPowerSpike)
    end
    if (TSHBarLockEnabled or RoninBarLockEnabled or KazanaBarLockEnabled) and tickCount % 6 == 0 then
        pcall(applyBarLocksTick)
    end

    -- Hitbox every 4 frames
    if HitboxEnabled and tickCount % 4 == 0 then
        pcall(modifyBallHitbox)
    end

    -- Serve UI every 3 frames
    if AutoStrongServeEnabled and tickCount % 3 == 0 then
        pcall(autoStrongServe)
    end

    -- Predict aim every 5 frames
    if PredictAimEnabled and tickCount % 5 == 0 then
        pcall(updatePredictAim)
    end
    if OptimalSpotEnabled and tickCount % 3 == 0 then
        pcall(updateOptimalSpot)
    end
    if NoCooldownEnabled and tickCount % 4 == 0 then
        pcall(runNoCooldownClear)
    end

    -- Rare tasks
    if tickCount % 15 == 0 then
        if JumpBoostEnabled then pcall(applyJumpBoost) end
        if DesyncEnabled then pcall(stripCharacterAnims, LocalPlayer.Character) end
    end
    if StreamerModeEnabled and tickCount % 45 == 0 then
        pcall(applyStreamerMode)
    end
    if UnlockAllVisualEnabled and tickCount % 90 == 0 then
        pcall(injectCosmeticInventory)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then pcall(applyUnlockAllVisual, pg) end
    end
    -- live users heartbeat ~ every 45s (Heartbeat ~60fps → 2700 ticks)
    if KingsOnlineEnabled and KingsOnlineApiUrl ~= "" and tickCount % 2700 == 0 then
        task.spawn(kingsOnlineHeartbeat)
    end
    if AntiModEnabled and tickCount % 60 == 0 then
        pcall(checkForModerators)
    end

    -- Corner aimbot (only when enabled)
    if AimbotCornerEnabled then
        cornerMarksDimmed = false
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if tickCount % 12 == 0 then
                local map = workspace:FindFirstChild("Map")
                local court = map and map:FindFirstChild("Court")
                if court and (court.Position - courtCenter).Magnitude > 20 then
                    findCourt()
                    cornerMySide = nil
                    refreshMarks()
                end
                local s = getSide()
                if s and s ~= cornerMySide then
                    cornerMySide = s
                    refreshMarks()
                end
            end
            if not cornerPinning and tickCount % 2 == 0 then
                local pick = pickCorner()
                if pick then cornerCurrent = pick end
                leftMark.Color = (pick == "Left") and GREEN or DARK
                rightMark.Color = (pick == "Right") and GREEN or DARK
                leftMark.Transparency = (pick == "Left") and 0.15 or 0.35
                rightMark.Transparency = (pick == "Right") and 0.15 or 0.35
            end
            local air = hrp.AssemblyLinearVelocity.Y > 8
            if not cornerWasAir and air and os.clock() - cornerLastJump > 0.5 then
                doJumpAim()
            end
            cornerWasAir = air
        end
    elseif not cornerMarksDimmed then
        leftMark.Color = DARK
        rightMark.Color = DARK
        leftMark.Transparency = 0.35
        rightMark.Transparency = 0.35
        cornerWasAir = false
        cornerMarksDimmed = true
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    cornerMySide, cornerCurrent, cornerPinning = nil, nil, false
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.Jumping:Connect(function(active)
            if active and AimbotCornerEnabled and os.clock() - cornerLastJump > 0.5 then
                task.wait(); doJumpAim()
            end
        end)
    end
end)


-- FPS COUNTER (fixed top, not movable)
local function destroyFpsCounter()
    if fpsGui then
        pcall(function() fpsGui:Destroy() end)
        fpsGui = nil
    end
end

local function createFpsCounter()
    destroyFpsCounter()
    local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if not pg then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "KingsHub_FPS"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 200
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        if gethui then gui.Parent = gethui() else gui.Parent = pg end
    end)
    if not gui.Parent then gui.Parent = pg end
    fpsGui = gui

    local label = Instance.new("TextLabel")
    label.Name = "FpsLabel"
    label.AnchorPoint = Vector2.new(0.5, 0)
    label.Position = UDim2.new(0.5, 0, 0, 8)
    label.Size = UDim2.fromOffset(120, 28)
    label.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
    label.BackgroundTransparency = 0.25
    label.BorderSizePixel = 0
    label.Text = "FPS: --"
    label.TextColor3 = Color3.fromRGB(120, 255, 160)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 200, 120)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = label

    task.spawn(function()
        local frames = 0
        local last = tick()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not fpsGui or not fpsGui.Parent then
                if conn then conn:Disconnect() end
                return
            end
            frames = frames + 1
            local now = tick()
            if now - last >= 0.5 then
                local fps = math.floor(frames / (now - last) + 0.5)
                frames = 0
                last = now
                if label and label.Parent then
                    label.Text = "FPS: " .. tostring(fps)
                    if fps >= 50 then
                        label.TextColor3 = Color3.fromRGB(120, 255, 160)
                    elseif fps >= 30 then
                        label.TextColor3 = Color3.fromRGB(255, 220, 80)
                    else
                        label.TextColor3 = Color3.fromRGB(255, 100, 100)
                    end
                end
            end
        end)
    end)
end

-- UI


local function buildUI()
    task.wait(0.05)
    local Window = Library:CreateWindow({
        Title = ScriptName, Center = true, AutoShow = true, Resizable = true,
        ShowCustomCursor = false, UnlockMouseWhileOpen = true, NotifySide = "Left",
        TabPadding = 8, MenuFadeTime = 0.15,
    })

    local Tabs = {
        Main = Window:AddTab(L("tab_main"), "activity"),
        Boost = Window:AddTab(L("tab_boost"), "zap"),
        Visuals = Window:AddTab(L("tab_visuals"), "eye"),
        Rollback = Window:AddTab(L("tab_rollback"), "rotate-ccw"),
        Settings = Window:AddTab(L("tab_settings"), "settings"),
    }
    local MainLeft = Tabs.Main:AddLeftGroupbox(L("group_combat"), "sword")
    local MainRight = Tabs.Main:AddRightGroupbox(L("group_aim_serve"), "target")
    local BoostLeft = Tabs.Boost:AddLeftGroupbox(L("group_jump"), "arrow-up")
    local BoostRight = Tabs.Boost:AddRightGroupbox(L("group_spike"), "zap")
    local VisLeft = Tabs.Visuals:AddLeftGroupbox(L("group_effects"), "sparkles")
    local VisRight = Tabs.Visuals:AddRightGroupbox(L("group_perf"), "gauge")
    local RollbackBox = Tabs.Rollback:AddLeftGroupbox(L("group_rollback"), "rotate-ccw")
    local SettingsLeft = Tabs.Settings:AddLeftGroupbox(L("group_info"), "info")
    local SettingsRight = Tabs.Settings:AddRightGroupbox(L("group_actions"), "settings")

    MainLeft:AddToggle("HitboxToggle", {
        Text = L("hitbox"), Default = false,
        Callback = function(v) HitboxEnabled = v; if not v then removeHitboxes() end; notify(v and (L("hitbox") .. " " .. L("on")) or (L("hitbox") .. " " .. L("off")), 4) end,
    })
    MainLeft:AddSlider("HitboxSize", {
        Text = L("hitbox_size"), Default = 10, Min = 0, Max = 50, Rounding = 0, Suffix = L("studs"),
        Callback = function(v) HitboxSize = v end,
    })
    MainLeft:AddSlider("HitboxTrans", {
        Text = L("hitbox_trans"), Default = 0.8, Min = 0, Max = 1, Rounding = 2,
        Callback = function(v) HitboxTransparency = v end,
    })
    MainLeft:AddLabel(L("hitbox_color")):AddColorPicker("HitboxColor", {
        Default = HitboxColor, Callback = function(v) HitboxColor = v end,
    })
    MainLeft:AddDivider()
    MainLeft:AddToggle("TSHBarLockToggle", {
        Text = L("bar_tsh"), Default = false,
        Tooltip = L("bar_tsh_tip"),
        Callback = function(v)
            TSHBarLockEnabled = v
            if v then pcall(patchTSHBarLock) end
            notify(L("bar_tsh") .. " " .. (v and L("on") or L("off")), 4)
        end,
    })
    MainLeft:AddToggle("RoninBarLockToggle", {
        Text = L("bar_ronin"), Default = false,
        Tooltip = L("bar_ronin_tip"),
        Callback = function(v)
            RoninBarLockEnabled = v
            notify(L("bar_ronin") .. " " .. (v and L("on") or L("off")), 4)
        end,
    })
    MainLeft:AddToggle("KazanaBarLockToggle", {
        Text = L("bar_kazana"), Default = false,
        Tooltip = L("bar_kazana_tip"),
        Callback = function(v)
            KazanaBarLockEnabled = v
            notify(L("bar_kazana") .. " " .. (v and L("on") or L("off")), 4)
        end,
    })
    MainLeft:AddDivider()
    MainLeft:AddToggle("DirectionalHitToggle", {
        Text = L("directional"), Default = false,
        Callback = function(v) DirectionalHitEnabled = v end,
    })
    MainLeft:AddToggle("OfficialPathToggle", {
        Text = L("official_path"), Default = true,
        Callback = function(v) OfficialPathEnabled = v end,
    })
    MainLeft:AddToggle("PerfectSpikeToggle", {
        Text = L("perfect_spike"), Default = true,
        Callback = function(v) PerfectSpikeAssistEnabled = v end,
    })
    MainLeft:AddToggle("MaxPowerSpikeToggle", {
        Text = L("max_power"), Default = false,
        Tooltip = L("max_power_tip"),
        Callback = function(v)
            MaxPowerSpikeEnabled = v
            notify(v and (L("max_power") .. " " .. L("on")) or (L("max_power") .. " " .. L("off")), 4)
        end,
    }):AddKeyPicker("MaxPowerSpikeKey", { Default = "T", SyncToggleState = true, Mode = "Toggle", Text = L("max_power") })
    MainLeft:AddToggle("SilentSpikeToggle", {
        Text = L("silent_spike"), Default = false,
        Tooltip = L("silent_spike_tip"),
        Callback = function(v)
            SilentSpikeEnabled = v
            if v then
                createSilentSpikeButton()
                notify(L("silent_on"), 5)
            else
                destroySilentSpikeButton()
                notify(L("silent_off"), 4)
            end
        end,
    }):AddKeyPicker("SilentSpikeKey", {
        Default = "C",
        Mode = "Hold",
        Text = L("silent_spike_key"),
        Callback = function() end,
        ChangedCallback = function() end,
    })
    MainLeft:AddToggle("LockPicoToggle", {
        Text = L("lock_pico"),
        Default = false,
        Tooltip = L("lock_pico_tip"),
        Callback = function(v)
            SilentSpikeLockBtn = v
            notify(v and L("pico_locked") or L("pico_unlocked"), 3)
        end,
    })
    MainLeft:AddToggle("DesyncToggle", {
        Text = L("desync"), Default = false,
        Tooltip = L("desync_tip"),
        Callback = function(v)
            if v then
                enableDesync()
                notify(L("desync_on"), 6)
            else
                disableDesync()
                notify(L("desync_off"), 5)
            end
        end,
    })
    MainLeft:AddToggle("AntiModToggle", {
        Text = L("anti_mod"), Default = false,
        Tooltip = L("anti_mod_tip"),
        Callback = function(v)
            AntiModEnabled = v
            if v then checkForModerators() end
            notify(v and (L("anti_mod") .. " " .. L("on")) or (L("anti_mod") .. " " .. L("off")), 4)
        end,
    })

    MainRight:AddToggle("CornerAimbotToggle", {
        Text = L("corner"), Default = false,
        Tooltip = L("corner_tip"),
        Callback = function(v)
            AimbotCornerEnabled = v
            if v then cornerMySide = nil; refreshMarks(); notify(L("corner") .. " " .. L("on") .. " (RNCRAZY)", 5)
            else cornerPinning = false; cornerCurrent = nil; notify(L("corner") .. " " .. L("off"), 4) end
        end,
    }):AddKeyPicker("CornerAimbotKey", { Default = "Z", SyncToggleState = true, Mode = "Toggle", Text = L("corner") })
    MainRight:AddLabel(L("corner_by"))
    MainRight:AddToggle("CameraJumpToggle", {
        Text = L("camera_jump"), Default = false,
        Tooltip = L("camera_jump_tip"),
        Callback = function(v)
            CameraJumpEnabled = v
            notify(v and (L("camera_jump") .. " " .. L("on")) or (L("camera_jump") .. " " .. L("off")), 4)
        end,
    })
    MainRight:AddDivider()
    MainRight:AddToggle("AutoStrongServeUI", {
        Text = L("auto_serve"), Default = false,
        Callback = function(v) AutoStrongServeEnabled = v end,
    })
    MainRight:AddToggle("AutoStrongServeForce", {
        Text = L("force_serve"), Default = false,
        Callback = function(v) AutoStrongServeEveryServeEnabled = v end,
    })
    MainRight:AddSlider("ServePower", {
        Text = L("serve_power"), Default = 1, Min = 0, Max = 1, Rounding = 2,
        Callback = function(v) ServeBoostPower = v end,
    })

    BoostLeft:AddToggle("JumpBoostToggle", {
        Text = L("jump_boost"), Default = false,
        Callback = function(v) JumpBoostEnabled = v; if v then applyJumpBoost() end end,
    })
    BoostLeft:AddSlider("JumpBoostMult", {
        Text = L("jump_mult"), Default = 1.35, Min = 1, Max = 2, Rounding = 2, Suffix = "x",
        Callback = function(v) JumpBoostMult = v; if JumpBoostEnabled then applyJumpBoost() end end,
    })
    BoostRight:AddToggle("SpikeBoostToggle", {
        Text = L("spike_boost"), Default = false,
        Callback = function(v) SpikeBoostEnabled = v end,
    })
    BoostRight:AddSlider("SpikeCharge", {
        Text = L("spike_charge"), Default = 1, Min = 0.5, Max = 1, Rounding = 2,
        Callback = function(v) SpikeBoostCharge = v end,
    })
    BoostRight:AddDivider()
    BoostRight:AddToggle("NoCooldownToggle", {
        Text = L("no_cd"), Default = false,
        Tooltip = L("no_cd_tip"),
        Callback = function(v)
            NoCooldownEnabled = v
            notify(L("no_cd") .. " " .. (v and L("on") or L("off")), 4)
        end,
    })
    BoostRight:AddToggle("NoCdSpike", {
        Text = L("no_cd_spike"), Default = true,
        Callback = function(v) NoCooldownActions.Spike = v end,
    })
    BoostRight:AddToggle("NoCdServe", {
        Text = L("no_cd_serve"), Default = false,
        Callback = function(v) NoCooldownActions.Serve = v end,
    })
    BoostRight:AddToggle("NoCdBlock", {
        Text = L("no_cd_block"), Default = false,
        Callback = function(v) NoCooldownActions.Block = v end,
    })
    BoostRight:AddToggle("NoCdDive", {
        Text = L("no_cd_dive"), Default = false,
        Callback = function(v) NoCooldownActions.Dive = v end,
    })
    BoostRight:AddToggle("NoCdSet", {
        Text = L("no_cd_set"), Default = false,
        Callback = function(v) NoCooldownActions.Set = v end,
    })
    BoostRight:AddToggle("NoCdReceive", {
        Text = L("no_cd_receive"), Default = false,
        Callback = function(v) NoCooldownActions.Receive = v end,
    })
    BoostRight:AddToggle("NoCdAbility", {
        Text = L("no_cd_ability"), Default = false,
        Callback = function(v) NoCooldownActions.Ability = v end,
    })

    VisLeft:AddDropdown("ScoreEffectSelect", {
        Text = L("score_select"), Values = scoreEffectList,
        Default = scoreEffectList[1] or "SupernovaScoreEffect",
        Callback = function(v) if v then scoreEffect = v; notify(v, 3) end end,
    })
    VisLeft:AddToggle("ScoreEffectToggle", {
        Text = L("score_toggle"), Default = false,
        Callback = function(v)
            ScoreEffectEnabled = v
            if v then enableScoreEffect() else disableScoreEffect() end
        end,
    })
    VisLeft:AddToggle("PredictAimToggle", {
        Text = L("predict"), Default = false,
        Tooltip = L("predict_tip"),
        Callback = function(v)
            PredictAimEnabled = v
            if not v then clearPredictAim() end
            notify(v and (L("predict") .. " " .. L("on")) or (L("predict") .. " " .. L("off")), 4)
        end,
    })
    VisLeft:AddSlider("PredictAimLength", {
        Text = L("predict_len"), Default = 25, Min = 5, Max = 50, Rounding = 0, Suffix = L("studs"),
        Callback = function(v) PredictAimLength = v end,
    })
    VisLeft:AddLabel(L("predict_color")):AddColorPicker("PredictAimColor", {
        Default = PredictAimColor, Callback = function(v) PredictAimColor = v end,
    })
    VisLeft:AddToggle("OptimalSpotToggle", {
        Text = L("optimal_spot"), Default = false,
        Tooltip = L("optimal_spot_tip"),
        Callback = function(v)
            OptimalSpotEnabled = v
            if not v then destroyOptimalSpot() end
            notify(v and L("optimal_on") or L("optimal_off"), 4)
        end,
    })
    VisRight:AddToggle("FpsCounterToggle", {
        Text = L("fps"), Default = true,
        Tooltip = L("fps_tip"),
        Callback = function(v)
            ShowFpsCounter = v
            if v then createFpsCounter() else destroyFpsCounter() end
        end,
    })
    VisRight:AddToggle("PotatoModeToggle", {
        Text = L("potato"), Default = false,
        Tooltip = L("potato_tip"),
        Callback = function(v)
            PotatoModeEnabled = v
            if v then pcall(enablePotatoMode); notify(L("potato") .. " " .. L("on"), 4)
            else pcall(disablePotatoMode); notify(L("potato") .. " " .. L("off"), 4) end
        end,
    })
    VisRight:AddDropdown("PerfLevelDrop", {
        Text = L("perf_level"),
        Values = { "Light", "Balanced", "Maximum" },
        Default = PerfLevel,
        Callback = function(v)
            if v then PerfLevel = v end
            if PotatoModeEnabled then
                pcall(enablePotatoMode)
                notify(L("perf_level") .. ": " .. tostring(v), 3)
            end
        end,
    })
    VisRight:AddToggle("StreamerModeToggle", {
        Text = L("streamer"), Default = false,
        Tooltip = L("streamer_tip"),
        Callback = function(v)
            StreamerModeEnabled = v
            if v then applyStreamerMode() else disableStreamerMode() end
            notify(v and (L("streamer") .. " " .. L("on")) or (L("streamer") .. " " .. L("off")), 4)
        end,
    })
    VisRight:AddToggle("UnlockAllVisualToggle", {
        Text = L("unlock_all"), Default = false,
        Tooltip = L("unlock_all_tip"),
        Callback = function(v)
            if v then
                enableUnlockAllVisual()
            else
                disableUnlockAllVisual()
                notify(L("unlock_off"), 4)
            end
        end,
    })

    SettingsLeft:AddLabel(ScriptName .. " v" .. ScriptVersion)
    SettingsLeft:AddLabel(L("last_updated") .. LastUpdated)
    SettingsLeft:AddDivider()
    SettingsLeft:AddLabel(L("creator"))
    SettingsLeft:AddLabel(L("ui_lib"))
    SettingsLeft:AddLabel(L("enjoy"))

    RollbackBox:AddLabel(L("rb_l1"))
    RollbackBox:AddLabel(L("rb_l2"))
    RollbackBox:AddLabel(L("rb_l3"))
    RollbackBox:AddDivider()
    RollbackBox:AddButton({
        Text = L("rb_run"),
        Func = doDataRollbackClassic,
        Tooltip = L("rb_tip"),
    })
    RollbackBox:AddButton({
        Text = L("rb_run_beta"),
        Func = doDataRollbackBeta,
        Tooltip = L("rb_tip_beta"),
    })
    RollbackBox:AddLabel(L("rb_l4"))

    SettingsRight:AddLabel(L("menu_bind"))
        :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = L("menu_bind") })
    SettingsRight:AddDivider()
    SettingsRight:AddToggle("OnlineCounterToggle", {
        Text = L("online_toggle"), Default = true,
        Tooltip = L("online_tip"),
        Callback = function(v)
            KingsOnlineEnabled = v
            if v and KingsOnlineApiUrl ~= "" then
                task.spawn(kingsOnlineHeartbeat)
            else
                kingsOnlineUpdateLabel()
            end
        end,
    })
    KingsOnlineLabel = SettingsRight:AddLabel(L("online_users") .. ": —")
    SettingsRight:AddButton({
        Text = L("unload"),
        Func = function()
            notify(L("unloading"), 3)
            HitboxEnabled = false
            AimbotCornerEnabled = false
            MaxPowerSpikeEnabled = false
            SilentSpikeEnabled = false
            PredictAimEnabled = false
            StreamerModeEnabled = false
            ScoreEffectEnabled = false
            PotatoModeEnabled = false
            AntiModEnabled = false
            pcall(disableDesync)
            pcall(disableScoreEffect)
            pcall(disablePotatoMode)
            pcall(disableStreamerMode)
            pcall(disableUnlockAllVisual)
            pcall(clearPredictAim)
            pcall(destroyOptimalSpot)
            pcall(removeHitboxes)
            pcall(destroySilentSpikeButton)
            pcall(destroyFpsCounter)
            if cornerFolder then cornerFolder:Destroy() end
            Library:Unload()
        end,
    })

    Library.ToggleKeybind = Options.MenuKeybind
    pcall(function()
        if ThemeManager then
            ThemeManager:SetLibrary(Library)
            ThemeManager:SetFolder("KingsHub")
            ThemeManager:ApplyToTab(Tabs.Settings)
        end
    end)
    pcall(function()
        if SaveManager then
            SaveManager:SetLibrary(Library)
            SaveManager:SetFolder("KingsHub")
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({"MenuKeybind"})
            SaveManager:BuildConfigSection(Tabs.Settings)
            SaveManager:LoadAutoloadConfig()
        end
    end)

    task.spawn(function()
        while true do
            local waitTime = SilentSpikeEnabled and 0.08 or 0.35
            task.wait(waitTime)
            pcall(function()
                if Options.CornerAimbotKey and Toggles.CornerAimbotToggle then
                    local s = Options.CornerAimbotKey:GetState()
                    if s ~= AimbotCornerEnabled then
                        AimbotCornerEnabled = s
                        Toggles.CornerAimbotToggle:SetValue(s)
                    end
                end
                if Options.MaxPowerSpikeKey and Toggles.MaxPowerSpikeToggle then
                    local s = Options.MaxPowerSpikeKey:GetState()
                    if s ~= MaxPowerSpikeEnabled then
                        MaxPowerSpikeEnabled = s
                        Toggles.MaxPowerSpikeToggle:SetValue(s)
                    end
                end
                if SilentSpikeEnabled and Options.SilentSpikeKey and Options.SilentSpikeKey:GetState() then
                    doSilentSpike()
                end
            end)
        end
    end)

    if ShowFpsCounter then pcall(createFpsCounter) end
    notify(L("welcome"), 8)
    notify(ScriptName .. " v" .. ScriptVersion .. L("loaded") .. LastUpdated, 5)
end

local function showLanguagePicker()
    local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 8)
    if not pg then
        CurrentLang = "en"
        buildUI()
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "KingsHub_LangPick"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 500
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        if gethui then gui.Parent = gethui() else gui.Parent = pg end
    end)
    if not gui.Parent then gui.Parent = pg end

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.35
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(320, 220)
    card.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    card.BorderSizePixel = 0
    card.Parent = bg
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 14)
    cardCorner.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(80, 255, 160)
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.35
    cardStroke.Parent = card

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.fromOffset(10, 18)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(240, 245, 240)
    title.Text = "KingsHub"
    title.Parent = card

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, -20, 0, 24)
    sub.Position = UDim2.fromOffset(10, 54)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 14
    sub.TextColor3 = Color3.fromRGB(180, 190, 185)
    sub.Text = "Select language / Elige el idioma"
    sub.Parent = card

    local function makeBtn(text, y, color, lang)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -40, 0, 42)
        b.Position = UDim2.fromOffset(20, y)
        b.BackgroundColor3 = color
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.TextSize = 16
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = text
        b.AutoButtonColor = true
        b.Parent = card
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = b
        b.MouseButton1Click:Connect(function()
            CurrentLang = lang
            pcall(function() gui:Destroy() end)
            buildUI()
        end)
        return b
    end

    makeBtn("English", 100, Color3.fromRGB(40, 90, 200), "en")
    makeBtn("Español", 152, Color3.fromRGB(30, 140, 90), "es")
end

showLanguagePicker()


task.defer(function()
    task.wait(2)
    if KingsOnlineEnabled and type(KingsOnlineApiUrl) == "string" and KingsOnlineApiUrl ~= "" then
        pcall(kingsOnlineHeartbeat)
    end
end)
