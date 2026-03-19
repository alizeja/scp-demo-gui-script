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
local teamTab = Window:CreateTab("Team")
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
PlaceId, JobId = game.PlaceId, game.JobId

local Camera = workspace.CurrentCamera

local localplr = Players.LocalPlayer
local cframe = CFrame.new(1.53290033, 1.97216606, -0.825374484, 0.982948065, -0.171378091, -0.0666531026, 0.0773534179, 0.714215279, -0.695638537, 0.166821882, 0.678620696, 0.715293169)
local falldmg = ReplicatedStorage.PVP:FindFirstChild("FallDamage")
local flashfx = localplr.PlayerGui.FlashFx

local iesp = false
local noshyguy = false
local fastoldman = false
local silentaimbot = false

local espelem = {}
local exitelem = {}

local runLoop
local endconnections = {}

---------------------FUNCS AND CONNECTIONS

function notif(text, title, dur)
    Rayfield:Notify({
        Title = title or "Notification",
        Content = text or "there should be text here",
        Duration = dur or 5
    })
end

local function sameTeam(plr)
    local localteam = localplr.Team
	local plrteam = plr.Team

	if plrteam == localteam then
		return true
	end
	if localteam.Name == "Class D" or localteam.Name == "Chaos Insurgency" then
		if plrteam.Name == "Class D" or plrteam.Name == "Chaos Insurgency" then
			return true
		else
			return false
		end
	end
	if localteam.Name == "Scientist" or localteam.Name == "Mobile Task Force" then
		if plrteam.Name == "Scientist" or plrteam.Name == "Mobile Task Force" then
			return true
		else
			return false
		end
	end
end

local function isDead(plr)
	local plrchar = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = plrchar:FindFirstChildWhichIsA("Humanoid")

	if plrchar and humanoid then
		return humanoid:GetState() == Enum.HumanoidStateType.Dead
	end
end

local function reset()
    local char = localplr.Character or localplr.CharacterAdded:Wait()
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    elseif char then
        char:BreakJoints()
    else
        notif("idk wtf happened but you cant reset")
    end
end

local function makefast(char)
	if fastoldman ~= true and localplr.Team.Name ~= "SCP" then return end
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if humanoid.WalkSpeed == 2.75 or humanoid.WalkSpeed == 16.5 then return end
			if humanoid.WalkSpeed <= 1.5 then
				humanoid.WalkSpeed = 2.75
			elseif humanoid.WalkSpeed <= 15 then
				humanoid.WalkSpeed = 16.5
			end
		end)
	end
end

localplr.CharacterAdded:Connect(makefast)

local function find(child)
	if child:IsA("Tool") then
		if not child:FindFirstChild("Handle") then return end
		local handle = child.Handle
		if handle:FindFirstChild("BoxHandleAdornment") then
			handle.BoxHandleAdornment:Destroy()
		end
		local ttype = child:GetAttribute("ToolType")

		local b = Instance.new("BoxHandleAdornment")
		b.Size = handle.Size
		b.Parent = handle
		b.Adornee = handle
		b.AlwaysOnTop = true
		b.ZIndex = 10
		b.Transparency = 0.5
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
	end
end

local function exit(child)
	return (child:IsA("BasePart") and (child.Name == "Front" or child.Name == "HCZ") and (child.Parent.Name == "CheckptA" or child.Parent.Name == "CheckptB" or child.Parent.Name == "914" or child.Parent.Name == "South HCZ-EZ Checkpoint" or child.Parent.Name == "North HCZ-EZ Checkpoint" or child.Parent.Name == "GateA" or child.Parent.Name == "GateB" or child.Parent.Name == "Warhead" or child.Parent.Name == "049"))
end

local circl = Drawing.new("Circle")
circl.Radius = 200
circl.Visible = false
circl.Thickness = 2
circl.Color = Color3.new(0,0,1)

local trackedPlayers = {}

