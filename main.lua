---------pleaseee dont look at my code, it's spaghetti







if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "SCP Demonstration by Ali",
    LoadingTitle = "SCP Demo GUI",
    LoadingSubtitle = "by Ali",
    ShowText = "SCP:D",

    ToggleUIKeybind = "K"
})

local mainTab = Window:CreateTab("Main")
local visualTab = Window:CreateTab("Visual")
local teamTab = Window:CreateTab("Team/Shop")
local plrTab = Window:CreateTab("Player")
local bindsTab = Window:CreateTab("Shortcuts")
local settingsTab = Window:CreateTab("Debug")

----------------------------------------------------
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local PlaceId, JobId = game.PlaceId, game.JobId

local Camera = workspace.CurrentCamera
local localplr = Players.LocalPlayer
local localgui = localplr.PlayerGui

local PVP = ReplicatedStorage:FindFirstChild("PVP")
local gameStatus = ReplicatedStorage:FindFirstChild("GameStatus")

local cframe = CFrame.new(1.53290033, 1.97216606, -0.825374484, 0.982948065, -0.171378091, -0.0666531026, 0.0773534179, 0.714215279, -0.695638537, 0.166821882, 0.678620696, 0.715293169)
local falldmg = PVP and PVP:FindFirstChild("FallDamage")
local flashfx = localgui:FindFirstChild("FlashFx") or nil

local iesp = false
local noshyguy = false
local fullbrightEnabled = false
local roomESPEnabled = false
local debugViewEnabled = false
local scriptDestroying = false
local teleportDropdown
local teleportBusy = false
local activeTeleportTween
local teleportSelectionReset = false
local teleportRefreshQueued = false
local roomParts = {}
local roomMarkers = {}
local specialRoomModels = {}
local debugParts = {}
local shyCovers = {}
local originalLighting = nil
local fastoldman = false
local silentaimbot = false
local filterteam = true
local filtercds = true
local resetafter = true
local plresp = false
local esp_tracers = true
local tracerOption = "From Mouse"
local esp_names = false
local esp_boxes = false
local esp_hl = true
local esp_skeleton = false
local esp_distance = false
local esp_health = false
local getclosestheadloopactive = true

local espDrawings = {}
local espelem = {}
local R15Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "HumanoidRootPart"},

    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},

    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},

    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},

    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}
local R6Bones = {
    {"Head", "Torso"},
    {"Torso", "HumanoidRootPart"},

    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local runLoop
local endconnections = {}
local localCharConnections = {}

gameStatus:SetAttribute("SpawnWaveTime", 0)

---------------------FUNCS AND CONNECTIONS

function notif(text, title, dur)
    Rayfield:Notify({
        Title = title or "Notification",
        Content = text or "there should be text here",
        Duration = dur or 5
    })
end

local function getChar(plr)
    return plr.Character or plr.CharacterAdded:Wait()
end
local function getHuman(char)
    return char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2)
end
local function getRoot(char, humanoid)
    if not humanoid then humanoid = getHuman(char) end
    return char:FindFirstChild("HumanoidRootPart") or (humanoid and humanoid.RootPart) or char:WaitForChild("HumanoidRootPart", 2) or char:FindFirstChild("Head")
end
local function getRigType(char)
    return char:FindFirstChild("UpperTorso") and "R15"
            or char:FindFirstChild("Torso") and "R6"
            or nil
end
local function clearLocalCharConnections()
    for _, c in ipairs(localCharConnections) do
        c:Disconnect()
    end
    localCharConnections = {}
end

local function safeFind(root, path) --this is a cool object path finder
    local current = root
    for _, name in ipairs(path) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function sameTeam(plr, isesp)
    local localteam = localplr.Team
	local plrteam = plr.Team

	if plrteam == localteam then
		return true
	end
	if localteam.Name == "Class D" or localteam.Name == "Chaos Insurgency" then
		if plrteam.Name == "Class D" or plrteam.Name == "Chaos Insurgency" or (not isesp and filtercds and localteam.Name == "Class D" and plrteam.Name == "Scientist") then
			return true
		else
			return false
		end
	end
	if localteam.Name == "Scientist" or localteam.Name == "Mobile Task Force" then
		if plrteam.Name == "Scientist" or plrteam.Name == "Mobile Task Force" or (not isesp and filtercds and localteam.Name == "Scientist" and plrteam.Name == "Class D") then
			return true
		else
			return false
		end
	end
    return false
end

local function isDead(plr)
    local char = plr.Character
    if not char then return true end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local fakeHp = humanoid:GetAttribute("Health")
    return (fakeHp ~= nil and fakeHp <= 0)
        or humanoid:GetState() == Enum.HumanoidStateType.Dead
end

local function reset()
    local char = getChar(localplr)
    local humanoid = getHuman(char)
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    elseif char then
        char:BreakJoints()
    else
        notif("idk wtf happened but you cant reset")
    end
end

local function makefast(char)
    clearLocalCharConnections()

    local humanoid = getHuman(char)
    if not humanoid then return end

    local hc = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not fastoldman and localplr.Team.Name ~= "SCP" then return end
        if humanoid.WalkSpeed == 3 or humanoid.WalkSpeed == 16.5 then return end

        if humanoid.WalkSpeed <= 1.5 then
            humanoid.WalkSpeed = 3
        elseif humanoid.WalkSpeed <= 15 then
            humanoid.WalkSpeed = 16.5
        end
    end)

    table.insert(localCharConnections, hc)
end
table.insert(localCharConnections, localplr.CharacterAdded:Connect(makefast))

local function find(child)
    if not child then return end --how no child
    
	if child:IsA("Tool") then
		if not child:FindFirstChild("Handle") then return end
		local handle = child.Handle
        local ba = handle:FindFirstChild("LocalItemESPBox")
		if ba then
			ba:Destroy()
		end
		local ttype = child:GetAttribute("ToolType")

		local b = Instance.new("BoxHandleAdornment")
        b.Name = "LocalItemESPBox"
		b.Size = handle.Size
		b.Parent = handle
		b.Adornee = handle
		b.AlwaysOnTop = true
		b.ZIndex = 10
		b.Transparency = .66
        table.insert(espelem, b)

		
		if ttype == "Keycard" then
			b.Color3 = Color3.fromRGB(0, 255, 255)
		elseif ttype == "Medical" then
			b.Color3 = Color3.fromRGB(0, 255, 0)
            if handle.Name == "DeadMedkit" then
                b.Color3 = Color3.fromRGB(255, 0, 0)
            end
            local nameconnection
            nameconnection = handle:GetPropertyChangedSignal("Name"):Connect(function()
                if handle.Name == "DeadMedkit" then
                    b.Color3 = Color3.fromRGB(255, 0, 0)
                    nameconnection:Disconnect()
                end
            end)
		elseif ttype == "Firearm" then
			b.Color3 = Color3.fromRGB(255, 0, 0)
		elseif ttype == "SCPItem" then
			b.Color3 = Color3.fromRGB(255, 0, 255)
		elseif ttype == "Grenade" then
			b.Color3 = Color3.fromRGB(255, 255, 0)
		elseif ttype == "Ammo" then
			b.Color3 = Color3.fromRGB(0, 0, 255)
		else
			b.Color3 = Color3.fromRGB(255, 255, 255)
		end

        ------micro
        if child.Name == "Micro HID" then
            local sscript = child:FindFirstChild("MicroServer")
            local charge = sscript and sscript:FindFirstChild("Charge")
            if not charge then return end
            b.Size += Vector3.new(.5,.5,.5)

            local function microCharge()
                local value = math.clamp(charge.Value, 0, 1)
                b.Color3 = Color3.new(value, value, value)
                b.Transparency = .5 + (1 - value) * .25
            end
            microCharge()

            local cgpcsc = charge:GetPropertyChangedSignal("Value"):Connect(microCharge)
            table.insert(endconnections, cgpcsc)

            child.Destroying:Once(function()
                if cgpcsc then
                    cgpcsc:Disconnect()
                end
            end)
        end
	end
end

