-- ===== จำกัดแมพ =====
local allowedPlaceId = 10449761463
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

if game.PlaceId ~= allowedPlaceId then
    LocalPlayer:Kick("This script can only be run in The strongest battlefield By zazq_io")
    return
end

-- ===== SERVICE =====
local RunService = game:GetService("RunService")

-- ===== CHARACTER SETUP =====
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:FindFirstChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = Character:WaitForChild("HumanoidRootPart")
end)

-- ===== Rayfield UI =====
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
	Name = "Luby Hub By zazq_io",
	Icon = "package",
	LoadingTitle = "Luby Hub",
	LoadingSubtitle = "wait...",
	ShowText = "เปิดเมนู",
	Theme = "Default",
	ToggleUIKeybind = "K",
})

-- ===== CONFIG =====
local attackMode = "LowestHP"
local attackDistance = 5
local attackDelay = 0.3

-- ===== HELPER =====
local function isAlive(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function getLowestHPPlayer()
    local lowest, target = math.huge, nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player.Character) then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health < lowest then
                lowest, target = hum.Health, player
            end
        end
    end
    return target
end

local function getClosestPlayer()
    local closest, target = math.huge, nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player.Character) then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and HRP then
                local dist = (HRP.Position - hrp.Position).Magnitude
                if dist < closest then
                    closest, target = dist, player
                end
            end
        end
    end
    return target
end

local function getTarget()
    if attackMode == "LowestHP" then
        return getLowestHPPlayer()
    elseif attackMode == "Closest" then
        return getClosestPlayer()
    end
end

-- ===== TOGGLE VARIABLES =====
local farming = false
local autoToolEnabled = false
local autoM1Enabled = false
local warpEnabled = false

-- ================== AUTO FARM ==================
local currentTarget
local function autoFarmLoop()
    while farming do
        if Character and HRP then
            if not currentTarget or not isAlive(currentTarget.Character) then
                currentTarget = getTarget()
            end

            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = currentTarget.Character.HumanoidRootPart
                local offset = targetHRP.CFrame.LookVector * -attackDistance
                HRP.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
            end
        end
        task.wait(0.03)
    end
end

local function startAutoFarm()
    if farming then return end
    farming = true
    task.spawn(autoFarmLoop)
end

local function stopAutoFarm()
    farming = false
    currentTarget = nil
end

-- ================== AUTO TOOL ==================
local function autoToolLoop()
    while autoToolEnabled do
        local char = LocalPlayer.Character
        if not char or not isAlive(char) then
            task.wait(0.5)
            continue
        end
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then
            task.wait(0.5)
            continue
        end

        local tools = {}
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool)
            end
        end

        for _, tool in ipairs(tools) do
            if not autoToolEnabled or not isAlive(char) then break end
            tool.Parent = char
            task.wait(0.1)
            pcall(function() tool:Activate() end)
            task.wait(0.3)
            tool.Parent = backpack
            task.wait(0.1)
        end

        task.wait(0.5)
    end
end

-- ================== AUTO M1 ==================
local function doM1()
    local char = LocalPlayer.Character
    if not char or not isAlive(char) then return end
    local communicate = char:FindFirstChild("Communicate") or game.ReplicatedStorage:FindFirstChild("Communicate")
    if communicate then
        pcall(function() communicate:FireServer({Goal="LeftClick"}) end)
    end
end

local function autoM1Loop()
    while autoM1Enabled do
        doM1()
        task.wait(attackDelay)
    end
end

local function startAutoM1()
    if autoM1Enabled then return end
    autoM1Enabled = true
    task.spawn(autoM1Loop)
end

local function stopAutoM1()
    autoM1Enabled = false
end

