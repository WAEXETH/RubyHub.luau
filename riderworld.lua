
local allowedPlaceId = 9301186334
if game.PlaceId ~= allowedPlaceId then
    game.Players.LocalPlayer:Kick("script rider world")
    return
end


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Luby Hub by zazq_io",
    SubTitle = "Rider World",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K
})

local Tabs = {
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


-- 📦 Service 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser") -- เพิ่ม VirtualUser

-- ⚙️ ตัวแปรพื้นฐาน
local attackDistance = 5
local AutoFarm = false
local AttackDelay = 0.05
local stickyEnabled, createdToggles = {}, {}
local lastAttack = 0

-- 📦 Player & Character
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- 🧩 Slider สำหรับระยะโจมตี (วางไว้บนสุด)
Tabs.AutoFarm:AddSlider("AttackDistance", {
    Title = "Attack Distance",
    Description = "ระยะโจมตีจากมอน",
    Default = attackDistance,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(value)
        attackDistance = value
    end
})

-- 🛡 Anti-AFK
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(), workspace.CurrentCamera.CFrame)
end)

-- 📦 Mob Folder ตรวจหาหลายชื่อ
local mobFolder = Workspace:FindFirstChild("Live") 
    or Workspace:FindFirstChild("Lives") 
    or Workspace:FindFirstChild("Enemies") 
    or Workspace:WaitForChild("Live", 10)

-- 🧩 อัปเดต Character เมื่อเกิดใหม่
player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- 🧮 ฟังก์ชันดึง Level จากชื่อมอน
local function getLevelFromName(name)
    local lv = name:match("Lv%.?%s*(%d+)")
    return tonumber(lv) or 0
end

-- 🔘 ฟังก์ชันสร้าง/อัปเดต Toggle ของมอน (เรียงตามเลเวล)
local function createMobToggles()
    if not mobFolder then return end

    local mobGroups = {}
    for _, mob in ipairs(mobFolder:GetChildren()) do
        if mob:IsA("Model")
        and mob:FindFirstChild("Humanoid")
        and mob:FindFirstChild("HumanoidRootPart")
        and mob.Humanoid.Health > 0
        and not Players:FindFirstChild(mob.Name) then
            mobGroups[mob.Name] = true
        end
    end

    local mobList = {}
    for name in pairs(mobGroups) do
        table.insert(mobList, name)
    end

    -- เรียงตามเลเวล
    table.sort(mobList, function(a, b)
        return getLevelFromName(a) < getLevelFromName(b)
    end)

    for _, name in ipairs(mobList) do
        if not createdToggles[name] then
            createdToggles[name] = true
            stickyEnabled[name] = false
            Tabs.AutoFarm:AddToggle("Mob_" .. name, {
                Title = name,
                Default = false,
                Callback = function(state)
                    stickyEnabled[name] = state
                    -- ตรวจว่ามี Toggle ไหนเปิดบ้าง
                    AutoFarm = false
                    for _, v in pairs(stickyEnabled) do
                        if v then
                            AutoFarm = true
                            break
                        end
                    end
                end
            })
            
        end
    end
end

-- 🔁 เรียกสร้างครั้งแรก
createMobToggles()

-- 🔁 อัปเดตอัตโนมัติเมื่อมีมอนเกิดใหม่
if mobFolder then
    mobFolder.ChildAdded:Connect(function(child)
        task.wait(0.5) -- รอให้ Humanoid ถูกสร้าง
        createMobToggles()
    end)
end