local function trackPlayer(player)
	if player == localplr then return end

	trackedPlayers[player] = {
		Player = player,
		Head = nil,
		Character = nil
	}

	local function onCharacter(char)
		trackedPlayers[player].Character = char
		trackedPlayers[player].Head = char:WaitForChild("Head", 2)
	end

	if player.Character then
		onCharacter(player.Character)
	end

	player.CharacterAdded:Connect(onCharacter)

	player.CharacterRemoving:Connect(function()
		trackedPlayers[player].Character = nil
		trackedPlayers[player].Head = nil
	end)
end

local function untrackPlayer(player)
	trackedPlayers[player] = nil
end

for _, p in ipairs(Players:GetPlayers()) do
	trackPlayer(p)
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(untrackPlayer)

local function GetClosestHead()
	local localChar = localplr.Character
	if not localChar then return nil end

	local localHead = localChar:FindFirstChild("Head")
	if not localHead then return nil end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {localChar}

	local closest = nil
	local dist = circl.Radius

	for player, data in pairs(trackedPlayers) do
        if sameTeam(player) then continue end
		local head = data.Head
		local char = data.Character

		if head and char and not isDead(player) then
			local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if not onScreen then continue end

			local screenPos = Vector2.new(pos.X, pos.Y)
			local mag = (screenPos - circl.Position).Magnitude
			if mag > dist then continue end

			local origin = localHead.Position
			local direction = head.Position - origin

			local result = workspace:Raycast(origin, direction, rayParams)

			local visible = false
			if result then
				local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
				visible = hitChar == char
			else
				visible = true
			end

			if visible then
				dist = mag
				closest = head
			end
		end
	end

	return closest
end

local chaosgui
local mtfgui
local shyguygui
local oldmangui
local docgui
local doggui
local dogagaingui

local buttons = localplr.PlayerGui.MenuGui.MainFrame.Teams.TeamButtons
local playerTeams = buttons.Other
local scpTeams = buttons.SCPs

local queuegui = buttons.Parent.QueuedText

for i, frame in playerTeams:GetChildren() do
    if not frame:IsA("Frame") then continue end
    if frame.Button.Image == "rbxassetid://14263777415" then
        chaosgui = frame
    elseif frame.Button.Image == "rbxassetid://6774779934" then
        mtfgui = frame
    end
end
for i, frame in scpTeams:GetChildren() do
    if not frame:IsA("Frame") then continue end
    if frame.Button.Image == "rbxassetid://14263837581" then
        shyguygui = frame
    elseif frame.Button.Image == "rbxassetid://9606026315" then
        oldmangui = frame
    elseif frame.Button.Image == "rbxassetid://130261444621233" then
        docgui = frame
    elseif frame.Button.Image == "rbxassetid://17660598360" then
        doggui = frame
    elseif frame.Button.Image == "rbxassetid://10563151614" then
        dogagaingui = frame
    end
end


workspace.ChildAdded:Connect(function()
	for i, child in workspace:GetChildren() do
		if iesp then
            find(child)
        end

		if noshyguy and child:IsA("Model") then
			for i, d in child:GetDescendants() do
				if d.Name == "FacePoint" then
					d:Destroy()
					notif("SCP-096 can no longer be angered.", "SCP-096 Detected")
				end
			end
		end
	end
end)

------------------------------------------------------------------

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
            for i, child in espelem do
                child:Destroy()
            end
        end
    end
})

local noFlash = visualTab:CreateToggle({
    Name = "Disable flash effect",
    CurrentValue = false,
    Callback = function(Value)
        if Value == true then
            if localplr.PlayerGui:FindFirstChild("FlashFx") then
                flashfx.Parent = ReplicatedStorage
            end
        else
            flashfx.Parent = localplr.PlayerGui
        end
    end
})

