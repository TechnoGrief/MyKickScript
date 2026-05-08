-- Kick a Lucky Block - Luau / Executor standalone build
-- No external UI library, no key system.
-- Uses only remotes found in the decoded file:
-- rev_B_Collect, rev_B_Upgrade, rev_SPEED_UPGRADE, rev_RebirthRequest, ref_B_SellAll

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local GUI_NAME = "KLB_Executor_Luau_Menu"
local GLOBAL_KEY = "__KLB_EXECUTOR_LUAU_STATE"

local globalEnv = (typeof(getgenv) == "function" and getgenv()) or _G

if globalEnv[GLOBAL_KEY] and typeof(globalEnv[GLOBAL_KEY].stop) == "function" then
    pcall(globalEnv[GLOBAL_KEY].stop)
end

local state = {
    alive = true,
    flags = {
        kick = false,
        bonus = false,
        cash = false,
        upgrade = false,
        speed = false,
        rebirth = false,
    },
    mutations = {},
    warned = {},
    highlights = {},
}

globalEnv[GLOBAL_KEY] = state

function state.stop()
    state.alive = false

    for key in pairs(state.flags) do
        state.flags[key] = false
    end

    for key in pairs(state.mutations) do
        state.mutations[key] = false
    end

    for _, highlight in pairs(state.highlights) do
        pcall(function()
            highlight:Destroy()
        end)
    end

    state.highlights = {}
end

local function log(...)
    print("[KLB]", ...)
end

local statusLabel

local function setStatus(text, color)
    log(text)
    if statusLabel then
        statusLabel.Text = tostring(text)
        statusLabel.TextColor3 = color or Color3.fromRGB(190, 205, 255)
    end
end

local function warnOnce(key, text)
    if state.warned[key] then
        return
    end

    state.warned[key] = true
    warn("[KLB]", text)

    if statusLabel then
        statusLabel.Text = tostring(text)
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
end

local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and coreGui then
        return coreGui
    end

    return playerGui
end

local guiParent = getGuiParent()

for _, parent in ipairs({guiParent, playerGui}) do
    pcall(function()
        local old = parent:FindFirstChild(GUI_NAME)
        if old then
            old:Destroy()
        end
    end)
end

local function create(className, props)
    local object = Instance.new(className)

    for key, value in pairs(props or {}) do
        object[key] = value
    end

    return object
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(80, 130, 255)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.35
    stroke.Parent = parent
    return stroke
end

local screenGui = create("ScreenGui", {
    Name = GUI_NAME,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = guiParent,
})

local main = create("Frame", {
    Size = UDim2.fromOffset(470, 560),
    Position = UDim2.new(0.5, -235, 0.5, -280),
    BackgroundColor3 = Color3.fromRGB(12, 13, 22),
    BorderSizePixel = 0,
    Parent = screenGui,
})
addCorner(main, 18)
addStroke(main, Color3.fromRGB(100, 155, 255), 1.4, 0.32)

create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 17, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 20, 55)),
    }),
    Rotation = 30,
    Parent = main,
})

local header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    Parent = main,
})
addCorner(header, 18)

create("TextLabel", {
    Size = UDim2.new(1, -120, 1, 0),
    Position = UDim2.fromOffset(18, 0),
    BackgroundTransparency = 1,
    Text = "KICK A LUCKY BLOCK",
    TextColor3 = Color3.fromRGB(255, 240, 185),
    TextSize = 23,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header,
})

local closeButton = create("TextButton", {
    Size = UDim2.fromOffset(36, 36),
    Position = UDim2.new(1, -48, 0, 14),
    BackgroundColor3 = Color3.fromRGB(255, 85, 100),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 23,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = header,
})
addCorner(closeButton, 18)

local minimizeButton = create("TextButton", {
    Size = UDim2.fromOffset(36, 36),
    Position = UDim2.new(1, -88, 0, 14),
    BackgroundColor3 = Color3.fromRGB(255, 190, 90),
    Text = "–",
    TextColor3 = Color3.fromRGB(35, 30, 20),
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = header,
})
addCorner(minimizeButton, 18)

local body = create("Frame", {
    Size = UDim2.new(1, -28, 1, -104),
    Position = UDim2.fromOffset(14, 76),
    BackgroundTransparency = 1,
    Parent = main,
})

local scroll = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -38),
    Position = UDim2.fromOffset(0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.fromOffset(0, 0),
    Parent = body,
})

local layout = create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = scroll,
})

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 10)
end)

statusLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 1, -30),
    BackgroundTransparency = 1,
    Text = "Ready",
    TextColor3 = Color3.fromRGB(180, 195, 235),
    TextSize = 14,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = body,
})

