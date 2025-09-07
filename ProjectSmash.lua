local allowedPlaceId = "15092647980"

if tostring(game.PlaceId) ~= allowedPlaceId then
    print("มึงหลอนไรรันแมพเหิ้ยนี้กูไม่ได้เขียนให้ใช้กับแมพนี้ ควย")
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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AutoFarm = false
local AutoM1 = false
local TargetPlayer = nil
local FallYThreshold = -10
local BehindDistance = 3

local M1Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("game"):WaitForChild("action"):WaitForChild("mouse1")

-- UI
local AutoFarmTab = Window:CreateTab("Auto Farm", "swords")

AutoFarmTab:CreateToggle({
    Name = "Auto Farm Player",
    CurrentValue = false,
    Flag = "AutoFarmNearest",
    Callback = function(Value)
        AutoFarm = Value
    end,
})

AutoFarmTab:CreateToggle({
    Name = "Auto M1",
    CurrentValue = false,
    Flag = "AutoM1",
    Callback = function(Value)
        AutoM1 = Value
    end,
})

AutoFarmTab:CreateSlider({
    Name = "Attack Distance",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "Stud",
    CurrentValue = BehindDistance,
    Flag = "BehindDistanceSlider",
    Callback = function(Value)
        BehindDistance = Value
    end,
})

-- หาเป้าหมายใกล้ที่สุด
local function GetNearestPlayer()
    local nearest = nil
    local shortestDistance = math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local localPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                nearest = player
            end
        end
    end
    return nearest
end

