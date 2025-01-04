local encodedUrl = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTI4MDYyOTI3ODAyMjgyODA1Mi95VHJCL1E2MlJIQ0pIMGxCLTVELWk1Q3VlUlZaZGdRM0JxQkZCMjFfVzFvQW1QY0J6eGo1RENjeEZFTGl3Njd0VWo4VQ=="
local Webhook_URL = httpService:JSONDecode(httpService:Base64Decode(encodedUrl))
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- Headers cho Webhook
local Headers = { ['Content-Type'] = 'application/json' }

-- Tính FPS
local fps = 0
RunService.RenderStepped:Connect(function(deltaTime)
    fps = math.floor(1 / deltaTime)
end)

-- Lấy thông tin người chơi và trò chơi
local player = Players.LocalPlayer
local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
local executionTime = os.date("%Y-%m-%d %H:%M:%S")

-- Dữ liệu gửi đến Webhook
local data = {
    embeds = {
        {
            title = "<:utility12:1241906228972617788> **SOMEONE EXECUTED WSJ** <:emoji_30:1324920362961735790>",
            description = "discord.gg/psE8EUa9kg",
            color = tonumber(0x7269da),
            fields = {
                { name = "**[ GAME NAME ]**", value = "||" .. gameName .. "||", inline = true },
                { name = "**[ EXECUTOR ]**", value = "**__" .. identifyexecutor() .. "__**", inline = true },
                { name = "**[ FPS ]**", value = "**__" .. tostring(fps) .. "__**", inline = true },
                { name = "**[ EXECUTION TIME ]**", value = "**__" .. executionTime .. "__**", inline = true },
            }
        }
    }
}

-- Gửi request đến Discord Webhook
local request = http_request or request or HttpPost or syn.request
request({
    Url = Webhook_URL,
    Body = HttpService:JSONEncode(data),
    Method = "POST",
    Headers = Headers
})