local findRooms = visualTab:CreateToggle({
    Name = "Find checkpoints, elevators, and gates",
    CurrentValue = false,
    Callback = function(Value)
        if Value == true then
            notif("Finding checkpoints, elevators, and gates.")
            task.wait(.2)
            for i, child in workspace:GetDescendants() do
        	    if exit(child) then
        		    local handle = child
            		for i, v in handle:GetChildren() do
                        if v:IsA("BoxHandleAdornment") or v:IsA("BillboardGui") then
                            v:Destroy()
                        end
                   end

            		local b = Instance.new("BoxHandleAdornment")
             		b.Size = handle.Size
             		b.Parent = handle
        	    	b.Adornee = handle
        	    	b.AlwaysOnTop = true
        	    	b.ZIndex = 10
	            	b.Transparency = 0.5
                    table.insert(exitelem, b)

        	    	if handle.Parent.Name == "049" or handle.Parent.Name == "Warhead" or handle.Parent.Name == "914" then
        		    	b.Color3 = Color3.new(255, 255, 0)
        	    	end

                    local ui = Instance.new("BillboardGui")
                    ui.Parent = handle
                    ui.Adornee = handle
                    ui.Size = UDim2.fromScale(10,2.5)
                    ui.AlwaysOnTop = true
                    local textlabel = Instance.new("TextLabel")
                    textlabel.Parent = ui
                    textlabel.BackgroundTransparency = 1
                    textlabel.Size = UDim2.fromScale(1,1)
                    textlabel.TextScaled = true
                    textlabel.RichText = true
                    textlabel.Text = handle.Parent.Name

                    table.insert(exitelem, ui)
	            end
            end

            notif("Found.")

        else
            for i, child in exitelem do
                child:Destroy()
            end
        end
    end
})

local fullbright = visualTab:CreateButton({
    Name = "Fullbright",
    Callback = function()
        Lighting.Brightness = 2
	    Lighting.ClockTime = 14
	    Lighting.FogEnd = 100000
	    Lighting.GlobalShadows = false
	    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
})


local healk = bindsTab:CreateKeybind({
    Name = "Quick Heal (Need medkit in inventory)",
    CurrentKeybind = "H",
    HoldToInteract = false,
    Callback = function(Keybind)
        local char = localplr.Character or localplr.CharacterAdded:Wait()
		local backpack = localplr.Backpack
		local medkit = backpack:FindFirstChild("Medkit")
		if medkit then
			medkit.Parent = char
			medkit.MedkitServer.Pressing:FireServer(true)
			notif("Healing! Unequip any non-medkit items!")
		else
			notif("No medkit in inventory.")
		end
    end
})

local ballk = bindsTab:CreateKeybind({
    Name = "Quick Ball Throw (Need normal SCP-018 in inventory)",
    CurrentKeybind = "B",
    HoldToInteract = false,
    Callback = function(Keybind)
        local char = localplr.Character or localplr.CharacterAdded:Wait()
		local hrp = char.HumanoidRootPart
		local backpack = localplr.Backpack

		local ball = backpack:FindFirstChild("SCP-018")
		if ball then
			ball.Parent = char
			ball.SCP018Interaction:FireServer("Throw", hrp.CFrame * cframe, game.Workspace.CurrentCamera.CFrame.LookVector)
			notif("Throwing ball!")
		else
			notif("No ball in inventory.")
		end
    end
})


local queuedsection = teamTab:CreateSection("Queue")
local queuelabel = teamTab:CreateLabel("Queued: None")
if queuegui.Text == nil or queuegui.Text == " " then
    queuelabel:Set(queuegui.Text)
else
    queuelabel:Set("Queued: None")
end

local playerteamsection = teamTab:CreateSection("Player Teams")
local chaoslabel = teamTab:CreateLabel(
    "Chaos Insurgency: "..tostring(chaosgui.Timer.Text),
    14263777415,
    Color3.new(),
    false
)
local mtflabel = teamTab:CreateLabel(
    "Mobile Task Force: "..tostring(mtfgui.Timer.Text),
    6774779934,
    Color3.new(),
    false
)

