local allowedPlaceId = 10449761463

if game.PlaceId ~= allowedPlaceId then
    game.Players.LocalPlayer:Kick("This script can only be run in The strongest battlefield By zazq_io")
    return
end


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


local Tab = Window:CreateTab("Auto Farm Player", g1) 
local Section = Tab:CreateSection("Function")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local following = false
local followConnection
local currentTarget -- ผู้เล่นที่เราตามอยู่

-- ฟังก์ชันหาผู้เล่นที่ใกล้ที่สุด ยกเว้นตัวเอง
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local distance = (HRP.Position - targetHRP.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- ตรวจสอบว่าตัวละครยังอยู่ (ไม่ตาย)
local function isCharacterAlive(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- เริ่มติดตามผู้เล่น (อัปเดตเรื่อย ๆ)
local function startFollowing()
    if following then return end
    following = true

    followConnection = RunService.RenderStepped:Connect(function()
        -- รีเฟรชข้อมูลตัวละครของเรา
        Character = LocalPlayer.Character
        HRP = Character and Character:FindFirstChild("HumanoidRootPart")

        if not HRP then return end

        -- รีเฟรชเป้าหมาย
        if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") or not isCharacterAlive(currentTarget.Character) then
            currentTarget = getClosestPlayer()
        end

        -- ถ้ามีเป้าหมายอยู่และเรายังมีตัว
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = currentTarget.Character.HumanoidRootPart
            local backOffset = targetHRP.CFrame.LookVector * -2 -- อยู่ด้านหลัง 2 หน่วย
            local newPos = targetHRP.Position + backOffset
            HRP.CFrame = CFrame.new(newPos, targetHRP.Position)
        end
    end)

    -- ฟื้นคืนเมื่อเราตาย
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        HRP = Character:WaitForChild("HumanoidRootPart")
    end)
end


local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    following = false
    currentTarget = nil
end


Tab:CreateToggle({
   Name = "Auto Farm Player",
   CurrentValue = false,
   Flag = "SmartGluePlayer",
   Callback = function(Value)
       if Value then
           startFollowing()
       else
           stopFollowing()
       end
   end,
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local autoToolEnabled = false


local function activateToolsSequentially()
    while autoToolEnabled do
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then break end

        local tools = {}
        
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool)
            end
        end

       
        for _, tool in ipairs(tools) do
            if not autoToolEnabled then break end

            
            tool.Parent = LocalPlayer.Character
            task.wait(0.1)

            
            pcall(function()
                tool:Activate()
            end)

            task.wait(0.3) 

            
            tool.Parent = backpack
            task.wait(0.1)
        end

        task.wait(0.5) 
    end
end


Tab:CreateToggle({
    Name = "Auto Skill",
    CurrentValue = false,
    Flag = "AutoToolLoop",
    Callback = function(Value)
        autoToolEnabled = Value
        if Value then
            task.spawn(activateToolsSequentially)
        end
    end,
})


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local autoM1Enabled = false

local function autoM1Loop()
    while autoM1Enabled do
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Communicate") then
            local args = {
                {
                    Goal = "LeftClick"
                }
            }
            pcall(function()
                character.Communicate:FireServer(unpack(args))
            end)
        end
        task.wait(0.2) -- ปรับความเร็วได้ตามต้องการ
    end
end

Tab:CreateToggle({
    Name = "Auto M1 ",
    CurrentValue = false,
    Flag = "AutoM1Remote",
    Callback = function(Value)
        autoM1Enabled = Value
        if Value then
            task.spawn(autoM1Loop)
        end
    end,
})
