-- Deobfuscated working version from D:\DEOB\KickaLuckyBlock.lua
-- Confirmed by:
--   D:\DEOB\deob_stage1_strings.py
--   D:\DEOB\KickaLuckyBlock.stage1.strings.txt
--   D:\DEOB\KickaLuckyBlock.trace.txt

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()

local Main = Library:CreateWindow("Kick a Lucky Block")

local flags = {
    kick = false,
    bonus = false,
    cash = false,
    upgrade = false,
    speed = false,
    rebirth = false,
}

local mutationFlags = {
    Golden = false,
    Diamond = false,
    Plasma = false,
    Molten = false,
    Radioactive = false,
    Shadow = false,
    Electrified = false,
    Rainbow = false,
}

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function nameHas(instance, ...)
    local name = lower(instance.Name)
    for _, token in ipairs({...}) do
        if string.find(name, lower(token), 1, true) then
            return true
        end
    end
    return false
end

local function findNetworkRemote(...)
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local shared = replicatedStorage:FindFirstChild("Shared")
    local packages = shared and shared:FindFirstChild("Packages")
    local Network = packages and packages:FindFirstChild("Network")
    if not Network then
        return nil
    end

    for _, object in ipairs(Network:GetDescendants()) do
        if (object:IsA("RemoteEvent") or object:IsA("RemoteFunction")) and nameHas(object, ...) then
            return object
        end
    end
end

local function useRemote(remote, ...)
    if type(remote) == "function" then
        remote = remote()
    end

    if not remote then
        return nil
    end

    if remote:IsA("RemoteEvent") then
        return remote:FireServer(...)
    end

    if remote:IsA("RemoteFunction") then
        return remote:InvokeServer(...)
    end
end

local function loopWhile(flagName, delayTime, callback)
    task.spawn(function()
        while flags[flagName] do
            pcall(callback)
            task.wait(delayTime or 0.2)
        end
    end)
end

local function findLocalPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return nil
    end

    local player = game:GetService("Players").LocalPlayer
    for _, plot in ipairs(plots:GetChildren()) do
        local owner = plot:GetAttribute("Owner") or plot:GetAttribute("Player") or plot:GetAttribute("UserId")
        if owner == player.Name or owner == player.UserId then
            return plot
        end
    end

    return plots:FindFirstChild(player.Name) or plots:GetChildren()[1]
end

local remotes = {
    kick = function() return findNetworkRemote("Kick") end,
    claim = function() return findNetworkRemote("Claim") end,
    bonus = function() return findNetworkRemote("Bonus", "Train") end,
    cash = function() return findNetworkRemote("Cash") end,
    upgrade = function() return findNetworkRemote("Upgrade") end,
    speed = function() return findNetworkRemote("Speed") end,
    rebirth = function() return findNetworkRemote("Rebirth") end,
    sellAll = function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local shared = replicatedStorage:FindFirstChild("Shared")
        local packages = shared and shared:FindFirstChild("Packages")
        local network = packages and packages:FindFirstChild("Network")
        return (network and network:FindFirstChild("ref_B_SellAll", true)) or findNetworkRemote("SellAll", "Sell")
    end,
}

Main:AddToggle({
    text = "Perfect Kick & Claim",
    flag = "toggle",
    state = false,
    callback = function(state)
        print("Kick: ", state)
        flags.kick = state
        loopWhile("kick", 0.2, function()
            useRemote(remotes.kick, 1)
            useRemote(remotes.claim)
        end)
    end,
})

Main:AddToggle({
    text = "Bonus Train",
    flag = "toggle",
    state = false,
    callback = function(state)
        print("Bonus: ", state)
        flags.bonus = state
        loopWhile("bonus", 0.2, function()
            useRemote(remotes.bonus)
        end)
    end,
})

Main:AddToggle({
    text = "Collect Cash",
    flag = "toggle",
    state = false,
    callback = function(state)
        print("Cash: ", state)
        flags.cash = state
        loopWhile("cash", 0.2, function()
            useRemote(remotes.cash)
        end)
    end,
})

Main:AddToggle({
    text = "Upgrade All",
    flag = "toggle",
    state = false,
    callback = function(state)
        print("Upgrade: ", state)
        flags.upgrade = state
        loopWhile("upgrade", 0.2, function()
            useRemote(remotes.upgrade, "Kick")
            useRemote(remotes.upgrade, "Speed")
            useRemote(remotes.upgrade, "Cash")
        end)
    end,
})

Main:AddToggle({
    text = "Buy Speed",
    flag = "toggle",
    state = false,
    callback = function(state)
        print("Speed: ", state)
        flags.speed = state
        loopWhile("speed", 0.2, function()
            useRemote(remotes.speed)
        end)
    end,
})

Main:AddToggle({
    text = "Auto Rebirth",
    flag = "toggle",
    state = false,
    callback = function(state)
        print("Rebirth: ", state)
        flags.rebirth = state
        loopWhile("rebirth", 0.5, function()
            useRemote(remotes.rebirth)
        end)
    end,
})

Main:AddButton({
    text = "Sell All",
    flag = "button",
    callback = function()
        useRemote(remotes.sellAll)
    end,
})

Main:AddLabel({
    text = "Find Mutation",
})

local Mutation = Library:CreateWindow("Find Mutation")

local function objectHasMutation(object, mutationName)
    if nameHas(object, mutationName) then
        return true
    end

    local mutation = object:GetAttribute("Mutation")
    if mutation and lower(mutation) == lower(mutationName) then
        return true
    end

    local title = object:FindFirstChild("Title", true) or object:FindFirstChild("Name", true)
    if title and title:IsA("TextLabel") and string.find(lower(title.Text), lower(mutationName), 1, true) then
        return true
    end

    return false
end

local function markMutation(object, mutationName)
    if object:FindFirstChild("FindMu") then
        return
    end

    local adornee = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true)
    if not adornee then
        return
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FindMu"
    billboard.Size = UDim2.new(0, 120, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.Adornee = adornee
    billboard.Parent = object

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = mutationName
    label.TextColor3 = Color3.fromRGB(255, 65, 65)
    label.TextScaled = true
    label.Parent = billboard
end

local function scanMutation(mutationName)
    task.spawn(function()
        while mutationFlags[mutationName] do
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, object in ipairs(plots:GetDescendants()) do
                    if objectHasMutation(object, mutationName) then
                        markMutation(object, mutationName)
                    end
                end
            end
            task.wait(1)
        end
    end)
end

for _, mutationName in ipairs({
    "Golden",
    "Diamond",
    "Plasma",
    "Molten",
    "Radioactive",
    "Shadow",
    "Electrified",
    "Rainbow",
}) do
    Mutation:AddToggle({
        text = mutationName,
        flag = mutationName,
        state = false,
        callback = function(state)
            mutationFlags[mutationName] = state
            if state then
                scanMutation(mutationName)
            end
        end,
    })
end
