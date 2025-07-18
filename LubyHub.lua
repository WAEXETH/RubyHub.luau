local allowedPlaceId = 8534845015

if game.PlaceId ~= allowedPlaceId then
    game.Players.LocalPlayer:Kick("This script can only be run in Sakura Stand By zazq_io")
    return
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Luby Hub By zazq_io",
	Icon = "package",
	LoadingTitle = "Load...you",
	LoadingSubtitle = "wait...you",
	ShowText = "เปิดเมนู",
	Theme = "Default",
	ToggleUIKeybind = "K",
	KeySystem = false
})


local autoFarmTab = Window:CreateTab("Auto Farm", "package")
local autoFarmSection = autoFarmTab:CreateSection("Farm")

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local VirtualInputManager = game:GetService("VirtualInputManager")
local workspace = game:GetService("Workspace")

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
setupCharacterAutoFarm()


local function holdE_AutoFarm(prompt)
	if not prompt then return end
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
	task.wait(prompt.HoldDuration or E_HOLD_TIME)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function collectPrompt_AutoFarm(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Parent then return end
	if not hrp then return end
	hrp.CFrame = prompt.Parent.CFrame + Vector3.new(0, 2, 0)
	task.wait(0.3)
	holdE_AutoFarm(prompt)
end

local function getAllValidPrompts_AutoFarm()
	local results = {}
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") and v.Parent and v.Enabled then
			local name = v.Parent.Name
			if name == "Box" or name == "Barrel" or name == "BoxDrop" then
				table.insert(results, v)
			end
		end
	end
	return results
end


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

function startAutoFarmBoxes()
	task.spawn(function()
		while isAutoFarmingBoxes do
			if not hrp then
				task.wait(1)
			else
				local prompts = getAllValidPrompts_AutoFarm()
				if #prompts > 0 then
					for _, p in ipairs(prompts) do
						if not isAutoFarmingBoxes then break end
						collectPrompt_AutoFarm(p)
						task.wait(1.2)
					end
				end
				collectItemsInWorkspace_AutoFarm()
				task.wait(2.5)
			end
		end
	end)
end

autoFarmTab:CreateToggle({
	Name = "Auto Farm Level",
	CurrentValue = false,
	Callback = function(state)
		isAutoFarmingBoxes = state
		if state then
			startAutoFarmBoxes()
		end
	end
})


local itemSection = autoFarmTab:CreateSection("Auto Collect Item")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local workspaceItems = workspace:WaitForChild("Item")

local ignoreNames = {"Box", "Chest", "Barrel"}
local failedAttempts = {}

local autoCollectEnabled = false


local Toggle = autoFarmTab:CreateToggle({
   Name = "Auto Collect Item",
   CurrentValue = false,
   Flag = "AutoItem",
   Callback = function(Value)
      autoCollectEnabled = Value
   end,
})

-- เช็คชื่อที่ต้องข้าม
local function isIgnored(itemName)
    for _, word in ipairs(ignoreNames) do
        if string.find(string.lower(itemName), string.lower(word)) then
            return true
        end
    end
    return false
end

-- ฟังก์ชันเก็บไอเทม
local function tryCollect(item)
    if not item:IsDescendantOf(workspace) then return end

    local itemName = item.Name
    failedAttempts[item] = failedAttempts[item] or 0
    if failedAttempts[item] >= 3 then return end

    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return false end

    local attempts = 0
    while attempts < 3 do
        if not item:IsDescendantOf(workspace) or not autoCollectEnabled then
            return true
        end

        local connection = RunService.RenderStepped:Connect(function()
            if item:IsDescendantOf(workspace) then
                hrp.CFrame = item.CFrame + Vector3.new(0, 2, 0)
            end
        end)

        pcall(function() prompt:InputHoldBegin() end)
        task.wait(prompt.HoldDuration + 0.2)
        pcall(function() prompt:InputHoldEnd() end)

        connection:Disconnect()

        if not item:IsDescendantOf(workspace) then
            return true
        end

        attempts += 1
    end

    failedAttempts[item] = failedAttempts[item] + 1
    return false
end

-- ลูปหลัก
task.spawn(function()
    while task.wait(0.5) do
        if autoCollectEnabled then
            for _, item in ipairs(workspaceItems:GetChildren()) do
                if not isIgnored(item.Name) and failedAttempts[item] ~= 3 then
                    tryCollect(item)
                    task.wait(0.2)
                end
            end
        end
    end
end)


local autoSellTab = Window:CreateTab("Auto Sell", "shopping-cart")
local autoSellSection = autoSellTab:CreateSection("Sell")

local sellableItems = {
	"Arrow", "Mysterious Camera", "Hamon Manual", "Rokakaka", "Stop Sign", "Stone Mask",
	"Haunted Sword", "Spin Manual", "Barrel", "Bomu Bomu Devil Fruit",
	"Mochi Mochi Devil Fruit", "Bari Bari Devil Fruit"
}

local sellToggleRunning = false
local sellToggleTask = nil

local function autoSellBackpackFast()
	local backpack = plr:FindFirstChild("Backpack")
	if not backpack then return end
	local sellRemote = game:GetService("ReplicatedStorage"):WaitForChild("GlobalUsedRemotes"):WaitForChild("SellItem")

	for _, itemName in ipairs(sellableItems) do
		local count = 0
		for _, item in ipairs(backpack:GetChildren()) do
			if item.Name == itemName then
				count = count + 1
			end
		end
		if count > 0 then
			for i = 1, count do
				sellRemote:FireServer(itemName)
				task.wait(0.05)
			end
		end
	end
end

local function autoSellAndTalk()
	sellToggleTask = task.spawn(function()
		while sellToggleRunning do
			local npc = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPCs") and workspace.Map.NPCs:FindFirstChild("Chxmei")
			if npc and npc:FindFirstChildOfClass("ProximityPrompt") then
				local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
				hrp.CFrame = CFrame.new(-619.713013, -32.5270004, 1921.901)
				task.wait(0.5)
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
				task.wait(prompt.HoldDuration or 1.5)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
				print("🗨️ ")
			else
				warn("❌ ")
			end

			autoSellBackpackFast()
			task.wait(5)
		end
	end)
end


autoSellTab:CreateToggle({
	Name = "Auto Sell Items",
	CurrentValue = false,
	Callback = function(state)
		if state then
			sellToggleRunning = true
			autoSellAndTalk()
		else
			sellToggleRunning = false
			if sellToggleTask then
				task.cancel(sellToggleTask)
				sellToggleTask = nil
			end
		end
	end
})


local teleportTab = Window:CreateTab("Teleport", "map")
local teleportSection = teleportTab:CreateSection("Teleport")


local teleportList = {
	["Shop"] = CFrame.new(-377.414978, -31.4648972, 1827.23376),
	["CAFE"] = CFrame.new(-184.333908, -32.6324806, 1450.97107),
	["book"] = CFrame.new(-48.9889183, -116.247437, 328.828979),
	["Hollow"] = CFrame.new(-9333.09082, 399.293854, 1739.05737),
	["PVP"] = CFrame.new(-519.294861, -35.1970901, 1655.45898),
	["Ronin"] = CFrame.new(-3674.99902, 94.8464127, -1169.98804),
	["BBQ3"] = CFrame.new(704.550049, 116.210938, -1357.19482),
	["BaikenPlace"] = CFrame.new(-14445.7402, -22.2789726, -3553.54053),
	["BossSpawn RoninV2"] = CFrame.new(-352.300415, 8.00000381, 13042.4004),
	["Chill and relax"] = CFrame.new(-349.424469, -9.99766541, 1176.19006),
	["Okarun"] = CFrame.new(-3701.47876, 696.754578, 5377.51123),
	["BossSpawn RoninV1"] = CFrame.new(-26239.3945, 30.2711182, 24850.1602),
	["EyeZone"] = CFrame.new(-18183.957, 990.572449, 7267.02295),
	["Wou"] = CFrame.new(-599.39032, -118.328743, 2098.08887),
	["Dio"] = CFrame.new(7476.32324, -430.687408, -4019.21753),
	["forestfire"] = CFrame.new(-2035.63354, -386.424042, -5356.22461),
	["Domain"] = CFrame.new(15668.4658, -379.998291, 25310.0898),
	["PB"] = CFrame.new(-2602.41211, 646.477661, -3351.8623),
	["BattleArena"] = CFrame.new(856.786316, -428.90448, -750.567993),
	["กูไม่รู้มันคือไร"] = CFrame.new(-3143.32495, -1.49950004, -10579.5752),
	["WOU2"] = CFrame.new(-18689.2637, 931.929993, 7134.66748),
	["ห้องทำงานพวกโง่"] = CFrame.new(-637.749084, 1.00501442, -262.399475),
	["เกดุ"] = CFrame.new(-7146.22119, -27.1148205, 1295.23523),
	["ดาบแดง"] = CFrame.new(-255.541168, 34.4699783, -2851.14014),
	["Cave"] = CFrame.new(-2284.29199, -393.49118, -4989.96924),
	["ถ้วย"] = CFrame.new(3813.12231, -157.168457, 4539.01416),
}


local plr = game.Players.LocalPlayer
for name, cframe in pairs(teleportList) do
	teleportTab:CreateButton({
		Name = name,
		Callback = function()
			local character = plr.Character or plr.CharacterAdded:Wait()
			local hrp = character:WaitForChild("HumanoidRootPart")

			if hrp then
				hrp.CFrame = cframe
			end
		end
	})
end


for name, cframe in pairs(teleportList) do
	teleportTab:CreateButton({
		Name = name,
		Callback = function()
			if hrp then
				hrp.CFrame = cframe
				
			end
		end
	})
end


local npcTeleportTab = Window:CreateTab("Teleport NPC", "users")
local npcSection = npcTeleportTab:CreateSection(" NPC ")


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
}

