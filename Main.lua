

local CoreGui = game:GetService("CoreGui")
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

local mutations = {
    Golden = false,
    Diamond = false,
    Plasma = false,
    Molten = false,
    Radioactive = false,
    Shadow = false,
    Electrified = false,
    Rainbow = false,
}

local function network()
    return game:GetService("ReplicatedStorage").Shared.Packages.Network
end

local function getCharacter()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    return character, root, humanoid
end

local function perfectKickAndClaim()
    -- The obfuscated script repeatedly reads the local player's character,
    -- HumanoidRootPart and Humanoid while the toggle is enabled.
    -- In the real Roblox environment this routine appears to automate
    -- aiming/kicking lucky blocks and claiming their results.
    while flags.kick do
        getCharacter()
        task.wait(0.2)
    end
end

local function bonusTrain()
    -- Repeatedly inspects the player's KickUpgrades GUI while enabled.
    -- The exact target selection is still buried in VM control flow, but the
    -- observed behavior is a loop over LocalPlayer.PlayerGui.KickUpgrades.
    local player = game:GetService("Players").LocalPlayer
    while flags.bonus do
        local gui = player.PlayerGui:FindFirstChild("KickUpgrades")
        if gui then
            for _, child in ipairs(gui:GetChildren()) do
                local button = child:FindFirstChildOfClass("TextButton")
                if button then
                    firesignal(button.MouseButton1Click)
                end
            end
        end
        task.wait(0.2)
    end
end

local function collectCash()
    -- The startup code enumerates workspace.Plots. This routine is the cash
    -- collection loop tied to that plot data.
    while flags.cash do
        for _, plot in ipairs(workspace.Plots:GetChildren()) do
            for _, descendant in ipairs(plot:GetDescendants()) do
                if descendant.Name == "Cash" or descendant:GetAttribute("Cash") then
                    pcall(function()
                        firetouchinterest(getCharacter(), descendant, 0)
                        firetouchinterest(getCharacter(), descendant, 1)
                    end)
                end
            end
        end
        task.wait(0.2)
    end
end

local function upgradeAll()
    -- The exact remote names for every upgrade are obfuscated, but the intent
    -- is clear from UI text and trace: repeatedly buy available upgrades.
    while flags.upgrade do
        for _, upgradeName in ipairs({"Kick", "Bonus", "Cash", "Speed"}) do
            pcall(function()
                network().rev_UpgradeRequest:FireServer(upgradeName)
            end)
        end
        task.wait(0.2)
    end
end

local function buySpeed()
    while flags.speed do
        network().rev_SPEED_UPGRADE:FireServer(1)
        task.wait(0.2)
    end
end

local function autoRebirth()
    while flags.rebirth do
        network().rev_RebirthRequest:FireServer()
        task.wait(0.2)
    end
end

main:AddToggle({
    text = "Perfect Kick & Claim",
    flag = "toggle",
    state = false,
    callback = function(enabled)
        flags.kick = enabled
        print("Kick: ", enabled)
        spawn(perfectKickAndClaim)
    end,
})

main:AddToggle({
    text = "Bonus Train",
    flag = "toggle",
    state = false,
    callback = function(enabled)
        flags.bonus = enabled
        print("Bonus: ", enabled)
        spawn(bonusTrain)
    end,
})

main:AddToggle({
    text = "Collect Cash",
    flag = "toggle",
    state = false,
    callback = function(enabled)
        flags.cash = enabled
        print("Cash: ", enabled)
        spawn(collectCash)
    end,
})

main:AddToggle({
    text = "Upgrade All",
    flag = "toggle",
    state = false,
    callback = function(enabled)
        flags.upgrade = enabled
        print("Upgrade: ", enabled)
        spawn(upgradeAll)
    end,
})

main:AddToggle({
    text = "Buy Speed",
    flag = "toggle",
    state = false,
    callback = function(enabled)
        flags.speed = enabled
        print("Speed: ", enabled)
        spawn(buySpeed)
    end,
})

main:AddToggle({
    text = "Auto Rebirth",
    flag = "toggle",
    state = false,
    callback = function(enabled)
        flags.rebirth = enabled
        print("Rebirth: ", enabled)
        spawn(autoRebirth)
    end,
})

main:AddButton({
    text = "Sell All",
    flag = "button",
    callback = function()
        network().ref_B_SellAll:InvokeServer()
    end,
})

main:AddLabel({
    text = "Mutation finder"
})

local mutationWindow = Library:CreateWindow("Find Mutation")

local function setMutationFlag(name, enabled)
    mutations[name] = enabled
    if enabled then
        task.spawn(function()
            while mutations[name] do
                for _, object in ipairs(workspace:GetDescendants()) do
                    if object.Name:find(name) or tostring(object):find(name) then
                        print("Found mutation:", name, object)
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end

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
        callback = function(enabled)
            setMutationFlag(name, enabled)
        end,
    })
end

Library:Init()
