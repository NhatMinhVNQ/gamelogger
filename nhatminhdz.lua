local Webhook_URL = "https://discord.com/api/webhooks/1250092636962820156/w-0KF2jXvXIo8XdJWXIJVaqPnKbXeZzONo6-iJLJA1Nw2xdVme9DMMbqUzxqbInNcvsh"

local Headers = {
    ['Content-Type'] = 'application/json',
}

local data = {
    ["embeds"] = {
        {
            ["title"] = "<a:3160botdiscord:1259040301914259556> Someone Executed : [ WORLD HUB ]",
            ["description"] = " UserName: "..  game.Players.LocalPlayer.Name,
            ["type"] = "rich",
            ["color"] = tonumber(0xffffff),
            ["fields"] = {
                {
                    ["name"] = "Game Name :",
                    ["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
                    ["inline"] = true,
                },
            },
        },
    },
}

local PlayerData = game:GetService('HttpService'):JSONEncode(data)

local Request = http_request or request or HttpPost or syn.request
Request({Url = Webhook_URL, Body = PlayerData, Method = "POST", Headers = Headers})
