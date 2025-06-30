--[[
    Luby Hub BY Zazq_io
    Description: Script for game automation including Auto Farm, ESP, and Auto Skill.
]]

--================================================================
-- LIBRARY & UI INITIALIZATION
--================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Luby Hub BY Zazq_io", "Midnight")

-- Tabs and Sections
local Tab = Window:NewTab("Auto Kill")
local Section = Tab:NewSection("Auto Kill")
local espSection = Tab:NewSection("ESP")

--================================================================
-- VARIABLE DECLARATIONS
--================================================================
-- Services
local Players = game:GetService("Players")

-- Local Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local backpack = player:WaitForChild("Backpack")

-- Workspace
local liveFolder = workspace:WaitForChild("Live")

-- State Variables
local isAutoFarmActive = false
local isAutoSkillActive = false -- This variable is now locally controlled in the Toggle function
local isEspActive = false
local isAttacking = false
local highlights = {}

--================================================================
-- CORE FUNCTIONS
--================================================================

-- Function to use a specific skill by tool name
local function useSkill(toolName)
    local tool = backpack:FindFirstChild(toolName)
    if tool then
        local args = {{
            Tool = tool,
            Goal = "Console Move",
            ToolName = toolName
        }}
        character:WaitForChild("Communicate"):FireServer(unpack(args))
    end
end

-- Function to perform a normal attack
local function normalAttack()
    local args = {{
        Goal = "LeftClick"
    }}
    character:WaitForChild("Communicate"):FireServer(unpack(args))
end

-- Function to find the closest enemy within a given distance
local function getClosestEnemy(maxDistance)
    local closestEnemy = nil
    local closestDist = maxDistance or 10000

    for _, model in ipairs(liveFolder:GetChildren()) do
        if model ~= character and
           model:FindFirstChild("HumanoidRootPart") and
           model:FindFirstChild("Humanoid") and
           model.Humanoid.Health > 0 and
           model.Name ~= "Weakest Dummy" then

            local dist = (hrp.Position - model.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closestEnemy = model
                closestDist = dist
            end
        end
    end

    return closestEnemy
end

--================================================================
-- FEATURE: AUTO FARM
--================================================================
local function autoFarmLoop()
    isAttacking = true
    local target = nil

    while isAutoFarmActive do
        if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
            target = getClosestEnemy(250)
        end

        if target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 then
            local enemyHRP = target.HumanoidRootPart
            local offsetPosition = enemyHRP.CFrame * CFrame.new(0, 0, 5)
            hrp.CFrame = CFrame.lookAt(offsetPosition.Position, enemyHRP.Position)

            -- Attack Combo
            normalAttack()
            useSkill("Normal Punch")
            useSkill("Consecutive Punches")
            useSkill("Shove")
            useSkill("Uppercut")
        end

        task.wait(0.05)
    end

    isAttacking = false
end

--================================================================
-- FEATURE: ESP (Extrasensory Perception)
--================================================================

-- Function to add a name tag to a character
local function addNameTag(char, plr)
    if char and plr and char:FindFirstChild("Head") and not char:FindFirstChild("NameTag") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NameTag"
        billboard.Size = UDim2.new(0, 100, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Adornee = char.Head
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = plr.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
    end
end

-- Function to create highlight and name tag for a player
local function createHighlightAndNameTag(plr)
    if plr.Character then
        local char = plr.Character

        -- Clean up old instances if they exist
        if highlights[plr] then
            if highlights[plr].Highlight and highlights[plr].Highlight.Parent then
                highlights[plr].Highlight:Destroy()
            end
            if highlights[plr].NameTag and highlights[plr].NameTag.Parent then
                highlights[plr].NameTag:Destroy()
            end
        end

        -- Create new Highlight
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.new(1, 0, 0)
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char

        -- Create new NameTag
        addNameTag(char, plr)

        -- Store references
        highlights[plr] = {
            Highlight = hl,
            NameTag = char:FindFirstChild("NameTag")
        }
    end
end

-- Function to handle player respawning for ESP
local function setupPlayerESP(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1) -- Wait for character to fully load
        if isEspActive then
            createHighlightAndNameTag(plr)
        end
    end)
end

-- Main toggle function for ESP
local function toggleESP(state)
    isEspActive = state
    if isEspActive then
        print("ESP Enabled")

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                createHighlightAndNameTag(plr)
                setupPlayerESP(plr) -- Setup for future spawns
            end
        end

        Players.PlayerAdded:Connect(function(plr)
            if plr ~= player then
                setupPlayerESP(plr)
            end
        end)
    else
        print("ESP Disabled")
        for _, data in pairs(highlights) do
            if data.Highlight and data.Highlight.Parent then
                data.Highlight:Destroy()
            end
            if data.NameTag and data.NameTag.Parent then
                data.NameTag:Destroy()
            end
        end
        highlights = {} -- Clear the table
    end
end


--================================================================
-- UI ELEMENT CREATION
--================================================================


Section:NewToggle("Auto Farm", "ตีศัตรูตัวเดิมจนตายก่อนเปลี่ยนเป้า", function(state)
    isAutoFarmActive = state
    print("Auto Farm is now", state and "On" or "Off")
    if isAutoFarmActive and not isAttacking then
        task.spawn(autoFarmLoop)
    end
end)


Section:NewToggle("Auto Skill All", "ใช้ทุกสกิลใน Backpack อัตโนมัติ", function(state)
	local autoSkillLoop = state
	print("Auto Skill is", state and "On" or "Off")

	task.spawn(function()
		while autoSkillLoop do
			local currentChar = player.Character or player.CharacterAdded:Wait()
			local backpack = player:FindFirstChild("Backpack")
			local communicate = currentChar:FindFirstChild("Communicate")

			if backpack and communicate then
				for _, tool in pairs(backpack:GetChildren()) do
					if tool:IsA("Tool") then
						local args = {{
							Tool = tool,
							Goal = "Console Move",
							ToolName = tool.Name
						}}
						communicate:FireServer(unpack(args))
						task.wait(0.05) 
					end
				end
			end

			task.wait(1)
		end
	end)
end)


espSection:NewToggle("ESP", "แสดงกรอบและชื่อผู้เล่นอื่น", function(state)
    toggleESP(state)
end)
