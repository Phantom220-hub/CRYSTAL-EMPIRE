local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local Services = ServerScriptService:WaitForChild("Services")
local DataService = require(Services:WaitForChild("DataService"))
local WorldService = require(Services:WaitForChild("WorldService"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local function getOrCreateRemote(name)
    local remote = remotes:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = remotes
    end
    return remote
end

local updateHUD = getOrCreateRemote("UpdateHUD")
local notify = getOrCreateRemote("Notify")
local mineRequest = getOrCreateRemote("MineRequest")

local sellPrompt, upgradePrompt = WorldService.Build()
local lastMine = {}

local function sync(player)
    local data = DataService.Get(player)
    if not data then return end
    updateHUD:FireClient(player, {
        Coins = data.Coins,
        Crystals = data.Crystals,
        Capacity = data.Capacity,
        Power = data.Power,
        UpgradeLevel = data.UpgradeLevel,
    })
end

local function setupLeaderstats(player, data)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = data.Coins
    coins.Parent = leaderstats

    local crystals = Instance.new("IntValue")
    crystals.Name = "Crystals"
    crystals.Value = data.Crystals
    crystals.Parent = leaderstats
end

local function updateLeaderstats(player)
    local data = DataService.Get(player)
    local stats = player:FindFirstChild("leaderstats")
    if not data or not stats then return end
    stats.Coins.Value = data.Coins
    stats.Crystals.Value = data.Crystals
end

local function mineNode(player, node)
    local data = DataService.Get(player)
    local world = workspace:FindFirstChild("CrystalEmpireWorld")
    if not data or not node or not world or not node:IsDescendantOf(world) then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - node.Position).Magnitude > 16 then return end
    local now = os.clock()
    if lastMine[player] and now - lastMine[player] < 0.35 then return end
    lastMine[player] = now
    if data.Crystals >= data.Capacity then
        notify:FireClient(player, "Bag full! Sell your crystals.")
        return
    end

    local health = node:GetAttribute("Health")
    if type(health) ~= "number" or health <= 0 then return end
    health -= data.Power
    node:SetAttribute("Health", health)

    if health <= 0 then
        local room = data.Capacity - data.Crystals
        data.Crystals += math.min(1, room)
        node.Transparency = 1
        node.CanCollide = false
        local prompt = node:FindFirstChildOfClass("ProximityPrompt")
        if prompt then prompt.Enabled = false end
        task.delay(Config.CrystalRespawnSeconds, function()
            if node and node.Parent then
                node:SetAttribute("Health", node:GetAttribute("MaxHealth"))
                node.Transparency = 0
                node.CanCollide = true
                if prompt then prompt.Enabled = true end
            end
        end)
        notify:FireClient(player, "Crystal mined! +1")
    else
        notify:FireClient(player, "Keep mining!")
    end

    updateLeaderstats(player)
    sync(player)
end

local worldFolder = workspace:FindFirstChild("CrystalEmpireWorld")
local crystalFolder = worldFolder and worldFolder:FindFirstChild("CrystalNodes")
if crystalFolder then
    for _, node in ipairs(crystalFolder:GetChildren()) do
        local prompt = node:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            prompt.Triggered:Connect(function(player)
                mineNode(player, node)
            end)
        end
    end
end

mineRequest.OnServerEvent:Connect(function(player, node)
    if typeof(node) ~= "Instance" or not node:IsA("BasePart") then return end
    mineNode(player, node)
end)

local function sell(player)
    local data = DataService.Get(player)
    if not data then return end
    if data.Crystals <= 0 then
        notify:FireClient(player, "Your bag is empty.")
        return
    end
    local amount = data.Crystals
    local totalValue = amount * 5
    data.Coins += totalValue
    data.Crystals = 0
    notify:FireClient(player, "Sold " .. amount .. " crystals for " .. totalValue .. " coins!")
    updateLeaderstats(player)
    sync(player)
end

local function upgrade(player)
    local data = DataService.Get(player)
    if not data then return end
    local nextUpgrade = Config.Upgrades[data.UpgradeLevel + 1]
    if not nextUpgrade then
        notify:FireClient(player, "Your pickaxe is fully upgraded!")
        return
    end
    if data.Coins < nextUpgrade.Cost then
        notify:FireClient(player, "You need " .. nextUpgrade.Cost .. " coins.")
        return
    end
    data.Coins -= nextUpgrade.Cost
    data.Power = nextUpgrade.Power
    data.Capacity = nextUpgrade.Capacity
    data.UpgradeLevel += 1
    notify:FireClient(player, "Unlocked " .. nextUpgrade.Name .. "!")
    updateLeaderstats(player)
    sync(player)
end

sellPrompt.Triggered:Connect(sell)
upgradePrompt.Triggered:Connect(upgrade)

Players.PlayerAdded:Connect(function(player)
    local data = DataService.Load(player)
    setupLeaderstats(player, data)
    sync(player)
end)

Players.PlayerRemoving:Connect(function(player)
    DataService.Save(player)
    DataService.Remove(player)
    lastMine[player] = nil
end)

game:BindToClose(function()
    DataService.SaveAll()
    task.wait(2)
end)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        local data = DataService.Load(player)
        setupLeaderstats(player, data)
        sync(player)
    end)
end
