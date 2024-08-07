game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Script carregado",
    Text = "V5.1 | Infinite Waiting Fix",
})

local HttpService = game:GetService("HttpService")
local http_request = syn and syn.request or http and http.request or http_request or request or httprequest
local Webhook_URL = "https://ptb.discord.com/api/webhooks/1269712358607945810/LKTMDMpw31-LnByV_sn9HD056xsaWY_bsdLDCi0nojto_7wK9W-E4Nna3wvR5DRFcoCL"

local lastItemName = ""

local desiredFruits = {
    "Magma Fruit",
    "Quake Fruit",
    "Human: Buddha Fruit",
    "Love Fruit",
    "Spider Fruit",
    "Sound Fruit",
    "Bird: Phoenix Fruit",
    "Portal Fruit",
    "Pain Fruit",
    "Blizzard Fruit",
    "Gravity Fruit",
    "Ice Fruit",
    "Mammoth Fruit",
    "Dough Fruit",
    "Shadow Fruit",
    "Venom Fruit",
    "Control Fruit",
    "Dark Fruit",
    "Spirit Fruit",
    "Dragon Fruit",
    "Leopard Fruit"
}

local function deleteLocalScripts()
    for _, object in pairs(game:GetService("Workspace"):GetDescendants()) do
        if object:IsA("LocalScript") and object.Name == "Movement + Swim" then
            print("Removendo LocalScript: ", object:GetFullName())
            object:Destroy()
        end
    end
    print("Water removida!")
end

deleteLocalScripts()



local function sendToDiscord(itemName, messageType, playerName)
    local currentTime = os.date("%Y-%m-%d  ---  %H:%M:%S")
    local response = http_request({
        Url = Webhook_URL,
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = HttpService:JSONEncode({
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = messageType == "fruit" and "🎉  **Nova fruta encontrada e armazenada com sucesso!**" or messageType == "destroyed" and "❌  **Fruta não desejada destruída.**" or "🍎  **Novo item na hotbar!**",
                ["description"] = messageType == "fruit" and "> ➜ Fruta encontrada: " .. itemName .. "\n> ➜ Instância que armazenou: " .. playerName or messageType == "destroyed" and "> ➜ Fruta não desejada: " .. itemName .. "\n> ➜ Instância que destruiu: " .. playerName or "> ➜ Item no terceiro slot: " .. itemName,
                ["type"] = "rich",
                ["color"] = tonumber(0xffffff),
                ["fields"] = {
                    {
                        ["name"] = "Horário:",
                        ["value"] = "> " .. currentTime,
                        ["inline"] = true
                    }
                }
            }}
        })
    })
end

local function sendNoFruitFoundNotification(serverId)
    local currentTime = os.date("%Y-%m-%d  ---  %H:%M:%S")
    local response = http_request({
        Url = Webhook_URL,
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = HttpService:JSONEncode({
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "🚫  **Nenhuma fruta desejada encontrada.**",
                ["description"] = "> ➜ Servidor: " .. serverId .. "\n> ➜ Horário: " .. currentTime .. "\n> ➜ Instância: " .. game.Players.LocalPlayer.Name,
                ["type"] = "rich",
                ["color"] = tonumber(0xff0000),
                ["fields"] = {
                    {
                        ["name"] = "Detalhes:",
                        ["value"] = "> Nenhuma fruta desejada foi encontrada no servidor especificado, a instância trocou de servidor.",
                        ["inline"] = false
                    }
                }
            }}
        })
    })
end

local function sendErrorNotification(errorMessage)
    local currentTime = os.date("%Y-%m-%d  ---  %H:%M:%S")
    local response = http_request({
        Url = Webhook_URL,
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = HttpService:JSONEncode({
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "🚨  **Erro ao armazenar fruta**",
                ["description"] = "> ➜ Erro: " .. errorMessage .. "\n> ➜ Horário: " .. currentTime .. "\n> ➜ Instância: " .. game.Players.LocalPlayer.Name,
                ["type"] = "rich",
                ["color"] = tonumber(0xff0000),
                ["fields"] = {
                    {
                        ["name"] = "Detalhes:",
                        ["value"] = "> Erro detectado ao tentar armazenar uma fruta. A fruta será destruída e o servidor será trocado se não houver mais frutas.",
                        ["inline"] = false
                    }
                }
            }}
        })
    })
end

if game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Main", 9e9):FindFirstChild("ChooseTeam") then
    game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Visible = not game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Visible
    game.workspace.CurrentCamera:Destroy()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
    wait(3)
end

local function isFruit(itemName)
    return itemName:find("Fruit") ~= nil
end

local function isDesiredFruit(itemName)
    return table.find(desiredFruits, itemName) ~= nil
end

local function getThirdSlotItemName(player)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        local tools = backpack:GetChildren()
        if #tools >= 3 then
            return tools[3]
        end
    end
    return nil
end