local roomNames = {
    CheckptA = true, CheckptB = true, ["914"] = true,
    ["South HCZ-EZ Checkpoint"] = true, ["North HCZ-EZ Checkpoint"] = true,
    GateA = true, GateB = true, Warhead = true, ["049"] = true,
    ["106"] = true, Armory = true, HID = true, ["Class D Spawn"] = true
}
local directRoomNames = {Armory = true, HID = true, ["Class D Spawn"] = true}
local function exit(child)
    if not child or not child:IsA("BasePart") then return false end
    local parent = child.Parent
    if not parent then return false end
    return (roomNames[parent.Name] and (child.Name == "Front" or child.Name == "HCZ"))
        or directRoomNames[child.Name] == true
        or (parent:IsA("Model") and directRoomNames[parent.Name] and specialRoomModels[parent] == child)
end

local function roomDisplayName(part)
    local parent = part.Parent
    local name = directRoomNames[part.Name] and part.Name or parent.Name
    if name == "CheckptA" or name == "CheckptB" or name == "Armory" then
        local container = directRoomNames[part.Name] and parent or parent.Parent
        return name .. " (" .. (container and container.Name or "Unknown") .. ")"
    end
    return name
end

local function getBoundingBox(char)
    local cf, size = char:GetBoundingBox()
    return cf, size
end

local function hideSkeleton(drawings)
    if drawings.Skeleton and drawings.Skeleton.Lines then
        for _, line in ipairs(drawings.Skeleton.Lines) do
            line.Visible = false
        end
    end
end