local scpssection = teamTab:CreateSection("SCPs")
local shyguylabel = teamTab:CreateLabel(
    "SCP-096 Shy Guy: "..tostring(shyguygui.Timer.Text),
    14263837581,
    Color3.new(),
    false
)
local oldmanlabel = teamTab:CreateLabel(
    "SCP-106 Old Man: "..tostring(oldmangui.Timer.Text),
    9606026315,
    Color3.new(),
    false
)
local doclabel = teamTab:CreateLabel(
    "SCP-049 Plague Doctor: "..tostring(docgui.Timer.Text),
    130261444621233,
    Color3.new(),
    false
)
local doglabel = teamTab:CreateLabel(
    "SCP-939-53 With Many Voices: "..tostring(doggui.Timer.Text),
    17660598360,
    Color3.new(),
    false
)
local dogagainlabel = teamTab:CreateLabel(
    "SCP-939-89 With Many Voices: "..tostring(dogagaingui.Timer.Text),
    10563151614,
    Color3.new(),
    false
)


local toggleaimbot = mainTab:CreateDropdown({
	Name = "Aimbot (Buggy)",
	Options = {"Toggle On/Off", "Circle"},
	CurrentOption = nil,
	MultipleOptions = true,
	Callback = function(Options)
		silentaimbot = (Options[1] == "Toggle On/Off" or Options[2] == "Toggle On/Off")
		circl.Visible = (Options[1] == "Circle" or Options[2] == "Circle")
		print("silent aimbot: "..tostring(silentaimbot)..", circle: "..tostring(circl.Visible))
	end
})

local noShyGuy = mainTab:CreateToggle({
    Name = "Disable SCP-096",
    CurrentValue = false,
    Callback = function(Value)
        noshyguy = Value
        if Value == true then
            for i, d in workspace:GetDescendants() do
				if d.Name == "FacePoint" then
					d:Destroy()
					notif("SCP-096 can no longer be angered.", "SCP-096 Detected")
				end
			end
        end
    end
})

local fasterOldMan = mainTab:CreateToggle({
		Name = "Faster 106 Door Movement",
		CurrentValue = false,
		Callback = function(Value)
			fastoldman = Value
			makefast(localplr.Character)
		end
})

local disablefdmg = mainTab:CreateButton({
    Name = "Disable Fall Damage",
    Callback = function()
        if falldmg then
            falldmg:Destroy()
        else
            notif("Fall Damaged already disabled.")
        end
    end
})

local disableit = mainTab:CreateSection("Disable Fall Damage First!")

local nuke = mainTab:CreateButton({
    Name = "Toggle Nuke (resets you after.)",
    Callback = function()
        local pos = CFrame.new(21, 955, -142)
        local char = localplr.Character or localplr.CharacterAdded:Wait()
        local root = char.HumanoidRootPart or char.Humanoid.RootPart

        TweenService:Create(root, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = pos}):Play()
        task.wait(1.1)
        workspace["Heavy Containment Zone"].WarheadNonModular.Room.Collidables.SCPSLPanel.LeverInteractables.Interaction:FireServer()
        task.wait()
        reset()
    end
})

local cancel = mainTab:CreateButton({
    Name = "Cancel Nuke (resets you after.)",
    Callback = function()
        local pos = CFrame.new(21, 955, -142)
        local char = localplr.Character or localplr.CharacterAdded:Wait()
        local root = char.HumanoidRootPart or char.Humanoid.RootPart

        TweenService:Create(root, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = pos}):Play()
        task.wait(1.1)
        workspace["Heavy Containment Zone"].WarheadNonModular.Room.Collidables.SCPSLPanel.ButtonInteractable.Interaction:FireServer()
        workspace["Heavy Containment Zone"].WarheadNonModular.Room.Collidables.SCPSLPanel.LeverInteractables.Interaction:FireServer()
        task.wait()
        reset()
    end
})

local ws = plrTab:CreateSlider({
    Name = "Walk Speed",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value)
        local char = localplr.Character or localplr.CharacterAdded:Wait()
        local humanoid = char:FindFirstChild("Humanoid")

        if char and humanoid then
            humanoid.WalkSpeed = Value
        end
    end
})

local jp = plrTab:CreateSlider({
    Name = "Jump Height",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 3,
    Callback = function(Value)
        local char = localplr.Character or localplr.CharacterAdded:Wait()
        local humanoid = char:FindFirstChild("Humanoid")

        if char and humanoid then
            humanoid.JumpHeight = Value
        end
    end
})

