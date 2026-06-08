local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local VehiclesFolder = workspace:WaitForChild("Vehicles")

local function IsMyVehicle(vehicle)
    
    local owner = vehicle:FindFirstChild("Owner", true)
    if owner then
        if owner:IsA("StringValue") and owner.Value == LocalPlayer.Name then
            return true
        end

        if owner:IsA("ObjectValue") and owner.Value == LocalPlayer then
            return true
        end
    end

    
    local seat = vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
    if seat and seat.Occupant then
        local character = seat.Occupant.Parent
        local player = Players:GetPlayerFromCharacter(character)

        if player == LocalPlayer then
            return true
        end
    end

    return false
end

local function AddHighlight(vehicle)
    if not vehicle:IsA("Model") then
        return
    end

    if IsMyVehicle(vehicle) then
        return
    end

    if vehicle:FindFirstChild("VehicleHighlight") then
        return
    end

    local hl = Instance.new("Highlight")
    hl.Name = "VehicleHighlight"
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = vehicle
    hl.Parent = vehicle
end

for _, vehicle in ipairs(VehiclesFolder:GetChildren()) do
    AddHighlight(vehicle)
end

VehiclesFolder.ChildAdded:Connect(function(vehicle)
    task.wait(0.1)
    AddHighlight(vehicle)
end)