local function makeLabel(text)
    local label = create("TextLabel", {
        Size = UDim2.new(1, -4, 0, 26),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 235, 180),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = scroll,
    })
    return label
end

local function makeButton(text, callback)
    local button = create("TextButton", {
        Size = UDim2.new(1, -4, 0, 42),
        BackgroundColor3 = Color3.fromRGB(32, 38, 64),
        Text = text,
        TextColor3 = Color3.fromRGB(230, 238, 255),
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        Parent = scroll,
    })
    addCorner(button, 11)
    addStroke(button, Color3.fromRGB(80, 125, 220), 1, 0.65)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 55, 92)}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 38, 64)}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        task.spawn(function()
            local ok, err = pcall(callback)
            if not ok then
                warnOnce("button_" .. text, text .. " error: " .. tostring(err))
            end
        end)
    end)

    return button
end

local function makeToggle(text, flagName, callback)
    local button = create("TextButton", {
        Size = UDim2.new(1, -4, 0, 42),
        BackgroundColor3 = Color3.fromRGB(28, 32, 50),
        TextColor3 = Color3.fromRGB(225, 232, 255),
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = scroll,
    })
    addCorner(button, 11)
    addStroke(button, Color3.fromRGB(70, 95, 150), 1, 0.72)

    local function redraw()
        local enabled = state.flags[flagName] or state.mutations[flagName]
        button.Text = (enabled and "   ON   " or "   OFF  ") .. text
        button.BackgroundColor3 = enabled and Color3.fromRGB(45, 95, 70) or Color3.fromRGB(28, 32, 50)
    end

    redraw()

    button.MouseButton1Click:Connect(function()
        local enabled

        if state.flags[flagName] ~= nil then
            enabled = not state.flags[flagName]
            state.flags[flagName] = enabled
        else
            enabled = not state.mutations[flagName]
            state.mutations[flagName] = enabled
        end

        redraw()

        task.spawn(function()
            local ok, err = pcall(callback, enabled)
            if not ok then
                warnOnce("toggle_" .. flagName, text .. " error: " .. tostring(err))
            end
        end)
    end)

    return button
end

local function getNetwork()
    local shared = ReplicatedStorage:FindFirstChild("Shared")
    local packages = shared and shared:FindFirstChild("Packages")
    local network = packages and packages:FindFirstChild("Network")

    if network then
        return network
    end

    network = ReplicatedStorage:FindFirstChild("Network", true)

    if network then
        return network
    end

    warnOnce("network_missing", "Network folder not found in ReplicatedStorage")
    return nil
end

local function getRemote(remoteName)
    local network = getNetwork()
    local remote = network and network:FindFirstChild(remoteName, true)

    if not remote then
        remote = ReplicatedStorage:FindFirstChild(remoteName, true)
    end

    return remote
end

local unpackArgs = table.unpack or unpack

local function callRemote(remoteName, ...)
    local args = {...}
    local argCount = select("#", ...)
    local remote = getRemote(remoteName)

    if not remote then
        warnOnce("missing_" .. remoteName, "Remote not found: " .. remoteName)
        return false, "missing"
    end

    if remote:IsA("RemoteEvent") then
        local ok, err = pcall(function()
            remote:FireServer(unpackArgs(args, 1, argCount))
        end)

        if not ok then
            warnOnce("fire_" .. remoteName, remoteName .. " FireServer error: " .. tostring(err))
            return false, err
        end

        return true
    end

    if remote:IsA("RemoteFunction") then
        local ok, result = pcall(function()
            return remote:InvokeServer(unpackArgs(args, 1, argCount))
        end)

        if not ok then
            warnOnce("invoke_" .. remoteName, remoteName .. " InvokeServer error: " .. tostring(result))
            return false, result
        end

        return true, result
    end

    warnOnce("badtype_" .. remoteName, remoteName .. " is not RemoteEvent/RemoteFunction, type = " .. remote.ClassName)
    return false, "bad type"
end

local function valueMatchesPlayer(value)
    if value == nil then
        return false
    end

    if typeof(value) == "Instance" then
        if value == player then
            return true
        end

        value = value.Name
    end

    local text = tostring(value)
    return text == player.Name or text == player.DisplayName or text == tostring(player.UserId)
end

local function getValueObjectValue(object)
    if object:IsA("ObjectValue") then
        return object.Value
    end

    if object:IsA("StringValue") or object:IsA("IntValue") or object:IsA("NumberValue") then
        return object.Value
    end

    return nil
end