local plr = game.Players.LocalPlayer

local function getHRP()
    local character = plr.Character or plr.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

for name, cframe in pairs(npcTeleportList) do
    npcTeleportTab:CreateButton({
        Name = name,
        Callback = function()
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = cframe
            end
        end
    })
end



local roninQuestTab = Window:CreateTab("Ronin Quest", "target")
local roninSection = roninQuestTab:CreateSection("Ronin Quest V2")


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

local plr = game.Players.LocalPlayer

local function getHRP()
    local character = plr.Character or plr.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

for number, cframe in pairs(roninQuestTeleportList) do
    roninQuestTab:CreateButton({
        Name = " TP " .. number,
        Callback = function()
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = cframe
            end
        end
    })
end


local Tab = Window:CreateTab("Chants")
local ChantsSection = Tab:CreateSection("Chants Section")


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

local function typeChat(message)
    local TextChatService = game:GetService("TextChatService")
    local GeneralChannel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")

    if GeneralChannel then
        GeneralChannel:SendAsync(message)
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
    end
end

-- สร้างปุ่มสำหรับแต่ละ chant
for _, chant in ipairs(chants) do
    Tab:CreateButton({
        Name = chant,
        Callback = function()
            print("ส่ง Chant: " .. chant)
            typeChat(chant)
        end,
    })
