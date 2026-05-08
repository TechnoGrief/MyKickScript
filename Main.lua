-- Decoded + fixed KickaLuckyBlock.lua
-- VM garbage removed, global-name bug fixed, duplicate toggle flags fixed.
-- No guessed missing payload added: Perfect Kick and Mutation Finder keep only behavior present in the original file.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local oldGui = CoreGui:FindFirstChild("ToraScript")
if oldGui then
    oldGui:Destroy()
end

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/TechnoGrief/MyKickScript/main/Coolscript.lua"
))()

local main = Library:CreateWindow("Kick a Lucky Block")

local flags = {
    kick = false,
    bonus = false,
    cash = false,
    upgrade = false,
    speed = false,
    rebirth = false,
}

local function network()
    return ReplicatedStorage.Shared.Packages.Network
end

local function getOwnedPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return nil
    end

    for _, plot in ipairs(plots:GetChildren()) do
        if plot:GetAttribute("Owner") == player.Name then
            return plot
        end
    end

    return nil
end

local function safeFireConnection(connection)
    if typeof(connection) ~= "table" then
        return
    end

    if typeof(connection.Fire) == "function" then
        pcall(function()
            connection:Fire()
        end)
    elseif typeof(connection.Function) == "function" then
        pcall(connection.Function)
    end
end

local function clickActivated(object)
    if not object then
        return
    end

    local signal = object.Activated or object.MouseButton1Click
    if not signal then
        return
    end

    if typeof(getconnections) == "function" then
        for _, connection in ipairs(getconnections(signal)) do
            safeFireConnection(connection)
        end
    elseif typeof(firesignal) == "function" then
        pcall(firesignal, signal)
    end
end

local function kickLoop()
    -- Exact decoded behavior: it only waits for the character, HumanoidRootPart and Humanoid.
    -- No actual kick/claim remote or touch logic exists in the uploaded obfuscated file.
    while flags.kick do
        task.wait()

        pcall(function()
            local character = player.Character or player.CharacterAdded:Wait()
            character:WaitForChild("HumanoidRootPart")
            character:WaitForChild("Humanoid")
        end)
    end
end

local function bonusLoop()
    while flags.bonus do
        wait()

        pcall(function()
            local backpack = player:WaitForChild("Backpack")
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:GetAttribute("GUID")
                end
            end

            local playerGui = player:FindFirstChild("PlayerGui")
            local upgradesGui = playerGui and playerGui:FindFirstChild("KickUpgrades")

            if upgradesGui then
                for _, item in ipairs(upgradesGui:GetChildren()) do
                    if item.Name == "Bonus" then
                        clickActivated(item)
                    end
                end
            end

            wait(0.2)
        end)
    end
end

local function collectCashLoop()
    while flags.cash do
        wait()

        pcall(function()
            local plot = getOwnedPlot()
            local buttons = plot and plot:FindFirstChild("Buttons")

            if buttons then
                for _, item in ipairs(buttons:GetDescendants()) do
                    if item:IsA("TouchTransmitter") then
                        local parentName = item.Parent and item.Parent.Name

                        if parentName == "l1" then
                            network().rev_B_Collect:FireServer(1)
                        elseif parentName == "l2" then
                            network().rev_B_Collect:FireServer(2)
                        else
                            network().rev_B_Collect:FireServer()
                        end
                    end
                end
            end

            wait(2)
        end)
    end
end

local function upgradeLoop()
    while flags.upgrade do
        wait()

        pcall(function()
            local plot = getOwnedPlot()
            local buttons = plot and plot:FindFirstChild("Buttons")

            if buttons then
                for _, item in ipairs(buttons:GetDescendants()) do
                    if item:IsA("TouchTransmitter") then
                        local parentName = item.Parent and item.Parent.Name

                        if parentName == "l1" then
                            network().rev_B_Upgrade:FireServer(1)
                            wait(0.2)
                        elseif parentName == "l2" then
                            network().rev_B_Upgrade:FireServer(2)
                            wait(0.2)
                        end
                    end
                end
            end

            wait(1)
        end)
    end
end

local function speedLoop()
    while flags.speed do
        wait()

        pcall(function()
            network().rev_SPEED_UPGRADE:FireServer(1)
            wait(0.2)
        end)
    end
end

local function rebirthLoop()
    while flags.rebirth do
        wait()

        pcall(function()
            network().rev_RebirthRequest:FireServer()
            wait(2)
        end)
    end
end

local function runLoop(flagName, enabled, loopFunction)
    flags[flagName] = enabled

    if enabled then
        task.spawn(loopFunction)
    end
end

main:AddToggle({
    text = "Perfect Kick & Claim",
    flag = "kick_toggle",
    state = false,
    callback = function(enabled)
        print("Kick: ", enabled)
        runLoop("kick", enabled, kickLoop)
    end,
})

main:AddToggle({
    text = "Bonus Train",
    flag = "bonus_toggle",
    state = false,
    callback = function(enabled)
        print("Bonus: ", enabled)
        runLoop("bonus", enabled, bonusLoop)
    end,
})

main:AddToggle({
    text = "Collect Cash",
    flag = "cash_toggle",
    state = false,
    callback = function(enabled)
        print("Cash: ", enabled)
        runLoop("cash", enabled, collectCashLoop)
    end,
})

main:AddToggle({
    text = "Upgrade All",
    flag = "upgrade_toggle",
    state = false,
    callback = function(enabled)
        print("Upgrade: ", enabled)
        runLoop("upgrade", enabled, upgradeLoop)
    end,
})

main:AddToggle({
    text = "Buy Speed",
    flag = "speed_toggle",
    state = false,
    callback = function(enabled)
        print("Speed: ", enabled)
        runLoop("speed", enabled, speedLoop)
    end,
})

main:AddToggle({
    text = "Auto Rebirth",
    flag = "rebirth_toggle",
    state = false,
    callback = function(enabled)
        print("Rebirth: ", enabled)
        runLoop("rebirth", enabled, rebirthLoop)
    end,
})

main:AddButton({
    text = "Sell All",
    flag = "sell_all_button",
    callback = function()
        pcall(function()
            network().ref_B_SellAll:InvokeServer()
        end)
    end,
})

main:AddLabel({
    text = "YouTube: Tora IsMe",
})

local mutationWindow = Library:CreateWindow("Find Mutation")

for _, name in ipairs({
    "Golden",
    "Diamond",
    "Plasma",
    "Molten",
    "Radioactive",
    "Shadow",
    "Electrified",
    "Rainbow",
}) do
    mutationWindow:AddToggle({
        text = name,
        flag = name,
        state = false,
        callback = function()
            -- Empty in the decoded source.
        end,
    })
end

Library:Init()
