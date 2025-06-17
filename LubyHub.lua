local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Luby Hub", "Synapse")

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Store original values - Make sure these are updated if character respawns
local originalWalkSpeed = hum.WalkSpeed
local originalJumpPower = hum.JumpPower
local originalGravity = workspace.Gravity

-- Re-initialize char, hrp, hum if character respawns
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
    originalWalkSpeed = hum.WalkSpeed -- Update original values on respawn
    originalJumpPower = hum.JumpPower
    -- If Speed/Jump Hack was active, reapply them
    if isSpeedHacked then
        hum.WalkSpeed = MovementSection:GetValue("WalkSpeed") or 50
    end
    if isJumpHacked then
        hum.JumpPower = MovementSection:GetValue("JumpPower") or 100
    end
end)


--- AutoFarm Tab ---
local AutoFarmTab = Window:NewTab("AutoFarm")
local AutoFarmSection = AutoFarmTab:NewSection("AutoFarm")

--- Teleport Map Tab ---
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

for name, cframe in pairs(teleportList) do
    TeleportSection:NewButton("Teleport: " .. name, "Teleport " .. name, function()
        hrp.CFrame = cframe
        print("วาร์ปไปยัง:", name)
    end)
end

--- Teleport NPC Tab ---
local TeleportNPCTab = Window:NewTab("Teleport NPC")
local NPCTeleportSection = TeleportNPCTab:NewSection("Teleport NPC")

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
    piknishi = CFrame.new(-193.988, -32.009, 1464.331)
}

for name, cframe in pairs(npcTeleportList) do
    NPCTeleportSection:NewButton("Teleport NPC: " .. name, "Teleport to " .. name, function()
        hrp.CFrame = cframe
        print("วาร์ปไปยัง NPC:", name)
    end)
end

--- Ronin Quest Tab ---
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

for name, cframe in pairs(roninQuestTeleportList) do
    RoninQuestTeleportSection:NewButton("Teleport: " .. name, "Teleport " .. name, function()
        hrp.CFrame = cframe
        print("Teleport:", name)
    end)
end

--- Chants Tab ---
local ChantsTab = Window:NewTab("Chants")
local ChantSection = ChantsTab:NewSection("Chants")

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
    local GeneralChannel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral") 

    if GeneralChannel then
        GeneralChannel:SendAsync(message)
        print("สวด:", message)
    else
        warn("ไม่พบช่องแชท RBXGeneral หรือช่องแชทที่กำหนด ใช้ VirtualInputManager แทน")
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Slash, false, game)
        task.wait(0.1) 
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Slash, false, game) 

        for i = 1, #message do
            local char_to_type = message:sub(i, i)
            VirtualInputManager:SendTextInput(char_to_type)
            task.wait(TYPE_DELAY)
        end
        
        task.wait(0.1)

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.1) 
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game) 
        print("สวด (ผ่าน VirtualInputManager ทีละตัว):", message)
    end
end

for _, chant in ipairs(chants) do
    ChantSection:NewButton("Chants: " .. chant, "พิมพ์ " .. chant .. " ลงแชท", function()
        typeChat(chant)
    end)
end

--- Movement Tab ---
local MovementTab = Window:NewTab("Movement")
local MovementSection = MovementTab:NewSection("Player Movement")

-- Run Speed
local isSpeedHacked = false
-- No need for speedConnection for WalkSpeed/JumpPower as they are direct property changes
MovementSection:NewSlider("WalkSpeed", "ปรับความเร็วในการเดิน", 500, 16, function(value)
    if isSpeedHacked and hum then -- Only update if speed hack is active and humanoid exists
        hum.WalkSpeed = value
    end
end)

MovementSection:NewToggle("Speed Hack", "เปิด/ปิดวิ่งเร็ว (ล็อคค่า)", function(state)
    isSpeedHacked = state
    if hum then -- Ensure humanoid exists before modifying
        if state then
            print("เปิดวิ่งเร็ว")
            originalWalkSpeed = hum.WalkSpeed -- Store current walkspeed before changing
            hum.WalkSpeed = MovementSection:GetValue("WalkSpeed") or 50 -- Set to slider value or default high
        else
            print("ปิดวิ่งเร็ว")
            hum.WalkSpeed = originalWalkSpeed -- Restore original walkspeed
        end
    end
end)

-- Jump Power
local isJumpHacked = false
MovementSection:NewSlider("JumpPower", "ปรับความสูงในการกระโดด", 1000, 50, function(value)
    if isJumpHacked and hum then -- Only update if jump hack is active and humanoid exists
        hum.JumpPower = value
    end
end)

MovementSection:NewToggle("Jump Hack", "เปิด/ปิดกระโดดสูง (ล็อคค่า)", function(state)
    isJumpHacked = state
    if hum then -- Ensure humanoid exists before modifying
        if state then
            print("เปิดกระโดดสูง")
            originalJumpPower = hum.JumpPower -- Store current jump power
            hum.JumpPower = MovementSection:GetValue("JumpPower") or 100 -- Set to slider value or default high
        else
            print("ปิดกระโดดสูง")
            hum.JumpPower = originalJumpPower -- Restore original jump power
        end
    end
end)