local function createESP(player)
    if espDrawings[player] then
        removeESP(player)
    end

    local drawings = {
        Line = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Box = Drawing.new("Square"),
        Highlight = Instance.new("Highlight"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text")
    }
    drawings.Skeleton = {
        Lines = {},
        Bones = {},
        RigType = nil
    }

    drawings.Line.Thickness = 1
    drawings.Line.Visible = false
    drawings.Line.Color = Color3.new(1,1,1)

    drawings.Name.Size = 13
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Visible = false
    drawings.Name.Color = Color3.new(1,1,1)
    
    drawings.Distance.Size = 13
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Visible = false
    drawings.Distance.Color = Color3.new(1,1,1)
    drawings._lastDist = nil
    drawings._lastDistUpdate = 0

    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    drawings.Box.Color = Color3.new(1,1,1)

    drawings.Highlight.Parent = CoreGui
    drawings.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    drawings.Highlight.Enabled = false
    drawings.Highlight.FillColor = Color3.new(1,1,1)
    drawings.Highlight.FillTransparency = .33
    drawings.Highlight.OutlineColor = Color3.new(1,1,1)
    drawings.Highlight.OutlineTransparency = .5

    drawings.Health.Size = 13
    drawings.Health.Center = true
    drawings.Health.Outline = true
    drawings.Health.Visible = false
    drawings.Health.Color = Color3.new(1,1,1)
    drawings._lastHp = nil
    drawings._lastHpUpdate = 0
    drawings._lastShield = nil

    espDrawings[player] = drawings
end

local function removeESP(player)
    local drawings = espDrawings[player]
    if not drawings then return end
    print("removing esp from:", player)

    if drawings.Skeleton and drawings.Skeleton.Lines then
        for _, line in ipairs(drawings.Skeleton.Lines) do
            line:Destroy()
        end
    end

    if drawings.Line then drawings.Line:Destroy() end
    if drawings.Name then drawings.Name:Destroy() end
    if drawings.Box then drawings.Box:Destroy() end
    if drawings.Highlight then drawings.Highlight:Destroy() end
    if drawings.Distance then drawings.Distance:Destroy() end
    if drawings.Health then drawings.Health:Destroy() end

    espDrawings[player] = nil
end

local function getScreenEdgePoint(worldPosition, camera)
    local projected = camera:WorldToViewportPoint(worldPosition)
    local viewport = camera.ViewportSize
    local center = viewport * 0.5

    local point = Vector2.new(projected.X, projected.Y)

    -- Flip the projected direction when the target is behind the camera.
    if projected.Z < 0 then
        point = center - (point - center)
    end

    local direction = point - center
    if direction.Magnitude < 0.001 then
        return Vector2.new(center.X, 0)
    end

    local scaleX = math.huge
    local scaleY = math.huge

    if direction.X > 0 then
        scaleX = (viewport.X - 2 - center.X) / direction.X
    elseif direction.X < 0 then
        scaleX = (2 - center.X) / direction.X
    end

    if direction.Y > 0 then
        scaleY = (viewport.Y - 2 - center.Y) / direction.Y
    elseif direction.Y < 0 then
        scaleY = (2 - center.Y) / direction.Y
    end

    local scale = math.min(
        math.abs(scaleX),
        math.abs(scaleY)
    )

    return Vector2.new(
        math.clamp(center.X + direction.X * scale, 2, viewport.X - 2),
        math.clamp(center.Y + direction.Y * scale, 2, viewport.Y - 2)
    )
end

local circl = Drawing.new("Circle")
circl.Radius = 115
circl.Visible = false
circl.Thickness = 2
circl.Color = Color3.new(0,0,1)

local reticle = Drawing.new("Circle")
reticle.Visible = false
reticle.Radius = 2
reticle.Thickness = 1
reticle.Filled = false
reticle.Color = Color3.new(1,1,1)

local trackedPlayers = {}
local function addConnection(player, conn)
    local data = trackedPlayers[player]
    if data then
        table.insert(data.Connections, conn)
    end
end

local function trackPlayer(player)
    if player == localplr or trackedPlayers[player] then return end

    createESP(player)
    local data = {
        Player = player, Character = nil, Head = nil, Root = nil,
        RigType = nil, Humanoid = nil, Connections = {},
        CharacterConnections = {}, Generation = 0
    }
    trackedPlayers[player] = data

    local function clearCharacterConnections()
        for _, conn in ipairs(data.CharacterConnections) do
            conn:Disconnect()
        end
        table.clear(data.CharacterConnections)
    end

    local function refreshSkeleton(char)
        local rigType = getRigType(char)
        if not rigType or data.RigType == rigType then return end

        data.RigType = rigType
        local drawings = espDrawings[player]
        if not drawings then return end

        for _, line in ipairs(drawings.Skeleton.Lines) do
            line:Destroy()
        end

        local bones = rigType == "R6" and R6Bones or R15Bones
        drawings.Skeleton = {Lines = {}, Bones = bones, RigType = rigType}

        for i = 1, #bones do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 1
            line.Color = Color3.new(1, 1, 1)
            drawings.Skeleton.Lines[i] = line
        end
    end

    local function onCharacter(char)
        if not char then return end

        data.Generation += 1
        local generation = data.Generation

        clearCharacterConnections()

        data.Character, data.Head, data.Root = char, nil, nil
        data.Humanoid, data.RigType = nil, nil

        local drawings = espDrawings[player]
        if drawings then
            drawings.Highlight.Adornee = nil
            hideSkeleton(drawings)
            for _, line in ipairs(drawings.Skeleton.Lines) do line:Destroy() end
            drawings.Skeleton = {Lines = {}, Bones = {}, RigType = nil}
        end

        local function valid()
            return trackedPlayers[player] == data and data.Generation == generation and player.Character == char and char.Parent ~= nil
        end

        local function refreshParts()
            if not valid() then return end

            local humanoid = getHuman(char)
            local head = char:FindFirstChild("Head")
            local root = getRoot(char)

            data.Head = head and head:IsA("BasePart") and head or nil
            data.Humanoid = humanoid
            data.Root = root and root:IsA("BasePart") and root or nil

            if data.Root then
                local current = espDrawings[player]
                if current then current.Highlight.Adornee = char end
            end
            refreshSkeleton(char)
        end

        table.insert(data.CharacterConnections, char.ChildAdded:Connect(refreshParts))
        table.insert(data.CharacterConnections, char.ChildRemoved:Connect(refreshParts))
        refreshParts()

        task.spawn(function()
            while valid() and not data.Root do
                refreshParts()
                task.wait(0.1)
            end
        end)
    end

    addConnection(player, player.CharacterAdded:Connect(onCharacter))
    addConnection(player, player.CharacterRemoving:Connect(function(char)
        if data.Character ~= char then return end

        data.Generation += 1
        clearCharacterConnections()

        data.Character, data.Head, data.Root = nil, nil, nil
        data.Humanoid, data.RigType = nil, nil

        local drawings = espDrawings[player]
        if drawings then
            drawings.Highlight.Adornee = nil
            hideSkeleton(drawings)
        end
    end))

    if player.Character then onCharacter(player.Character) end
end

local function untrackPlayer(player)
    local data = trackedPlayers[player]
    if not data then
        if espDrawings[player] then removeESP(player) end
        return
    end
    
    data.Generation += 1
    trackedPlayers[player] = nil

    for _, conn in ipairs(data.Connections) do conn:Disconnect() end
    for _, conn in ipairs(data.CharacterConnections) do conn:Disconnect() end

    table.clear(data.Connections)
    table.clear(data.CharacterConnections)
    
    removeESP(player)
end

local function retrackPlayer(player)
    if player == localplr or player.Parent ~= Players then return end
    untrackPlayer(player)
    trackPlayer(player)
end

local function retrackAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        retrackPlayer(player)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
	trackPlayer(p)
end

table.insert(endconnections, Players.PlayerAdded:Connect(trackPlayer))
table.insert(endconnections, Players.PlayerRemoving:Connect(untrackPlayer))

local function getAimPart(data)
    local char = data.Character
    if not char or not char.Parent then return nil end

    local head = data.Head
    if head and head:IsDescendantOf(char) then return head end

    -- SCP rigs may have no conventional Head.
    for _, name in ipairs({"Head", "FacePoint", "HeadMesh", "Mesh", "UpperTorso", "Torso", "HumanoidRootPart"}) do
        local part = char:FindFirstChild(name, true)
        if part and part:IsA("BasePart") then return part end
    end
    if data.Root and data.Root:IsDescendantOf(char) then return data.Root end
    return char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart", true)
end

local function GetClosestHead(previous)
    local localChar = localplr.Character
    if not localChar then return nil end
    local origin = Camera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {localChar}
    local best, bestDist = nil, circl.Radius

    for player, data in pairs(trackedPlayers) do
        if filterteam and sameTeam(player) then continue end
        if isDead(player) then continue end
        local part = getAimPart(data)
        if not part then continue end
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen or pos.Z <= 0 then continue end
        local distance = (Vector2.new(pos.X, pos.Y) - circl.Position).Magnitude
        if distance > circl.Radius then continue end

        local delta = part.Position - origin
        local hit = workspace:Raycast(origin, delta, rayParams)
        if hit and not hit.Instance:IsDescendantOf(data.Character) then continue end

        -- Small preference for the existing target avoids oscillation between players.
        local score = distance - ((previous and previous:IsDescendantOf(data.Character)) and 12 or 0)
        if score < bestDist then
            bestDist, best = score, part
        end
    end
    return best
end

local chaosgui
local mtfgui
local shyguygui
local oldmangui
local docgui
local doggui
local dogagaingui
local peanutgui

local buttons = safeFind(localgui, {
    "MenuGui",
    "MainFrame",
    "Teams",
    "TeamButtons"
})
local playerTeams = buttons and buttons:FindFirstChild("Other")
local scpTeams = buttons and buttons:FindFirstChild("SCPs")

local queuegui = buttons and buttons.Parent:FindFirstChild("QueuedText")
local credits = buttons and safeFind(buttons.Parent.Parent, {
    "Shop",
    "Credits"
})

for i, frame in playerTeams:GetChildren() do
    if not frame:IsA("Frame") then continue end

    local fbutton = frame:FindFirstChild("Button")
    if fbutton.Image == "rbxassetid://14263777415" then
        chaosgui = frame
    elseif fbutton.Image == "rbxassetid://6774779934" then
        mtfgui = frame
    end
end
for i, frame in scpTeams:GetChildren() do
    if not frame:IsA("Frame") then continue end

    local fbutton = frame:FindFirstChild("Button")
    if fbutton.Image == "rbxassetid://6652560715" then
        shyguygui = frame
    elseif fbutton.Image == "rbxassetid://9606026315" then
        oldmangui = frame
    elseif fbutton.Image == "rbxassetid://130261444621233" then
        docgui = frame
    elseif fbutton.Image == "rbxassetid://17660598360" then
        doggui = frame
    elseif fbutton.Image == "rbxassetid://10563151614" then
        dogagaingui = frame
    elseif fbutton.Image == "rbxassetid://107633438687013" then
        peanutgui = frame
    end
end


local function coverFacePoint(facepoint)
    if not noshyguy or not facepoint:IsA("BasePart") or shyCovers[facepoint] then return end
    local cover = Instance.new("Part")
    cover.Name = "Local096FaceCover"
    cover.Size = facepoint.Size * Vector3.new(1.1, 1.1, 1.1)
    cover.CFrame = facepoint.CFrame
    cover.Color = Color3.fromRGB(255, 220, 0)
    cover.Material = Enum.Material.Neon
    cover.Transparency = 0.5
    cover.Anchored = false
    cover.CanCollide = false
    cover.CanTouch = false
    cover.CanQuery = true
    cover.Massless = true
    cover.Parent = facepoint.Parent
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = facepoint
    weld.Part1 = cover
    weld.Parent = cover
    shyCovers[facepoint] = cover
end

local function clearShyCovers()
    for facepoint, cover in pairs(shyCovers) do
        if cover then cover:Destroy() end
        shyCovers[facepoint] = nil
    end
end

local presetDestinations = {
    {"Exit", Vector3.new(51, -1536, 412)},
    {"MTF Spawn", Vector3.new(-215, -1515, 459)},
    {"Chaos Insurgency Spawn", Vector3.new(-117, -1527, 27)},
    {"Warhead", Vector3.new(2, 957, -185)},
    {"049", Vector3.new(179, 635, -198)},
    {"Outside Elevator A", Vector3.new(2, -1497, -23)},
    {"Outside Elevator B", Vector3.new(-112, -1514, 212)},
    {"Warhead Control", Vector3.new(-90, -1527, 98)}
}

local presetByName = {}
local dynamicDestinations = {}

for _, entry in ipairs(presetDestinations) do
    presetByName[entry[1]] = entry[2]
end

local function setRoomMarkerVisible(marker, visible)
    if marker.Box and marker.Box.Parent then marker.Box.Visible = visible end
    if marker.Label and marker.Label.Parent then marker.Label.Enabled = visible end
end

local function refreshTeleportOptions()
    if not teleportDropdown or scriptDestroying then return end

    local options = {}

    for _, entry in ipairs(presetDestinations) do
        table.insert(options, entry[1])
    end

    table.clear(dynamicDestinations)

    local names = {}
    for part in pairs(roomParts) do
        if part:IsDescendantOf(workspace) and exit(part) then
            local name = roomDisplayName(part)
            local baseName = directRoomNames[part.Name] and part.Name or part.Parent.Name
            if not presetByName[baseName] then
                table.insert(names, {name = name, part = part})
            end
        end
    end

    table.sort(names, function(a, b)
        if a.name == b.name then return a.part:GetFullName() < b.part:GetFullName() end
        return a.name < b.name
    end)

    local counts = {}
    for _, entry in ipairs(names) do
        counts[entry.name] = (counts[entry.name] or 0) + 1
        local name = entry.name
        if counts[name] > 1 then name ..= " (" .. counts[name] .. ")" end
        dynamicDestinations[name] = entry.part
        table.insert(options, name)
    end

    teleportDropdown:Refresh(options)
end

local function queueTeleportRefresh()
    if teleportRefreshQueued or scriptDestroying then return end

    teleportRefreshQueued = true
    task.delay(0.2, function()
        teleportRefreshQueued = false

        if not scriptDestroying then refreshTeleportOptions() end
    end)
end

local function unmarkRoomPart(handle)
    roomParts[handle] = nil

    local marker = roomMarkers[handle]
    if marker then
        if marker.Box then marker.Box:Destroy() end
        if marker.Label then marker.Label:Destroy() end
        roomMarkers[handle] = nil
    end

    queueTeleportRefresh()
end

local function markRoomPart(handle)
    if not handle:IsA("BasePart") or not exit(handle) or roomParts[handle] then return end
    roomParts[handle] = true

    local b = Instance.new("BoxHandleAdornment")
    b.Name = "LocalRoomESPBox"
    b.Size = handle.Size
    b.Adornee = handle
    b.AlwaysOnTop = true
    b.ZIndex = 10
    b.Transparency = .5
    b.Color3 = (handle.Parent.Name == "049" or handle.Parent.Name == "Warhead" or handle.Parent.Name == "914" or handle.Parent.Name == "106") and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,255,255)
    b.Visible = roomESPEnabled
    b.Parent = handle

    local ui = Instance.new("BillboardGui")
    ui.Name = "LocalRoomESPLabel"
    ui.Adornee = handle
    ui.Size = UDim2.fromScale(10, 2.5)
    ui.AlwaysOnTop = true
    ui.Enabled = roomESPEnabled
    ui.Parent = handle

    local label = Instance.new("TextLabel")
    label.Parent = ui
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.TextScaled = true
    label.RichText = true
    label.Text = roomDisplayName(handle)

    roomMarkers[handle] = {Box = b, Label = ui}
    queueTeleportRefresh()