-----------------------------------------------

local iy = settingsTab:CreateButton({
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

local rj = settingsTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        notif("Rejoining...")
        if #Players:GetPlayers() <= 1 then
		    Players.LocalPlayer:Kick("\nRejoining...")
		    wait()
		    TeleportService:Teleport(PlaceId, Players.LocalPlayer)
	    else
		    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
	    end
    end
})

local function destroyrayfield()
    print("Destroying...")
	notif("Destroying...")
    itemEsp:Set(false)
    findRooms:Set(false)
    noFlash:Set(false)
    noShyGuy:Set(false)
    ws:Set(15)
    jp:Set(3)
    silentaimbot = false
    circl:Destroy()
	if runLoop == true then
        RunService:UnbindFromRenderStep("Aimbot") 
    end
    for i, connection in endconnections do
        connection:Disconnect()
    end
    task.wait(.5)
    Rayfield:Destroy()
end

local destroy = settingsTab:CreateButton({
    Name = "Destroy GUI/Panic",
    Callback = function()
		destroyrayfield()
    end
})

local rescript = settingsTab:CreateButton({
	Name = "Reload Script",
	Callback = function()
		print("Reloading...")
		destroyrayfield()
		task.wait(.5)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/alizeja/scp-demo-gui-script/refs/heads/main/main.lua"))()
	end	
})



---------LOOOP and END CONNECTIONS!!!!


local qgc = queuegui:GetPropertyChangedSignal("Text"):Connect(function()
    if queuegui.Text == nil or queuegui.Text == " " then
        queuelabel:Set(queuegui.Text)
    else
        queuelabel:Set("Queued: None")
    end
end)
table.insert(endconnections, qgc)
local cgc = chaosgui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    chaoslabel:Set("Chaos Insurgency: "..tostring(chaosgui.Timer.Text))
end)
table.insert(endconnections, cgc)
local mtfgc = mtfgui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    mtflabel:Set("Mobile Task Force: "..tostring(mtfgui.Timer.Text))
end)
table.insert(endconnections, mtfgc)
local sggc = shyguygui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    shyguylabel:Set("SCP-096 Shy Guy: "..tostring(shyguygui.Timer.Text))
end)
table.insert(endconnections, sggc)
local omgc = oldmangui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    oldmanlabel:Set("SCP-106 Old Man: "..tostring(oldmangui.Timer.Text))
end)
table.insert(endconnections, omgc)
local pdgc = docgui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    doclabel:Set("SCP-049 Plague Doctor: "..tostring(docgui.Timer.Text))
end)
table.insert(endconnections, pdgc)
local dgc = doggui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    doglabel:Set("SCP-939-53 With Many Voices: "..tostring(doggui.Timer.Text))
end)
table.insert(endconnections, dgc)
local dagc = dogagaingui.Timer:GetPropertyChangedSignal("Text"):Connect(function()
    dogagainlabel:Set("SCP-939-89 With Many Voices: "..tostring(dogagaingui.Timer.Text))
end)
table.insert(endconnections, dagc)

local currentTarget = nil
local dz = 0.004

RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
	circl.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	if not silentaimbot then
		currentTarget = nil
		return
	end

	local newTarget = GetClosestHead()

	if newTarget then
		currentTarget = newTarget
	else
		currentTarget = nil
	end

	if not currentTarget then return end

	local camCF = Camera.CFrame
	local camPos = camCF.Position

    local velocity = currentTarget.AssemblyLinearVelocity
    local predictedPos = currentTarget.Position + velocity * 0.05

	local targetDir = (predictedPos - camPos).Unit
	local currentDir = camCF.LookVector
    local diff = (targetDir - currentDir).Magnitude
    if diff < dz then
	    return
    end
    if diff < 0.05 then
        Camera.CFrame = CFrame.new(camPos, currentTarget.Position)
	    return
    end

	local alpha = math.clamp(dt * 10, 0, 1)
	local newDir = currentDir:Lerp(targetDir, alpha)
    
	Camera.CFrame = CFrame.new(camPos, camPos + newDir)
end)
runLoop = true
