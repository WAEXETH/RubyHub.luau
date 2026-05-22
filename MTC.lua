local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local VehicleESPs = {}
local PlayerESPs = {}

local VehicleFolder = workspace:WaitForChild("SpawnedVehicles")
local PlayerFolder = workspace:WaitForChild("SpawnedPlayers")

local Settings = {
    VehicleESP = false,
    VehicleColor = Color3.fromRGB(255, 0, 0),
    VehicleFill = false,
    VehicleFillTransparency = 0.7,
    VehicleName = true,

    PlayerESP = false,
    PlayerColor = Color3.fromRGB(0, 200, 255),
    PlayerFill = false,
    PlayerFillTransparency = 0.7,
    PlayerName = true,

    -- AIMBOT
    AimEnabled = false,
    AimFOV = 150,
    AimSmoothness = 0.15,
    ShowFOV = true,
}

-- FOV CIRCLE
local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Color = Color3.fromRGB(255,255,255)
Circle.Thickness = 1
Circle.NumSides = 100
Circle.Radius = Settings.AimFOV
Circle.Filled = false
Circle.Transparency = 1

local function GetClosestPlayer()
	local Closest = nil
	local ClosestDistance = Settings.AimFOV

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local character = player.Character

			if character then
				local head = character:FindFirstChild("Head")
				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if head and humanoid and humanoid.Health > 0 then
					local screenPos, visible = Camera:WorldToViewportPoint(head.Position)

					if visible then
						local mousePos = Vector2.new(
                            Camera.ViewportSize.X / 2,
                            Camera.ViewportSize.Y / 2
                        )

						local distance = (
                            Vector2.new(screenPos.X, screenPos.Y) - mousePos
                        ).Magnitude

						if distance < ClosestDistance then
							ClosestDistance = distance
							Closest = head
						end
					end
				end
			end
		end
	end

	return Closest
end

