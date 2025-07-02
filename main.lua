local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:AddTheme({
    Name = "Dark",
    Accent = "#18181b",
    Outline = "#FFFFFF",
    Text = "#FFFFFF",
    Placeholder = "#999999",
    Background = "#0e0e10",
    Button = "#52525b",
    Icon = "#a1a1aa",
})

local Window = WindUI:CreateWindow({
    Title = "Script blox spin",
    Icon = "door-open",
    Author = "Snow",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    Background = "",
    BackgroundImageTransparency = 0.80,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("clicked")
        end,
    },
    KeySystem = {
        Key = { "123"},
        Note = "Key 123.",
        Thumbnail = {
            Image = "rbxassetid://",
            Title = "Thumbnail",
        },
        URL = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJa0gpcYxDTR5Mdcznwxnv8eeFImOJJq_gnw&s",
        SaveKey = false,
    },
})

-- Tabs
local Combat = Window:Tab({ Title = "Combat", Icon = "crosshair", Locked = false })
local Visuals = Window:Tab({ Title = "Visuals", Icon = "eye", Locked = false })
local Farms = Window:Tab({ Title = "Farms", Icon = "circle-dollar-sign", Locked = false })

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aimbot Toggle
local Aimbot = Combat:Toggle({
    Title = "Aimbot",
    Desc = "Puxa a mira nos players dentro do fov.",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        print("Aimbot: " .. tostring(state))
    end
})

-- FOV Circle Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 2
fovCircle.Transparency = 1
fovCircle.Filled = false
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
fovCircle.Radius = 70

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Show FOV Toggle
local ShowFOV = Combat:Toggle({
    Title = "Show Fov",
    Desc = "Mostra o fov na tela.",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        fovCircle.Visible = state
        print("FOV Visibility: " .. tostring(state))
    end
})

-- FOV Size Slider
local FovSize = Combat:Slider({
    Title = "Fov Size",
    Step = 1,
    Value = { Min = 25, Max = 200, Default = 70 },
    Callback = function(value)
        fovCircle.Radius = value
        print("FOV Size: " .. tostring(value))
    end
})

-- Dropdown de amigos
local friendList = {}
local Dropdown -- aqui vai ficar o dropdown ativo

local function createFriendDropdown()
    if Dropdown then
        Dropdown:Destroy() -- destrói o dropdown antigo (se existir)
    end

    local values = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(values, player.Name)
        end
    end

    -- Filtra a lista de amigos que ainda estão na lista de jogadores
    local validFriends = {}
    for _, name in ipairs(friendList) do
        if table.find(values, name) then
            table.insert(validFriends, name)
        end
    end

    Dropdown = Combat:Dropdown({
        Title = "Add friends",
        Values = values,
        Value = validFriends,
        Multi = true,
        AllowNone = true,
        Callback = function(option)
            friendList = option
            print("Amigos selecionados: " .. HttpService:JSONEncode(friendList))
        end,
    })
end

-- Cria o dropdown pela primeira vez
createFriendDropdown()

-- Atualiza dropdown quando players entrarem ou saírem
Players.PlayerAdded:Connect(createFriendDropdown)
Players.PlayerRemoving:Connect(createFriendDropdown)




-- Funções auxiliares do Aimbot
local function getScreenDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function isInFOV(pos, radius)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return onScreen and getScreenDistance(Vector2.new(screenPos.X, screenPos.Y), center) <= radius
end

local function getClosestTarget(radius)
    local closest = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if isInFOV(head.Position, radius) and not table.find(friendList, player.Name) then
                local distance = getScreenDistance(Vector2.new(screenPos.X, screenPos.Y), Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
                if distance < shortestDistance then
                    closest = head
                    shortestDistance = distance
                end
            end
        end
    end

    return closest
end

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if Aimbot.Value and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget(fovCircle.Radius)
        if target then
            local screenPos = Camera:WorldToViewportPoint(target.Position)
            local mouseLocation = UserInputService:GetMouseLocation()
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            local moveDelta = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter)

            -- Suavizar (opcional)
            local smoothFactor = 0.15
            moveDelta = moveDelta * smoothFactor

            mousemoverel(moveDelta.X, moveDelta.Y)
        end
    end
