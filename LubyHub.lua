local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Luby Hub By zazq_io", "Synapse")

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local workspace = game:GetService("Workspace")


local autoFarmBoxTab = Window:NewTab("Auto Farm Box")
local autoFarmBoxSection = autoFarmBoxTab:NewSection("Box & Barrel Farm")

local isAutoFarmingBoxes = false
local E_HOLD_TIME = 3
local EXCLUDED_ITEM_INDEX = 7
local EXCLUDED_ITEM = nil


local function setupCharacterAutoFarm()
    if plr.Character then
        hrp = plr.Character:WaitForChild("HumanoidRootPart", 5)
    end

    plr.CharacterAdded:Connect(function(char)
        hrp = char:WaitForChild("HumanoidRootPart", 5)

            
        if isAutoFarmingBoxes then
            task.wait(1)
            startAutoFarmBoxes()
        end
    end)
end

-- Initialize character setup
setupCharacterAutoFarm()

-- Function to hold 'E' key for interaction
local function holdE_AutoFarm(prompt)
    if not prompt then return end
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(prompt.HoldDuration or E_HOLD_TIME)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Function to collect an item via ProximityPrompt
local function collectPrompt_AutoFarm(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Parent then return end
    if not hrp then
        warn("❌ ไม่พบ HRP สำหรับการเก็บของ")
        return
    end
    hrp.CFrame = prompt.Parent.CFrame + Vector3.new(0, 2, 0)
    task.wait(0.3)
    holdE_AutoFarm(prompt)
    print("✅ เก็บ:", prompt.Parent.Name)
end

-- Function to get all valid Box/Barrel prompts
local function getAllValidPrompts_AutoFarm()
    local results = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Parent and v.Enabled then
            local name = v.Parent.Name
            if name == "Box" or name == "Barrel" then
                table.insert(results, v)
            end
        end
    end
    return results
end

-- Function to collect items in the workspace (excluding a specific item)
local function collectItemsInWorkspace_AutoFarm()
    if not workspace:FindFirstChild("Item") then return end

    if EXCLUDED_ITEM == nil then
        local children = workspace.Item:GetChildren()
        if #children >= EXCLUDED_ITEM_INDEX then
            EXCLUDED_ITEM = children[EXCLUDED_ITEM_INDEX]
        end
    end

    for _, item in ipairs(workspace.Item:GetChildren()) do
        if item and item ~= EXCLUDED_ITEM then
            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                collectPrompt_AutoFarm(prompt)
                task.wait(1)
            end
        end
    end
end

-- Main function to start auto farming
function startAutoFarmBoxes()
    task.spawn(function()
        while isAutoFarmingBoxes do
            if not hrp then
                print("⚠️ รอ HRP ก่อนเริ่มฟาร์ม...")
                task.wait(1)
                continue
            end

            local prompts = getAllValidPrompts_AutoFarm()
            if #prompts > 0 then
                for _, p in ipairs(prompts) do
                    if not isAutoFarmingBoxes then break end
                    collectPrompt_AutoFarm(p)
                    task.wait(1.2)
                end
            else
                print("📭 ไม่พบกล่องหรือบาเรล รอสแกนใหม่...")
            end

            collectItemsInWorkspace_AutoFarm()
            task.wait(2.5)
        end
        print("🚫 หยุด Auto Farm กล่องและบาเรลแล้ว")
    end)
end

-- Toggle for Auto Farm Boxes & Barrels
autoFarmBoxSection:NewToggle("Auto Farm Boxes & Barrels", "เปิด/ปิดระบบฟาร์มกล่องและบาเรลอัตโนมัติ", function(state)
    isAutoFarmingBoxes = state
    if isAutoFarmingBoxes then
        print("✅ เริ่ม Auto Farm กล่องและบาเรล")
        startAutoFarmBoxes()
    else
        print("⛔ หยุด Auto Farm กล่องและบาเรล")
    end
end)

---
-- ### แท็บที่สอง: Auto Sell
-- ---
local autoSellTab = Window:NewTab("Auto Sell")
local autoSellSection = autoSellTab:NewSection("Auto Sell Items")

-- List of sellable items
local sellableItems = {
    "Arrow",
    "Mysterious Camera",
    "Hamon Manual",
    "Rokakaka",
    "Stop Sign",
    "Stone Mask",
    "Haunted Sword",
    "Spin Manual",
    "Barrel",
    "Bomu Bomu Devil Fruit",
    "Mochi Mochi Devil Fruit",
    "Bari Bari Devil Fruit"
}

-- Toggle control variables
local sellToggleRunning = false
local sellToggleTask = nil

-- Function to rapidly sell items in the backpack
local function autoSellBackpackFast()
    local backpack = plr:FindFirstChild("Backpack")
    if not backpack then return end

    local sellRemote = game:GetService("ReplicatedStorage"):WaitForChild("GlobalUsedRemotes"):WaitForChild("SellItem")

    for _, itemName in ipairs(sellableItems) do
        -- Count items with the same name in Backpack
        local count = 0
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == itemName then
                count = count + 1
            end
        end

        -- Fire sell command for each item rapidly
        if count > 0 then
            for i = 1, count do
                sellRemote:FireServer(itemName)
                print("🪙 ขายไอเทม:", itemName, "(" .. i .. "/" .. count .. ")")
                task.wait(0.05) -- Small delay to prevent issues
            end
        end
    end
end

-- Function to warp, talk to NPC, and sell items
local function autoSellAndTalk()
    sellToggleTask = task.spawn(function()
        while sellToggleRunning do
            -- 1. Warp to Chxmei
            local npc = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPCs") and workspace.Map.NPCs:FindFirstChild("Chxmei")
            if npc and npc:FindFirstChildOfClass("ProximityPrompt") then
                local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
                hrp.CFrame = CFrame.new(-619.713013, -32.5270004, 1921.901)
                task.wait(0.5)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(prompt.HoldDuration or 1.5)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                print("🗨️ คุยกับ Chxmei แล้ว")
            else
                warn("❌ ไม่พบ Chxmei หรือ Prompt")
            end

            -- 2. Rapidly sell items
            autoSellBackpackFast()

            task.wait(5) -- Delay before looping again
        end
    end)
end

-- Toggle button for auto-selling
autoSellSection:NewToggle(" Auto Sell Items", "เปิด/ปิดการขายของอัตโนมัติ + วาร์ป Chxmei", function(state)
    if state then
        sellToggleRunning = true
        autoSellAndTalk()
        print("✅ เริ่มขายของอัตโนมัติ")
    else
        sellToggleRunning = false
        if sellToggleTask then
            task.cancel(sellToggleTask)
            sellToggleTask = nil
        end
        print("🛑 หยุดขายของอัตโนมัติ")
    end
end)

---
-- ### แท็บที่สาม: Teleport Map
-- ---
local TeleportMapTab = Window:NewTab("Teleport Map")
local TeleportSection = TeleportMapTab:NewSection("Teleport Map")

local teleportList = {
    ["Shop"] = CFrame.new(-377.414978, -31.4648972, 1827.23376, 0.937943637, 0.0056101419, 0.346742332, -0.0806112289, 0.976007879, 0.202263251, -0.337288499, -0.217662856, 0.915892601),
    ["CAFE"] = CFrame.new(-184.333908, -32.6324806, 1450.97107, 0.542804658, 0.0135867689, 0.839749038, -0.0196342822, 0.999801099, -0.00348495319, -0.839629471, -0.0145962201, 0.542963505),
    ["book"] = CFrame.new(-48.9889183, -116.247437, 328.828979, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Hollow"] = CFrame.new(-9333.09082, 399.293854, 1739.05737, 4.29153442e-05, 3.75509262e-06, -1, -0.173663557, 0.984805048, -3.75509262e-06, 0.984804988, 0.173663557, 4.29153442e-05),
    ["PVP"] = CFrame.new(-519.294861, -35.1970901, 1655.45898, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Ronin"] = CFrame.new(-3674.99902, 94.8464127, -1169.98804, 0, 0, 1, 0, -1, 0, 1, 0, -0),
    ["BBQ3"] = CFrame.new(704.550049, 116.210938, -1357.19482, -1, 0, 0, 0, 0, 1, 0, 1, -0),
    ["BaikenPlace"] = CFrame.new(-14445.7402, -22.2789726, -3553.54053, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["BossSpawn RoninV2"] = CFrame.new(-352.300415, 8.00000381, 13042.4004, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Chill and relax"] = CFrame.new(-349.424469, -9.99766541, 1176.19006, 0.965929627, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, 0.965929627),
    ["Okarun"] = CFrame.new(-3701.47876, 696.754578, 5377.51123, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["BossSpawn RoninV1"] = CFrame.new(-26239.3945, 30.2711182, 24850.1602, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["EyeZone"] = CFrame.new(-18183.957, 990.572449, 7267.02295, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Wou"] = CFrame.new(-599.39032, -118.328743, 2098.08887, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Dio"] = CFrame.new(7476.32324, -430.687408, -4019.21753, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["forestfire"] = CFrame.new(-2035.63354, -386.424042, -5356.22461, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Domain"] = CFrame.new(15668.4658, -379.998291, 25310.0898, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["PB"] = CFrame.new(-2602.41211, 646.477661, -3351.8623, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["BattleArena"] = CFrame.new(856.786316, -428.90448, -750.567993, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["กูไม่รู้มันคือไร"] = CFrame.new(-3143.32495, -1.49950004, -10579.5752, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["WOU2"] = CFrame.new(-18689.2637, 931.929993, 7134.66748, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["ห้องทำงานพวกโง่"] = CFrame.new(-637.749084, 1.00501442, -262.399475, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["เกดุ"] = CFrame.new(-7146.22119, -27.1148205, 1295.23523, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["ดาบแดง"] = CFrame.new(-255.541168, 34.4699783, -2851.14014, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Cave"] = CFrame.new(-2284.29199, -393.49118, -4989.96924, -0.993314743, 0.100021183, 0.0576342195, 0.0373474397, -0.1939677, 0.980296731, 0.109229609, 0.975895643, 0.188935399),
    ["ถ้วย"] = CFrame.new(3813.12231, -157.168457, 4539.01416, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

-- Create buttons for each teleport location
for name, cframe in pairs(teleportList) do
    TeleportSection:NewButton("Teleport: " .. name, "Teleport " .. name, function()
        hrp.CFrame = cframe
        print("วาร์ปไปยัง:", name)
    end)
end

---
-- ### แท็บที่สี่: Teleport NPC
-- ---
local NPCTeleportTab = Window:NewTab("Teleport NPC")
local NPCTeleportSection = NPCTeleportTab:NewSection("Teleport NPC")

local npcTeleportList = {
    AMM = CFrame.new(-236.787, -32.525, 1472.125),
    Aubby = CFrame.new(-377.415, -32.228, 1827.396),
    Blacko_Coffee = CFrame.new(-82.483, -116.37, 360.842),
    Carmen = CFrame.new(-202.07, -264.768, -4251.815),
    Cashier = CFrame.new(-3526.258, 736.75, -11586.988),
    Chxmei = CFrame.new(-619.713, -32.527, 1921.901),
    CragBlock = CFrame.new(-695.705, -31.354, 1651.713),
    Drago = CFrame.new(-96.575, -32.013, 1676.773),
    Ego = CFrame.new(-235.857, -32.523, 1404.031),
    Eyegonis = CFrame.Angles(0, math.rad(-58), 0) + Vector3.new(-7409.198, -31.518, 1104.279),
    Geto = CFrame.new(-490.283, -32.493, 1837.344),
    Gojo = CFrame.new(-575.494, -30.922, 1415.523),
    Harold = CFrame.new(-21.264, -31.117, 1513.454),
    Hikarishi_XL = CFrame.new(-508.402, -32.964, 1504.683),
    Isagi = CFrame.new(-711.296, -32.493, 1287.708),
    Jeffy = CFrame.new(-225.047, -31.809, 1438.867),
    KFCKuzma = CFrame.new(-3502.495, 736.76, -11563.025),
    King_Bon = CFrame.new(634.389, 102.49, -1335.855),
    Kisuke = CFrame.new(-281.293, -30.838, 1228.765),
    Kusakabe = CFrame.new(-247.521, -32.648, 1744.211),
    LanternGuy = CFrame.new(-527.176, -264.768, -4282.515),
    LibraryBook = CFrame.new(-93.21, -115.17, 331.017),
    Milkytillys = CFrame.new(-233.689, -32.058, 1439.916),
    Momo = CFrame.new(-3634.823, 614.127, 5430.563),
    N4Animation = CFrame.new(11.162, -32.737, 1612.887),
    NameClan = CFrame.new(-430.454, -32.644, 1131.485),
    Olivier = CFrame.new(-394.915, -264.763, -4488.778),
    PuddingBumby = CFrame.new(-184.242, -32.158, 1451.031),
    Q3Prototype_Bon = CFrame.new(-637.299, 4.01, -345.199),
    Q3Prototype2 = CFrame.new(16.771, -32.456, 1877.99),
    Q3Prototype3 = CFrame.new(687.85, 104.001, -1381.4),
    Reevulu = CFrame.new(753.35, 102.5, -1372.55),
    Ronin_Book = CFrame.new(-3765.174, -32.685, -1274.375),
    RoninDialogue = CFrame.new(-258.032, -71.28, 13042.168),
    Simplrr = CFrame.new(-397.289, -30.792, 1825.063),
    Sukuna = CFrame.new(-215.827, -32.493, 1880.099),
    Syrentia = CFrame.new(-203.474, -31.65, 1440.17),
    TrueSwordsMan = CFrame.new(57.509, -32.537, 1576.532),
    TurboGranny_Bon = CFrame.new(-3686.247, 610.462, 5376.722),
    Vergilius = CFrame.new(-694.137, -31.12, 1585.219),
    buttersky20000 = CFrame.new(-2067.959, -289.603, -4685.778),
    piknishi = CFrame.new(-193.988, -32.009, 1464.331),
    Baiken = CFrame.new(-446.574921, -33.3681908, 1818.41248, 0.105164446, 0.187645465, 0.97659111, 0.0408497751, 0.980392337, -0.192774728, -0.993615866, 0.060166575, 0.0954371542)
}

-- Create buttons for each NPC teleport location
for name, cframe in pairs(npcTeleportList) do
    NPCTeleportSection:NewButton("Teleport NPC: " .. name, "Teleport to " .. name, function()
        hrp.CFrame = cframe
        print("วาร์ปไปยัง NPC:", name)
    end)
end

---
-- ### แท็บที่ห้า: Ronin Quest
-- ---
local RoninQuestTab = Window:NewTab("Ronin Quest")
local RoninQuestTeleportSection = RoninQuestTab:NewSection("Ronin QuestV2")

local roninQuestTeleportList = {
    ["1"] = CFrame.new(-534.262878, -261.767517, -4447.94678, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["2"] = CFrame.new(7558.78906, -416.672913, -3887.48145, 0.923132539, 0.0497069918, -0.38125518, 0.0210493021, 0.983586729, 0.179203987, 0.383905202, -0.173454195, 0.906934619),
    ["3"] = CFrame.new(-8931.51953, 420.982635, 1407.76099, -0.0231808424, -0.0539431982, -0.998275042, 0.0529567339, 0.997075081, -0.0551080592, 0.998327851, -0.0541428216, -0.0202564001),
    ["4"] = CFrame.new(-3701.47876, 696.754578, 5377.51123, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["5"] = CFrame.new(-2136.93872, -286.097168, -4591.50928, 0.698880374, -0.268390417, -0.662972748, -0.12495631, 0.86685282, -0.482651114, 0.704238713, 0.420158029, 0.572289348),
    ["6"] = CFrame.new(-3866.35962, -180.888901, -999.858276, 0.815359712, 0.0296349041, -0.578195691, -0.0711272061, 0.996251166, -0.0492401645, 0.574568868, 0.081273891, 0.814410925),
    ["7"] = CFrame.new(-324.765259, 31.1866627, -2903.82251, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["8"] = CFrame.new(-6965.54248, -29.1699066, 1101.05481, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

-- Create buttons for each Ronin Quest teleport location
for name, cframe in pairs(roninQuestTeleportList) do
    RoninQuestTeleportSection:NewButton("Teleport: " .. name, "Teleport " .. name, function()
        hrp.CFrame = cframe
        print("Teleport:", name)
    end)
end

---
-- ### แท็บที่หก: Chants
-- ---
local chantTab = Window:NewTab("Chants")
local chantSection = chantTab:NewSection("Chants")

local vim = game:GetService("VirtualInputManager")
local chants = {
    "Teiwaz",
    "Othala",
    "Inguz",
    "Berkano",
    "Dagaz",
    "Laguz",
    "Ehwaz",
    "Mannaz"
}

local TYPE_DELAY = 0.05

-- Function to type a message into chat
local function typeChat(message)
    local TextChatService = game:GetService("TextChatService")
    local GeneralChannel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")

    if GeneralChannel then
        GeneralChannel:SendAsync(message)
        print("สวด:", message)
    else
        warn("ไม่พบช่องแชท RBXGeneral หรือช่องแชทที่กำหนด ใช้ VirtualInputManager แทน")
        vim:SendKeyEvent(true, Enum.KeyCode.Slash, false, game)
        task.wait(0.1)
        vim:SendKeyEvent(false, Enum.KeyCode.Slash, false, game)

        for i = 1, #message do
            local char_to_type = message:sub(i, i)
            vim:SendTextInput(char_to_type)
            task.wait(TYPE_DELAY)
        end

        task.wait(0.1)
        vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.1)
        vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        print("สวด (ผ่าน VirtualInputManager ทีละตัว):", message)
    end
end

-- Create buttons for each chant
for _, chant in ipairs(chants) do
    chantSection:NewButton("Chants: " .. chant, "พิมพ์ " .. chant .. " ลงแชท", function()
        typeChat(chant)
    end)
end


local holdETeleportTab = Window:NewTab("Auto random skin")
local holdETeleportSection = holdETeleportTab:NewSection("Auto random skin")

local bodyPos = nil
local isHoldingE = false
local targetPos = Vector3.new(-193.988007, -32.0089989 + 3, 1464.33105)

local function startHoldingE()
    if isHoldingE then return end
    isHoldingE = true
    task.spawn(function()
        while isHoldingE do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.1)
        end
    end)
end

local function stopHoldingE()
    if not isHoldingE then return end
    isHoldingE = false
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function lockPosition()
    if bodyPos then return end
    bodyPos = Instance.new("BodyPosition")
    bodyPos.Position = targetPos
    bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyPos.P = 1e4
    bodyPos.Parent = hrp
end

local function unlockPosition()
    if bodyPos then
        bodyPos:Destroy()
        bodyPos = nil
    end
end

local function teleportLockAndHoldE()
    hrp.CFrame = CFrame.new(targetPos)
    task.wait(0.3)
    lockPosition()
    startHoldingE()
end

local function releaseLockAndStopE()
    unlockPosition()
    stopHoldingE()
end

holdETeleportSection:NewToggle("Auto random skin", " E ", function(state)
    if state then
        
        teleportLockAndHoldE()
    else
        
        releaseLockAndStopE()
    end
end)