-- ================== WARP SYSTEM (with Stick) ==================
local cfList = { 
    CFrame.new(121.953453, 439.527344, 407.232025, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(72.2151031, 439.488281, -81.3822479, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(508.766602, 439.464844, -19.1403656, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(58.4590607, 439.449219, -275.26059, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(411.070374, 439.445312, 271.739319, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(-110.537064, 439.523438, 286.194611, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(447.087219, 439.464844, 228.916199, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(299.886475, 439.480469, 321.855194, 0.923881173, -0.000526666758, 0.382679135, 0.00116660062, 0.999998271, -0.00144020026, -0.382677704, 0.00177700771, 0.923880219),
    CFrame.new(126.398453, 439.4375, 182.860962, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(43.2541809, 439.632812, 166.788376, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(507.741455, 439.488281, 171.604034, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new( -214.415909, 439.46875, 131.032166, 0.923881531, 3.36807352e-05, 0.382678568, 3.36807352e-05, 1, -0.000169326799, -0.382678568, 0.000169326799, 0.923881531),
    CFrame.new(173.699249, 439.4375, 158.917801, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(458.145599, 439.457031, 104.157127, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(-215.374466, 439.484375, -70.0110245, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(-8.20291138, 439.453125, 387.563904, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(458.619629, 439.441406, -5.89402151, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(320.668732, 439.492188, 53.4356194, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(2.36297607, 439.542969, 55.0222664, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(127.467255, 439.195312, -103.563225, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(437.67923, 439.453125, -192.728149, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(242.914001, 439.503906, -311.29776, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247),
    CFrame.new(-207.826553, 439.480469, -225.92157, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(436.410461, 439.492188, -104.724602, 0.923881531, 1.54557347e-05, 0.382678658, 0.000523436, 0.999998987, -0.00130409305, -0.3826783, 0.00140513526, 0.923880577),
    CFrame.new(138.616394, 439.488281, -315.248596, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(8.06893921, 439.449219, -261.340546, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
    CFrame.new(-63.5329437, 439.195312, -228.971527, 0.923881531, 0, 0.382678568, 0, 1, 0, -0.382678568, 0, 0.923881531),
}

local delayTime = 1.5

local function doClick()
    local comm = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Communicate")
    if comm then pcall(function() comm:FireServer({{Goal="LeftClick"}}) end) end
end

-- ฟังก์ชันติดกาวไปยัง target (item หรือ player)
local function stickToTarget(hrp, targetPart, maxTime)
    local startTime = tick()
    while tick() - startTime < maxTime and warpEnabled do
        if not targetPart or not targetPart.Parent then break end
        local distance = (hrp.Position - targetPart.Position).Magnitude
        if distance > 2 then
            hrp.CFrame = CFrame.new(targetPart.Position - targetPart.CFrame.LookVector * 2, targetPart.Position)
        end
        doClick()
        task.wait(0.15)
    end
end

-- Warp Loop หลัก
local function startWarpLoop()
    spawn(function()
        while warpEnabled do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(1) continue end

            -- 1️⃣ วาร์ปไปยังจุดสุ่ม
            local cf = cfList[math.random(1,#cfList)]
            hrp.CFrame = cf
            task.wait(delayTime)

            -- 2️⃣ หา item ใกล้และติดกาวเก็บ
            local items = workspace:GetChildren()
            for _, item in pairs(items) do
                if item.Name == "ItemPart" and item:IsA("BasePart") then
                    stickToTarget(hrp, item, 1.5)
                end
            end

            -- 3️⃣ หา player ที่เลือดน้อยสุดและติดกาวโจมตี
            local target = getLowestHPPlayer()
            if target and target.Character then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    stickToTarget(hrp, targetHRP, 1.5)
                end
            end
        end
    end)
end


-- ================== RAYFIELD UI ==================
local Tab = Window:CreateTab("Luby Hub By zazq_io", "swords")

Tab:CreateDropdown({
    Name = "Target Mode",
    Options = {"LowestHP", "Closest"},
    CurrentOption = "LowestHP",
    Callback = function(Option)
        attackMode = Option
    end,
})

Tab:CreateSlider({
    Name = "Attack Distance",
    Range = {2, 15},
    Increment = 1,
    CurrentValue = attackDistance,
    Callback = function(Value)
        attackDistance = Value
    end,
})

Tab:CreateToggle({
    Name = "Auto Farm Player",
    CurrentValue = false,
    Callback = function(Value)
        if Value then startAutoFarm() else stopAutoFarm() end
    end,
})

Tab:CreateToggle({
    Name = "Auto Skill",
    CurrentValue = false,
    Callback = function(Value)
        autoToolEnabled = Value
        if Value then task.spawn(autoToolLoop) end
    end,
})

Tab:CreateToggle({
    Name = "Auto M1",
    CurrentValue = false,
    Callback = function(Value)
        if Value then startAutoM1() else stopAutoM1() end
    end,
})

Tab:CreateToggle({
    Name = "Warp Loop",
    CurrentValue = false,
    Callback = function(Value)
        warpEnabled = Value
        if Value then startWarpLoop() end
    end,
})
