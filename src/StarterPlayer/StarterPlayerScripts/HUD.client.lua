local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateHUD = remotes:WaitForChild("UpdateHUD")
local notify = remotes:WaitForChild("Notify")
local mineRequest = remotes:WaitForChild("MineRequest")

local gui = Instance.new("ScreenGui")
gui.Name = "CrystalEmpireHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeLabel(name, size, position, text, textSize)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.BackgroundColor3 = Color3.fromRGB(18, 25, 45)
    label.BackgroundTransparency = 0.15
    label.TextColor3 = Color3.fromRGB(230, 245, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = textSize
    label.Text = text
    label.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = label
    return label
end

local stats = makeLabel("Stats", UDim2.fromOffset(240, 82), UDim2.fromOffset(14, 14), "CRYSTAL EMPIRE\nLoading...", 17)
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextYAlignment = Enum.TextYAlignment.Center

local toast = makeLabel("Toast", UDim2.new(0.7, 0, 0, 42), UDim2.new(0.15, 0, 0.82, 0), "", 16)
toast.Visible = false

local mineButton = Instance.new("TextButton")
mineButton.Name = "MineButton"
mineButton.Size = UDim2.fromOffset(132, 54)
mineButton.Position = UDim2.new(1, -150, 1, -90)
mineButton.BackgroundColor3 = Color3.fromRGB(40, 170, 235)
mineButton.TextColor3 = Color3.new(1, 1, 1)
mineButton.Text = "MINE"
mineButton.TextSize = 21
mineButton.Font = Enum.Font.GothamBlack
mineButton.Parent = gui
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 16)
buttonCorner.Parent = mineButton

local function nearestNode()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local world = workspace:FindFirstChild("CrystalEmpireWorld")
    local folder = world and world:FindFirstChild("CrystalNodes")
    if not root or not folder then return nil end

    local best, bestDistance = nil, 14
    for _, node in ipairs(folder:GetChildren()) do
        if node:IsA("BasePart") and node.Transparency < 1 then
            local distance = (node.Position - root.Position).Magnitude
            if distance < bestDistance then
                best, bestDistance = node, distance
            end
        end
    end
    return best
end

mineButton.Activated:Connect(function()
    local node = nearestNode()
    if node then
        mineRequest:FireServer(node)
    else
        toast.Text = "Move closer to a crystal."
        toast.Visible = true
        task.delay(1.5, function() toast.Visible = false end)
    end
end)

updateHUD.OnClientEvent:Connect(function(data)
    stats.Text = string.format("✦ CRYSTAL EMPIRE\nCoins: %d\nCrystals: %d / %d", data.Coins, data.Crystals, data.Capacity)
end)

notify.OnClientEvent:Connect(function(message)
    toast.Text = tostring(message)
    toast.Visible = true
    task.delay(2.2, function()
        toast.Visible = false
    end)
end)