end

local function markSpecialModel(model)
    if not model:IsA("Model") or not directRoomNames[model.Name] or specialRoomModels[model] then return end

    local part = model:FindFirstChild("Front", true) or model:FindFirstChild("HCZ", true) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not part or not part:IsA("BasePart") then return end

    if part.Parent == model then
        specialRoomModels[model] = part
        markRoomPart(part)
    end
end

local function scanRoomParts()
    for _, child in ipairs(workspace:GetDescendants()) do
        if child:IsA("Model") and directRoomNames[child.Name] then markSpecialModel(child) end

        if child:IsA("BasePart") and (child.Name == "Front" or child.Name == "HCZ" or directRoomNames[child.Name]) then
            markRoomPart(child)
        end
    end
end

local function markDebugPart(part)
    if not debugViewEnabled or not part:IsA("BasePart") or debugParts[part] then return end

    local name = part.Name
    local transparency, color

    if name == "Detector" then
        if not part:FindFirstChild("TouchInterest") or part.Transparency ~= 1 then return end

        transparency, color = .625, Color3.new(0, 0, 1)
    elseif name == "Death" then
        transparency, color = .5, Color3.new(1, 0, 0)
    elseif name == "InvisCollision" or name == "Barrier" then
        transparency = .5
    else
        return
    end

    debugParts[part] = {Transparency = part.Transparency, Color = part.Color}
    part.Transparency = transparency

    if color then part.Color = color end
end

local function clearDebugParts()
    for part, original in pairs(debugParts) do
        if part.Parent then
            part.Transparency = original.Transparency
            part.Color = original.Color
        end

        debugParts[part] = nil
    end
end

table.insert(endconnections, workspace.ChildAdded:Connect(function(child)
    if iesp then find(child) end
end))

table.insert(endconnections, workspace.DescendantAdded:Connect(function(child)
    if iesp then
        if child:IsA("Tool") then
            task.defer(function() if iesp and child:IsDescendantOf(workspace) then find(child) end end)
        elseif child.Name == "Handle" and child.Parent and child.Parent:IsA("Tool") then
            task.defer(function() if iesp then find(child.Parent) end end)
        end
    end
    if noshyguy and child.Name == "FacePoint" then
        task.defer(function() coverFacePoint(child) end)
    end
    
    if child:IsA("BasePart") then
        if child.Name == "Front" or child.Name == "HCZ" or directRoomNames[child.Name] then
            markRoomPart(child)
        end
        if debugViewEnabled then markDebugPart(child) end
    elseif child:IsA("Model") and directRoomNames[child.Name] then
        task.defer(function() if child:IsDescendantOf(workspace) then markSpecialModel(child) end end)
    elseif debugViewEnabled and child.Name == "TouchInterest" then
        local parent = child.Parent
        if parent and parent:IsA("BasePart") and parent.Name == "Detector" then
            task.defer(function() if debugViewEnabled then markDebugPart(parent) end end)
        end
    end
end))
table.insert(endconnections, workspace.DescendantRemoving:Connect(function(child)
    if roomParts[child] then unmarkRoomPart(child) end
    if specialRoomModels[child] then specialRoomModels[child] = nil end
    debugParts[child] = nil
end))

scanRoomParts()


local nukeframe
local disabled
local timeframes
local minone
local mintwo
local secone
local sectwo
local milone
local miltwo
local inevitable

local nukeconnections = {}

local function getNukeVars()
    local hcz = workspace:FindFirstChild("Heavy Containment Zone")
    if hcz then
        for i, connection in nukeconnections do
            connection:Disconnect()
            nukeconnections[i] = nil
        end

        local nukeframe = safeFind(hcz, {
            "WarheadNonModular",
            "Room",
            "Collidables",
            "SCPSLPanel",
            "Screen",
            "WarheadScreen",
            "MainFrame"
        })
		disabled = nukeframe:FindFirstChild("Disabled")
        timeframes = nukeframe:FindFirstChild("Time")
        minone = timeframes:FindFirstChild("Min1")
        mintwo = timeframes:FindFirstChild("Min2")
        secone = timeframes:FindFirstChild("Sec1")
        sectwo = timeframes:FindFirstChild("Sec2")
        milone = timeframes:FindFirstChild("Mil1")
        miltwo = timeframes:FindFirstChild("Mil2")
        inevitable = nukeframe:FindFirstChild("Inevitable")
        return true
    else
        return false
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local espd = visualTab:CreateDropdown({
    Name = "Player ESP",
    Options = {"Toggle", "Highlight", "Names", "Boxes", "Tracers", "Skeleton", "Distance", "Health"},
    CurrentOption = {"Highlight", "Tracers"},
    MultipleOptions = true,
    Callback = function(Options)
        plresp = table.find(Options, "Toggle") ~= nil
        esp_boxes = table.find(Options, "Boxes") ~= nil
        esp_tracers = table.find(Options, "Tracers") ~= nil
        esp_names = table.find(Options, "Names") ~= nil
        esp_hl = table.find(Options, "Highlight") ~= nil
        esp_skeleton = table.find(Options, "Skeleton") ~= nil
        esp_distance = table.find(Options, "Distance") ~= nil
        esp_health = table.find(Options, "Health") ~= nil
    end
})

visualTab:CreateDropdown({
    Name = "Tracer ESP Options",
    Options = {"From Bottom", "From Top", "From Center", "From Mouse", "From Character"},
    CurrentOption = {"From Mouse"},
    MultipleOptions = false,
    Callback = function(Options)
        tracerOption = Options[1]
    end
})
visualTab:CreateButton({
    Name = "Reload ESP",
    Callback = function()
        retrackAllPlayers()
        notif("Player ESP tracking reinitialized.", "ESP Reloaded")
    end
})

local itemEsp = visualTab:CreateToggle({
    Name = "Item Esp",
    CurrentValue = false,
    Callback = function(Value)
        iesp = Value
        if Value == true then
            for i, child in workspace:GetChildren() do
	            find(child)
            end
        else
            for i, child in pairs(espelem) do
                child:Destroy()
                espelem[i] = nil
            end
        end
    end
})

local reticletoggle = visualTab:CreateToggle({
    Name = "Reticle",
    CurrentValue = false,
    Callback = function(Value)
        reticle.Visible = Value
    end
})

local noFlash = visualTab:CreateToggle({
    Name = "Disable flash effect",
    CurrentValue = false,
    Callback = function(Value)
        if Value == true then
            if localgui:FindFirstChild("FlashFx") then
                flashfx.Parent = ReplicatedStorage
            end
        else
            flashfx.Parent = localgui
        end
    end
})

local findRooms = visualTab:CreateToggle({
    Name = "Find checkpoints, elevators, and gates",
    CurrentValue = false,
    Callback = function(Value)
        roomESPEnabled = Value

        for _, marker in pairs(roomMarkers) do
            setRoomMarkerVisible(marker, Value)
        end
    end
})

local visd = visualTab:CreateToggle({
    Name = "Debug View",
    CurrentValue = false,
    Callback = function(Value)
        debugViewEnabled = Value

        if Value then
            local count = 0
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    markDebugPart(part)
                end
            end

            for _ in pairs(debugParts) do count += 1 end
            notif("Found " .. count .. " Parts.")
        else
            clearDebugParts()
        end
    end
})

