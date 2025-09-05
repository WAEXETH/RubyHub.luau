
local allowedPlaceId = 8534845015

if game.PlaceId ~= allowedPlaceId then
    game.Players.LocalPlayer:Kick("script Sakura Stand")
    return
end


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


local autoFarmTab = Window:CreateTab("Auto Farm", "package")
local itemSection = autoFarmTab:CreateSection("Auto Farm")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local EXCLUDED_ITEM_INDEX = 7
local ignoreNames = {"Box", "Chest", "Barrel"} 
local LEVEL_ITEM_NAMES = {"Box", "Barrel", "BoxDrop"} 

-- Control variables
local autoFarmEnabled = false
local autoCollectEnabled = false
local EXCLUDED_ITEM = nil
local failedAttempts = {}

-- Update character references
local function updateCharacter()
	character = plr.Character or plr.CharacterAdded:Wait()
	hrp = character:WaitForChild("HumanoidRootPart", 5)
end
plr.CharacterAdded:Connect(updateCharacter)

-- Check if item should be ignored (Auto Collect)
local function isIgnored(itemName)
	for _, word in ipairs(ignoreNames) do
		if string.lower(itemName) == string.lower(word) then
			return true
		end
	end
	return false
end

-- Check if item is a Level-Up item
local function isLevelItem(itemName)
	for _, word in ipairs(LEVEL_ITEM_NAMES) do
		if string.lower(itemName) == string.lower(word) then
			return true
		end
	end
	return false
end

-- Instant Interact (ใช้ FireProximityPrompt)
local function interactPrompt(prompt)
	if not prompt then return end
	pcall(function()
		fireproximityprompt(prompt, 1)
	end)
end

-- Collect a single prompt (ใช้ offset ป้องกันวาร์ปทับ)
local function collectPrompt(prompt)
	if not prompt or not prompt.Parent or not hrp then return end
	hrp.CFrame = prompt.Parent.CFrame + Vector3.new(0, 3, 0)
	task.wait(0.1)
	interactPrompt(prompt)
end

-- Get valid Level-Up prompts
local function getValidLevelPrompts()
	local results = {}
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") and v.Parent and v.Enabled and isLevelItem(v.Parent.Name) then
			table.insert(results, v)
		end
	end
	return results
end

-- Try collect item (Auto Collect)
local function tryCollectItem(item)
	if not item:IsDescendantOf(Workspace) then return false end
	if isLevelItem(item.Name) then return false end
	if failedAttempts[item] and failedAttempts[item] >= 2 then return false end

	local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt or not prompt.Enabled then 
		warn("[AutoCollect] ❌ ไม่มี Prompt หรือ Disabled สำหรับ:", item.Name)
		return false 
	end

	-- warp + interact
	hrp.CFrame = item.CFrame + Vector3.new(0, 3, 0)
	task.wait(0.1)
	interactPrompt(prompt)

	-- check ถ้าเก็บสำเร็จ (item หายไป)
	if not item:IsDescendantOf(Workspace) then
		print("[AutoCollect] ✅ เก็บสำเร็จ:", item.Name)
		return true
	end

	-- fail → บันทึกว่าเก็บไม่ได้
	failedAttempts[item] = (failedAttempts[item] or 0) + 1
	warn("[AutoCollect] ⚠️ เก็บไม่สำเร็จ:", item.Name, "ครั้งที่", failedAttempts[item])
	return false
end

-- Main Auto Loop (เบาลง)
task.spawn(function()
	while true do
		task.wait(0.3) -- เดิม 0.1 → ลดภาระ CPU

		-- Auto Farm Level
		if autoFarmEnabled then
			for _, prompt in ipairs(getValidLevelPrompts()) do
				if not autoFarmEnabled then break end
				task.spawn(function()
					collectPrompt(prompt)
				end)
				task.wait(0.1)
			end
		end

		-- Auto Collect Items
		if autoCollectEnabled and Workspace:FindFirstChild("Item") then
			for _, item in ipairs(Workspace.Item:GetChildren()) do
				if not isIgnored(item.Name) then
					task.spawn(function()
						tryCollectItem(item)
					end)
					task.wait(0.1)
				end
			end
		end
	end
end)

