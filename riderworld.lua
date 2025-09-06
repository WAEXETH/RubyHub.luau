-- ✅ Limit Place
local allowedPlaceId = 9301186334
if game.PlaceId ~= allowedPlaceId then
    game.Players.LocalPlayer:Kick("script rider world")
    return
end

-- ✅ Load Rayfield
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


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local attackDistance = 5
local AutoFarm = false
local AttackDelay = 0.01 -- โจมตีเร็วเหมือน Instant Interact

local mobFolder = workspace:WaitForChild("Lives")
local stickyEnabled = {}
local createdToggles = {}

-- 🔹 ตัวแปรเช็คมอนเตอร์เรียลไทม์
local hasMobs = false
local currentMobs = {}

-- 🔹 ฟังก์ชันอัปเดตมอนเตอร์เรียลไทม์
local function updateMobs()
    currentMobs = {} -- รีเซ็ต
    for _, mob in pairs(mobFolder:GetChildren()) do
        if mob:IsA("Model")
        and mob:FindFirstChild("Humanoid")
        and mob:FindFirstChild("HumanoidRootPart")
        and mob.Humanoid.Health > 0
        and not Players:FindFirstChild(mob.Name) then -- ไม่เอาชื่อผู้เล่น
            table.insert(currentMobs, mob)
        end
    end
    hasMobs = #currentMobs > 0
end

-- เชื่อมกับ Spawn/Remove มอน
mobFolder.ChildAdded:Connect(updateMobs)
mobFolder.ChildRemoved:Connect(updateMobs)

-- 🔹 อัปเดต character และ hrp ทุกครั้งที่เกิดใหม่
player.CharacterAdded:Connect(function(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
end)

-- เรียกครั้งแรกตอนเริ่มเกม
updateMobs()

-- 📝 สร้าง Tab UI
local AutoFarmTab = Window:CreateTab("Auto Farm", "swords")

-- Slider Attack Distance
AutoFarmTab:CreateSlider({
    Name = "Attack Distance",
    Range = {1, 15},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = attackDistance,
    Flag = "AttackDistance",
    Callback = function(value)
        attackDistance = value
    end,
})

-- 🔹 ฟังก์ชันช่วยดึงเลขเลเวลจากชื่อมอน
local function getLevelFromName(name)
    local lv = name:match("Lv%.?%s*(%d+)")
    return tonumber(lv) or 0
end

-- 🔹 ฟังก์ชันสร้าง Toggle สำหรับมอนใหม่ (ไม่ซ้ำ, ไม่เอาชื่อผู้เล่น)
local function createMobToggles()
    local mobGroups = {}

    for _, mob in pairs(mobFolder:GetChildren()) do
        if mob:IsA("Model") 
        and mob:FindFirstChild("Humanoid") 
        and mob:FindFirstChild("HumanoidRootPart") 
        and not Players:FindFirstChild(mob.Name) then
            local name = mob.Name
            if not mobGroups[name] then
                mobGroups[name] = {}
            end
            table.insert(mobGroups[name], mob)
        end
    end

    local mobList = {}
    for name, group in pairs(mobGroups) do
        table.insert(mobList, {name = name, group = group})
    end

    table.sort(mobList, function(a, b)
        return getLevelFromName(a.name) < getLevelFromName(b.name)
    end)

    for _, data in ipairs(mobList) do
        local name = data.name
        if not createdToggles[name] then
            createdToggles[name] = true
            stickyEnabled[name] = false

            AutoFarmTab:CreateToggle({
                Name = name,
                CurrentValue = false,
                Flag = "Sticky_" .. name,
                Callback = function(state)
                    stickyEnabled[name] = state
                    local anyActive = false
                    for _, v in pairs(stickyEnabled) do
                        if v then anyActive = true break end
                    end
                    AutoFarm = anyActive
                end,
            })
        end
    end
end

-- เรียกสร้าง Toggle ตอนเริ่มเกม
createMobToggles()

-- อัปเดต toggle อัตโนมัติเมื่อมอน Spawn ใหม่
mobFolder.ChildAdded:Connect(function()
    createMobToggles()
end)

-- 🔹 ฟังก์ชันโจมตี
local function LightAttack(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    if not char or not char:FindFirstChild("PlayerHandler") then return end
    local handlerEvent = char.PlayerHandler:FindFirstChild("HandlerEvent")
    if not handlerEvent then return end

    local targetCFrame = mob.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0)
    local args = {
        {
            CombatAction = true,
            LightAttack = true,
            MouseData = targetCFrame
        }
    }
    handlerEvent:FireServer(unpack(args))
end

-- 🔹 ระบบ Auto Farm + Auto Attack ปรับให้ใช้ currentMobs
local lastAttack = 0
RunService.RenderStepped:Connect(function()
    if not AutoFarm then return end
    if not character or not hrp or not hrp.Parent then return end
    if not hasMobs then return end -- ไม่มีมอนเตอร์ อย่าโจมตี

    local closestTarget = nil
    local closestDistance = math.huge

    for _, mob in pairs(currentMobs) do
        if stickyEnabled[mob.Name] then
            local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < closestDistance then
                closestDistance = dist
                closestTarget = mob
            end
        end
    end

    if closestTarget then
        hrp.CFrame = CFrame.new(
            closestTarget.HumanoidRootPart.Position - closestTarget.HumanoidRootPart.CFrame.LookVector * attackDistance,
            closestTarget.HumanoidRootPart.Position
        )

        if tick() - lastAttack >= AttackDelay then
            LightAttack(closestTarget)
            lastAttack = tick()
        end
    end
end)


local ConfigTab = Window:CreateTab("settings", "settings")

-- Toggle Auto Henshin
local AutoHenshin = false
local IsHenshin = false -- เช็คสถานะว่าทำแล้วหรือยัง

-- Toggle UI
ConfigTab:CreateToggle({
    Name = "Auto Henshin",
    CurrentValue = false,
    Callback = function(state)
        AutoHenshin = state
    end
})

-- ฟังก์ชันแปรงร่าง
local function doHenshin()
    if not character or not character:FindFirstChild("PlayerHandler") then return end
    local handlerEvent = character.PlayerHandler:FindFirstChild("HandlerEvent")
    if not handlerEvent then return end

    local args = {
        {
            Henshin = true
        }
    }
    handlerEvent:FireServer(unpack(args))
    IsHenshin = true
end

-- ตรวจสอบ character ใหม่ตอน respawn
player.CharacterAdded:Connect(function(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
    IsHenshin = false -- รีเซ็ตสถานะแปรงร่าง
end)

-- Loop หลัก ตรวจสอบทุก tick
RunService.RenderStepped:Connect(function()
    if AutoHenshin and not IsHenshin then
        doHenshin()
    end
end)


-- ตัวแปร Toggle Auto Heal
local AutoHeal = false

-- สร้าง Toggle ใน Config Tab
ConfigTab:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = false,
    Flag = "AutoHeal",
    Callback = function(state)
        AutoHeal = state
    end
})

