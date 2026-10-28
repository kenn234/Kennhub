local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local RS = ReplicatedStorage

local Config = { AutoThrow = false, AutoGym = false }

local function getRoot() 
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") 
end

local function notify(t, txt) 
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title=t, Text=txt, Duration=2}) end) 
end

local function fireRemote(remoteName, ...)
    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") and string.upper(obj.Name) == string.upper(remoteName) then
            pcall(function() obj:FireServer(...) end)
        end
    end
end

local function findClosest(keyword)
    local root = getRoot()
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), keyword) then
            local d = (root.Position - obj.Position).Magnitude
            if d < minDist then minDist = d; closest = obj end
        end
    end
    return closest
end

local function buildUI()
    local playerGui = LP:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("KENN_THROW_V12")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "KENN_THROW_V12"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 260, 0, 150)
    main.Position = UDim2.new(0.5, -130, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    task.spawn(function()
        local hue = 0
        while main.Parent do
            hue = (hue + 0.005) % 1
            stroke.Color = Color3.fromHSV(hue, 0.8, 1)
            task.wait(0.03)
        end
    end)

    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(20, 28, 48)
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KENN AUTO V12"
    title.TextColor3 = Color3.fromRGB(124, 162, 255)
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -32, 0, 4)
    close.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 100, 120)
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    local btn1 = Instance.new("TextButton", main)
    btn1.Size = UDim2.new(1, -20, 0, 35)
    btn1.Position = UDim2.new(0, 10, 0, 45)
    btn1.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
    btn1.Text = "AUTO THROW: OFF"
    btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn1.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn1).CornerRadius = UDim.new(0, 8)

    local btn2 = Instance.new("TextButton", main)
    btn2.Size = UDim2.new(1, -20, 0, 35)
    btn2.Position = UDim2.new(0, 10, 0, 90)
    btn2.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
    btn2.Text = "AUTO GYM: OFF"
    btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn2.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn2).CornerRadius = UDim.new(0, 8)

    btn1.MouseButton1Click:Connect(function()
        Config.AutoThrow = not Config.AutoThrow
        btn1.Text = "AUTO THROW: " .. (Config.AutoThrow and "ON" or "OFF")
        btn1.BackgroundColor3 = Config.AutoThrow and Color3.fromRGB(30, 80, 50) or Color3.fromRGB(60, 30, 40)
    end)

    btn2.MouseButton1Click:Connect(function()
        Config.AutoGym = not Config.AutoGym
        btn2.Text = "AUTO GYM: " .. (Config.AutoGym and "ON" or "OFF")
        btn2.BackgroundColor3 = Config.AutoGym and Color3.fromRGB(30, 80, 50) or Color3.fromRGB(60, 30, 40)
    end)
end

buildUI()

local function doAutoThrow()
    if not Config.AutoThrow then return end
    local root = getRoot()
    if not root then return end

    local target = findClosest("food") or findClosest("animal") or findClosest("meat")
    
    if target then
        pcall(function() root.CFrame = CFrame.new(target.Position + Vector3.new(0, 2, 0)) end)
        task.wait(0.5)
        notify("KENN", "Melempar...")
        fireRemote("THROW_START", target)
        task.wait(2) 
        fireRemote("THROW_FINISH", target)
        task.wait(1.5) 
    else
        task.wait(1)
    end
end

local function doAutoGym()
    if not Config.AutoGym then return end
    local root = getRoot()
    if not root then return nil end

    local gym = findClosest("gym") or findClosest("dumb") or findClosest("train")
    
    if gym then
        pcall(function() root.CFrame = CFrame.new(gym.Position + Vector3.new(0, 2, 0)) end)
        task.wait(0.5)
        notify("KENN", "Latihan Gym...")
        fireRemote("TRAINING_START", gym)
        task.wait(3) 
        fireRemote("TRAINING_STOP", gym)
        task.wait(1)
    else
        task.wait(2)
    end
end

task.spawn(function() while true do pcall(doAutoThrow); task.wait(0.5) end end)
task.spawn(function() while true do pcall(doAutoGym); task.wait(0.5) end end)

notify("KENN HUB", "V12 Loaded!")