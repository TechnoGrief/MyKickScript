-- Deobfuscated from D:\DEOB\KickaLuckyBlock.lua.
-- Evidence files:
--   D:\DEOB\deob_stage1_strings.py
--   D:\DEOB\KickaLuckyBlock.stage1.strings.txt
--   D:\DEOB\KickaLuckyBlock.stage1.gmap.txt
--   D:\DEOB\trace_vm.lua
--   D:\DEOB\KickaLuckyBlock.trace.txt
--
-- This file contains only behavior confirmed by decoded constants and the
-- sandbox trace. Unknown callback bodies are left as unknown instead of guessed.

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew",
    true
))()

local Main = Library:CreateWindow("Kick a Lucky Block")

task.spawn(function()
    -- Confirmed spawned loop uses tick/task.wait.
    -- Body was not expanded in the safe trace to avoid running an infinite loop.
end)

local perfectKickAndClaim = false
Main:AddToggle({
    text = "Perfect Kick & Claim",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Kick: ", value)
        perfectKickAndClaim = value
        -- Unknown body. Decoded constants include: Kick, FireServer, Fire,
        -- GetChildren, GetDescendants, FindFirstChild, WaitForChild.
    end,
})

local bonusTrain = false
Main:AddToggle({
    text = "Bonus Train",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Bonus: ", value)
        bonusTrain = value
        -- Unknown body. Decoded constants include: Bonus.
    end,
})

local plots = workspace.Plots:GetChildren()

local collectCash = false
Main:AddToggle({
    text = "Collect Cash",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Cash: ", value)
        collectCash = value
        -- Unknown body. Decoded constants include: Cash.
    end,
})

local upgradeAll = false
Main:AddToggle({
    text = "Upgrade All",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Upgrade: ", value)
        upgradeAll = value
        -- Unknown body. Decoded constants include: Upgrade.
    end,
})

local buySpeed = false
Main:AddToggle({
    text = "Buy Speed",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Speed: ", value)
        buySpeed = value
        -- Unknown body. Decoded constants include: Speed.
    end,
})

local autoRebirth = false
Main:AddToggle({
    text = "Auto Rebirth",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Rebirth: ", value)
        autoRebirth = value
        -- Unknown body. Decoded constants include: Rebirth.
    end,
})

Main:AddButton({
    text = "Sell All",
    flag = "button",
    callback = function()
        game:GetService("ReplicatedStorage")
            .Shared
            .Packages
            .Network
            .ref_B_SellAll
            :InvokeServer()
    end,
})

Main:AddLabel({
    -- Label table content was not exposed by the current trace.
})

local Mutation = Library:CreateWindow("Find Mutation")

local mutations = {
    "Golden",
    "Diamond",
    "Plasma",
    "Molten",
    "Radioactive",
    "Shadow",
    "Electrified",
    "Rainbow",
}

for _, mutationName in ipairs(mutations) do
    Mutation:AddToggle({
        text = mutationName,
        flag = mutationName,
        state = false,
        callback = function(value)
            -- Confirmed callback exists for each mutation toggle.
            -- Trace did not execute these callback bodies.
        end,
    })
end
