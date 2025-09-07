local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Luby Hub | Game Loader",
    LoadingTitle = "Luby Hub",
    LoadingSubtitle = "by Yuzuhaแฟนกู❤🎧"
})

local Tab = Window:CreateTab("Select Game", "gamepad-2")

Tab:CreateButton({
    Name = "Sakura Stand",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/LubyHub.lua"))()
    end
})

Tab:CreateButton({
    Name = "The Strongest Battlegrounds",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/Kikik.lua"))()
    end
})

Tab:CreateButton({
    Name = "Heroes Battlegrounds",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/HB.lua"))()
    end
})

Tab:CreateButton({
    Name = "Rider World",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/riderworld.lua"))()
    end
})