local function monitorBackpack()
    local plr = game.Players.LocalPlayer
    while true do
        if plr.Backpack then
            for _, item in ipairs(plr.Backpack:GetChildren()) do
                if item:IsA("Tool") and isFruit(item.Name) and not isDesiredFruit(item.Name) then
                    sendToDiscord(item.Name, "destroyed", plr.Name)
                    item:Destroy()
                end
            end
        end
        wait(0.25)
    end
end

local function teleportToServer()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"

    local _place = game.PlaceId
    local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"

    local function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        return Http:JSONDecode(Raw)
    end

    local Server, Next
    repeat
        local Servers = ListServers(Next)
        Server = Servers.data[1]
        Next = Servers.nextPageCursor
    until Server

    local success
    repeat
        success, errorMessage = pcall(function()
            TPS:TeleportToPlaceInstance(_place, Server.id, game.Players.LocalPlayer)
        end)
        if not success then
            warn("❌ Teleport falhou, tentando novamente... Erro: " .. errorMessage)
            if errorMessage:find("unauthorized") or errorMessage:find("not found") then
                wait(1)
            else
                wait(2)
            end
        end
    until success
end

local function checkForError()
    local player = game.Players.LocalPlayer
    local notifications = player.PlayerGui:FindFirstChild("Notifications")
    if notifications then
        local errorTextLabel = notifications:FindFirstChild("NotificationTemplate") and notifications.NotificationTemplate:FindFirstChild("TranslateMe")
        if errorTextLabel and errorTextLabel.Text:match("{color1_Red}You can only store 1 of each Blox Fruit.{color1_/}") then
            sendErrorNotification("Você pode armazenar apenas 1 de cada Blox Fruit.")
            local backpack = player.Backpack
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and isFruit(item.Name) then
                    item:Destroy()
                end
            end
            wait(1)
            teleportToServer()
        end
    end
end

local function monitorForHandle()
    while true do
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Fruit") and (v:IsA("Tool") or v:IsA("Model")) then
                local fruitHandle = v:FindFirstChild("Handle")
                if not fruitHandle then
                    sendToDiscord(v.Name, "error", game.Players.LocalPlayer.Name)
                    teleportToServer()
                    break
                end
            end
        end
        wait(2)
    end
end

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--local function waitForGameToLoad()
--    local player = game.Players.LocalPlayer
--    repeat
--        wait(1)
--    until player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.PlayerGui:FindFirstChild("Main")
--end

--waitForGameToLoad()

if getgenv().Ran then 
    return
else
    getgenv().Ran = true
end

local plr = game.Players.LocalPlayer
local chr = plr.Character
local t = game.TweenService

local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1/0, 1/0, 1/0)
bv.Velocity = Vector3.new()
bv.Name = "bV"
local bav = Instance.new("BodyAngularVelocity")
bav.AngularVelocity = Vector3.new()
bav.MaxTorque = Vector3.new(1/0, 1/0, 1/0)
bav.Name = "bAV"

local foundFruit = false

for _,v in next, workspace:GetChildren() do
    if v.Name:find("Fruit") and (v:IsA("Tool") or v:IsA("Model")) then
        repeat
            local anc1 = bv:Clone()
            anc1.Parent = chr.HumanoidRootPart
            local anc2 = bav:Clone()
            anc2.Parent = chr.HumanoidRootPart
            local p = t:Create(chr.HumanoidRootPart, TweenInfo.new((plr:DistanceFromCharacter(v.Handle.Position)-100)/320, Enum.EasingStyle.Linear), {CFrame = v.Handle.CFrame + Vector3.new(0, v.Handle.Size.Y, 0)})
            p:Play()
            p.Completed:Wait()
            chr.HumanoidRootPart.CFrame = v.Handle.CFrame
            anc1:Destroy()
            anc2:Destroy()
            wait(1)
        until v.Parent ~= workspace
        wait(1)
        local fruit = chr:FindFirstChildOfClass("Tool") and chr:FindFirstChildOfClass("Tool").Name:find("Fruit") and chr:FindFirstChildOfClass("Tool") or (function()
            for _, fr in plr.Backpack:GetChildren() do
                if fr.Name:find("Fruit") then
                    return fr
                end
            end
        end)()
        if fruit then
            local backpack = plr.Backpack
            if isDesiredFruit(fruit.Name) then
                print(fruit)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruit:GetAttribute("OriginalName"), fruit)
                sendToDiscord(fruit.Name, "fruit", plr.Name)
                foundFruit = true
            else
                fruit:Destroy()
                sendToDiscord(fruit.Name, "destroyed", plr.Name)
            end
        end
    end
end

if not foundFruit then
    local serverId = game.JobId
    sendNoFruitFoundNotification(serverId)
    teleportToServer()
end

local function monitorAndCheck()
    while true do
        monitorBackpack()
        checkForError()
        wait(0.5)
    end
end

monitorAndCheck()
monitorForHandle()
wait(180)
teleportToServer()
