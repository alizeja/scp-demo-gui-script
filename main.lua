---------pleaseee dont look at my code, it's spaghetti


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
local plrTab = Window:CreateTab("Player")
local bindsTab = Window:CreateTab("Shortcuts")
local settingsTab = Window:CreateTab("Debug")

----------------------------------------------------
local Players = game.Players
local TeleportService = game:GetService("TeleportService")
local Lighting = game.Lighting
local TweenService = game:GetService("TweenService")
PlaceId, JobId = game.PlaceId, game.JobId

local plr = Players.LocalPlayer
local cframe = CFrame.new(1.53290033, 1.97216606, -0.825374484, 0.982948065, -0.171378091, -0.0666531026, 0.0773534179, 0.714215279, -0.695638537, 0.166821882, 0.678620696, 0.715293169)
local falldmg = game:GetService("ReplicatedStorage").PVP:FindFirstChild("FallDamage")
local flashfx = plr.PlayerGui.FlashFx

local iesp = false
local noshyguy = false

local espelem = {}
local exitelem = {}

function notif(text, title, dur)
    Rayfield:Notify({
        Title = title or "Notification",
        Content = text or "there should be text here",
        Duration = dur or 5
    })
end

local function reset()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char.Humanoid
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    elseif char then
        char:BreakJoints()
    else
        notif("idk wtf happened but you cant reset")
    end
end

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

local noFlash = visualTab:CreateToggle({
    Name = "Disable flash effect",
    CurrentValue = false,
    Callback = function(Value)
        if Value == true then
            if plr.PlayerGui:FindFirstChild("FlashFx") then
                flashfx.Parent = game.ReplicatedStorage
            end
        else
            flashfx.Parent = plr.PlayerGui
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
        local char = plr.Character or plr.CharacterAdded:Wait()
		local backpack = plr.Backpack
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
        local char = plr.Character or plr.CharacterAdded:Wait()
		local hrp = char.HumanoidRootPart
		local backpack = plr.Backpack
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
        local char = plr.Character or plr.CharacterAdded:Wait()
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
        local char = plr.Character or plr.CharacterAdded:Wait()
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
        local char = plr.Character or plr.CharacterAdded:Wait()
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
        local char = plr.Character or plr.CharacterAdded:Wait()
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

local destroy = settingsTab:CreateButton({
    Name = "Destroy GUI/Panic",
    Callback = function()
        itemEsp:Set(false)
        findRooms:Set(false)
        noFlash:Set(false)
        noShyGuy:Set(false)
        ws:Set(15)
        jp:Set(3)
        task.wait(.5)
        Rayfield:Destroy()
    end
})
