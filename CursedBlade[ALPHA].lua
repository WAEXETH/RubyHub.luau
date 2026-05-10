local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Cursed Blade[ALPHA]",
    SubTitle = "by zazq_io",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "sword" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")


local skillLoop = nil
local followConnection = nil
local noclipConnection = nil

local bodyPosition = nil
local bodyGyro = nil

local function fireAllSkills(character, hrp)
    local netMessage = character:FindFirstChild("NetMessage")
    if not netMessage then return end

    for _, remote in ipairs(netMessage:GetChildren()) do
        if remote.Name == "TrigerSkill" and remote:IsA("RemoteEvent") then
            local args = {
                101,
                "Enter",
                hrp.CFrame,
                1
            }
            pcall(function()
                remote:FireServer(unpack(args))
            end)
        end
    end
end

local function startSkillLoop()
    skillLoop = task.spawn(function()
        while Options.SkillToggle.Value do
            local char = player.Character
            if char then
                local hrp2 = char:FindFirstChild("HumanoidRootPart")
                if hrp2 then
                    fireAllSkills(char, hrp2)
                end
            end
            task.wait(0.1)
        end
    end)
end

local function stopSkillLoop()
    if skillLoop then
        task.cancel(skillLoop)
        skillLoop = nil
    end
end

local function startNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end


local followHeight = 10 

local function findNearestTarget()
    local entity = workspace:FindFirstChild("Entity")
    if not entity then return nil end

    local char = player.Character
    local hrpNow = char and char:FindFirstChild("HumanoidRootPart")
    if not hrpNow then return nil end

    local nearest = nil
    local minDist = math.huge

    for _, mob in ipairs(entity:GetChildren()) do
        if mob.Name == "1000" then
            local mobHumanoid = mob:FindFirstChildOfClass("Humanoid")
            if mobHumanoid and mobHumanoid.Health > 0 then
                local mobPart = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                if mobPart then
                    local dist = (hrpNow.Position - mobPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = mob
                    end
                end
            end
        end
    end

    return nearest
end

local function startFollow()
    local char = player.Character
    if not char then return end
    local hrpNow = char:FindFirstChild("HumanoidRootPart")
    if not hrpNow then return end

    bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPosition.P = 10000
    bodyPosition.Parent = hrpNow

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.Parent = hrpNow

    startNoclip()

    followConnection = RunService.Heartbeat:Connect(function()
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end

        if not bodyPosition or not bodyPosition.Parent then return end
        if not bodyGyro or not bodyGyro.Parent then return end

        local target = findNearestTarget()
        if target then
            local targetPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                bodyPosition.Position = targetPart.Position + Vector3.new(0, followHeight, 0)
                bodyGyro.CFrame = CFrame.new(h.Position, targetPart.Position)
            end
        else
            bodyPosition.Position = h.Position
        end
    end)
end

local function stopFollow()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    stopNoclip()
    if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end


local HeightSlider = Tabs.Main:AddSlider("HeightSlider", {
    Title = "Distance",
    Description = "ปรับความระยะ",
    Default = 10,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        followHeight = Value
    end
})


do

    local SkillToggle = Tabs.Main:AddToggle("SkillToggle", {
        Title = "Auto M1",
        Description = "ตีออโต้",
        Default = false
    })

    SkillToggle:OnChanged(function()
        if Options.SkillToggle.Value then
            
            startSkillLoop()
        else
            
            stopSkillLoop()
        end
    end)

    
    local FollowToggle = Tabs.Main:AddToggle("FollowToggle", {
        Title = "Level Farm",
        Description = "ฟาร๋มเวล",
        Default = false
    })

    FollowToggle:OnChanged(function()
        if Options.FollowToggle.Value then
           
            startFollow()
        else
            
            stopFollow()
        end
    end)
end

local BLACKLIST = {
    ["\228\188\160\233\128\129\233\151\168\231\148\159\230\136\144"] = true
}

local WHITELIST = {
    ["Default"] = true,
    ["Fort Stone"] = true,
    ["EmblStlBelt"] = true,
    ["SpkLayBoots"] = true,
    ["HrnIrnHelm"] = true,
    ["CrmGrdChest"] = true,
} 

local function teleportToNearestFX()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local fx = workspace:FindFirstChild("FX")
    if not fx then
        warn("ไม่พบ workspace.FX")
        return
    end

    local nearest = nil
    local minDist = math.huge

    for _, item in ipairs(fx:GetChildren()) do
       
        if WHITELIST[item.Name] and not BLACKLIST[item.Name] then
            local part = nil
            if item:IsA("BasePart") then
                part = item
            elseif item:IsA("Model") then
                part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            end

            if part then
                local dist = (hrp.Position - part.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = part
                end
            end
        end
    end

    if nearest then
        hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 5, 0))
        
    else
       
    end
end


local fxLoop = nil

local FXToggle = Tabs.Main:AddToggle("FXToggle", {
    Title = "Auto Item",
    Description = "เก็บไอเทม",
    Default = false
})

FXToggle:OnChanged(function()
    if Options.FXToggle.Value then
       
        fxLoop = task.spawn(function()
            while Options.FXToggle.Value do
                teleportToNearestFX()
                task.wait(1)
            end
        end)
    else
        
        if fxLoop then
            task.cancel(fxLoop)
            fxLoop = nil
        end
    end
end)


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("MonsterScript")
SaveManager:SetFolder("MonsterScript/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Script",
    Content = "โหลดสำเร็จ",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