-- Fly
local isFlying = false
local flySpeed = 100 -- ความเร็วในการบิน
local flyConnection = nil
local originalMoveState = hum.Sit -- Store original Humanoid.Sit state (will be updated on char respawn)
local inputConnections = {} -- Table to hold input connections for fly mode

MovementSection:NewToggle("Fly", "เปิด/ปิดโหมดบิน", function(state)
    isFlying = state
    if isFlying then
        print("เปิดโหมดบิน")
        originalGravity = workspace.Gravity
        workspace.Gravity = 0 -- ปิดแรงโน้มถ่วง
        originalMoveState = hum.PlatformStand -- Store original PlatformStand state
        hum.PlatformStand = true -- ทำให้ตัวละครลอย
        
        -- Disconnect existing input connections if any
        for _, conn in pairs(inputConnections) do
            conn:Disconnect()
        end
        inputConnections = {}

        -- Input Began Connection
        table.insert(inputConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if isFlying and hrp then -- Check hrp existence
                local currentCameraCFrame = workspace.CurrentCamera.CFrame
                local moveDirection = Vector3.new(0,0,0)

                if input.KeyCode == Enum.KeyCode.W then
                    moveDirection = moveDirection + currentCameraCFrame.lookVector
                elseif input.KeyCode == Enum.KeyCode.S then
                    moveDirection = moveDirection - currentCameraCFrame.lookVector
                elseif input.KeyCode == Enum.KeyCode.A then
                    moveDirection = moveDirection - currentCameraCFrame.rightVector
                elseif input.KeyCode == Enum.KeyCode.D then
                    moveDirection = moveDirection + currentCameraCFrame.rightVector
                elseif input.KeyCode == Enum.KeyCode.Space then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftControl then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                -- Normalize the direction to prevent faster movement diagonally
                if moveDirection.Magnitude > 0 then
                    hrp.Velocity = moveDirection.Unit * flySpeed
                else
                    hrp.Velocity = Vector3.new(0,0,0) -- Stop if no key is pressed (in case of other inputs)
                end
            end
        end))
        
        -- Input Ended Connection
        table.insert(inputConnections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if isFlying and hrp then -- Check hrp existence
                -- Check if any of the movement keys are still pressed
                local anyMovementKey = UserInputService:IsKeyDown(Enum.KeyCode.W) or
                                       UserInputService:IsKeyDown(Enum.KeyCode.S) or
                                       UserInputService:IsKeyDown(Enum.KeyCode.A) or
                                       UserInputService:IsKeyDown(Enum.KeyCode.D) or
                                       UserInputService:IsKeyDown(Enum.KeyCode.Space) or
                                       UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                
                if not anyMovementKey then
                    hrp.Velocity = Vector3.new(0,0,0) -- หยุดการเคลื่อนที่เมื่อไม่มีปุ่มกด
                end
            end
        end))

        -- To keep applying velocity as long as keys are held down (for smoother movement)
        -- This part ensures continuous movement based on held keys
        flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if isFlying and hrp then
                local currentCameraCFrame = workspace.CurrentCamera.CFrame
                local moveDirection = Vector3.new(0,0,0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + currentCameraCFrame.lookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - currentCameraCFrame.lookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - currentCameraCFrame.rightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + currentCameraCFrame.rightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end

                if moveDirection.Magnitude > 0 then
                    hrp.Velocity = moveDirection.Unit * flySpeed
                else
                    hrp.Velocity = Vector3.new(0,0,0) -- Stop if no key is pressed
                end
            end
        end)

    else
        print("ปิดโหมดบิน")
        workspace.Gravity = originalGravity -- คืนค่าแรงโน้มถ่วง
        hum.PlatformStand = originalMoveState -- คืนค่า PlatformStand เดิม
        if hrp then hrp.Velocity = Vector3.new(0,0,0) end -- หยุดแรงค้าง
        
        -- Disconnect all fly related connections
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        for _, conn in pairs(inputConnections) do
            conn:Disconnect()
        end
        inputConnections = {}
    end
end)


-- Noclip (เดินทะลุ)
local isNoClipping = false
local noclipConnection = nil

MovementSection:NewToggle("Noclip", "เปิด/ปิดโหมดเดินทะลุ", function(state)
    isNoClipping = state
    if isNoClipping then
        print("เปิดโหมดเดินทะลุ (NoClip)")
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if char then -- Ensure character exists
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.CanTouch = false
                    end
                end
            end
        end)
    else
        print("ปิดโหมดเดินทะลุ (NoClip)")
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        -- ตรวจสอบให้แน่ใจว่ากลับมาชนวัตถุได้ (อาจต้องรอ Char re-spawn หรือ Manually Re-enable)
        if char then -- Ensure character exists
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.CanTouch = true
                end
            end
        end
    end
end)