-- ⚔️ ฟังก์ชันโจมตี
local function LightAttack(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local char = player.Character
    if not char or not char:FindFirstChild("PlayerHandler") then return end
    local event = char.PlayerHandler:FindFirstChild("HandlerEvent")
    if not event then return end

    event:FireServer({
        {
            CombatAction = true,
            LightAttack = true,
            MouseData = mob.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
        }
    })
end

-- 🧭 ค้นหามอนใกล้ที่สุด
local function findClosestMob()
    local closest, minDist = nil, math.huge
    if not mobFolder then return end

    for _, mob in ipairs(mobFolder:GetChildren()) do
        if mob:IsA("Model")
        and mob:FindFirstChild("Humanoid")
        and mob:FindFirstChild("HumanoidRootPart")
        and mob.Humanoid.Health > 0
        and stickyEnabled[mob.Name] then
            local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = mob
            end
        end
    end
    return closest
end

-- 🔄 ระบบ Auto Farm หลัก
RunService.RenderStepped:Connect(function()
    if not AutoFarm or not character or not hrp then return end

    local mob = findClosestMob()
    if not mob then return end

    -- 🌀 วาร์ปไปข้างหลังมอน
    hrp.CFrame = CFrame.new(
        mob.HumanoidRootPart.Position - mob.HumanoidRootPart.CFrame.LookVector * attackDistance,
        mob.HumanoidRootPart.Position
    )

    -- ⚔️ โจมตีต่อเนื่อง
    if tick() - lastAttack >= AttackDelay then
        LightAttack(mob)
        lastAttack = tick()
    end
end)



-- ===== ตั้งค่า AutoHenshin, AutoHeal, AutoSkill =====
local AutoHenshin = false
local AutoHeal = false
local AutoSkill = false
local HealThreshold = 40
local HealCount = 3

local Skills = {
    {Key = "E", AttackType = "Down", MouseData = CFrame.new(209.0955, -2.0791, 15.1587), Enabled = true, Order = 1},
    {Key = "R", AttackType = "Down", MouseData = CFrame.new(209.0955, -2.0791, 15.1587), Enabled = true, Order = 2},
    {Key = "V", AttackType = "Down", MouseData = CFrame.new(753.456, 9.958, -1001.693), Enabled = true, Order = 3}
}

-- ===== เพิ่ม Toggle UI =====
Tabs.Settings:AddToggle("AutoHenshin", {
    Title = "Auto Henshin",
    Default = false,
    Callback = function(v) AutoHenshin = v end
})

Tabs.Settings:AddToggle("AutoHeal", {
    Title = "Auto Heal",
    Default = false,
    Callback = function(v) AutoHeal = v end
})

Tabs.Settings:AddToggle("AutoSkill", {
    Title = "Auto Skill",
    Default = false,
    Callback = function(v) AutoSkill = v end
})



-- ===== ฟังก์ชัน Henshin =====
local player = game:GetService("Players").LocalPlayer

local function isHenshinActive(char)
    -- ตรวจหาว่ามี Effect หรือ Attribute ที่บ่งบอกว่ากำลังแปลงร่าง
    -- ตัวอย่างเช่น ถ้าเกมสร้าง Folder หรือ Value ตอนแปลงร่างไว้
    return char:FindFirstChild("Henshin") or char:FindFirstChild("Transformed") or (char:FindFirstChild("PlayerHandler") and char.PlayerHandler:FindFirstChild("Transformed"))
end

local function doHenshin()
    local char = player.Character
    if not char then return end

    -- ถ้าแปลงร่างอยู่แล้ว ไม่ต้องทำอะไร
    if isHenshinActive(char) then
        return
    end

    local handler = char:FindFirstChild("PlayerHandler")
    local event = handler and handler:FindFirstChild("HandlerEvent")
    if event then
        pcall(function()
            local args = {{Henshin = true}}
            event:FireServer(unpack(args))
        end)
    end
end


-- ===== ฟังก์ชัน Heal =====
local function doHeal()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    if humanoid.Health / humanoid.MaxHealth * 100 <= HealThreshold then
        local handler = char:FindFirstChild("PlayerHandler")
        local event = handler and handler:FindFirstChild("HandlerEvent")
        if event then
            for i = 1, HealCount do
                pcall(function()
                    local args = {{Heal = true}}
                    event:FireServer(unpack(args))
                end)
                task.wait(0.1)
            end
        end
    end
end

-- ===== ฟังก์ชัน Skill =====
local function castSkill(skill)
    if not skill.Enabled then return end
    local char = player.Character
    if not char then return end
    local handler = char:FindFirstChild("PlayerHandler")
    local event = handler and handler:FindFirstChild("HandlerEvent")
    if event then
        pcall(function()
            local args = {{
                Skill = true,
                AttackType = skill.AttackType,
                Key = skill.Key,
                MouseData = skill.MouseData
            }}
            event:FireServer(unpack(args))
        end)
    end
end

-- ===== Loop หลัก AutoHenshin/Heal/Skill =====
RunService.RenderStepped:Connect(function()
    if AutoHenshin then doHenshin() end
    if AutoHeal then doHeal() end
    if AutoSkill then
        table.sort(Skills, function(a,b) return a.Order < b.Order end)
        for _, skill in ipairs(Skills) do
            castSkill(skill)
        end
    end
end)

-- ===== ฟัง CharacterAdded =====
player.CharacterAdded:Connect(function()
    task.wait(1)
    if AutoHenshin then doHenshin() end
    if AutoHeal then doHeal() end
    if AutoSkill then
        table.sort(Skills, function(a,b) return a.Order < b.Order end)
        for _, skill in ipairs(Skills) do
            castSkill(skill)
        end
    end
end)



local AutoM1 = false

Tabs.Settings:AddToggle("AutoM1", { 
    Title = "Auto M1",
    Default = false,
    Callback = function(v) 
        AutoM1 = v
        if AutoM1 then
            spawn(function()
                while AutoM1 do
                    local player = game:GetService("Players").LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local handlerEvent = character:WaitForChild("PlayerHandler"):WaitForChild("HandlerEvent")

                    -- หาเป้าหมาย (ตัวอย่าง)
                    local targetCFrame
                    local enemies = workspace:FindFirstChild("Enemies")
                    if enemies then
                        for _, enemy in pairs(enemies:GetChildren()) do
                            if enemy:FindFirstChild("HumanoidRootPart") then
                                targetCFrame = enemy.HumanoidRootPart.CFrame
                                break
                            end
                        end
                    end
                    -- ถ้าไม่เจอเป้าหมาย ใช้ตำแหน่งหน้าตัวเอง
                    if not targetCFrame then
                        targetCFrame = character.HumanoidRootPart.CFrame + character.HumanoidRootPart.CFrame.LookVector*5
                    end

                    local args = {
                        {
                            CombatAction = true,
                            LightAttack = true,
                            MouseData = targetCFrame
                        }
                    }
                    handlerEvent:FireServer(unpack(args))
                    wait(0.1)
                end
            end)
        end
    end
})


-- ⚙️ ตัวแปรควบคุม
local AutoAttack = false
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 🟢 Toggle เปิด/ปิด Auto Attack
Tabs.Settings:AddToggle("Auto Weapon", {
    Title = "Auto Weapon",
    Default = false,
    Callback = function(state)
        AutoAttack = state
    end
})

-- 🔄 ระบบ Auto Attack
RunService.RenderStepped:Connect(function()
    if not AutoAttack then return end -- ถ้า Toggle ปิด จะไม่ทำอะไร

    local tool = player.Character:FindFirstChild("Attack") or player.Backpack:FindFirstChild("Attack")
    if tool then
        if tool.Parent ~= player.Character then
            tool.Parent = player.Character -- ถือ Tool
        end
        tool:Activate() -- โจมตี
    end
end)


-- ✅ ตั้งค่า SaveManager & InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("LubyHub")
SaveManager:SetFolder("LubyHub/Configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "Luby Hub",
    Content = "Fluent UI Loaded Successfully!",
    Duration = 5
})