-- Toggles
autoFarmTab:CreateToggle({
	Name = "Auto Farm Level",
	CurrentValue = false,
	Callback = function(state)
		autoFarmEnabled = state
	end
})

autoFarmTab:CreateToggle({
	Name = "Auto Collect Item",
	CurrentValue = false,
	Callback = function(state)
		autoCollectEnabled = state
	end
})


local autoSellTab = Window:CreateTab("Auto Sell", "shopping-cart")
local autoSellSection = autoSellTab:CreateSection("Sell")

local sellableItems = {
	"Arrow", "Mysterious Camera", "Hamon Manual", "Rokakaka", "Stop Sign", "Stone Mask",
	"Haunted Sword", "Spin Manual", "Barrel", "Bomu Bomu Devil Fruit",
	"Mochi Mochi Devil Fruit", "Bari Bari Devil Fruit"
}

local sellToggleRunning = false
local sellToggleTask = nil

-- Function to sell all items in backpack
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
				pcall(function()
					sellRemote:FireServer(itemName)
				end)
				task.wait(0.05)
			end
		end
	end
end

-- Function to interact with NPC via ProximityPrompt
local function interactNPC(npc)
	if not npc or not npc:IsDescendantOf(workspace) then return end
	local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		-- กด prompt โดยไม่วาร์ป
		pcall(function() prompt:InputHoldBegin() end)
		task.wait(prompt.HoldDuration or 1.5)
		pcall(function() prompt:InputHoldEnd() end)
		return true
	end
	return false
end

-- Main Auto Sell Loop
local function autoSellLoop()
	sellToggleTask = task.spawn(function()
		while sellToggleRunning do
			-- หา NPC อัปเดตใหม่ทุกครั้ง
			local npc = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPCs") and workspace.Map.NPCs:FindFirstChild("Chxmei")
			if npc then
				interactNPC(npc)
				autoSellBackpackFast()
			else
				warn("❌ NPC 'Chxmei' ไม่พบ")
			end
			task.wait(3) -- รอ 3 วินาที ก่อนเช็คใหม่
		end
	end)
end

