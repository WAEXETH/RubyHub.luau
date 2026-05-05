local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local autoSpeed = false

task.spawn(function()
    while true do
        if autoSpeed then
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateSpeed"):FireServer("Walking")
        end
        task.wait(0)
    end
end)

local targetCFrame = CFrame.new(-14001.9141, 749.77887, 3067.99707)
local speed = 5
local autoFly = false

RunService.Stepped:Connect(function()
    if autoFly and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
bv.Velocity = Vector3.zero
bv.Parent = hrp

task.spawn(function()
    while true do
        if autoFly then
            repeat
                local direction = (targetCFrame.Position - hrp.Position).Unit
                bv.Velocity = direction * (50 * speed)
                task.wait()
            until (hrp.Position - targetCFrame.Position).Magnitude <= 5 or not autoFly
            hrp.CFrame = targetCFrame
            task.wait(0.5)
        else
            bv.Velocity = Vector3.zero
            task.wait(0.1)
        end
    end
end)

local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/aaaa"))()
local UI = GUI:CreateWindow("By:zazq_io","101010")
local Home = UI:addPage("Main",1,true,6)
Home:addToggle("Auto Farm",function(value) autoSpeed = value end)
Home:addToggle("Auto WINP",function(value) autoFly = value end)
