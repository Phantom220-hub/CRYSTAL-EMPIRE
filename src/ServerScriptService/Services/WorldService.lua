local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local WorldService = {}
local nodeFolder

local function makePart(parent, name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function spawnNode(position, crystalInfo)
    local node = makePart(nodeFolder, crystalInfo.Name, crystalInfo.Size, position, crystalInfo.Color, Enum.Material.Neon)
    node.Shape = Enum.PartType.Ball
    node.CanCollide = true
    node:SetAttribute("Value", crystalInfo.Value)
    node:SetAttribute("Health", crystalInfo.Health)
    node:SetAttribute("MaxHealth", crystalInfo.Health)

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Mine"
    prompt.ObjectText = crystalInfo.Name
    prompt.HoldDuration = 0.4
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = node


    return node
end

function WorldService.Build()
    local old = Workspace:FindFirstChild("CrystalEmpireWorld")
    if old then old:Destroy() end

    local world = Instance.new("Folder")
    world.Name = "CrystalEmpireWorld"
    world.Parent = Workspace

    makePart(world, "MainIsland", Vector3.new(180, 8, 180), Vector3.new(0, -4, 0), Color3.fromRGB(75, 145, 100), Enum.Material.Grass)
    makePart(world, "SpawnPlatform", Vector3.new(34, 2, 34), Vector3.new(0, 1, 0), Color3.fromRGB(75, 110, 155), Enum.Material.Slate)

    local sign = makePart(world, "WelcomeSign", Vector3.new(20, 10, 1), Vector3.new(0, 8, -22), Color3.fromRGB(25, 35, 65), Enum.Material.SmoothPlastic)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.Parent = sign
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "CRYSTAL EMPIRE\nMine • Sell • Upgrade"
    label.TextColor3 = Color3.fromRGB(120, 225, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui

    nodeFolder = Instance.new("Folder")
    nodeFolder.Name = "CrystalNodes"
    nodeFolder.Parent = world

    local positions = {
        Vector3.new(-45, 2, -35), Vector3.new(-25, 2, -45), Vector3.new(0, 2, -48),
        Vector3.new(25, 2, -40), Vector3.new(45, 2, -20), Vector3.new(-48, 2, 10),
        Vector3.new(-25, 2, 35), Vector3.new(0, 2, 45), Vector3.new(28, 2, 35),
        Vector3.new(48, 2, 12), Vector3.new(-10, 2, 15), Vector3.new(15, 2, -5),
    }

    for index, position in ipairs(positions) do
        local info = Config.Crystals[((index - 1) % #Config.Crystals) + 1]
        spawnNode(position, info)
    end

    local sellPad = makePart(world, "SellStation", Vector3.new(14, 2, 14), Vector3.new(-55, 1, 55), Color3.fromRGB(60, 220, 145), Enum.Material.Neon)
    local sellPrompt = Instance.new("ProximityPrompt")
    sellPrompt.ActionText = "Sell crystals"
    sellPrompt.ObjectText = "Crystal Exchange"
    sellPrompt.HoldDuration = 0.5
    sellPrompt.MaxActivationDistance = 14
    sellPrompt.Parent = sellPad

    local upgradePad = makePart(world, "UpgradeStation", Vector3.new(14, 2, 14), Vector3.new(55, 1, 55), Color3.fromRGB(175, 105, 255), Enum.Material.Neon)
    local upgradePrompt = Instance.new("ProximityPrompt")
    upgradePrompt.ActionText = "Upgrade pickaxe"
    upgradePrompt.ObjectText = "Forge"
    upgradePrompt.HoldDuration = 0.5
    upgradePrompt.MaxActivationDistance = 14
    upgradePrompt.Parent = upgradePad

    return sellPrompt, upgradePrompt
end

return WorldService