local function getOwnedPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        warnOnce("plots_missing", "workspace.Plots not found")
        return nil
    end

    local attributeNames = {
        "Owner",
        "owner",
        "OwnerName",
        "ownerName",
        "Player",
        "player",
        "UserId",
        "OwnerUserId",
        "ownerUserId",
    }

    for _, plot in ipairs(plots:GetChildren()) do
        for _, attrName in ipairs(attributeNames) do
            if valueMatchesPlayer(plot:GetAttribute(attrName)) then
                return plot
            end
        end

        for _, childName in ipairs(attributeNames) do
            local child = plot:FindFirstChild(childName)
            if child and valueMatchesPlayer(getValueObjectValue(child)) then
                return plot
            end
        end
    end

    warnOnce("plot_missing", "Owned plot not found. Use Dump Plots to check owner attributes.")
    return nil
end

local function dumpRemotes()
    setStatus("Dumping remotes to F9 Output...", Color3.fromRGB(120, 210, 255))

    local count = 0
    for _, object in ipairs(ReplicatedStorage:GetDescendants()) do
        if object:IsA("RemoteEvent") or object:IsA("RemoteFunction") then
            count += 1
            if count <= 250 then
                print("[KLB Remote]", object.ClassName, object:GetFullName())
            end
        end
    end

    setStatus("Remote dump done: " .. tostring(count), Color3.fromRGB(120, 255, 170))
end

local function dumpPlots()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        setStatus("workspace.Plots not found", Color3.fromRGB(255, 120, 120))
        return
    end

    print("[KLB] LocalPlayer:", player.Name, player.DisplayName, player.UserId)

    for _, plot in ipairs(plots:GetChildren()) do
        print("[KLB Plot]", plot:GetFullName())

        local ok, attrs = pcall(function()
            return plot:GetAttributes()
        end)

        if ok then
            for key, value in pairs(attrs) do
                print("    Attribute", key, value)
            end
        end

        for _, child in ipairs(plot:GetChildren()) do
            if child:IsA("ObjectValue") or child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue") then
                print("    ValueObject", child.Name, child.ClassName, child.Value)
            end
        end
    end

    local owned = getOwnedPlot()
    setStatus(owned and ("Owned plot: " .. owned.Name) or "Owned plot not found", owned and Color3.fromRGB(120, 255, 170) or Color3.fromRGB(255, 120, 120))
end

local function doCollect()
    local called = false
    local plot = getOwnedPlot()
    local buttons = plot and plot:FindFirstChild("Buttons")

    if buttons then
        for _, item in ipairs(buttons:GetDescendants()) do
            if item:IsA("TouchTransmitter") then
                local parentName = item.Parent and item.Parent.Name

                if parentName == "l1" then
                    called = callRemote("rev_B_Collect", 1) or called
                elseif parentName == "l2" then
                    called = callRemote("rev_B_Collect", 2) or called
                else
                    called = callRemote("rev_B_Collect") or called
                end
            end
        end
    end

    if not called then
        callRemote("rev_B_Collect")
        callRemote("rev_B_Collect", 1)
        callRemote("rev_B_Collect", 2)
    end
end

local function doUpgrade()
    local called = false
    local plot = getOwnedPlot()
    local buttons = plot and plot:FindFirstChild("Buttons")

    if buttons then
        for _, item in ipairs(buttons:GetDescendants()) do
            if item:IsA("TouchTransmitter") then
                local parentName = item.Parent and item.Parent.Name

                if parentName == "l1" then
                    called = callRemote("rev_B_Upgrade", 1) or called
                    task.wait(0.15)
                elseif parentName == "l2" then
                    called = callRemote("rev_B_Upgrade", 2) or called
                    task.wait(0.15)
                end
            end
        end
    end

    if not called then
        callRemote("rev_B_Upgrade", 1)
        task.wait(0.15)
        callRemote("rev_B_Upgrade", 2)
    end
end

local function fireConnection(connection)
    local ok = pcall(function()
        connection:Fire()
    end)

    if ok then
        return true
    end

    if typeof(connection) == "table" and typeof(connection.Function) == "function" then
        local okFunction = pcall(connection.Function)
        if okFunction then
            return true
        end
    end

    return false
end