local function applyFullbright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end

local fullbright = visualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(Value)
        fullbrightEnabled = Value
        if Value then
            originalLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                OutdoorAmbient = Lighting.OutdoorAmbient
            }
            applyFullbright()
        elseif originalLighting then
            for property, value in pairs(originalLighting) do
                Lighting[property] = value
            end
            originalLighting = nil
        end
    end
})

local function updatelabel(gui, label, textname:string, gamepass:boolean)
	if not gui or not label or not textname then return end

    local timer = gui:FindFirstChild("Timer")
    local required = gui:FindFirstChild("Required")
    if not timer or not required then return end

	local open = timer.Text == "0:00" or timer.TextTransparency == 1
	if required.TextTransparency == 0 then
		if gamepass then
			label:Set(textname..": ??? (Gamepass Required)")
		else
			if open then
				label:Set(textname..": Open (Badge Required)")
			else
				label:Set(textname..": "..tostring(timer.Text).." (Badge Required)")
			end
		end
	else
		if open then
			label:Set(textname..": Open")
		else
			label:Set(textname..": "..tostring(timer.Text))
		end
	end
end

local creditslabel = teamTab:CreateLabel(credits.Text)

teamTab:CreateSection("Queue")
local queuelabel = teamTab:CreateLabel("Queued: None")
if queuegui.Text == nil or queuegui.Text == "" then
    queuelabel:Set("Queued: None")
else
    queuelabel:Set(queuegui.Text)
end

teamTab:CreateSection("Player Teams")
local swlabel = teamTab:CreateLabel(
    "End-game Spawn Wave Timer: "..gameStatus:GetAttribute("SpawnWaveTime"),
    nil,
    Color3.new(),
    false
)
local chaoslabel = teamTab:CreateLabel(
    "Chaos Insurgency: "..tostring(chaosgui.Timer.Text),
    14263777415,
    Color3.new(),
    false
)
updatelabel(chaosgui, chaoslabel, "Chaos Insurgency", false)
local mtflabel = teamTab:CreateLabel(
    "Mobile Task Force: "..tostring(mtfgui.Timer.Text),
    6774779934,
    Color3.new(),
    false
)
updatelabel(mtfgui, mtflabel, "Mobile Task Force", false)

teamTab:CreateSection("SCPs")
local shyguylabel = teamTab:CreateLabel(
    "SCP-096 Shy Guy: "..tostring(shyguygui.Timer.Text),
    6652560715,
    Color3.new(),
    false
)
updatelabel(shyguygui, shyguylabel, "SCP-096 Shy Guy", true)
local oldmanlabel = teamTab:CreateLabel(
    "SCP-106 Old Man: "..tostring(oldmangui.Timer.Text),
    9606026315,
    Color3.new(),
    false
)
updatelabel(oldmangui, oldmanlabel, "SCP-106 Old Man", true)
local doclabel = teamTab:CreateLabel(
    "SCP-049 Plague Doctor: "..tostring(docgui.Timer.Text),
    130261444621233,
    Color3.new(),
    false
)
updatelabel(docgui, doclabel, "SCP-049 Plague Doctor", true)
local doglabel = teamTab:CreateLabel(
    "SCP-939-53 With Many Voices: "..tostring(doggui.Timer.Text),
    17660598360,
    Color3.new(),
    false
)
updatelabel(doggui, doglabel, "SCP-939-53 With Many Voices", true)
local dogagainlabel = teamTab:CreateLabel(
    "SCP-939-89 With Many Voices: "..tostring(dogagaingui.Timer.Text),
    10563151614,
    Color3.new(),
    false
)
updatelabel(dogagaingui, dogagainlabel, "SCP-939-89 With Many Voices", true)
local peanutlabel = teamTab:CreateLabel(
    "SCP-173 The Sculpture: "..tostring(peanutgui.Timer.Text),
    107633438687013,
    Color3.new(),
    false
)
updatelabel(peanutgui, peanutlabel, "SCP-173 The Scuplture", true)

local function tweenToDestination(destination)
    if teleportBusy or scriptDestroying then return end

    local char = localplr.Character
    if not char then notif("Character is not ready.", "Teleport") return end
    
    local human = getHuman(char)
    local root = getRoot(char, human)
    if not root or not root:IsA("BasePart") then
        notif("No valid root or head found.", "Teleport")
        return
    end

    teleportBusy = true

    local target = CFrame.new(destination) * root.CFrame.Rotation
    local tween = TweenService:Create(root, TweenInfo.new(1.25, Enum.EasingStyle.Linear), {CFrame = target})
    activeTeleportTween = tween

    local completedConnection
    completedConnection = tween.Completed:Connect(function()
        if completedConnection then completedConnection:Disconnect() end

        if activeTeleportTween == tween then
            activeTeleportTween = nil
            teleportBusy = false
        end

        tween:Destroy()
    end)

    tween:Play()
end

local toggleaimbot = mainTab:CreateDropdown({
	Name = "Aimbot",
	Options = {"Toggle", "Filter Team", "Filter Class D/Scientist", "Circle"},
	CurrentOption = {"Filter Team", "Filter Class D/Scientist"},
	MultipleOptions = true,
	Callback = function(Options)
		silentaimbot = table.find(Options, "Toggle") ~= nil
        filterteam = table.find(Options, "Filter Team") ~= nil
        filtercds = table.find(Options, "Filter Class D/Scientist") ~= nil
		circl.Visible = table.find(Options, "Circle") ~= nil
	end
})

local noShyGuy = mainTab:CreateToggle({
    Name = "Disable SCP-096",
    CurrentValue = false,
    Callback = function(Value)
        noshyguy = Value
        if Value then
            for _, d in ipairs(workspace:GetDescendants()) do
                if d.Name == "FacePoint" then coverFacePoint(d) end
            end
        else
            clearShyCovers()
        end
    end
})

mainTab:CreateToggle({
	Name = "Faster 106 Door Movement",
	CurrentValue = false,
	Callback = function(Value)
		fastoldman = Value
		makefast(getChar(localplr))
	end
})

mainTab:CreateButton({
    Name = "Disable Fall Damage",
    Callback = function()
        if falldmg then
            falldmg:Destroy()
            notif("Fall Damage disabled.")
        else
            notif("Fall Damage already disabled.")
        end
    end
})

mainTab:CreateSection("Disable Fall Damage First!")

local teleportOptions = {}
for _, entry in ipairs(presetDestinations) do table.insert(teleportOptions, entry[1]) end

teleportDropdown = mainTab:CreateDropdown({
    Name = "Teleport",
    Options = teleportOptions,
    CurrentOption = nil,
    MultipleOptions = false,
    Callback = function(Options)
        if teleportSelectionReset or teleportBusy or scriptDestroying then return end

        local choice = Options and Options[1]
        if not choice then return end

        local destination = presetByName[choice]
        if not destination then
            local part = dynamicDestinations[choice]

            if part and part:IsDescendantOf(workspace) and exit(part) then
                destination = part.Position + Vector3.new(0, 4, 0)
            end
        end

        teleportSelectionReset = true
        teleportDropdown:Set({""})
        teleportSelectionReset = false

        if destination then
            tweenToDestination(destination)
        else
            notif("Destination no longer exists.", "Teleport")
            queueTeleportRefresh()
        end
    end
})
refreshTeleportOptions()

