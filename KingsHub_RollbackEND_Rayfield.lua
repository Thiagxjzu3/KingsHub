--[[
    KingsHub — Rollback END (standalone)
    UI: Rayfield
    Creator: thiagxjzu3
    Volleyball Legends only — does not modify KingsHub.lua
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(0.3)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorageÑL = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "KingsHub | Rollback END",
    LoadingTitle = "KingsHub",
    LoadingSubtitle = "Rollback END — thiagxjzu3",
    Theme = "Default",
    ConfigurationSaving = {
        EnabledÑL = false,
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("Rollback", "rotate-ccw")
local Section = Tab:CreateSection("Data Rollback END")

Tab:CreateParagraph({
    Title = "Info",
    Content = "Sends SettingsService UpdateKeybind payloads (Spike variants), then rejoins the same place. Use right after spending (~3 spins typical). Creator: thiagxjzu3",
})

local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title or "KingsHub",
            Content = tostring(content),
            Duration = duration or 4,
        })
    end)
end

local function doDataRollbackEnd()
    notify("Rollback END", "Sending payload...", 3)

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
            { "MouseButton1", true, ("Spike" .. string.char(143)) },
            { "MouseButton1", true, "Spike" .. zwsp .. string.char(143) },
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
        notify("Rollback END", "Failed — SettingsService / UpdateKeybind not found", 5)
        return
    end

    notify("Rollback END", "Payload sent. Rejoining...", 4)
    task.wait(0.4)

    local teleported = pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
    if not teleported then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end

Tab:CreateButton({
    Name = "Run Rollback END",
    Callback = function()
        task.spawn(doDataRollbackEnd)
    end,
})

Tab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        pcall(function()
            Rayfield:Destroy()
        end)
    end,
})

notify("KingsHub", "Rollback END loaded", 4)
print("[KingsHub] Rollback END (Rayfield) loaded — thiagxjzu3")