end)

--esp toggles
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Suas toggles (certifique-se que estão definidas assim no seu script)
local EspBox = Visuals:Toggle({
    Title = "Esp Box",
    Desc = "Cria uma box em volta dos players.",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
})

local EspSkeleton = Visuals:Toggle({
    Title = "Esp Skeleton",
    Desc = "Cria um esqueleto nos players.",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
})

local EspDistance = Visuals:Toggle({
    Title = "Esp Distance",
    Desc = "Mostra a distancia dos players.",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
})

local EspHealth = Visuals:Toggle({
    Title = "Esp Health",
    Desc = "Mostra a vida dos players.",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
})

-- Armazenar todos os desenhos de ESP para cada player
local ESPData = {}

-- Função para criar desenhos básicos
local function createDrawing(type, properties)
    local d = Drawing.new(type)
    for k,v in pairs(properties) do
        d[k] = v
    end
    return d
end

local function get2DPosition(vec3)
    local pos, onScreen = Camera:WorldToViewportPoint(vec3)
    if onScreen then
        return Vector2.new(pos.X, pos.Y)
    else
        return nil
    end
end

local function getBoxCorners(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not hrp or not head then return end

    local rootPos, onScreenRoot = Camera:WorldToViewportPoint(hrp.Position)
    local headPos, onScreenHead = Camera:WorldToViewportPoint(head.Position)
    if not onScreenRoot or not onScreenHead then return end

    local height = (headPos.Y - rootPos.Y) * -1 -- inverso pois Y cresce pra baixo na tela
    local width = height / 2

    local extraWidth = 8 -- aumenta 10 pixels pra esquerda e direita
    local extraHeight = 35 -- aumenta 15 pixels para baixo

    local bottomLeft = Vector2.new(rootPos.X - width - extraWidth, rootPos.Y + extraHeight)
    local topRight = Vector2.new(rootPos.X + width + extraWidth, rootPos.Y - height)

    return bottomLeft, topRight
end


local function drawBox(player)
    local character = player.Character
    if not character then return end

    local bottomLeft, topRight = getBoxCorners(character)
    if not bottomLeft or not topRight then
        if ESPData[player] and ESPData[player].Box then
            ESPData[player].Box.Visible = false
        end
        return
    end

    local sizeX = topRight.X - bottomLeft.X
    local sizeY = topRight.Y - bottomLeft.Y

    if not ESPData[player] then ESPData[player] = {} end
    local data = ESPData[player]

    if not data.Box then
        data.Box = createDrawing("Square", {
            Color = Color3.new(1,1,1),
            Thickness = 2,
            Filled = false,
            Visible = true,
        })
    end

    data.Box.Position = bottomLeft
    data.Box.Size = Vector2.new(sizeX, sizeY)
    data.Box.Visible = EspBox.Value
end


local function drawHealthBar(player)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local bottomLeft, topRight = getBoxCorners(character)
    if not bottomLeft or not topRight then
        if ESPData[player] and ESPData[player].HealthBar then
            ESPData[player].HealthBar.Visible = false
            ESPData[player].HealthBarOutline.Visible = false
        end
        return
    end

    if not ESPData[player] then ESPData[player] = {} end
    local data = ESPData[player]

    if not data.HealthBar then
        data.HealthBar = createDrawing("Square", {
            Color = Color3.new(0,1,0),
            Thickness = 1,
            Filled = true,
            Visible = true,
        })
        data.HealthBarOutline = createDrawing("Square", {
            Color = Color3.new(0,0,0),
            Thickness = 1,
            Filled = false,
            Visible = true,
        })
    end

    local sizeY = topRight.Y - bottomLeft.Y
    local sizeX = 4
    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
    local barHeight = sizeY * healthPercent

    data.HealthBar.Position = Vector2.new(bottomLeft.X - sizeX - 2, topRight.Y + (sizeY - barHeight))
    data.HealthBar.Size = Vector2.new(sizeX, barHeight)
    data.HealthBar.Color = Color3.fromRGB(0, math.floor(255 * healthPercent), 0)
    data.HealthBar.Visible = EspHealth.Value

    data.HealthBarOutline.Position = Vector2.new(bottomLeft.X - sizeX - 2, topRight.Y)
    data.HealthBarOutline.Size = Vector2.new(sizeX, sizeY)
    data.HealthBarOutline.Visible = EspHealth.Value
end


local function drawDistance(player)
    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos2d = get2DPosition(hrp.Position)
    if not pos2d then
        if ESPData[player] and ESPData[player].DistanceText then
            ESPData[player].DistanceText.Visible = false
        end
        return
    end

    if not ESPData[player] then ESPData[player] = {} end
    local data = ESPData[player]

    if not data.DistanceText then
        data.DistanceText = createDrawing("Text", {
            Text = "",
            Color = Color3.new(1,1,1),
            Size = 16,
            Center = true,
            Outline = true,
            Font = 2,
            Visible = true,
        })
    end

    local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
    data.DistanceText.Text = string.format("%.1f m", dist)
    data.DistanceText.Position = pos2d + Vector2.new(0, 15)
    data.DistanceText.Visible = EspDistance.Value
end


local function drawSkeleton(player)
    local character = player.Character
    if not character then return end

    local function getPartPos(name)
        local part = character:FindFirstChild(name)
        if part then
            return get2DPosition(part.Position)
        end
        return nil
    end

    local joints = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"UpperTorso", "LowerTorso"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }

    if not ESPData[player] then ESPData[player] = {} end
    local data = ESPData[player]

    if not data.SkeletonLines then
        data.SkeletonLines = {}
        for i=1, #joints do
            data.SkeletonLines[i] = createDrawing("Line", {
                Color = Color3.new(1,1,1),
                Thickness = 1.5,
                Transparency = 1,
                Visible = true,
            })
        end
    end

    for i, joint in ipairs(joints) do
        local pos1 = getPartPos(joint[1])
        local pos2 = getPartPos(joint[2])
        local line = data.SkeletonLines[i]
        if pos1 and pos2 then
            line.From = pos1
            line.To = pos2
            line.Visible = EspSkeleton.Value
        else
            line.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if EspBox.Value then drawBox(player) else
                if ESPData[player] and ESPData[player].Box then
                    ESPData[player].Box.Visible = false
                end
            end

            if EspHealth.Value then
                drawHealthBar(player)
            else
                if ESPData[player] and ESPData[player].HealthBar then
                    ESPData[player].HealthBar.Visible = false
                    ESPData[player].HealthBarOutline.Visible = false
                end
            end

            if EspDistance.Value then
                drawDistance(player)
            else
                if ESPData[player] and ESPData[player].DistanceText then
                    ESPData[player].DistanceText.Visible = false
                end
            end

            if EspSkeleton.Value then
                drawSkeleton(player)
            else
                if ESPData[player] and ESPData[player].SkeletonLines then
                    for _, line in pairs(ESPData[player].SkeletonLines) do
                        line.Visible = false
                    end
                end
            end
        else
            -- Hide everything if player doesn't have character or is dead
            if ESPData[player] then
                if ESPData[player].Box then ESPData[player].Box.Visible = false end
                if ESPData[player].HealthBar then ESPData[player].HealthBar.Visible = false end
                if ESPData[player].HealthBarOutline then ESPData[player].HealthBarOutline.Visible = false end
                if ESPData[player].DistanceText then ESPData[player].DistanceText.Visible = false end
                if ESPData[player].SkeletonLines then
                    for _, line in pairs(ESPData[player].SkeletonLines) do
                        line.Visible = false
                    end
                end
            end
        end
    end
end)