mainTab:CreateToggle({
	Name = "Reset After Pressing Buttons Below",
	CurrentValue = true,
	Callback = function(Value)
		resetafter = Value
	end
})
mainTab:CreateButton({
    Name = "Contain SCP-106 Old Man",
    Callback = function()
        local hcz = workspace:FindFirstChild("Heavy Containment Zone")
        local cell = hcz and safeFind(hcz, {
            "106",
            "Room",
            "Collidables",
            "106_Cell"
        })
        local buttoncf
        local touchcf
        local inter

        if cell then
            local recontainmentbutton = cell:FindFirstChild("RecontainmentButton")
            local touch = cell:FindFirstChild("Touch")

            if not recontainmentbutton or not touch then
                notif("Cannot find 106 cell child Recontainment Button or Touch. (Map is loading?)", "Containment Failed")
                return
            end

            buttoncf = recontainmentbutton.Button.CFrame
            touchcf = touch.CFrame
            inter = recontainmentbutton.Interaction
        else
            notif("Cannot find 106 room. (Map is loading?)", "Containment Failed")
            return
        end

        local char = getChar(localplr)
        local root = getRoot(char)
        local cur = root.CFrame

        if root then
            TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = touchcf}):Play()
            task.wait(3)
            char = getChar(localplr)
            root = getRoot(char)
            TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = buttoncf}):Play()
            task.wait(1.65)
            inter:FireServer()
            task.wait(.25)
            if resetafter then
                reset()
            else
                TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = cur}):Play()
            end
        else
            if isDead(localplr) then
                notif("You're dead.", "Containment Failed")
            else
                notif("Your root is gone?", "Containment Failed")
            end
        end
    end
})
local nuke = mainTab:CreateButton({
    Name = "Toggle Nuke",
    Callback = function()
        local char = getChar(localplr)
        local root = getRoot(char)
        local cur = root.CFrame
        local pos = CFrame.new(21, 955, -142)
        local leverinteract = safeFind(workspace, {
            "Heavy Containment Zone",
            "WarheadNonModular",
            "Room",
            "Collidables",
            "SCPSLPanel",
            "LeverInteractables",
            "Interaction"
        })
        if not leverinteract then
            notif("Could not find nuke lever. (Map is loading?)")
            return
        end

        TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = pos}):Play()
        task.wait(1.65)
        leverinteract:FireServer()
        task.wait(.25)
        if resetafter then
            reset()
        else
            TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = cur}):Play()
        end
    end
})

mainTab:CreateButton({
    Name = "Cancel Nuke",
    Callback = function()
        local char = getChar(localplr)
        local root = getRoot(char)
        local pos = CFrame.new(21, 955, -142)
        local cur = root.CFrame
        local buttoninteract = safeFind(workspace, {
            "Heavy Containment Zone",
            "WarheadNonModular",
            "Room",
            "Collidables",
            "SCPSLPanel",
            "ButtonInteractable",
            "Interaction"
        })
        local leverinteract = buttoninteract and safeFind(buttoninteract.Parent.Parent, {
            "LeverInteractables",
            "Interaction"
        })
        if not buttoninteract or not leverinteract then
            notif("Could not find nuke lever or button. (Map is loading?)")
        end

        TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = pos}):Play()
        task.wait(1.65)
        buttoninteract:FireServer()
        leverinteract:FireServer()
        task.wait(.25)
        if resetafter then
            reset()
        else
            TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = cur}):Play()
        end
    end
})
mainTab:CreateButton({
    Name = "Activate Nuke",
    Callback = function()
        local char = getChar(localplr)
        local root = getRoot(char)
        local cur = root.CFrame
        local pos = CFrame.new(-82, -1527, 99)

        local cover = safeFind(workspace, {
            "Surface",
            "Surface",
            "GateA",
            "Warhead Control Room",
            "Collidables",
            "WarheadStand",
            "CoverInteractables",
            "Interaction"
        })
        local button = cover and safeFind(cover.Parent.Parent, {
            "ButtonInteractable",
            "Interaction"
        })
        if not cover or not button then
            notif("Could not find surface nuke button or its cover. (Map is loading?)")
            return
        end

        TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = pos}):Play()
        task.wait(1.65)
        cover:FireServer()
        task.wait(.1)
        button:FireServer()
        task.wait(.25)
        if resetafter then
            reset()
        else
            TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = cur}):Play()
        end
    end
})

bindsTab:CreateKeybind({
    Name = "Toggle Aimbot",
    CurrentKeybind = "P",
    HoldToInteract = false,
    Callback = function(Keybind)
        local options = {}
        if not silentaimbot then
            table.insert(options, "Toggle")
        end
        if filtercds then
            table.insert(options, "Filter Class D/Scientist")
        end
        if filterteam then
            table.insert(options, "Filter Team")
        end
        if circl.Visible then
            table.insert(options, "Circle")
        end

        toggleaimbot:Set(options)
    end
})

bindsTab:CreateKeybind({
    Name = "Toggle ESP",
    CurrentKeybind = "O",
    HoldToInteract = false,
    Callback = function(Keybind)
        local options = {}
        if not plresp then
            table.insert(options, "Toggle")
        end
        if esp_boxes then
            table.insert(options, "Boxes")
        end
        if esp_names then
            table.insert(options, "Names")
        end
        if esp_tracers then
            table.insert(options, "Tracers")
        end
        if esp_hl then
            table.insert(options, "Highlight")
        end
        if esp_skeleton then
            table.insert(options, "Skeleton")
        end
        if esp_distance then
            table.insert(options, "Distance")
        end
        if esp_health then
            table.insert(options, "Health")
        end

        espd:Set(options)
    end
})

bindsTab:CreateKeybind({
    Name = "Quick Heal (Need medkit in inventory)",
    CurrentKeybind = "H",
    HoldToInteract = false,
    Callback = function(Keybind)
        local char = getChar(localplr)
		local backpack = localplr.Backpack
		local medkit = backpack:FindFirstChild("Medkit")
        local medkitinteraction = medkit and safeFind(medkit, {
            "MedkitServer",
            "Pressing"
        })
		if medkit and medkitinteraction then
			medkit.Parent = char
			medkitinteraction:FireServer(true)
			notif("Healing! Unequip any non-medkit items!")
		else
			notif("No medkit in inventory or medkit is broken. (Or you're already holding one!)")
		end
    end
})

bindsTab:CreateKeybind({
    Name = "Quick Ball Throw (Need normal SCP-018 in inventory)",
    CurrentKeybind = "B",
    HoldToInteract = false,
    Callback = function(Keybind)
        local char = getChar(localplr)
		local hrp = getRoot(char)
		local backpack = localplr.Backpack

		local ball = backpack:FindFirstChild("SCP-018")
        local interaction = ball and safeFind(ball, {
            "SCP018Interaction"
        })
		if ball and interaction then
			ball.Parent = char
			interaction:FireServer("Throw", hrp.CFrame * cframe, Camera.CFrame.LookVector)
			notif("Throwing ball!")
		else
			notif("No ball in inventory or ball is broken. (Or you're already holding one!)")
		end
    end
})

mainTab:CreateSection("Nuke Info")
local disabledlabel = mainTab:CreateLabel("NO NUKE INFO")
if disabled == nil then
    disabledlabel:Set("NO NUKE INFO")
else
    disabledlabel:Set("Nuke: "..disabled.Text)
end
local timelabel = mainTab:CreateLabel("NO NUKE INFO")
if timeframes == nil then
    timelabel:Set("NO NUKE INFO")
else
    timelabel:Set(minone.Text..mintwo.Text..":"..secone.Text..sectwo.Text..":"..milone.Text..miltwo.Text)
end
mainTab:CreateButton({
    Name = "Get Nuke Information (for above)",
    Callback = function()
        if getNukeVars() == true then
            notif("Got Nuke Info.")
            disabledlabel:Set("Nuke: "..disabled.Text)
            timelabel:Set(minone.Text..mintwo.Text..":"..secone.Text..sectwo.Text..":"..milone.Text..miltwo.Text)

            local nuketext
            local dc = disabled:GetPropertyChangedSignal("Text"):Connect(function()
                nuketext = "Nuke: "..disabled.Text
                disabledlabel:Set(nuketext)
            end)
            table.insert(nukeconnections, dc)
            local ic = inevitable:GetPropertyChangedSignal("Visible"):Connect(function()
                if inevitable.Visible == true then
                    disabledlabel:Set("Nuke: "..inevitable.Inevitable.Text)
                else
                    disabledlabel:Set(nuketext)
                end
            end)
            table.insert(nukeconnections, ic)
            local mc = miltwo:GetPropertyChangedSignal("Text"):Connect(function()
                timelabel:Set(minone.Text..mintwo.Text..":"..secone.Text..sectwo.Text..":"..milone.Text..miltwo.Text)
            end)
            table.insert(nukeconnections, mc)
        else
            notif("Cannot Get Nuke Info. (Map is loading?)")
        end
    end
})


plrTab:CreateSlider({
    Name = "Walk Speed",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value)
        local char = getChar(localplr)
        local humanoid = getHuman(char)

        if char and humanoid then
            humanoid.WalkSpeed = Value
        end
    end
})

