local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local store = DataStoreService:GetDataStore(Config.DataStoreName)

local DataService = {}
local cache = {}

local function defaultData()
    return {
        Coins = Config.StartingCoins,
        Crystals = 0,
        Capacity = Config.StartingCapacity,
        Power = Config.StartingPower,
        UpgradeLevel = 0,
    }
end

function DataService.Get(player)
    return cache[player]
end

function DataService.Load(player)
    local key = "player_" .. player.UserId
    local data = defaultData()

    local success, result = pcall(function()
        return store:GetAsync(key)
    end)

    if success and type(result) == "table" then
        for field, defaultValue in pairs(defaultData()) do
            if type(result[field]) == type(defaultValue) then
                data[field] = result[field]
            end
        end
    elseif not success then
        warn("[CrystalEmpire] Data load failed for", player.UserId, result)
    end

    cache[player] = data
    return data
end

function DataService.Save(player)
    local data = cache[player]
    if not data then return end

    local key = "player_" .. player.UserId
    local success, err = pcall(function()
        store:UpdateAsync(key, function()
            return data
        end)
    end)

    if not success then
        warn("[CrystalEmpire] Data save failed for", player.UserId, err)
    end
end

function DataService.Remove(player)
    cache[player] = nil
end

function DataService.SaveAll()
    for _, player in ipairs(Players:GetPlayers()) do
        DataService.Save(player)
    end
end

return DataService