local function activateButton(button)
    local fired = false

    if typeof(getconnections) == "function" then
        local signals = {}

        pcall(function()
            table.insert(signals, button.Activated)
        end)

        pcall(function()
            table.insert(signals, button.MouseButton1Click)
        end)

        for _, signal in ipairs(signals) do
            local ok, connections = pcall(getconnections, signal)
            if ok then
                for _, connection in ipairs(connections) do
                    fired = fireConnection(connection) or fired
                end
            end
        end
    end

    if not fired and typeof(firesignal) == "function" then
        pcall(function()
            firesignal(button.Activated)
            fired = true
        end)

        pcall(function()
            firesignal(button.MouseButton1Click)
            fired = true
        end)
    end

    if not fired then
        pcall(function()
            button:Activate()
            fired = true
        end)
    end

    return fired
end

local function doBonus()
    local pg = player:FindFirstChild("PlayerGui")
    local upgradesGui = pg and pg:FindFirstChild("KickUpgrades", true)

    if not upgradesGui then
        warnOnce("bonus_gui_missing", "PlayerGui.KickUpgrades not found")
        return
    end

    local fired = false

    for _, item in ipairs(upgradesGui:GetDescendants()) do
        if item.Name == "Bonus" and item:IsA("GuiButton") then
            fired = activateButton(item) or fired
        end
    end

    if not fired and upgradesGui:IsA("GuiButton") and upgradesGui.Name == "Bonus" then
        fired = activateButton(upgradesGui) or fired
    end

    if not fired then
        warnOnce("bonus_button_missing", "Bonus GuiButton found no fireable signal")
    end
end

local function getCharacterParts()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end

local function tryKickTools()
    local character, humanoid = getCharacterParts()
    local backpack = player:FindFirstChild("Backpack")
    local activated = 0

    local function useTool(tool)
        if not tool:IsA("Tool") then
            return
        end

        if humanoid and tool.Parent ~= character then
            pcall(function()
                humanoid:EquipTool(tool)
            end)
            task.wait(0.05)
        end

        local ok = pcall(function()
            tool:Activate()
        end)

        if ok then
            activated += 1
        end
    end

    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            useTool(tool)
        end
    end

    for _, tool in ipairs(character:GetChildren()) do
        useTool(tool)
    end

    return activated
end

local function doKickAndClaim()
    local activated = tryKickTools()

    -- The decoded original has no real kick remote. These collect calls are the only claim remotes present in the file.
    callRemote("rev_B_Collect")
    callRemote("rev_B_Collect", 1)
    callRemote("rev_B_Collect", 2)

    return activated
end

local function cleanMutationHighlights()
    for object, highlight in pairs(state.highlights) do
        if not object.Parent or not highlight.Parent then
            state.highlights[object] = nil
            pcall(function()
                highlight:Destroy()
            end)
        end
    end
end

local function objectMatchesMutation(object, mutationName)
    local target = string.lower(mutationName)

    if string.find(string.lower(object.Name), target, 1, true) then
        return true
    end

    local ok, attrs = pcall(function()
        return object:GetAttributes()
    end)

    if ok then
        for key, value in pairs(attrs) do
            local text = string.lower(tostring(key) .. " " .. tostring(value))
            if string.find(text, target, 1, true) then
                return true
            end
        end
    end

    return false
end

local function scanMutations()
    local anyEnabled = false
    for _, enabled in pairs(state.mutations) do
        if enabled then
            anyEnabled = true
            break
        end
    end

    if not anyEnabled then
        for _, highlight in pairs(state.highlights) do
            pcall(function()
                highlight:Destroy()
            end)
        end
        state.highlights = {}
        return
    end

    cleanMutationHighlights()

    local added = 0
    local checked = 0

    for _, object in ipairs(workspace:GetDescendants()) do
        if checked > 4000 then
            break
        end

        checked += 1

        local canHighlight = object:IsA("Model") or object:IsA("BasePart")
        if canHighlight then
            for mutationName, enabled in pairs(state.mutations) do
                if enabled and objectMatchesMutation(object, mutationName) then
                    if not state.highlights[object] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "KLB_Mutation_Highlight"
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.FillTransparency = 0.65
                        highlight.OutlineTransparency = 0
                        highlight.Parent = object
                        state.highlights[object] = highlight
                        added += 1
                    end
                    break
                end
            end
        end
    end

    if added > 0 then
        setStatus("Mutation highlights added: " .. tostring(added), Color3.fromRGB(120, 255, 170))
    end
end

local function loopKick()
    setStatus("Perfect Kick loop ON", Color3.fromRGB(120, 255, 170))

    while state.alive and state.flags.kick do
        local activated = doKickAndClaim()
        if activated > 0 then
            setStatus("Kick tools activated: " .. tostring(activated), Color3.fromRGB(120, 255, 170))
        end
        task.wait(0.35)
    end

    setStatus("Perfect Kick loop OFF", Color3.fromRGB(190, 205, 255))
end