-- วาร์ปไปด้านหลังผู้เล่นพร้อมเช็คพื้น
local function FarmPlayer(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local targetHRP = player.Character.HumanoidRootPart
    local localHRP = LocalPlayer.Character.HumanoidRootPart

    local behindPos = targetHRP.Position - (targetHRP.CFrame.LookVector * BehindDistance)

    local rayOrigin = behindPos + Vector3.new(0, 50, 0)
    local rayDirection = Vector3.new(0, -100, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        behindPos = Vector3.new(behindPos.X, raycastResult.Position.Y + 3, behindPos.Z)
    else
        behindPos = behindPos + Vector3.new(0, 3, 0)
    end

    localHRP.CFrame = CFrame.new(behindPos, targetHRP.Position)
end

-- ฟังก์ชันยิง M1 Instant Interact
local function FireM1(targetHRP)
    if not targetHRP then return end
    local args = {
        true,
        tick() * math.random() -- สร้างค่าเปลี่ยนทุกครั้ง
    }
    M1Remote:FireServer(unpack(args))
end

-- Loop ฟาร์ม + M1
RunService.RenderStepped:Connect(function()
    if AutoFarm then
        if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("Humanoid") or TargetPlayer.Character.Humanoid.Health <= 0 then
            TargetPlayer = GetNearestPlayer()
            return
        end

        local targetHRP = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = TargetPlayer.Character:FindFirstChild("Humanoid")
        if not targetHRP or not targetHumanoid then return end

        -- วาร์ปซ้ำจนตกแมพ
        if targetHRP.Position.Y > FallYThreshold then
            FarmPlayer(TargetPlayer)
        end

        -- Auto M1 แบบ Instant Interact
        if AutoM1 then
            FireM1(targetHRP)
        end

        -- ถ้าเป้าหมายตกแมพหรือตาย → หาเป้าหมายใหม่
        if targetHRP.Position.Y < FallYThreshold or targetHumanoid.Health <= 0 then
            TargetPlayer = GetNearestPlayer()
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoAbility = false
local AbilityRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("game"):WaitForChild("action"):WaitForChild("ability")


AutoFarmTab:CreateToggle({
    Name = "Auto Ability",
    CurrentValue = false,
    Flag = "AutoAbility",
    Callback = function(Value)
        AutoAbility = Value
    end,
})

-- ตารางสกิลของตัวละครแต่ละตัว
local CharacterSkills = {
    "One",   -- ตัวอย่างสกิล 1
    "Two",   -- ตัวอย่างสกิล 2
    "Three", -- ตัวอย่างสกิล 3
    "Four"   -- ตัวอย่างสกิล 4
}

-- ฟังก์ชันสร้าง args แบบ dynamic
local function CreateAbilityArgs(skillName, character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local cam = workspace.CurrentCamera

    local vec = {
        lookVector = cam.CFrame.LookVector,
        mouseHit = cam.CFrame.Position + (cam.CFrame.LookVector * 10),
        floorMaterial = Enum.Material.Plastic,
        clientRootPos = hrp.Position,
        clientRootCFrame = hrp.CFrame,
        cameraLookVector = cam.CFrame.LookVector
    }

    local dynamicValue = tick() * math.random()

    return {
        skillName,
        true,  -- กดสกิลออกไปเลย
        vec,
        dynamicValue
    }
end

-- Loop Auto Skill หลายตัวละคร
RunService.RenderStepped:Connect(function()
    if AutoAbility then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                for _, skillName in ipairs(CharacterSkills) do
                    local args = CreateAbilityArgs(skillName, player.Character)
                    if args then
                        AbilityRemote:FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local NoKnockback = false
local MaxKnockback = 0.1 -- แทบไม่เด่นเลย

-- ================== UI ==================
local NoKnockbackTab = Window:CreateTab("Settings", "settings")

NoKnockbackTab:CreateToggle({
    Name = "No Knockback ",
    CurrentValue = false,
    Flag = "NoKnockbackToggle",
    Callback = function(Value)
        NoKnockback = Value
    end,
})

-- ================== ฟังก์ชัน ==================
local function PreventKnockback(humanoid)
    humanoid.StateChanged:Connect(function(_, new)
        if NoKnockback and (new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.FallingDown) then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

-- เรียกใช้สำหรับ Humanoid ปัจจุบัน
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    PreventKnockback(LocalPlayer.Character.Humanoid)
end

-- เรียกใช้ทุกครั้งที่ Character รีสปอว์
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    PreventKnockback(humanoid)
end)

-- ================== Loop ป้องกัน Knockback ==================
RunService.RenderStepped:Connect(function()
    if NoKnockback then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local vel = hrp.AssemblyLinearVelocity

            -- ถ้าแรงมากเกิน MaxKnockback ให้บล็อกแรง แต่ยังให้ MoveDirection ปกติ
            if vel.Magnitude > MaxKnockback then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local moveDir = humanoid.MoveDirection * humanoid.WalkSpeed
                    -- บล็อกแรง Knockback แต่ให้ตัวละครเดินตาม MoveDirection
                    hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X, vel.Y, moveDir.Z)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                else
                    hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
                end
            end
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local FreezeCharacter = false -- Toggle

NoKnockbackTab:CreateToggle({
    Name = "Freeze Character",
    CurrentValue = false,
    Flag = "FreezeCharacterToggle",
    Callback = function(Value)
        FreezeCharacter = Value
    end,
})

-- ================== Loop ป้องกันการเคลื่อนที่ ==================
RunService.RenderStepped:Connect(function()
    if FreezeCharacter then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if hrp and humanoid then
                -- ล็อกตำแหน่งกับ velocity
                local pos = hrp.Position
                hrp.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
                
                -- ป้องกันเดิน/กระโดด
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
            end
        end
    end
end)

-- ================== ป้องกันแรงจาก Force ต่าง ๆ ==================
RunService.Heartbeat:Connect(function()
    if FreezeCharacter then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, bf in pairs(hrp:GetChildren()) do
                    if bf:IsA("BodyForce") or bf:IsA("VectorForce") or bf:IsA("BodyVelocity") then
                        bf.Force = Vector3.new(0,0,0)
                        bf.Velocity = Vector3.new(0,0,0)
                    end
                end
            end
        end
    end
end)

-- ================== รีสปอว์ ==================
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    if FreezeCharacter then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- ================== ตั้งค่าเริ่มต้น ==================
local AimBotEnabled = false
local LockDistance = 50
local CircleSize = 50
local CircleColor = Color3.fromRGB(255,0,0)
local CrosshairSize = 10
local CrosshairColor = Color3.fromRGB(255,0,0)

-- ================== UI ==================
if not AimBotTab then
    AimBotTab = Window:CreateTab("AimBot", "target")
end

AimBotTab:CreateToggle({
    Name = "Enable AimBot",
    CurrentValue = false,
    Flag = "AimBotToggle",
    Callback = function(Value)
        AimBotEnabled = Value
        if Crosshair then
            Crosshair.Visible = Value
        end
    end
})

AimBotTab:CreateSlider({
    Name = "Lock Distance",
    Range = {10,200},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = LockDistance,
    Flag = "LockDistanceSlider",
    Callback = function(Value)
        LockDistance = Value
    end
})

AimBotTab:CreateSlider({
    Name = "Red Circle Size",
    Range = {20,150},
    Increment = 1,
    Suffix = " px",
    CurrentValue = CircleSize,
    Flag = "CircleSizeSlider",
    Callback = function(Value)
        CircleSize = Value
    end
})

-- ================== Crosshair ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimBotCrosshair"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Crosshair = Instance.new("Frame")
Crosshair.Size = UDim2.new(0,CrosshairSize,0,CrosshairSize)
Crosshair.Position = UDim2.new(0.5,-CrosshairSize/2,0.5,-CrosshairSize/2)
Crosshair.BackgroundColor3 = CrosshairColor
Crosshair.BorderSizePixel = 0
Crosshair.AnchorPoint = Vector2.new(0.5,0.5)
Crosshair.Visible = false
Crosshair.Parent = ScreenGui

-- ================== ฟังก์ชัน ==================
local function GetNearestPlayer()
    local nearest = nil
    local shortestDistance = math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local localPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            local headPos = player.Character.Head.Position
            local dist = (localPos - headPos).Magnitude
            if dist < shortestDistance and dist <= LockDistance then
                shortestDistance = dist
                nearest = player
            end
        end
    end
    return nearest
end

local function CreateHeadCircle(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    local existing = head:FindFirstChild("AimCircle")
    if existing then
        existing.Size = UDim2.new(0,CircleSize,0,CircleSize)
        return existing
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AimCircle"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,CircleSize,0,CircleSize)
    billboard.AlwaysOnTop = true

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = CircleColor
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = billboard

    billboard.Parent = head
    return billboard
end

local function RemoveHeadCircle(player)
    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        if head then
            local circle = head:FindFirstChild("AimCircle")
            if circle then circle:Destroy() end
        end
    end
end

-- ================== Loop หลัก ==================
RunService.RenderStepped:Connect(function()
    if AimBotEnabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = GetNearestPlayer()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    if player == target then
                        CreateHeadCircle(player)
                        if player.Character and player.Character:FindFirstChild("Head") and Camera then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, player.Character.Head.Position)
                        end
                    else
                        RemoveHeadCircle(player)
                    end
                end
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            RemoveHeadCircle(player)
        end
    end
end)
