-- ตรวจสอบ PlaceId
local allowedPlaceId = 13076380114
if game.PlaceId ~= allowedPlaceId then
    game.Players.LocalPlayer:Kick("script Heroes Battlegrounds")
    return
end

-- โหลด Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Luby Hub By zazq_io",
	Icon = "package",
	LoadingTitle = "Load...you",
	LoadingSubtitle = "wait",
	ShowText = "เปิดเมนู",
	Theme = "Default",
	ToggleUIKeybind = "K",
})

-- Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =================== AUTO FARM PLAYER ===================
local AutoFarm = false
local AttackDistance = 3 -- ระยะติดหลังผู้เล่น

local AutoFarmTab = Window:CreateTab("Auto Farm", "swords")

AutoFarmTab:CreateToggle({
    Name = "Auto Farm Player",
    CurrentValue = false,
    Flag = "AutoFarmNearest",
    Callback = function(Value) AutoFarm = Value end,
})

AutoFarmTab:CreateSlider({
    Name = "Attack Distance",
    Range = {1, 15},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = AttackDistance,
    Flag = "AttackDistanceSlider",
    Callback = function(Value) AttackDistance = Value end,
})

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHRP = player.Character.HumanoidRootPart
            if myHRP then
                local distance = (myHRP.Position - targetHRP.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer, shortestDistance
end


RunService.Heartbeat:Connect(function()
    if AutoFarm then
        local target, dist = getClosestPlayer()
        if target and dist < 50 then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if myHRP and targetHRP then
                local backOffset = -targetHRP.CFrame.LookVector * AttackDistance
                local newPosition = Vector3.new(
                    targetHRP.Position.X + backOffset.X,
                    myHRP.Position.Y,
                    targetHRP.Position.Z + backOffset.Z
                )
                myHRP.CFrame = CFrame.new(newPosition, targetHRP.Position)
            end
        end
    end
end)

-- =================== AUTO FARM MONSTER ===================
local AutoFarmMonster = false
local MonsterDistance = 3

AutoFarmTab:CreateToggle({
    Name = "Auto Farm Monster (Nomu)",
    CurrentValue = false,
    Flag = "AutoFarmMonster",
    Callback = function(Value) AutoFarmMonster = Value end,
})

AutoFarmTab:CreateSlider({
    Name = "Monster Distance",
    Range = {1, 15},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = MonsterDistance,
    Flag = "MonsterDistanceSlider",
    Callback = function(Value) MonsterDistance = Value end,
})

RunService.Heartbeat:Connect(function()
    if AutoFarmMonster then
        local monster = workspace:FindFirstChild("Live") and workspace.Live:FindFirstChild("Nomu")
        if monster and monster:FindFirstChild("HumanoidRootPart") and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local monsterHRP = monster.HumanoidRootPart
            if myHRP and monsterHRP then
                local backOffset = -monsterHRP.CFrame.LookVector * MonsterDistance
                local newPosition = Vector3.new(
                    monsterHRP.Position.X + backOffset.X,
                    myHRP.Position.Y,
                    monsterHRP.Position.Z + backOffset.Z
                )
                myHRP.CFrame = CFrame.new(newPosition, monsterHRP.Position)
            end
        end
    end
end)

-- =================== AUTO SKILL REMOTE ===================
-- =================== AUTO SKILL แบบครบทุกสกิล ===================
local AutoSkill = false
local SkillDelay = 0.2

-- Toggle / Slider
AutoFarmTab:CreateToggle({
    Name = "Auto Skill (All Tools)",
    CurrentValue = false,
    Flag = "AutoSkillAll",
    Callback = function(Value) AutoSkill = Value end,
})

AutoFarmTab:CreateSlider({
    Name = "Skill Delay",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = " sec",
    CurrentValue = SkillDelay,
    Flag = "SkillDelayAll",
    Callback = function(Value) SkillDelay = Value end,
})

spawn(function()
    -- รอ Character + Backpack + RemoteEvent โหลด
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local mainRemote = char:WaitForChild("Main"):WaitForChild("RemoteEvent")
    local backpack = LocalPlayer:WaitForChild("Backpack")

    -- รายชื่อสกิลทั้งหมดของตัวละคร
    local skillNames = {
        "Thousand Slashes",
        "Triple Dagger Throw",
        "Blackout Clutch",
        "Curdle Pierce"
    }

    while true do
        if AutoSkill then
            -- เลือกเป้าหมาย
            local target = nil
            local closestDist = math.huge

            -- หาผู้เล่นใกล้ที่สุด
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local myHRP = char:FindFirstChild("HumanoidRootPart")
                    local targetHRP = player.Character.HumanoidRootPart
                    if myHRP then
                        local dist = (myHRP.Position - targetHRP.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            target = player.Character
                        end
                    end
                end
            end

            -- ถ้าไม่มีผู้เล่น เลือก Nomu (มอนสเตอร์)
            if not target then
                local nomu = workspace:FindFirstChild("Live") and workspace.Live:FindFirstChild("Nomu")
                if nomu and nomu:FindFirstChild("Humanoid") and nomu.Humanoid.Health > 0 then
                    target = nomu
                end
            end

            -- ยิงทุกสกิล
            if target then
                for _, skillName in pairs(skillNames) do
                    local tool = backpack:FindFirstChild(skillName)
                    if tool then
                        mainRemote:FireServer("UsingMoveCustom", tool)
                        task.wait(SkillDelay)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