plrTab:CreateSlider({
    Name = "Jump Height",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 3,
    Callback = function(Value)
        local char = getChar(localplr)
        local humanoid = getHuman(char)

        if char and humanoid then
            humanoid.JumpHeight = Value
        end
    end
})

-----------------------------------------------

settingsTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

local re = settingsTab:CreateButton({
	Name = "Reset",
	Callback = function()
		reset()
	end
})

settingsTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        notif("Rejoining...")
        if #Players:GetPlayers() <= 1 then
		    Players.LocalPlayer:Kick("\nRejoining...")
		    task.wait()
		    TeleportService:Teleport(PlaceId, Players.LocalPlayer)
	    else
		    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
	    end
    end
})

local function destroyrayfield()
    print("Destroying...")
    notif("Destroying...")

    if runLoop == true then
        RunService:UnbindFromRenderStep("Aimbot")
        print("aimbot unbinded")

        RunService:UnbindFromRenderStep("ESP")
        print("esp unbinded")

        RunService:UnbindFromRenderStep("Reticle")
        print("reticle unbinded")
    end

    scriptDestroying = true
    if activeTeleportTween then
        activeTeleportTween:Cancel()
        activeTeleportTween = nil
    end
    teleportBusy = false
    clearDebugParts()
    for part, marker in pairs(roomMarkers) do
        if marker.Box then marker.Box:Destroy() end
        if marker.Label then marker.Label:Destroy() end
        roomMarkers[part] = nil
        roomParts[part] = nil
    end
    table.clear(dynamicDestinations)
    table.clear(specialRoomModels)

    getclosestheadloopactive = false
    print("getclosestheadloopactive while loop set to false")

    clearLocalCharConnections()
    print("cleared local char connections")

    local nc = 0
    for i, connection in ipairs(endconnections) do
        if connection then
            connection:Disconnect()
            endconnections[i] = nil
            nc += 1
        end
    end
    print(nc, "connections disconnected")

    local nnc = 0
    for i, connection in ipairs(nukeconnections) do
        connection:Disconnect()
        nukeconnections[i] = nil
        nnc += 1
    end
    print(nnc, "nuke connections disconnected")

    itemEsp:Set(false)
    print("item esp off")

    reticletoggle:Set(false)
    if reticle then
        reticle:Destroy()
    end
    print("reticle fully off")

    findRooms:Set(false)
    print("find rooms off")

    noFlash:Set(false)
    print("no flash off")

    noShyGuy:Set(false)
    fullbright:Set(false)
    print("no shy guy off")
    
    toggleaimbot:Set({})
    if circl then
        circl:Destroy()
    end
    print("aimbot fully off")

    espd:Set({})

    for player in pairs(trackedPlayers) do
        untrackPlayer(player)
    end

    local n = 0
    for i, drawings in pairs(espDrawings) do
        if drawings then
            if drawings.Skeleton and drawings.Skeleton.Lines then
                local lines = drawings.Skeleton.Lines
                for i, line in ipairs(lines) do
                    pcall(function()
                        line:Destroy()
                        line = nil
                        lines[i] = nil
                        n += 1
                    end)
                end
            end

            for i, d in pairs(drawings) do
                pcall(function()
                    d:Destroy()
                    d = nil
                    drawings[i] = nil
                    n += 1
                end)
            end

            espDrawings[i] = nil
        end
    end
    print("destroyed", n, "drawings")
    print("esp fully off")

    fastoldman = false
    print("faster old man off")

    visd:Set(false)
    print("debug view off")

    R15Bones = nil
    R6Bones = nil
    trackedPlayers = {}
    print("cleaned tables")

    print("rayfield destroying...")
    task.wait(1)
    Rayfield:Destroy()
end

settingsTab:CreateButton({
    Name = "Destroy GUI/Panic",
    Callback = function()
		destroyrayfield()
    end
})

settingsTab:CreateButton({
	Name = "Reload Script",
	Callback = function()
		print("Reloading...")
		destroyrayfield()
		print("rayfield destroyed, loading script...")
		task.wait(.5)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/alizeja/scp-demo-gui-script/refs/heads/main/main.lua"))()
	end	
})



---------LOOOP and END CONNECTIONS!!!!

table.insert(endconnections, credits:GetPropertyChangedSignal("Text"):Connect(function()
    creditslabel:Set(credits.Text)
end))
table.insert(endconnections, queuegui:GetPropertyChangedSignal("Text"):Connect(function()
    if queuegui.Text == nil or queuegui.Text == "" then
        queuelabel:Set("Queued: None")
    else
        queuelabel:Set(queuegui.Text)
    end
end))
table.insert(endconnections, chaosgui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    updatelabel(chaosgui, chaoslabel, "Chaos Insurgency", false)
end))
table.insert(endconnections, mtfgui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    updatelabel(mtfgui, mtflabel, "Mobile Task Force", false)
end))
table.insert(endconnections, shyguygui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    updatelabel(shyguygui, shyguylabel, "SCP-096 Shy Guy", true)
end))
table.insert(endconnections, oldmangui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    updatelabel(oldmangui, oldmanlabel, "SCP-106 Old Man", true)
end))
table.insert(endconnections, docgui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    updatelabel(docgui, doclabel, "SCP-049 Plague Doctor", true)
end))
table.insert(endconnections, doggui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    updatelabel(doggui, doglabel, "SCP-939-53 With Many Voices", true)
end))
table.insert(endconnections, dogagaingui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    updatelabel(dogagaingui, dogagainlabel, "SCP-939-89 With Many Voices", true)
end))
table.insert(endconnections, peanutgui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    updatelabel(peanutgui, peanutlabel, "SCP-173 The Sculpture", true)
end))
table.insert(endconnections, gameStatus:GetAttributeChangedSignal("SpawnWaveTime"):Connect(function()
    swlabel:Set("End-game Spawn Wave Timer: "..gameStatus:GetAttribute("SpawnWaveTime"))
end))


-- Input-driven aim assist: custom camera controllers own Camera.CFrame.
-- Move the mouse instead of fighting the camera controller every frame.
local currentTarget = nil
local aimResponse = 13
local aimMaxPixelsPerSecond = 1800
local aimDeadzonePixels = 2
local aimMouseRemainder = Vector2.zero
local aimMouseMover = mousemoverel

task.spawn(function()
    while getclosestheadloopactive do
        if silentaimbot then
            currentTarget = GetClosestHead(currentTarget)
        else
            currentTarget = nil
        end

        task.wait(0.03)
    end
end)

RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Last.Value - 1, function(dt)
    Camera = workspace.CurrentCamera or Camera
    circl.Position = Camera.ViewportSize * 0.5

    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        currentTarget = nil
        aimMouseRemainder = Vector2.zero
        return
    end
    
    if not silentaimbot or not currentTarget or not currentTarget.Parent then
        aimMouseRemainder = Vector2.zero
        return
    end

    local targetPos = currentTarget.Position
    local projected, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen or projected.Z <= 0 then return end

    -- Read where the custom camera is actually pointing; no competing CFrame.
    local center = Camera.ViewportSize * 0.5
    local errorPixels = Vector2.new(projected.X, projected.Y) - center
    local distance = errorPixels.Magnitude
    if distance <= aimDeadzonePixels then
        aimMouseRemainder = Vector2.zero
        return
    end

    local deltaTime = math.clamp(dt, 0, 0.03)
    local alpha = 1 - math.exp(-aimResponse * deltaTime)
    local move = errorPixels * alpha
    local maxStep = aimMaxPixelsPerSecond * deltaTime
    if move.Magnitude > maxStep then move = move.Unit * maxStep end

    -- Keep subpixel precision when the executor accepts integer mouse deltas.
    move += aimMouseRemainder
    local dx = math.round(move.X)
    local dy = math.round(move.Y)
    aimMouseRemainder = move - Vector2.new(dx, dy)
    if dx ~= 0 or dy ~= 0 then
        aimMouseMover(dx, dy)
    end
end)

local lastUpdate = 0
local RATE = 1/20
local dSuffix = "Distance: "
local dRATE = 1/10
local hSuffix = "Health: "
local hRATE = 1/45