end



local Tab = Window:CreateTab("Monster & dummy ")
local DummySection = Tab:CreateSection("Monster & dummy Section")

local stickyEnemies = {
    "Dummy",
    "Attacking Dummy",
    "Blocking Dummy",
    "Counter Dummy",
    "Adjuchas",
    "Deku",
    "Toji",
    "Thug",
    "Spider Curse",
    "Mosquito Curse",
    "Bandit",
    "Frog Hollow",
    "Fishbone",
    "Glutton Curse",
    "Contorted Curse",
    "Menos",
    "Jotaro Kujo",
    "Mimicry",
    "The Red Mist",
}

local stickyEnabled = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
end)

-- ✅ สร้าง Toggle ให้แต่ละชื่อ
for _, name in ipairs(stickyEnemies) do
    Tab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = "Sticky_" .. name,
        Callback = function(state)
            stickyEnabled[name] = state
        end,
    })
end

-- ✅ วาร์ปไปหาตัวที่ "เปิด toggle" และ "ใกล้ที่สุด"
RunService.RenderStepped:Connect(function()
    local closestTarget = nil
    local closestDistance = math.huge

    for _, obj in pairs(workspace.Living:GetChildren()) do
        if obj:IsA("Model")
        and obj ~= character
        and obj:FindFirstChild("Humanoid")
        and obj:FindFirstChild("HumanoidRootPart")
        and obj.Humanoid.Health > 0
        and stickyEnabled[obj.Name] then -- ✅ ตรวจว่าชื่อนี้ toggle อยู่
            local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < closestDistance then
                closestDistance = dist
                closestTarget = obj
            end
        end
    end

    if closestTarget then
        hrp.CFrame = closestTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
    end
end)


local Tab = Window:CreateTab("Auto Use Skills & Attacking M1")
local DummySection = Tab:CreateSection("Auto Use Skills & Attacking M1")

