-- Kick a Lucky Block - Luau / Executor standalone build V2
-- No external UI library, no key system.
-- Uses decoded remotes + touch fallback + remote spy:
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

local function packArgs(...)
    local packed = { ... }
    packed.n = select("#", ...)
    return packed
end

local function copyArgs(args)
    local copied = { n = args and (args.n or #args) or 0 }

    for i = 1, copied.n do
        copied[i] = args[i]
    end

    return copied
end

local function argsToText(args)
    args = args or { n = 0 }
    local parts = {}
    local n = args.n or #args

    for i = 1, math.min(n, 8) do
        local value = args[i]
        local valueType = typeof(value)

        if valueType == "Instance" then
            local ok, fullName = pcall(function()
                return value:GetFullName()
            end)
            parts[#parts + 1] = ok and (value.ClassName .. ":" .. fullName) or (value.ClassName .. ":" .. value.Name)
        elseif valueType == "string" then
            parts[#parts + 1] = string.format("%q", value)
        else
            parts[#parts + 1] = tostring(value)
        end
    end

    if n > 8 then
        parts[#parts + 1] = "..."
    end

    return table.concat(parts, ", ")
end

local function callRemoteObject(remote, argsPack, label)
    argsPack = argsPack or { n = 0 }
    argsPack.n = argsPack.n or #argsPack
    label = label or (remote and remote.Name) or "remote"

    if not remote then
        return false, "missing remote object"
    end

    if not (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        warnOnce("badtype_obj_" .. label, label .. " is not RemoteEvent/RemoteFunction, type = " .. tostring(remote.ClassName))
        return false, "bad type"
    end

    local oldSuppress = state.suppressSpy
    state.suppressSpy = true

    local ok, result

    if remote:IsA("RemoteEvent") then
        ok, result = pcall(function()
            remote:FireServer(unpackArgs(argsPack, 1, argsPack.n))
        end)
    else
        ok, result = pcall(function()
            return remote:InvokeServer(unpackArgs(argsPack, 1, argsPack.n))
        end)
    end

    state.suppressSpy = oldSuppress

    if not ok then
        warnOnce("call_obj_" .. label, label .. " call error: " .. tostring(result))
        return false, result
    end

    return true, result
end

local function callRemote(remoteName, ...)
    local remote = getRemote(remoteName)

    if not remote then
        warnOnce("missing_" .. remoteName, "Remote not found: " .. remoteName)
        return false, "missing"
    end

    return callRemoteObject(remote, packArgs(...), remoteName)
end

local function findRemoteCandidates(words, maxResults)
    local found = {}
    maxResults = maxResults or 15

    for _, object in ipairs(ReplicatedStorage:GetDescendants()) do
        if object:IsA("RemoteEvent") or object:IsA("RemoteFunction") then
            local name = string.lower(object.Name)
            local fullName = string.lower(object:GetFullName())
            local matched = true

            for _, word in ipairs(words) do
                local needle = string.lower(tostring(word))
                if not string.find(name, needle, 1, true) and not string.find(fullName, needle, 1, true) then
                    matched = false
                    break
                end
            end

            if matched then
                found[#found + 1] = object
                if #found >= maxResults then
                    break
                end
            end
        end
    end

    return found
end

local remoteSpy = globalEnv.__KLB_REMOTE_SPY_V2 or {
    enabled = false,
    installed = false,
    calls = {},
    max = 80,
}

globalEnv.__KLB_REMOTE_SPY_V2 = remoteSpy
state.learned = state.learned or {}

local function recordSpyCall(remote, method, args)
    local ok, fullName = pcall(function()
        return remote:GetFullName()
    end)

    local packed = copyArgs(args or { n = 0 })

    local call = {
        remote = remote,
        method = method,
        args = packed,
        name = remote.Name,
        className = remote.ClassName,
        path = ok and fullName or remote.Name,
        time = os.clock(),
    }

    table.insert(remoteSpy.calls, call)

    while #remoteSpy.calls > remoteSpy.max do
        table.remove(remoteSpy.calls, 1)
    end

    print("[KLB SPY]", method, call.path, "ARGS:", argsToText(packed))
end

local function installRemoteSpy()
    if remoteSpy.installed then
        return true
    end

    if typeof(hookmetamethod) ~= "function" or typeof(getnamecallmethod) ~= "function" or typeof(newcclosure) ~= "function" then
        warnOnce("spy_not_supported", "Remote spy unsupported: executor has no hookmetamethod/getnamecallmethod/newcclosure")
        return false
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()

        local activeState = globalEnv[GLOBAL_KEY]
        local suppressed = activeState and activeState.suppressSpy

        if remoteSpy.enabled and not suppressed and typeof(self) == "Instance" then
            if method == "FireServer" or method == "InvokeServer" then
                if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                    recordSpyCall(self, method, packArgs(...))
                end
            end
        end

        return oldNamecall(self, ...)
    end))

    remoteSpy.oldNamecall = oldNamecall
    remoteSpy.installed = true
    return true
end

local function setSpyEnabled(enabled)
    if enabled then
        if not installRemoteSpy() then
            setStatus("Spy unsupported by executor", Color3.fromRGB(255, 120, 120))
            return false
        end

        remoteSpy.enabled = true
        setStatus("Spy ON: do action manually, then Learn Last", Color3.fromRGB(120, 255, 170))
        return true
    end

    remoteSpy.enabled = false
    setStatus("Spy OFF", Color3.fromRGB(190, 205, 255))
    return true
end

local function clearSpyCalls()
    remoteSpy.calls = {}
    setStatus("Spy calls cleared", Color3.fromRGB(190, 205, 255))
end

local function printSpyCalls()
    print("[KLB SPY] Last calls:", #remoteSpy.calls)

    for index, call in ipairs(remoteSpy.calls) do
        print(string.format("[KLB SPY #%d] %s %s ARGS: %s", index, tostring(call.method), tostring(call.path), argsToText(call.args)))
    end

    setStatus("Printed spy calls to F9: " .. tostring(#remoteSpy.calls), Color3.fromRGB(120, 210, 255))
end

local function getLastSpyCall()
    return remoteSpy.calls[#remoteSpy.calls]
end

local function learnLastRemote(actionName)
    local call = getLastSpyCall()

    if not call then
        setStatus("No spy calls. Turn Spy ON and do the action manually.", Color3.fromRGB(255, 120, 120))
        return false
    end

    state.learned[actionName] = {
        remote = call.remote,
        method = call.method,
        args = copyArgs(call.args),
        path = call.path,
        className = call.className,
    }

    setStatus("Learned " .. actionName .. ": " .. tostring(call.name), Color3.fromRGB(120, 255, 170))
    print("[KLB LEARNED]", actionName, call.method, call.path, "ARGS:", argsToText(call.args))
    return true
end

local function callLearnedRemote(actionName)
    local learned = state.learned[actionName]

    if not learned or not learned.remote then
        return false, "not learned"
    end

    if not learned.remote.Parent then
        warnOnce("learned_dead_" .. actionName, "Learned remote for " .. actionName .. " is no longer parented")
        return false, "dead remote"
    end

    return callRemoteObject(learned.remote, learned.args, "learned_" .. actionName)
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

local activateButton

local function getCharacterPartsV2()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end

local function getObjectPosition(object)
    local ok, result = pcall(function()
        if object:IsA("BasePart") then
            return object.Position
        end

        if object:IsA("Model") then
            return object:GetPivot().Position
        end

        local basePart = object:FindFirstChildWhichIsA("BasePart", true)
        return basePart and basePart.Position or nil
    end)

    return ok and result or nil
end

local function getBestButtonsFolder()
    local owned = getOwnedPlot()
    local ownedButtons = owned and owned:FindFirstChild("Buttons")

    if ownedButtons then
        return ownedButtons, "owned plot"
    end

    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return nil, "no workspace.Plots"
    end

    local _, _, root = getCharacterPartsV2()
    local bestButtons
    local bestDistance = math.huge

    for _, plot in ipairs(plots:GetChildren()) do
        local buttons = plot:FindFirstChild("Buttons")
        local pos = buttons and getObjectPosition(plot)

        if buttons and pos then
            local distance = root and (root.Position - pos).Magnitude or 0

            if distance < bestDistance then
                bestDistance = distance
                bestButtons = buttons
            end
        end
    end

    if bestButtons then
        return bestButtons, "nearest plot"
    end

    return nil, "buttons not found"
end

local function getTouchButtonParts(mode)
    local buttons, reason = getBestButtonsFolder()
    local parts = {}

    if not buttons then
        warnOnce("buttons_missing_" .. tostring(mode), "Buttons folder not found: " .. tostring(reason))
        return parts
    end

    for _, item in ipairs(buttons:GetDescendants()) do
        if item:IsA("TouchTransmitter") and item.Parent and item.Parent:IsA("BasePart") then
            local part = item.Parent
            local partName = string.lower(part.Name)
            local fullName = string.lower(part:GetFullName())
            local include = false

            if mode == "collect" then
                include = true
            elseif mode == "upgrade" then
                include = partName == "l1" or partName == "l2" or string.find(fullName, "upgrade", 1, true) ~= nil
            else
                include = true
            end

            if include then
                parts[#parts + 1] = part
            end
        end
    end

    return parts
end

local function touchPart(part)
    local _, _, root = getCharacterPartsV2()

    if not root or not part then
        return false
    end

    if typeof(firetouchinterest) ~= "function" then
        warnOnce("no_firetouchinterest", "firetouchinterest is unavailable in this executor")
        return false
    end

    local touched = false

    pcall(function()
        firetouchinterest(root, part, 0)
        task.wait(0.03)
        firetouchinterest(root, part, 1)
        touched = true
    end)

    pcall(function()
        firetouchinterest(part, root, 0)
        task.wait(0.03)
        firetouchinterest(part, root, 1)
        touched = true
    end)

    return touched
end

local function touchButtons(mode, limit)
    local count = 0
    local parts = getTouchButtonParts(mode)
    limit = limit or 60

    for _, part in ipairs(parts) do
        if count >= limit then
            break
        end

        if touchPart(part) then
            count += 1
        end
    end

    return count
end

local function textOfGuiButton(button)
    local texts = { button.Name }

    pcall(function()
        if button.Text and button.Text ~= "" then
            texts[#texts + 1] = button.Text
        end
    end)

    for _, child in ipairs(button:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            pcall(function()
                if child.Text and child.Text ~= "" then
                    texts[#texts + 1] = child.Text
                end
            end)
        end
    end

    return string.lower(table.concat(texts, " "))
end

local function isOwnGuiObject(object)
    local ok, result = pcall(function()
        return object:IsDescendantOf(screenGui)
    end)

    return ok and result or false
end

local function findGuiButtonsByWords(words)
    local found = {}
    local playerGuiNow = player:FindFirstChild("PlayerGui")

    if not playerGuiNow then
        return found
    end

    for _, object in ipairs(playerGuiNow:GetDescendants()) do
        if object:IsA("GuiButton") and not isOwnGuiObject(object) then
            local text = textOfGuiButton(object)
            local matched = true

            for _, word in ipairs(words) do
                if not string.find(text, string.lower(tostring(word)), 1, true) then
                    matched = false
                    break
                end
            end

            if matched then
                found[#found + 1] = object
            end
        end
    end

    return found
end

local function clickGuiButtonsByWords(words, limit)
    local clicked = 0
    local buttons = findGuiButtonsByWords(words)
    limit = limit or 10

    for _, button in ipairs(buttons) do
        if clicked >= limit then
            break
        end

        if activateButton and activateButton(button) then
            clicked += 1
        end
    end

    return clicked, #buttons
end

local function equipGuidTools()
    local character, humanoid = getCharacterPartsV2()
    local backpack = player:FindFirstChild("Backpack")
    local equipped = 0

    local function tryEquip(tool)
        if not tool:IsA("Tool") then
            return
        end

        local hasGuid = false
        pcall(function()
            hasGuid = tool:GetAttribute("GUID") ~= nil
        end)

        if humanoid and (hasGuid or string.find(string.lower(tool.Name), "kick", 1, true)) then
            pcall(function()
                humanoid:EquipTool(tool)
            end)
            equipped += 1
            task.wait(0.05)
        end
    end

    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            tryEquip(tool)
        end
    end

    if character then
        for _, tool in ipairs(character:GetChildren()) do
            tryEquip(tool)
        end
    end

    return equipped
end

local function doCollect()
    local remoteCalls = 0

    if callLearnedRemote("collect") then
        remoteCalls += 1
    end

    if callRemote("rev_B_Collect") then
        remoteCalls += 1
    end

    if callRemote("rev_B_Collect", 1) then
        remoteCalls += 1
    end

    if callRemote("rev_B_Collect", 2) then
        remoteCalls += 1
    end

    local touches = touchButtons("collect", 80)

    if remoteCalls > 0 or touches > 0 then
        setStatus("Collect: remotes " .. tostring(remoteCalls) .. ", touches " .. tostring(touches), Color3.fromRGB(120, 255, 170))
        return true
    end

    setStatus("Collect failed: no remote/touch", Color3.fromRGB(255, 120, 120))
    return false
end

local function doUpgrade()
    local remoteCalls = 0

    if callLearnedRemote("upgrade") then
        remoteCalls += 1
    end

    if callRemote("rev_B_Upgrade", 1) then
        remoteCalls += 1
    end

    task.wait(0.08)

    if callRemote("rev_B_Upgrade", 2) then
        remoteCalls += 1
    end

    local touches = touchButtons("upgrade", 60)

    if remoteCalls > 0 or touches > 0 then
        setStatus("Upgrade: remotes " .. tostring(remoteCalls) .. ", touches " .. tostring(touches), Color3.fromRGB(120, 255, 170))
        return true
    end

    setStatus("Upgrade failed: no remote/touch", Color3.fromRGB(255, 120, 120))
    return false
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

activateButton = function(button)
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

    if typeof(firesignal) == "function" then
        pcall(function()
            firesignal(button.Activated)
            fired = true
        end)

        pcall(function()
            firesignal(button.MouseButton1Click)
            fired = true
        end)
    end

    pcall(function()
        button:Activate()
        fired = true
    end)

    pcall(function()
        local virtualInput = game:GetService("VirtualInputManager")
        local pos = button.AbsolutePosition + (button.AbsoluteSize / 2)
        virtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        task.wait(0.03)
        virtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
        fired = true
    end)

    return fired
end

local function doBonus()
    local remoteCalls = 0
    local clicks = 0
    local found = 0

    equipGuidTools()

    if callLearnedRemote("bonus") then
        remoteCalls += 1
    end

    local clicked1, found1 = clickGuiButtonsByWords({ "bonus" }, 20)
    clicks += clicked1
    found += found1

    local playerGuiNow = player:FindFirstChild("PlayerGui")
    local upgradesGui = playerGuiNow and playerGuiNow:FindFirstChild("KickUpgrades", true)

    if upgradesGui then
        for _, item in ipairs(upgradesGui:GetDescendants()) do
            if item:IsA("GuiButton") and not isOwnGuiObject(item) then
                local text = textOfGuiButton(item)
                if string.find(text, "bonus", 1, true) then
                    found += 1
                    if activateButton(item) then
                        clicks += 1
                    end
                end
            end
        end
    end

    if remoteCalls > 0 or clicks > 0 then
        setStatus("Bonus: remotes " .. tostring(remoteCalls) .. ", clicked " .. tostring(clicks), Color3.fromRGB(120, 255, 170))
        return true
    end

    setStatus("Bonus not fired. Found buttons: " .. tostring(found), Color3.fromRGB(255, 120, 120))
    return false
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
    local remoteCalls = 0

    if callLearnedRemote("kick") then
        remoteCalls += 1
    end

    local activated = tryKickTools()
    local clickedKick, foundKick = clickGuiButtonsByWords({ "kick" }, 8)
    local clickedClaim, foundClaim = clickGuiButtonsByWords({ "claim" }, 8)

    -- Claim/cash remotes from the decoded file.
    callRemote("rev_B_Collect")
    callRemote("rev_B_Collect", 1)
    callRemote("rev_B_Collect", 2)

    local total = remoteCalls + activated + clickedKick + clickedClaim

    if total > 0 then
        setStatus(
            "Kick: learned " .. tostring(remoteCalls)
                .. ", tools " .. tostring(activated)
                .. ", gui " .. tostring(clickedKick + clickedClaim),
            Color3.fromRGB(120, 255, 170)
        )
    else
        setStatus("Kick not found. GUI kick/claim found: " .. tostring(foundKick + foundClaim), Color3.fromRGB(255, 120, 120))
    end

    return total
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

makeLabel("Remote Spy / Learn")

makeButton("Spy ON / OFF", function()
    setSpyEnabled(not remoteSpy.enabled)
end)

makeButton("Spy Clear", clearSpyCalls)
makeButton("Spy Print Calls to F9", printSpyCalls)

makeButton("Learn Last as Kick", function()
    learnLastRemote("kick")
end)

makeButton("Learn Last as Bonus", function()
    learnLastRemote("bonus")
end)

makeButton("Learn Last as Collect", function()
    learnLastRemote("collect")
end)

makeButton("Learn Last as Upgrade", function()
    learnLastRemote("upgrade")
end)

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