local function CreateVehicleESP(obj)
    if VehicleESPs[obj] then return end

    local espPart, size

    if obj:IsA("Model") then
        local cf, s = obj:GetBoundingBox()
        size = s

        espPart = Instance.new("Part")
        espPart.Name = "ESPPart"
        espPart.Anchored = true
        espPart.CanCollide = false
        espPart.Transparency = 1
        espPart.Size = s
        espPart.CFrame = cf
        espPart.Parent = workspace

    elseif obj:IsA("BasePart") then
        size = obj.Size
        espPart = obj
    else
        return
    end

    local box = Instance.new("Highlight")
    box.Name = "VehicleESP"
    box.Adornee = obj
    box.FillTransparency = Settings.VehicleFill and Settings.VehicleFillTransparency or 1
    box.OutlineTransparency = 0
    box.OutlineColor = Settings.VehicleColor
    box.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    box.Parent = game:GetService("CoreGui")

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPName"
    billboard.Adornee = espPart
    billboard.Size = UDim2.new(0, 120, 0, 20)
    billboard.StudsOffset = Vector3.new(0, size.Y / 2 + 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.VehicleName
    billboard.Parent = espPart

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = obj.Name
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextStrokeTransparency = 0
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.Parent = billboard

    VehicleESPs[obj] = {
        Part = espPart,
        Highlight = box,
        Gui = billboard
    }
end

local function RemoveVehicleESP(obj)
    local data = VehicleESPs[obj]

    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Gui then data.Gui:Destroy() end
        if data.Part and data.Part.Name == "ESPPart" then
            data.Part:Destroy()
        end

        VehicleESPs[obj] = nil
    end
end

local function ClearAllVehicleESP()
    for obj in pairs(VehicleESPs) do
        RemoveVehicleESP(obj)
    end
end

local function CreatePlayerESP(obj)
    if PlayerESPs[obj] then return end

    local espPart, size

    if obj:IsA("Model") then
        local cf, s = obj:GetBoundingBox()
        size = s

        espPart = Instance.new("Part")
        espPart.Name = "ESPPart"
        espPart.Anchored = true
        espPart.CanCollide = false
        espPart.Transparency = 1
        espPart.Size = s
        espPart.CFrame = cf
        espPart.Parent = workspace

    elseif obj:IsA("BasePart") then
        size = obj.Size
        espPart = obj
    else
        return
    end

    local box = Instance.new("Highlight")
    box.Name = "PlayerESP"
    box.Adornee = obj
    box.FillTransparency = Settings.PlayerFill and Settings.PlayerFillTransparency or 1
    box.OutlineTransparency = 0
    box.OutlineColor = Settings.PlayerColor
    box.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    box.Parent = game:GetService("CoreGui")

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPName"
    billboard.Adornee = espPart
    billboard.Size = UDim2.new(0, 120, 0, 20)
    billboard.StudsOffset = Vector3.new(0, size.Y / 2 + 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.PlayerName
    billboard.Parent = espPart

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = obj.Name
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextStrokeTransparency = 0
    text.TextScaled = false
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.Parent = billboard

    PlayerESPs[obj] = {
        Part = espPart,
        Highlight = box,
        Gui = billboard
    }
end

local function RemovePlayerESP(obj)
    local data = PlayerESPs[obj]

    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Gui then data.Gui:Destroy() end
        if data.Part and data.Part.Name == "ESPPart" then
            data.Part:Destroy()
        end

        PlayerESPs[obj] = nil
    end
end

local function ClearAllPlayerESP()
    for obj in pairs(PlayerESPs) do
        RemovePlayerESP(obj)
    end
end

VehicleFolder.ChildAdded:Connect(function(v)
    task.wait(0.2)

    if Settings.VehicleESP then
        CreateVehicleESP(v)
    end
end)

VehicleFolder.ChildRemoved:Connect(function(v)
    RemoveVehicleESP(v)
end)

PlayerFolder.ChildAdded:Connect(function(v)
    task.wait(0.2)

    if Settings.PlayerESP then
        CreatePlayerESP(v)
    end
end)

PlayerFolder.ChildRemoved:Connect(function(v)
    RemovePlayerESP(v)
end)

RunService.RenderStepped:Connect(function()

    local center = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )

    Circle.Position = center
    Circle.Visible = Settings.ShowFOV
    Circle.Radius = Settings.AimFOV

    
    if Settings.AimEnabled then
        local target = GetClosestPlayer()

        if target then
            local targetCF = CFrame.new(
                Camera.CFrame.Position,
                target.Position
            )

            Camera.CFrame = Camera.CFrame:Lerp(
                targetCF,
                Settings.AimSmoothness
            )
        end
    end

    
    if Settings.VehicleESP then
        for obj, data in pairs(VehicleESPs) do
            if obj and obj.Parent then
                if obj:IsA("Model") and data.Part then
                    local cf, size = obj:GetBoundingBox()

                    data.Part.CFrame = cf
                    data.Part.Size = size

                    if data.Gui then
                        data.Gui.StudsOffset = Vector3.new(
                            0,
                            size.Y / 2 + 2,
                            0
                        )
                    end
                end
            else
                RemoveVehicleESP(obj)
            end
        end

        for _, v in ipairs(VehicleFolder:GetChildren()) do
            if not VehicleESPs[v] then
                CreateVehicleESP(v)
            end
        end
    end

   
    if Settings.PlayerESP then
        for obj, data in pairs(PlayerESPs) do
            if obj and obj.Parent then
                if obj:IsA("Model") and data.Part then
                    local cf, size = obj:GetBoundingBox()

                    data.Part.CFrame = cf
                    data.Part.Size = size

                    if data.Gui then
                        data.Gui.StudsOffset = Vector3.new(
                            0,
                            size.Y / 2 + 2,
                            0
                        )
                    end
                end
            else
                RemovePlayerESP(obj)
            end
        end

        for _, v in ipairs(PlayerFolder:GetChildren()) do
            if not PlayerESPs[v] then
                CreatePlayerESP(v)
            end
        end
    end
end)


local Window = Fluent:CreateWindow({
    Title = "MTC",
    SubTitle = "By zazq_io",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Vehicle = Window:AddTab({ Title = "Vehicle ESP", Icon = "car" }),
    Player  = Window:AddTab({ Title = "Player ESP", Icon = "user" }),
    Aimbot  = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options


local VehicleToggle = Tabs.Vehicle:AddToggle("VehicleESP", {
    Title = "Enable Vehicle ESP",
    Default = false
})

VehicleToggle:OnChanged(function()
    Settings.VehicleESP = Options.VehicleESP.Value

    if Settings.VehicleESP then
        for _, v in ipairs(VehicleFolder:GetChildren()) do
            CreateVehicleESP(v)
        end
    else
        ClearAllVehicleESP()
    end
end)

local VehicleColorPicker = Tabs.Vehicle:AddColorpicker("VehicleColor", {
    Title = "Outline Color",
    Default = Color3.fromRGB(255, 0, 0)
})

VehicleColorPicker:OnChanged(function()
    Settings.VehicleColor = VehicleColorPicker.Value

    for _, data in pairs(VehicleESPs) do
        if data.Highlight then
            data.Highlight.OutlineColor = Settings.VehicleColor
        end
    end
end)

local VehicleFillToggle = Tabs.Vehicle:AddToggle("VehicleFill", {
    Title = "Enable Fill",
    Default = false
})

VehicleFillToggle:OnChanged(function()
    Settings.VehicleFill = Options.VehicleFill.Value

    for _, data in pairs(VehicleESPs) do
        if data.Highlight then
            data.Highlight.FillTransparency =
                Settings.VehicleFill and
                Settings.VehicleFillTransparency or 1
        end
    end
end)

Tabs.Vehicle:AddSlider("VehicleFillTransparency", {
    Title = "Fill Transparency",
    Default = 7,
    Min = 0,
    Max = 10,
    Rounding = 0,

    Callback = function(Value)
        Settings.VehicleFillTransparency = Value / 10

        if Settings.VehicleFill then
            for _, data in pairs(VehicleESPs) do
                if data.Highlight then
                    data.Highlight.FillTransparency =
                        Settings.VehicleFillTransparency
                end
            end
        end
    end
})

local VehicleNameToggle = Tabs.Vehicle:AddToggle("VehicleName", {
    Title = "Show Name Label",
    Default = true
})

VehicleNameToggle:OnChanged(function()
    Settings.VehicleName = Options.VehicleName.Value

    for _, data in pairs(VehicleESPs) do
        if data.Gui then
            data.Gui.Enabled = Settings.VehicleName
        end
    end
end)


local PlayerToggle = Tabs.Player:AddToggle("PlayerESP", {
    Title = "Enable Player ESP",
    Default = false
})

PlayerToggle:OnChanged(function()
    Settings.PlayerESP = Options.PlayerESP.Value

    if Settings.PlayerESP then
        for _, v in ipairs(PlayerFolder:GetChildren()) do
            CreatePlayerESP(v)
        end
    else
        ClearAllPlayerESP()
    end
end)

local PlayerColorPicker = Tabs.Player:AddColorpicker("PlayerColor", {
    Title = "Outline Color",
    Default = Color3.fromRGB(0, 200, 255)
})

PlayerColorPicker:OnChanged(function()
    Settings.PlayerColor = PlayerColorPicker.Value

    for _, data in pairs(PlayerESPs) do
        if data.Highlight then
            data.Highlight.OutlineColor = Settings.PlayerColor
        end
    end
end)

local PlayerFillToggle = Tabs.Player:AddToggle("PlayerFill", {
    Title = "Enable Fill",
    Default = false
})

PlayerFillToggle:OnChanged(function()
    Settings.PlayerFill = Options.PlayerFill.Value

    for _, data in pairs(PlayerESPs) do
        if data.Highlight then
            data.Highlight.FillTransparency =
                Settings.PlayerFill and
                Settings.PlayerFillTransparency or 1
        end
    end
end)

Tabs.Player:AddSlider("PlayerFillTransparency", {
    Title = "Fill Transparency",
    Default = 7,
    Min = 0,
    Max = 10,
    Rounding = 0,

    Callback = function(Value)
        Settings.PlayerFillTransparency = Value / 10

        if Settings.PlayerFill then
            for _, data in pairs(PlayerESPs) do
                if data.Highlight then
                    data.Highlight.FillTransparency =
                        Settings.PlayerFillTransparency
                end
            end
        end
    end
})

local PlayerNameToggle = Tabs.Player:AddToggle("PlayerName", {
    Title = "Show Name Label",
    Default = true
})

PlayerNameToggle:OnChanged(function()
    Settings.PlayerName = Options.PlayerName.Value

    for _, data in pairs(PlayerESPs) do
        if data.Gui then
            data.Gui.Enabled = Settings.PlayerName
        end
    end
end)


local AimToggle = Tabs.Aimbot:AddToggle("AimEnabled", {
    Title = "Enable Aimbot",
    Default = false
})

AimToggle:OnChanged(function()
    Settings.AimEnabled = Options.AimEnabled.Value
end)

Tabs.Aimbot:AddSlider("AimFOV", {
    Title = "FOV Radius",
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,

    Callback = function(Value)
        Settings.AimFOV = Value
    end
})

Tabs.Aimbot:AddSlider("AimSmoothness", {
    Title = "Smoothness",
    Default = 15,
    Min = 1,
    Max = 100,
    Rounding = 0,

    Callback = function(Value)
        Settings.AimSmoothness = Value / 100
    end
})

local ShowFOVToggle = Tabs.Aimbot:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Default = true
})

ShowFOVToggle:OnChanged(function()
    Settings.ShowFOV = Options.ShowFOV.Value
end)


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("ESPMenu")
SaveManager:SetFolder("ESPMenu/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Menu loaded!",
    Content = "Script loaded!",
    Duration = 6
})

SaveManager:LoadAutoloadConfig()