--- AutoFarm Logic ---
local farmTeleportPoints = {
    CFrame.new(-676.028442, -34.4872017, 1824.49011),
    CFrame.new(-202.499771, -21.7434502, 1475.51172),
    CFrame.new(-681.279785, -34.9928169, 1556.7666),
    CFrame.new(-237.836639, -35.0265427, 1272.09192),
    CFrame.new(-209.397476, -34.9928093, 1918.94165),
    CFrame.new(-697.179321, -34.9928131, 1276.71667),
    CFrame.new(-585.617004, -34.9928017, 1918.23755),
    CFrame.new(-537.18335, -34.9928093, 1819.58142),
    CFrame.new(-313.208466, -34.184124, 1802.14001),
    CFrame.new(58.4846497, -35.0372467, 1785.9054),
    CFrame.new(73.7697754, -35.0372467, 1544.45923),
    CFrame.new(-98.1705246, -35.2372437, 1558.54834),
}

local isFarming = false
local farmCoroutine = nil

local function interactWithItem(item)
    local proximityPrompt = item:FindFirstChildOfClass("ProximityPrompt")
    if proximityPrompt and proximityPrompt.Enabled then
        print("กำลังโต้ตอบกับ ProximityPrompt ของ:", item.Name)
        local activationKey = proximityPrompt.KeyboardKeyCode
        if activationKey ~= Enum.KeyCode.Unknown then
            VirtualInputManager:SendKeyEvent(true, activationKey, false, game)
            task.wait(proximityPrompt.HoldDuration + 0.1)
            VirtualInputManager:SendKeyEvent(false, activationKey, false, game)
        else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    else
        print("กำลังพยายามเก็บไอเท็ม (กด E/F) หรือเดินชน:", item.Name)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

local function startFarmingLoop()
    while isFarming do
        if not char or not hrp or not hum then
            print("รอตัวละครโหลดใน AutoFarm...")
            char = plr.Character or plr.CharacterAdded:Wait()
            hrp = char:WaitForChild("HumanoidRootPart")
            hum = char:WaitForChild("Humanoid")
            task.wait(1) -- รอให้พร้อม
            continue
        end

        for i, cframe in ipairs(farmTeleportPoints) do
            if not isFarming then break end

            hrp.CFrame = cframe
            print(string.format("วาร์ปไปยังจุดฟาร์มที่ %d: %s", i, cframe.Position))
            task.wait(1.5) -- รอให้โหลดฉากและไอเทมปรากฏ

            local radius = 35 
            local foundItems = {}
            
            for _, item in ipairs(workspace:GetDescendants()) do 
                if not isFarming then break end
                
                local isPotentialItem = false
                local itemNamesToCollect = {
                    "Item", "Loot", "DroppedItem", "Coin", "Cash", "Material", "Orb",
                    "Box", "Barrel",
                    "StandArrow", "Rokakaka", "RibCage", "Heart", "Eye",
                    "Ability Orb", "Skill Orb", "Gem", "Fragment", "Dust"
                }
                
                local itemPosition = nil
                if item:IsA("BasePart") then
                    itemPosition = item.Position
                elseif item:IsA("Model") and item.PrimaryPart then
                    itemPosition = item.PrimaryPart.Position
                end

                if itemPosition then
                    local distance = (hrp.Position - itemPosition).Magnitude
                    if distance <= radius then
                        for _, namePattern in ipairs(itemNamesToCollect) do
                            if string.find(item.Name, namePattern) then
                                isPotentialItem = true
                                break
                            end
                        end
                        
                        if (item.Parent and item.Parent.Name == "Item") or (item:IsA("Model") and item.Name == "Item") then
                             isPotentialItem = true
                        end

                        if isPotentialItem then
                            table.insert(foundItems, item)
                        end
                    end
                end
            end

            if #foundItems > 0 then
                print(string.format("พบไอเท็ม %d ชิ้นในบริเวณจุดวาร์ป", #foundItems))
                for _, itemToCollect in ipairs(foundItems) do
                    if not isFarming then break end
                    hrp.CFrame = CFrame.new(itemToCollect.Position) + Vector3.new(0, 5, 0)
                    task.wait(0.2)
                    interactWithItem(itemToCollect)
                    task.wait(0.5)
                end
            else
                print("ไม่พบไอเท็มในบริเวณจุดวาร์ป")
            end
            task.wait(1)
        end
        print("วนครบทุกจุดฟาร์มแล้ว กำลังเริ่มรอบใหม่...")
        task.wait(3)
    end
    print("AutoFarm หยุดทำงาน")
end

AutoFarmSection:NewToggle("AutoFarm", "เปิด/ปิดระบบฟาร์ม", function(state)
    if state then
        if not isFarming then
            print("เริ่ม AutoFarm")
            isFarming = true
            farmCoroutine = task.spawn(startFarmingLoop)
        end
    else
        print("หยุด AutoFarm")
        isFarming = false
        if farmCoroutine then
            task.cancel(farmCoroutine)
            farmCoroutine = nil
        end
    end
end)