-- Toggle
autoSellTab:CreateToggle({
	Name = "Auto Sell Items",
	CurrentValue = false,
	Callback = function(state)
		if state then
			sellToggleRunning = true
			autoSellLoop()
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
    ["AMM"] = CFrame.new(-9586.11914, 805.007996, 9422.08398, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Auddy"] = CFrame.new(-9497.18457, 805.220459, 9039.4209, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["Blacko_Coffee"] = CFrame.new(-82.4833221, -116.369576, 360.841919, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["buttersky20000"] = CFrame.new(-9047.70312, 805.00824, 8950.38379, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Carmen"] = CFrame.new(-202.069824, -264.767517, -4251.81494, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Cashier"] = CFrame.new(-3526.25781, 736.750122, -11586.9883, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Chxmei"] = CFrame.new(-9855.39941, 834.228638, 9464.40527, 0.971264243, 3.80203128e-05, 0.238003805, 0.0425439477, 0.983866215, -0.173773795, -0.234170511, 0.178905904, 0.955592394),
    ["CragBlock"] = CFrame.new(-9800.01172, 810.658325, 8786.83203, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["Dast"] = CFrame.new(13419.5889, 1602.41528, -2919.8252, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Drago"] = CFrame.new(-9338.46875, 805.212585, 9303.79297, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Ego"] = CFrame.new(-10030.2764, 820.817505, 9211.25879, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["Eyegonis"] = CFrame.new(-10112.4961, 805.48407, 8850.9873, -0.512227774, 0, -0.858849585, 0, 1, 0, 0.858849585, 0, -0.512227774),
    ["freehotdogeveryday"] = CFrame.new(-10893.9297, 573.020264, 8478.0625, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["Geto"] = CFrame.new(-9885.08203, 869.695435, 9693.59961, 0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, 0.422592998),
    ["Gojo"] = CFrame.new(-9226.83984, 810.660217, 8778.01758, -0.906296611, 0, 0.422642082, 0, 1, 0, -0.422642082, 0, -0.906296611),
    ["GoldShip"] = CFrame.new(-9303.10938, 818.50824, 9531.81934, -0.99619168, 0, -0.0871905237, 0, 1, 0, 0.0871905237, 0, -0.99619168),
    ["Harold"] = CFrame.new(-10118.998, 807.865234, 8828.19824, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Hika"] = CFrame.new(-8955.53125, 561.163269, 7619.96191, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["Hikarishi_XL"] = CFrame.new(-9670.7373, 805.208252, 9053.93945, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Hongler"] = CFrame.new(3641.03394, -232.919495, 4517.34375, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Isagi"] = CFrame.new(-10173.3057, 820.850159, 9219.16211, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Jeffy"] = CFrame.new(-9852.97754, 806.684021, 8656.24707, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["KFCKuzma"] = CFrame.new(-3502.49512, 736.760132, -11563.0254, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["King Bon"] = CFrame.new(634.38916, 102.489998, -1335.85522, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["KingMon"] = CFrame.new(-9447.86426, 796.520447, 9429.20898, 0.912216544, 0, 0.409708411, 0, 1, 0, -0.409708411, 0, 0.912216544),
    ["Kisuke"] = CFrame.new(-9685.89062, 806.763489, 9209.16797, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Kusakabe"] = CFrame.new(-9856.35156, 805.00824, 9162.38086, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["LanternGuy"] = CFrame.new(-9146.58496, 805.052551, 8838.41504, 0.79861635, 0, -0.601840496, 0, 1, 0, 0.601840496, 0, 0.79861635),
    ["Library Book"] = CFrame.new(-527.175781, -264.767517, -4282.51465, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Milkytillys"] = CFrame.new(-93.2099991, -115.169998, 331.016998, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Mirror"] = CFrame.new(-9853.67969, 805.101318, 8686.65625, -0.866007447, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, -0.866007447),
    ["Momo"] = CFrame.new(-11482.543, 418.379669, 8789.37598, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["N4Animation"] = CFrame.new(-3634.82324, 614.126648, 5430.56348, 0.999098122, 0, 0.0424608514, 0, 1, 0, -0.0424608514, 0, 0.999098122),
    ["NameClan"] = CFrame.new(-10153.4424, 821.075378, 8967.65527, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07),
    ["Olivier"] = CFrame.new(-10090.6953, 807.812317, 8872.9502, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["piknishi"] = CFrame.new(-8179.33203, 837.377014, 6505.67139, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["PuddingBumby"] = CFrame.new(-394.915009, -264.763, -4488.77783, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Q3Prototype"] = CFrame.new(-9858.06836, 805.869568, 8638.28125, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Q3Prototype2"] = CFrame.new(-637.299072, 4.01001358, -345.199463, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Q3Prototype3"] = CFrame.new(-9238.39062, 805.008301, 9201.88672, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247),
    ["Reevulu"] = CFrame.new(687.850037, 104.001007, -1381.40002, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Ronin Book"] = CFrame.new(753.350037, 102.5, -1372.55005, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["RoninDialogue"] = CFrame.new(-3765.17407, -32.6850014, -1274.375, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Sakuya"] = CFrame.new(-258.700195, -72.0999985, 13042.0996, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Silver Fang"] = CFrame.new(-10140.6719, 820.815491, 9297.62891, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Simplrr"] = CFrame.new(-9568.89453, 805.007996, 9535.00781, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["Sukuna"] = CFrame.new(-9514.4707, 806.02533, 9039.57031, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["สุ่มเกลือเพื่อรับรางวัล"] = CFrame.new(-9874.85742, 805.684509, 8645.39746, -0.906296611, 0, 0.422642082, 0, 1, 0, -0.422642082, 0, -0.906296611),
    ["Syanyte"] = CFrame.new(-9896.3916, 829.425354, 9459.84863, -0.499959469, 0, -0.866048813, 0, 1, 0, 0.866048813, 0, -0.499959469),
    ["Syrentia"] = CFrame.new(3802.38403, -232.919495, 4574.19971, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["TrueSwordsMan"] = CFrame.new(-9865.37988, 806.575623, 8677.53906, 0.573598742, 0, 0.81913656, 0, 1, 0, -0.81913656, 0, 0.573598742),
    ["Turbo Granny"] = CFrame.new(-9419.27441, 810.546387, 9010.62793, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Vergilius"] = CFrame.new(-3686.24707, 610.462036, 5376.72168, -0.999098182, 0, -0.0424608514, 0, 1, 0, 0.0424608514, 0, -0.999098182)
}

local plr = game.Players.LocalPlayer

local function getHRP()
    local character = plr.Character or plr.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

-- ดึงชื่อทั้งหมด
local names = {}
for name in pairs(npcTeleportList) do
    table.insert(names, name)
end

-- เรียงตามตัวอักษร (A-Z)
table.sort(names)

-- สร้างปุ่มตามลำดับที่เรียงแล้ว
for _, name in ipairs(names) do
    local cframe = npcTeleportList[name]
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


local npcSection = npcTeleportTab:CreateSection(" NPC Special (Random birth) ")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")

local function teleportToNPCHead(npcName)
    local npc = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPCs") and workspace.Map.NPCs:FindFirstChild(npcName)
    if npc and npc:FindFirstChild("Head") then
        hrp.CFrame = npc.Head.CFrame + Vector3.new(0, 3, 0)
        print("✅ Teleported to " .. npcName)
    else
        warn("❌ " .. npcName .. " not found.")
    end
end

npcTeleportTab:CreateButton({
    Name = "Baiken",
    Callback = function()
        teleportToNPCHead("Baiken")
    end,
})

npcTeleportTab:CreateButton({
    Name = "Kuzma",
    Callback = function()
        teleportToNPCHead("Kuzma")
    end,
})


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


local Tab = Window:CreateTab("Monster & Dummy")
local DummySection = Tab:CreateSection("Monster & Dummy Section")

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
    "Dog",
    "Monkey",
    "Space Curse",
    "Paper Curse Half",
    "Paper Curse Quarter"
}

local stickyEnabled = {}
local attackDistance = 5 -- ค่าเริ่มต้น

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
end)

-- ✅ Attack Distance อยู่บนสุด
Tab:CreateSlider({
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

-- ✅ Toggle สำหรับเลือกมอน/ดัมมี่
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

-- ✅ ระบบหาตัวที่ใกล้ที่สุดที่เปิด Toggle
RunService.RenderStepped:Connect(function()
    local closestTarget = nil
    local closestDistance = math.huge

    for _, obj in pairs(workspace.Living:GetChildren()) do
        if obj:IsA("Model")
        and obj ~= character
        and obj:FindFirstChild("Humanoid")
        and obj:FindFirstChild("HumanoidRootPart")
        and obj.Humanoid.Health > 0
        and stickyEnabled[obj.Name] then
            local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < closestDistance then
                closestDistance = dist
                closestTarget = obj
            end
        end
    end

    if closestTarget then
        hrp.CFrame = CFrame.new(
            closestTarget.HumanoidRootPart.Position - closestTarget.HumanoidRootPart.CFrame.LookVector * attackDistance,
            closestTarget.HumanoidRootPart.Position
        )
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


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local autoParryEnabled = false
local parryCooldown = 2.5
local parryHoldTime = 1.5 -- เวลาค้าง F ก่อนปล่อย
local lastParry = 0

-- Detect range
local detectRadius = 15
local activeThreats = {}
local isHolding = false

-- เริ่มกดค้าง F
local function startHold()
    if not isHolding then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        isHolding = true
    end
end

-- ปล่อย F = ทำ Parry
local function releaseParry()
    if isHolding then
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        isHolding = false
        lastParry = tick()
    end
end

-- ตรวจหาใกล้ตัว
local function detectThreats()
    for obj, _ in pairs(activeThreats) do
        if obj.Parent and obj:IsA("BasePart") then
            local distance = (obj.Position - humanoidRootPart.Position).Magnitude
            if distance <= detectRadius then
                return true
            end
        else
            activeThreats[obj] = nil
        end
    end
    return false
end

-- ฟัง Event เมื่อมี object โผล่มา
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") then
        local name = obj.Name:lower()
        if name:find("hitbox") or name:find("projectile") then
            activeThreats[obj] = true
            obj.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    activeThreats[obj] = nil
                end
            end)
        end
    end
end)

-- Loop ตรวจจับ
RunService.Heartbeat:Connect(function()
    if autoParryEnabled and humanoidRootPart then
        local now = tick()

        -- เริ่มกดค้างไว้ก่อน
        if not isHolding and (now - lastParry) >= parryCooldown then
            startHold()
        end

        -- ถ้ามี Threat เข้ามาใกล้ → ปล่อยเพื่อ Parry
        if isHolding and detectThreats() then
            releaseParry()
        end
    else
        -- ถ้าปิดระบบ → ปล่อยปุ่ม F ถ้าค้างอยู่
        if isHolding then
            releaseParry()
        end
    end
end)

-- UI Toggle
local Toggle = Tab:CreateToggle({
    Name = "Auto Parry v2",
    CurrentValue = false,
    Flag = "AutoParrySmart",
    Callback = function(state)
        autoParryEnabled = state
    end,
})

-- Slider Cooldown
local SliderCooldown = Tab:CreateSlider({
    Name = "Parry Cooldown",
    Range = {0.2, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = parryCooldown,
    Flag = "ParryCooldownSlider",
    Callback = function(value)
        parryCooldown = value
    end,
})

-- Slider Detect Radius
local SliderDetect = Tab:CreateSlider({
    Name = "Detect Range",
    Range = {5, 50},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = detectRadius,
    Flag = "DetectRadiusSlider",
    Callback = function(value)
        detectRadius = value
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
local attackDistance = 4

-- โหมด: "Nearest" หรือ "LowestHealth"
local killMode = "Nearest"

-- รีอัปเดต character และ hrp เมื่อผู้เล่นฟื้นคืนชีพ
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ฟังก์ชันเช็คว่าผู้เล่นตายหรือไม่
local function isDead(player)
    if not player.Character then return true end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return not humanoid or humanoid.Health <= 0
end

-- ฟังก์ชันหาผู้เล่นที่ใกล้ที่สุด
local function getNearestPlayer()
    local nearest = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local dist = (HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

-- ฟังก์ชันหาผู้เล่นที่เลือดน้อยที่สุด
local function getLowestHealthPlayer()
    local lowest = nil
    local lowestHealth = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and humanoid.Health < lowestHealth then
                lowestHealth = humanoid.Health
                lowest = player
            end
        end
    end
    return lowest
end

-- Loop หลัก
RunService.Heartbeat:Connect(function()
    if not autoKillEnabled or not HumanoidRootPart then return end

    if killMode == "Nearest" then
        currentTarget = getNearestPlayer()
    elseif killMode == "LowestHealth" then
        currentTarget = getLowestHealthPlayer()
    end

    -- วาร์ปไปหาเป้าหมาย
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = currentTarget.Character.HumanoidRootPart
        HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, attackDistance)
    end
end)

-- UI: Toggle เปิดปิด Auto Kill
AutoKillTab:CreateToggle({
    Name = "Auto Kill Player",
    CurrentValue = false,
    Flag = "AutoKillV2",
    Callback = function(state)
        autoKillEnabled = state
        if not state then
            currentTarget = nil
        end
    end,
})

-- UI: Dropdown เลือกโหมด
AutoKillTab:CreateDropdown({
    Name = "Select Kill Mode",
    Options = {"Nearest", "LowestHealth"},
    CurrentOption = {"Nearest"},
    Flag = "KillModeDropdown",
    Callback = function(option)
        killMode = option[1]
        print("Kill mode set to:", killMode)
    end,
})

-- UI: Slider ปรับระยะโจมตี
AutoKillTab:CreateSlider({
    Name = "Attack Distance",
    Range = {2, 10},
    Increment = 0.5,
    CurrentValue = attackDistance,
    Flag = "AttackDistanceSlider",
    Callback = function(value)
        attackDistance = value
    end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ค่าเริ่มต้น Roblox
local defaultWalkSpeed = 16
local defaultJumpPower = 50

-- ค่าที่ปรับได้
local walkSpeed = 100
local jumpPower = 150
local speedEnabled = false
local jumpEnabled = false

-- ฟังก์ชันปรับค่า Humanoid
local function applySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    if speedEnabled then
        humanoid.WalkSpeed = walkSpeed
    else
        humanoid.WalkSpeed = defaultWalkSpeed
    end

    if jumpEnabled then
        humanoid.JumpPower = jumpPower
    else
        humanoid.JumpPower = defaultJumpPower
    end
end

-- Loop คงค่า
RunService.Heartbeat:Connect(function()
    applySpeed()
end)

-- รีเซ็ตเวลาเกิดใหม่
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.1) -- รอ Humanoid โหลด
    applySpeed()
end)

-- UI: วิ่งเร็ว
AutoKillTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(state)
        speedEnabled = state
        applySpeed()
    end,
})

AutoKillTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = walkSpeed,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        walkSpeed = value
    end,
})

-- UI: กระโดดสูง
AutoKillTab:CreateToggle({
    Name = "Enable High Jump",
    CurrentValue = false,
    Flag = "JumpToggle",
    Callback = function(state)
        jumpEnabled = state
        applySpeed()
    end,
})

AutoKillTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = jumpPower,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        jumpPower = value
    end,
})


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local clickTPEnabled = false
local tpOffset = Vector3.new(0, 3, 0) -- ยกตัวเล็กน้อยให้ไม่ติดพื้น

-- รีอัปเดต character และ HRP
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ฟังก์ชันวาร์ป
local function teleportTo(position)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(position + tpOffset)
    end
end

-- ตรวจสอบคลิกเมาส์
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not clickTPEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Target then
            teleportTo(mouse.Hit.Position)
        end
    end
end)

-- UI Toggle เปิด/ปิด
AutoKillTab:CreateToggle({
    Name = "Click Teleport",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(state)
        clickTPEnabled = state
    end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ค่าตั้งต้น
local flyEnabled = false
local flySpeed = 50

-- ฟังก์ชันบินง่าย ๆ
local function flyCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local direction = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + hrp.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - hrp.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - hrp.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + hrp.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0,1,0) end

    -- ถ้ามีทิศทาง ให้เคลื่อนที่
    if direction.Magnitude > 0 then
        hrp.Velocity = direction.Unit * flySpeed
    else
        hrp.Velocity = Vector3.new(0,0,0)
    end
end

-- Loop ควบคุมบิน
RunService.Heartbeat:Connect(function()
    if flyEnabled then
        flyCharacter()
    end
end)

-- UI: Toggle เปิด/ปิดบิน
AutoKillTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(state)
        flyEnabled = state
    end,
})

-- UI: Slider ปรับความเร็วบิน
AutoKillTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 1,
    CurrentValue = flySpeed,
    Flag = "FlySpeedSlider",
    Callback = function(value)
        flySpeed = value
    end,
})


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local noclipEnabled = false
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")


local function setNoClip(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not state
        end
    end
end


RunService.Heartbeat:Connect(function()
    if noclipEnabled then
        setNoClip(true)
    end
end)


LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if noclipEnabled then
        setNoClip(true)
    end
end)


AutoKillTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(state)
        noclipEnabled = state
        setNoClip(state)
    end,
})
