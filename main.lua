local HttpService = game:GetService("HttpService")
local http_request = syn and syn.request or http and http.request or http_request or request or httprequest
local Webhook_URL = "https://ptb.discord.com/api/webhooks/1269712358607945810/LKTMDMpw31-LnByV_sn9HD056xsaWY_bsdLDCi0nojto_7wK9W-E4Nna3wvR5DRFcoCL"

local lastItemName = ""

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
                ["title"] = messageType == "fruit" and "🍎  **Nova fruta armazenada!**" or messageType == "destroyed" and "💣  **Fruta destruída!**" or "🍎  **Novo item na hotbar!**",
                ["description"] = messageType == "fruit" and "> ➜ Fruta armazenada: " .. itemName .. "\n> ➜ Jogador: " .. playerName or messageType == "destroyed" and "> ➜ Fruta destruída: " .. itemName .. "\n> ➜ Jogador: " .. playerName or "> ➜ Item no terceiro slot: " .. itemName,
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

local function hasDesiredFruit(backpack)
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
    
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and table.find(desiredFruits, item.Name) then
            return true
        end
    end
    return false
end

-- Anti-AFK Code
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Script Base
repeat wait() until game:IsLoaded and (game.Players.LocalPlayer or game.Players.PlayerAdded:Wait()) and (game.Players.LocalPlayer.Character or game.Players.CharacterAdded:Wait())
if getgenv().Ran then 
    return
else
    getgenv().Ran = true
end

if game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Main", 9e9):FindFirstChild("ChooseTeam") then
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
    wait(3)
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
            if hasDesiredFruit(backpack) then
                print(fruit)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruit:GetAttribute("OriginalName"), fruit)
                sendToDiscord(fruit.Name, "fruit", plr.Name)
            else
                fruit:Destroy()
                sendToDiscord(fruit.Name, "destroyed", plr.Name)
            end
        end
    end
end

print('nope')
local currentJobId = game.JobId

repeat
    task.spawn(pcall, function()
        local success = false
        repeat
            local teleportSuccess, errorMessage = pcall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer, game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer(math.random(1, 2000))[math.random(1, 2000)])
            end)
            if teleportSuccess then
                success = true
            else
                warn("Teleport falhou, tentando novamente... Erro: " .. errorMessage)
                wait(2) -- Espera 2 segundos antes de tentar novamente
            end
        until success
    end)
    wait(2)
until game.JobId ~= currentJobId

-- Monitorar o terceiro item na hotbar
while true do
    local thirdItem = getThirdSlotItemName(plr)
    
    if thirdItem then
        if thirdItem.Name ~= lastItemName then
            sendToDiscord(thirdItem.Name, "hotbar", plr.Name)
            lastItemName = thirdItem.Name
        end
    end

    wait(0.25)
end