local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local autoSkillEnabled = false
local autoAttackEnabled = false

-- สร้าง Toggle เปิด/ปิด Auto Skill
local skillToggle = Tab:CreateToggle({
    Name = "Auto Skill ",
    CurrentValue = false,
    Flag = "AutoSkillToggle",
    Callback = function(Value)
        autoSkillEnabled = Value
    end,
})

-- สร้าง Toggle เปิด/ปิด Auto Attack (คลิกเมาส์ซ้าย)
local attackToggle = Tab:CreateToggle({
    Name = "Auto Attack M1",
    CurrentValue = false,
    Flag = "AutoAttackToggle",
    Callback = function(Value)
        autoAttackEnabled = Value
    end,
})

-- รายการ KeyCode สกิลทั้งหมด
local skillKeys = {
    Enum.KeyCode.E,
    Enum.KeyCode.R,
    Enum.KeyCode.T,
    Enum.KeyCode.Y,
    Enum.KeyCode.G,
    Enum.KeyCode.H,
    Enum.KeyCode.Q,
    Enum.KeyCode.Z,
    Enum.KeyCode.X,
    Enum.KeyCode.V,
    Enum.KeyCode.B,
}

local lastPause = tick() -- เวลาเริ่มต้น
local pauseDuration = 2 -- เวลาหยุด (วินาที)
local activeDuration = 5 -- เวลาทำงาน (วินาที)
local isPaused = false

-- ใช้สกิล
local function pressSkillKeys()
    for _, keyCode in ipairs(skillKeys) do
        VirtualInputManager:SendKeyEvent(true, keyCode, false, nil)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, nil)
        task.wait(0.1)
    end
end


local function pressAttack()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local centerX = screenSize.X / 2
    local centerY = screenSize.Y / 2

    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
end


RunService.RenderStepped:Connect(function()
    local now = tick()

    
    if not isPaused and now - lastPause >= activeDuration then
        isPaused = true
        lastPause = now
    elseif isPaused and now - lastPause >= pauseDuration then
        isPaused = false
        lastPause = now
    end

    
    if not isPaused then
        if autoSkillEnabled then pressSkillKeys() end
        if autoAttackEnabled then pressAttack() end
    end
end)

local VirtualInputManager = game:GetService("VirtualInputManager") 

local autoParryEnabled = false
local parryCooldown = 2.5
local parryHoldTime = 3

function autoParry()
    while autoParryEnabled do
        print("AutoParry: กดปุ่ม F ค้าง")
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(parryHoldTime)
        print("AutoParry: ปล่อยปุ่ม F")
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        print("AutoParry: รอ cooldown")
        task.wait(parryCooldown)
    end
end

function toggleAutoParry(state)
    print("toggleAutoParry called with", state)
    autoParryEnabled = state
    if autoParryEnabled then
        task.spawn(autoParry)
    end
end

-- Toggle UI
local Toggle = Tab:CreateToggle({
    Name = "Auto Parry Beta Farm only!",
    CurrentValue = false,
    Flag = "AutoParryToggle",
    Callback = function(state)
        toggleAutoParry(state)
    end,
})


local AutoKillTab = Window:CreateTab("Auto Kill", "sword")
local AutoKillSection = AutoKillTab:CreateSection("Auto Kill Player")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local currentTarget = nil
local autoKillEnabled = false

-- รีอัปเดต character และ hrp เมื่อผู้เล่นฟื้นคืนชีพ
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ฟังก์ชันหาผู้เล่นที่อยู่ใกล้ที่สุด
local function getNearestPlayer()
    local nearest = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                nearest = player
            end
        end
    end

    return nearest
end

-- ฟังก์ชันเช็คว่าผู้เล่นตายหรือไม่
local function isDead(player)
    if not player.Character then return true end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return not humanoid or humanoid.Health <= 0
end

RunService.Heartbeat:Connect(function()
    if not autoKillEnabled then return end

    if not currentTarget or isDead(currentTarget) then
        currentTarget = getNearestPlayer()
        if not currentTarget then return end
    end

    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        HumanoidRootPart.CFrame = currentTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
    end
end)

AutoKillTab:CreateToggle({
    Name = "Auto Kill Player Beta",
    CurrentValue = false,
    Flag = "AutoKill Player Beta",
    Callback = function(state)
        autoKillEnabled = state
        if not state then
            currentTarget = nil
        end
    end,
})
