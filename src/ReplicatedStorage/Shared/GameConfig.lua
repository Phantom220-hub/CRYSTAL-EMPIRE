local GameConfig = {}

GameConfig.DataStoreName = "CrystalEmpire_PlayerData_v1"
GameConfig.StartingCoins = 0
GameConfig.StartingCapacity = 20
GameConfig.StartingPower = 1
GameConfig.CrystalRespawnSeconds = 8
GameConfig.Crystals = {
    { Name = "Azure Crystal", Value = 3, Health = 1, Color = Color3.fromRGB(50, 190, 255), Size = Vector3.new(3, 4, 3) },
    { Name = "Rose Crystal", Value = 7, Health = 3, Color = Color3.fromRGB(255, 90, 170), Size = Vector3.new(3, 3, 3) },
    { Name = "Sun Crystal", Value = 12, Health = 5, Color = Color3.fromRGB(255, 190, 55), Size = Vector3.new(3, 4, 3) },
}
GameConfig.Upgrades = {
    { Power = 2, Capacity = 30, Cost = 100, Name = "Copper Pickaxe" },
    { Power = 3, Capacity = 45, Cost = 300, Name = "Crystal Pickaxe" },
    { Power = 5, Capacity = 70, Cost = 800, Name = "Astral Pickaxe" },
    { Power = 8, Capacity = 100, Cost = 2000, Name = "Celestial Pickaxe" },
}

return GameConfig