-- ฟังก์ชันเช็ค HP และใช้ Heal
local function autoHeal()
    if not AutoHeal then return end  -- ตรวจสอบ Toggle ก่อน
    if not character or not character:FindFirstChild("Humanoid") then return end

    local humanoid = character.Humanoid
    local hpPercent = humanoid.Health / humanoid.MaxHealth * 100

    if hpPercent <= 40 then
        local handlerEvent = character:FindFirstChild("PlayerHandler") and character.PlayerHandler:FindFirstChild("HandlerEvent")
        if not handlerEvent then return end

        local args = {
            {
                Heal = true
            }
        }

        -- ใช้ Heal 3 ครั้ง
        for i = 1, 3 do
            handlerEvent:FireServer(unpack(args))
        end
    end
end

-- Loop หลัก
RunService.RenderStepped:Connect(function()
    -- ระบบ Auto Henshin
    if AutoHenshin and not IsHenshin then
        doHenshin()
    end

    -- ระบบ Auto Heal
    autoHeal()
end)


-- Toggle Auto Skill
local AutoSkill = false

-- สร้าง Toggle ใน Tab UI
ConfigTab:CreateToggle({
    Name = "Auto Skill",
    CurrentValue = false,
    Flag = "AutoSkill",
    Callback = function(state)
        AutoSkill = state
    end
})

-- กำหนดสกิลที่จะใช้
local Skills = {
    {
        Key = "E",
        AttackType = "Down",
        MouseData = CFrame.new(-1241.37, 2.26, -676.69)
    },
    {
        Key = "R",
        AttackType = "Down",
        MouseData = CFrame.new(1019.27, 9.98, -812.99)
    },
    {
        Key = "V",
        AttackType = "Down",
        MouseData = CFrame.new(697.65, 9.98, -882.97)
    }
}

-- ฟังก์ชันยิงสกิล
local function castSkill(skill)
    if not character or not character:FindFirstChild("PlayerHandler") then return end
    local handlerEvent = character.PlayerHandler:FindFirstChild("HandlerEvent")
    if not handlerEvent then return end

    local args = {
        {
            Skill = true,
            AttackType = skill.AttackType,
            Key = skill.Key,
            MouseData = skill.MouseData
        }
    }
    handlerEvent:FireServer(unpack(args))
end

-- Loop หลัก วนลูปกดสกิลทุก tick (หรือปรับ delay เพิ่มได้)
RunService.RenderStepped:Connect(function()
    if AutoSkill then
        for _, skill in pairs(Skills) do
            castSkill(skill)
        end
    end
end)