RunService:BindToRenderStep("ESP", Enum.RenderPriority.Camera.Value + 2, function()
    local now = tick()
    if now - lastUpdate < RATE then return end
    lastUpdate = now

    if not plresp then
        for _, drawings in pairs(espDrawings) do
            drawings.Line.Visible = false
            drawings.Name.Visible = false
            drawings.Box.Visible = false
            drawings.Highlight.Enabled = false
            drawings.Distance.Visible = false
            drawings.Health.Visible = false
            hideSkeleton(drawings)
        end
        return
    end

    local cam = Camera or workspace.CurrentCamera
    local camCF = cam.CFrame
    local camPos = camCF.Position
    local viewport = cam.ViewportSize
    local screenBottom = Vector2.new(viewport.X / 2, viewport.Y)
    local screenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local screenTop = Vector2.new(viewport.X / 2, 0)

    for player, data in pairs(trackedPlayers) do
        if player == localplr then continue end

        local char = data.Character
        local root = data.Root
        local rigType = data.RigType
        local h = data.Humanoid
        local drawings = espDrawings[player]
        local dist: number = root and math.floor((camPos - root.Position).Magnitude * 10 + .5) / 10

        if not drawings or not char or not root or isDead(player) or (dist and dist > 750) then
            if drawings then
                drawings.Line.Visible = false
                drawings.Name.Visible = false
                drawings.Box.Visible = false
                drawings.Highlight.Enabled = false
                drawings.Distance.Visible = false
                drawings.Health.Visible = false
                hideSkeleton(drawings)
            end
            continue
        end

        local teamColor = player.Team and player.Team.TeamColor.Color or Color3.new(1,1,1)
        local bones = rigType == "R6" and R6Bones or R15Bones

        local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)
        local screenPos

        if onScreen and rootPos.Z > 0 then
            screenPos = Vector2.new(rootPos.X, rootPos.Y)
        else
            screenPos = getScreenEdgePoint(root.Position, cam)
        end

        if not onScreen then
            drawings.Name.Visible = false
            drawings.Box.Visible = false
            drawings.Highlight.Enabled = false
            drawings.Distance.Visible = false
            drawings.Health.Visible = false
            hideSkeleton(drawings)
        end


        if esp_boxes and onScreen then
            local cf, size = getBoundingBox(char)

            local corners = {
                Vector3.new(-1, -1, -1),
                Vector3.new(-1, -1,  1),
                Vector3.new(-1,  1, -1),
                Vector3.new(-1,  1,  1),
                Vector3.new( 1, -1, -1),
                Vector3.new( 1, -1,  1),
                Vector3.new( 1,  1, -1),
                Vector3.new( 1,  1,  1),
            }

            local minX, minY = math.huge, math.huge
            local maxX, maxY = -math.huge, -math.huge
            local anyOnScreen = false

            for _, corner in ipairs(corners) do
                local worldPoint = cf:PointToWorldSpace(corner * size * .5)
                local screenPoint, onScreen = cam:WorldToViewportPoint(worldPoint)

                if onScreen then
                    anyOnScreen = true
                end

                minX = math.min(minX, screenPoint.X)
                minY = math.min(minY, screenPoint.Y)
                maxX = math.max(maxX, screenPoint.X)
                maxY = math.max(maxY, screenPoint.Y)
            end

            if anyOnScreen then
                drawings.Box.Position = Vector2.new(minX, minY)
                drawings.Box.Size = Vector2.new(maxX - minX, maxY - minY)
                drawings.Box.Color = teamColor
                drawings.Box.Visible = true
            else
                drawings.Box.Visible = false
            end
        else
            drawings.Box.Visible = false
        end

        if esp_names then
            drawings.Name.Text = player.Name
            drawings.Name.Position = screenPos - Vector2.new(0, 50)
            drawings.Name.Color = teamColor
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end

        if esp_tracers then
            if tracerOption == "From Bottom" then
               drawings.Line.From = screenBottom
            elseif tracerOption == "From Center" then
                drawings.Line.From = screenCenter
            elseif tracerOption == "From Top" then
                drawings.Line.From = screenTop
            elseif tracerOption == "From Mouse" then 
                drawings.Line.From = reticle.Position
            elseif tracerOption == "From Character" then
                local localChar = localplr.Character
                local r = localChar and (localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChild("Head"))
                if r then
                    local rp, v = Camera:WorldToViewportPoint(r.Position)

                    if v then
                        drawings.Line.From = Vector2.new(rp.X, rp.Y)
                    else
                        local x = math.clamp(rp.X, 0, viewport.X)
                        local y = math.clamp(rp.Y, 0, viewport.Y)
                        drawings.Line.From = Vector2.new(x, y)
                    end
                end
            else
                drawings.Line.From = screenBottom
            end
            drawings.Line.To = screenPos
            drawings.Line.Color = teamColor
            drawings.Line.Visible = true
        else
            drawings.Line.Visible = false
        end

        if esp_hl and onScreen then
            if not drawings.Highlight.Adornee then
                drawings.Highlight.Adornee = char
            end
            
            drawings.Highlight.FillColor = teamColor

            if dist > 350 or dist < 15 then
                drawings.Highlight.Enabled = false
            else
                drawings.Highlight.Enabled = true
            end
        else
            if drawings.Highlight.Adornee then
                drawings.Highlight.Adornee = nil
            end
            drawings.Highlight.Enabled = false
        end
        
        if esp_skeleton and drawings.Skeleton and drawings.Skeleton.Lines and onScreen then
            if dist <= 350 and dist > 10 then
                local bones = drawings.Skeleton.Bones
                local lines = drawings.Skeleton.Lines

                for i, bone in ipairs(bones) do
                    local part0 = char:FindFirstChild(bone[1])
                    local part1 = char:FindFirstChild(bone[2])

                    local line = lines[i]
                    if part0 and part1 and line then
                        local p0, on0 = cam:WorldToViewportPoint(part0.Position)
                        local p1, on1 = cam:WorldToViewportPoint(part1.Position)

                       if on0 and on1 then
                            line.From = Vector2.new(p0.X, p0.Y)
                            line.To = Vector2.new(p1.X, p1.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    elseif line then
                        line.Visible = false
                    end
                end
            else
                hideSkeleton(drawings)
            end
        else
           hideSkeleton(drawings)
        end

        if esp_distance then
            local now = tick()
            if now - drawings._lastDistUpdate > dRATE then
                drawings._lastDistUpdate = now
                
                local newDist = math.floor((camPos - root.Position).Magnitude * 10 + .5) / 10

                if not drawings._lastDist or math.abs(drawings._lastDist - newDist) >= .1 then
                    drawings._lastDist = newDist
                    drawings.Distance.Text = dSuffix..newDist
                end
            end

            drawings.Distance.Position = screenPos - Vector2.new(0, 40)
            drawings.Distance.Color = teamColor
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
        end

        if esp_health and onScreen then
            local now = tick()
            if now - drawings._lastHpUpdate > hRATE then
                drawings._lastHpUpdate = now

                local withShieldText = nil
                local curHp = h and h:GetAttribute("Health") or 0
                local newHp = curHp and math.floor(curHp * 10 + .5) / 10
                local curShield = h and h:GetAttribute("Shield")
                local newShield = curShield and math.floor(curShield * 10 + .5) / 10

                if newShield and newShield > 0 then
                    withShieldText = hSuffix..newHp.." + "..newShield
                end

                if not drawings._lastHp or math.abs(drawings._lastHp - newHp) >= .1 or drawings._lastShield ~= newShield then
                    drawings._lastHp = newHp
                    drawings._lastShield = newShield

                    drawings.Health.Text = withShieldText or hSuffix..newHp
                end
            end

            drawings.Health.Position = screenPos - Vector2.new(0, 30)
            drawings.Health.Color = teamColor
            drawings.Health.Visible = true
        else
            drawings.Health.Visible = false
        end
    end
end)

RunService:BindToRenderStep("Reticle", Enum.RenderPriority.Last.Value, function()
    if fullbrightEnabled then applyFullbright() end
    local mpos = UserInputService:GetMouseLocation()

    reticle.Position = Vector2.new(mpos.X, mpos.Y)
end)

runLoop = true
