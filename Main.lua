-- Luau UI-first deobfuscation pass.
-- Goal: reproduce the original UI without doing any game/remotes work before UI is visible.

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()

local Main = Library:CreateWindow("Kick a Lucky Block")

local perfectKickAndClaim = false
local bonusTrain = false
local collectCash = false
local upgradeAll = false
local buySpeed = false
local autoRebirth = false

Main:AddToggle({
    text = "Perfect Kick & Claim",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Kick: ", value)
        perfectKickAndClaim = value
    end,
})

Main:AddToggle({
    text = "Bonus Train",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Bonus: ", value)
        bonusTrain = value
    end,
})

Main:AddToggle({
    text = "Collect Cash",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Cash: ", value)
        collectCash = value
    end,
})

Main:AddToggle({
    text = "Upgrade All",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Upgrade: ", value)
        upgradeAll = value
    end,
})

Main:AddToggle({
    text = "Buy Speed",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Speed: ", value)
        buySpeed = value
    end,
})

Main:AddToggle({
    text = "Auto Rebirth",
    flag = "toggle",
    state = false,
    callback = function(value)
        print("Rebirth: ", value)
        autoRebirth = value
    end,
})

Main:AddButton({
    text = "Sell All",
    flag = "button",
    callback = function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local shared = replicatedStorage:FindFirstChild("Shared")
        local packages = shared and shared:FindFirstChild("Packages")
        local network = packages and packages:FindFirstChild("Network")
        local sellAll = network and network:FindFirstChild("ref_B_SellAll", true)

        if sellAll then
            sellAll:InvokeServer()
        end
    end,
})

Main:AddLabel({
    text = "Find Mutation",
})

local Mutation = Library:CreateWindow("Find Mutation")

local golden = false
local diamond = false
local plasma = false
local molten = false
local radioactive = false
local shadow = false
local electrified = false
local rainbow = false

Mutation:AddToggle({
    text = "Golden",
    flag = "Golden",
    state = false,
    callback = function(value)
        golden = value
    end,
})

Mutation:AddToggle({
    text = "Diamond",
    flag = "Diamond",
    state = false,
    callback = function(value)
        diamond = value
    end,
})

Mutation:AddToggle({
    text = "Plasma",
    flag = "Plasma",
    state = false,
    callback = function(value)
        plasma = value
    end,
})

Mutation:AddToggle({
    text = "Molten",
    flag = "Molten",
    state = false,
    callback = function(value)
        molten = value
    end,
})

Mutation:AddToggle({
    text = "Radioactive",
    flag = "Radioactive",
    state = false,
    callback = function(value)
        radioactive = value
    end,
})

Mutation:AddToggle({
    text = "Shadow",
    flag = "Shadow",
    state = false,
    callback = function(value)
        shadow = value
    end,
})

Mutation:AddToggle({
    text = "Electrified",
    flag = "Electrified",
    state = false,
    callback = function(value)
        electrified = value
    end,
})

Mutation:AddToggle({
    text = "Rainbow",
    flag = "Rainbow",
    state = false,
    callback = function(value)
        rainbow = value
    end,
})