local function loopBonus()
    setStatus("Bonus loop ON", Color3.fromRGB(120, 255, 170))

    while state.alive and state.flags.bonus do
        doBonus()
        task.wait(0.3)
    end

    setStatus("Bonus loop OFF", Color3.fromRGB(190, 205, 255))
end

local function loopCash()
    setStatus("Cash loop ON", Color3.fromRGB(120, 255, 170))

    while state.alive and state.flags.cash do
        doCollect()
        task.wait(1.2)
    end

    setStatus("Cash loop OFF", Color3.fromRGB(190, 205, 255))
end

local function loopUpgrade()
    setStatus("Upgrade loop ON", Color3.fromRGB(120, 255, 170))

    while state.alive and state.flags.upgrade do
        doUpgrade()
        task.wait(1)
    end

    setStatus("Upgrade loop OFF", Color3.fromRGB(190, 205, 255))
end

local function loopSpeed()
    setStatus("Speed loop ON", Color3.fromRGB(120, 255, 170))

    while state.alive and state.flags.speed do
        callRemote("rev_SPEED_UPGRADE", 1)
        task.wait(0.5)
    end

    setStatus("Speed loop OFF", Color3.fromRGB(190, 205, 255))
end

local function loopRebirth()
    setStatus("Rebirth loop ON", Color3.fromRGB(120, 255, 170))

    while state.alive and state.flags.rebirth do
        callRemote("rev_RebirthRequest")
        task.wait(2)
    end

    setStatus("Rebirth loop OFF", Color3.fromRGB(190, 205, 255))
end

local mutationLoopRunning = false
local function startMutationLoop()
    if mutationLoopRunning then
        return
    end

    mutationLoopRunning = true

    task.spawn(function()
        while state.alive do
            scanMutations()
            task.wait(1.5)
        end

        mutationLoopRunning = false
    end)
end

makeLabel("Main")

makeToggle("Perfect Kick & Claim", "kick", function(enabled)
    if enabled then
        task.spawn(loopKick)
    end
end)

makeToggle("Bonus Train", "bonus", function(enabled)
    if enabled then
        task.spawn(loopBonus)
    end
end)

makeToggle("Collect Cash", "cash", function(enabled)
    if enabled then
        task.spawn(loopCash)
    end
end)

makeToggle("Upgrade All", "upgrade", function(enabled)
    if enabled then
        task.spawn(loopUpgrade)
    end
end)

makeToggle("Buy Speed", "speed", function(enabled)
    if enabled then
        task.spawn(loopSpeed)
    end
end)

makeToggle("Auto Rebirth", "rebirth", function(enabled)
    if enabled then
        task.spawn(loopRebirth)
    end
end)

makeLabel("Buttons")

makeButton("Sell All", function()
    local ok = callRemote("ref_B_SellAll")
    setStatus(ok and "Sell All called" or "Sell All failed", ok and Color3.fromRGB(120, 255, 170) or Color3.fromRGB(255, 120, 120))
end)

makeButton("Test Collect / Upgrade / Speed", function()
    doCollect()
    task.wait(0.2)
    doUpgrade()
    task.wait(0.2)
    callRemote("rev_SPEED_UPGRADE", 1)
    setStatus("Test calls sent", Color3.fromRGB(120, 255, 170))
end)

makeButton("Dump Remotes to F9", dumpRemotes)
makeButton("Dump Plots to F9", dumpPlots)

makeLabel("Find Mutation")

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
    state.mutations[mutationName] = false

    makeToggle(mutationName, mutationName, function()
        startMutationLoop()
    end)
end

local minimized = false
local originalSize = main.Size

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        body.Visible = false
        minimizeButton.Text = "+"
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(470, 64),
        }):Play()
    else
        body.Visible = true
        minimizeButton.Text = "–"
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Size = originalSize,
        }):Play()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    state.stop()
    screenGui:Destroy()
end)

local dragging = false
local dragStart
local startPosition
local dragInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

local function startupCheck()
    local network = getNetwork()
    if network then
        log("Network:", network:GetFullName())
    end

    for _, remoteName in ipairs({
        "rev_B_Collect",
        "rev_B_Upgrade",
        "rev_SPEED_UPGRADE",
        "rev_RebirthRequest",
        "ref_B_SellAll",
    }) do
        local remote = getRemote(remoteName)
        log(remoteName, remote and (remote.ClassName .. " | " .. remote:GetFullName()) or "NOT FOUND")
    end

    setStatus("Loaded. Check F9 if something fails.", Color3.fromRGB(120, 255, 170))
end

task.spawn(startupCheck)
