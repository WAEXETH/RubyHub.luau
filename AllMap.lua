local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "RubyHub | Map Selector",
    LoadingTitle = "RubyHub Loader",
    LoadingSubtitle = "Select Map",
    ConfigurationSaving = {
        Enabled = false
    }
})


local Maps = {
    ["Sakura Stand"] = {
        url = "https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/Test.lua",
        status = "ready"
    },
    ["Rider World"] = {
        url = "https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/riderworld.lua",
        status = "ready"
    },
    ["The Strongest Battlegrounds"] = {
        url = "https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/Kikik.lua",
        status = "ready"
    },
    ["Project Smash"] = {
        url = "https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/ProjectSmash.lua",
        status = "ready"
    },
    ["Heroes Battlegrounds"] = {
        url = "https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/refs/heads/main/HB.lua",
        status = "ready"
    },
    ["Jujutsu Shenanigans"] = {
        status = "dev"
    }
}


local Tab = Window:CreateTab("Map Select", "map")
local Section = Tab:CreateSection("Choose Your Game")


for mapName, data in pairs(Maps) do
    Tab:CreateButton({
        Name = mapName,
        Callback = function()
            if data.status == "dev" then
                Rayfield:Notify({
                    Title = "🚧 Coming Soon",
                    Content = mapName .. " กำลังพัฒนาอยู่",
                    Duration = 5
                })
                return
            end

            Rayfield:Notify({
                Title = "✅ Loading",
                Content = "กำลังโหลด " .. mapName,
                Duration = 3
            })

            loadstring(game:HttpGet(data.url))()
        end
    })
end
