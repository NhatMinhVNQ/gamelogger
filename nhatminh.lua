local Webhook_URL = "https://discord.com/api/webhooks/1280629278022828052/yTrB_Q62RHCJH0lB-5D-i5CueRVZkdQ3BqBFB21_W1oAmPcBzxj5DCcxFELiw67tUj8U"

local Headers = {
    ['Content-Type'] = 'application/json',
}

local data = {
    ["embeds"] = {
        {
            ["title"] = " <a:3160botdiscord:1259040301914259556> Someone Executed : [ WORLD HUB ]",
            ["description"] = "≫ [ Status Game ] ≪```\n  Executor : " .. identifyexecutor() .."``` ```Coming Soon...```",
            ["color"] = tonumber(0x7269da),
            ["fields"] = {
                {
                    ["name"] = "Game Name: ",
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