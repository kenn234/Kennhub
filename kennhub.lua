--[[
    Kenn Hub v1
    100% original code. No telemetry. No external calls. No obfuscated libraries.
    Owned by: Kenn
    License: Free to use and modify for personal use.
]]

--=====================================================================
-- LOADING SCREEN
--=====================================================================
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "KennHubLoading"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.DisplayOrder = 1000
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.fromOffset(320, 88)
LoadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = LoadingGui

Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 12)

local LoadingStroke = Instance.new("UIStroke", LoadingFrame)
LoadingStroke.Color = Color3.fromRGB(255, 60, 60)
LoadingStroke.Thickness = 1.5

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(1, -24, 0, 20)
LoadingTitle.Position = UDim2.fromOffset(12, 10)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.TextSize = 16
LoadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingTitle.TextXAlignment = Enum.TextXAlignment.Left
LoadingTitle.Text = "Kenn Hub"
LoadingTitle.Parent = LoadingFrame

local LoadingPercent = Instance.new("TextLabel")
LoadingPercent.Size = UDim2.new(1, -24, 0, 20)
LoadingPercent.Position = UDim2.fromOffset(12, 10)
LoadingPercent.BackgroundTransparency = 1
LoadingPercent.Font = Enum.Font.GothamBold
LoadingPercent.TextSize = 16
LoadingPercent.TextColor3 = Color3.fromRGB(255, 120, 90)
LoadingPercent.TextXAlignment = Enum.TextXAlignment.Right
LoadingPercent.Text = "0%"
LoadingPercent.Parent = LoadingFrame

local LoadingBarBg = Instance.new("Frame")
LoadingBarBg.Size = UDim2.new(1, -24, 0, 8)
LoadingBarBg.Position = UDim2.fromOffset(12, 40)
LoadingBarBg.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
LoadingBarBg.BorderSizePixel = 0
LoadingBarBg.Parent = LoadingFrame
Instance.new("UICorner", LoadingBarBg).CornerRadius = UDim.new(1, 0)

local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadingBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadingBarFill.BorderSizePixel = 0
LoadingBarFill.Parent = LoadingBarBg
Instance.new("UICorner", LoadingBarFill).CornerRadius = UDim.new(1, 0)
Instance.new("UIGradient", LoadingBarFill).Color = ColorSequence.new(
    Color3.fromRGB(255, 50, 50),
    Color3.fromRGB(255, 150, 60)
)

local LoadingStep = Instance.new("TextLabel")
LoadingStep.Size = UDim2.new(1, -24, 0, 16)
LoadingStep.Position = UDim2.fromOffset(12, 56)
LoadingStep.BackgroundTransparency = 1
LoadingStep.Font = Enum.Font.GothamMedium
LoadingStep.TextSize = 12
LoadingStep.TextColor3 = Color3.fromRGB(170, 170, 185)
LoadingStep.TextXAlignment = Enum.TextXAlignment.Left
LoadingStep.Text = "Starting..."
LoadingStep.Parent = LoadingFrame

local function setProgress(step, total, text)
    local pct = math.clamp(step / total, 0, 1)
    LoadingBarFill.Size = UDim2.new(pct, 0, 1, 0)
    LoadingPercent.Text = math.floor(pct * 100) .. "%"
    LoadingStep.Text = text or ("Loading " .. step .. " / " .. total)
end

--=====================================================================
-- THEME
--=====================================================================
local Theme = {
    Bg          = Color3.fromRGB(18, 18, 22),
    Surface     = Color3.fromRGB(28, 28, 34),
    SurfaceAlt  = Color3.fromRGB(36, 36, 44),
    Accent      = Color3.fromRGB(255, 60, 60),
    AccentSoft  = Color3.fromRGB(255, 120, 90),
    Text        = Color3.fromRGB(240, 240, 245),
    TextDim     = Color3.fromRGB(170, 170, 185),
    Good        = Color3.fromRGB(80, 220, 140),
    Warn        = Color3.fromRGB(255, 190, 70),
    Bad         = Color3.fromRGB(240, 90, 90),
    Stroke      = Color3.fromRGB(58, 56, 66),
}

--=====================================================================
-- CONFIG SYSTEM (save/load via writefile/readfile kalau ada)
--=====================================================================
local ConfigPath = "KennHub/config.json"

local function ensureFolder()
    if type(isfolder) ~= "function" then return false end
    if type(makefolder) ~= "function" then return false end
    if not isfolder("KennHub") then
        pcall(makefolder, "KennHub")
    end
    return true
end

local function saveConfig(data)
    if type(writefile) ~= "function" then return false end
    ensureFolder()
    local HttpService = game:GetService("HttpService")
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false end
    local ok2 = pcall(writefile, ConfigPath, encoded)
    return ok2
end

local function loadConfig()
    if type(isfile) ~= "function" then return nil end
    if type(readfile) ~= "function" then return nil end
    local ok, exists = pcall(isfile, ConfigPath)
    if not ok or not exists then return nil end
    local HttpService = game:GetService("HttpService")
    local ok2, raw = pcall(readfile, ConfigPath)
    if not ok2 or type(raw) ~= "string" then return nil end
    local ok3, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok3 or type(decoded) ~= "table" then return nil end
    return decoded
end

--=====================================================================
-- HUB STATE
--=====================================================================
local State = {
    Toggles = {},   -- [id] = bool
    Sliders = {},   -- [id] = number
    Dropdowns = {}, -- [id] = string
    Inputs = {},    -- [id] = string
    Listeners = {}, -- [id] = {callback, ...}
}

local function notify(id, value)
    if State.Listeners[id] then
        for _, cb in ipairs(State.Listeners[id]) do
            pcall(cb, value)
        end
    end
end

local function setToggle(id, value)
    State.Toggles[id] = value
    notify(id, value)
    saveConfig({ Toggles = State.Toggles, Sliders = State.Sliders })
end

local function setSlider(id, value)
    State.Sliders[id] = value
    notify(id, value)
    saveConfig({ Toggles = State.Toggles, Sliders = State.Sliders })
end

--=====================================================================
-- MAIN WINDOW
--=====================================================================
setProgress(2, 10, "Building window...")

local HubGui = Instance.new("ScreenGui")
HubGui.Name = "KennHub"
HubGui.ResetOnSpawn = false
HubGui.IgnoreGuiInset = true
HubGui.DisplayOrder = 999
HubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HubGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(560, 380)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Parent = HubGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Stroke
MainStroke.Thickness = 1.5

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Theme.Surface
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 20)
TitleBarFix.Position = UDim2.new(0, 0, 1, -20)
TitleBarFix.BackgroundColor3 = Theme.Surface
TitleBarFix.BorderSizePixel = 0
TitleBarFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Kenn Hub"
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 6)
CloseBtn.BackgroundColor3 = Theme.Bad
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "X"
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    HubGui.Enabled = not HubGui.Enabled
end)

-- Tab sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.fromOffset(8, 46)
Sidebar.BackgroundColor3 = Theme.Surface
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 4)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 6)
SidebarPad.PaddingLeft = UDim.new(0, 6)
SidebarPad.PaddingRight = UDim.new(0, 6)

-- Content area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -146, 1, -50)
Content.Position = UDim2.fromOffset(138, 46)
Content.BackgroundColor3 = Theme.Surface
Content.BorderSizePixel = 0
Content.Parent = Main
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -12, 1, -12)
ContentScroll.Position = UDim2.fromOffset(6, 6)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.ScrollBarThickness = 4
ContentScroll.ScrollBarImageColor3 = Theme.Accent
ContentScroll.Parent = Content

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 6)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Parent = ContentScroll

local ContentPad = Instance.new("UIPadding", ContentScroll)
ContentPad.PaddingTop = UDim.new(0, 4)
ContentPad.PaddingLeft = UDim.new(0, 6)
ContentPad.PaddingRight = UDim.new(0, 6)
ContentPad.PaddingBottom = UDim.new(0, 4)

--=====================================================================
-- TAB SYSTEM
--=====================================================================
local Tabs = {}
local CurrentTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 30)
    tabBtn.BackgroundColor3 = Theme.SurfaceAlt
    tabBtn.BorderSizePixel = 0
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 13
    tabBtn.TextColor3 = Theme.TextDim
    tabBtn.Text = name
    tabBtn.Parent = Sidebar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.fromScale(1, 0)
    tabContent.AutomaticSize = Enum.AutomaticSize.Y
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = ContentScroll

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContent

    local tab = { Name = name, Button = tabBtn, Content = tabContent }
    table.insert(Tabs, tab)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Theme.SurfaceAlt
            t.Button.TextColor3 = Theme.TextDim
        end
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Theme.Accent
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = tab
    end)

    return tab
end

--=====================================================================
-- UI COMPONENTS
--=====================================================================
local function createToggle(parent, id, label, default)
    if State.Toggles[id] == nil then
        State.Toggles[id] = default or false
    end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Theme.SurfaceAlt
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.fromOffset(10, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label
    lbl.Parent = row

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.fromOffset(44, 22)
    switch.Position = UDim2.new(1, -54, 0.5, -11)
    switch.BackgroundColor3 = State.Toggles[id] and Theme.Good or Theme.Stroke
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.Parent = row
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = State.Toggles[id] and UDim2.new(1, -19, 0.5, -8) or UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local on = State.Toggles[id]
        switch.BackgroundColor3 = on and Theme.Good or Theme.Stroke
        knob.Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.fromOffset(3, 3)
    end

    switch.MouseButton1Click:Connect(function()
        setToggle(id, not State.Toggles[id])
        refresh()
    end)

    refresh()
    return row
end

local function createSlider(parent, id, label, min, max, default)
    if State.Sliders[id] == nil then
        State.Sliders[id] = default or min
    end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Theme.SurfaceAlt
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -120, 0, 22)
    lbl.Position = UDim2.fromOffset(10, 4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.fromOffset(90, 22)
    valLbl.Position = UDim2.new(1, -100, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = Theme.AccentSoft
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = tostring(State.Sliders[id])
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 1, -14)
    track.BackgroundColor3 = Theme.Stroke
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((State.Sliders[id] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 3)
    btn.Position = UDim2.new(0, 0, -0.5, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = track

    local dragging = false

    local function updateFromMouse(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel + 0.5)
        State.Sliders[id] = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLbl.Text = tostring(val)
        notify(id, val)
    end

    btn.MouseButton1Down:Connect(function()
        dragging = true
        local m = game:GetService("UserInputService"):GetMouseLocation()
        updateFromMouse(m.X)
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse(input.Position.X)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            setSlider(id, State.Sliders[id])
        end
    end)

    return row
end

local function createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundColor3 = Theme.SurfaceAlt
    lbl.BorderSizePixel = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = Theme.AccentSoft
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "  " .. text
    lbl.Parent = parent
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
    return lbl
end

local function createButton(parent, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.Accent
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = label
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    return btn
end

--=====================================================================
-- PUBLIC API
--=====================================================================
local Kenn = {}
Kenn.Theme = Theme
Kenn.State = State
Kenn.Notify = notify

function Kenn:CreateTab(name)
    return createTab(name)
end

function Kenn:Toggle(parent, id, label, default, callback)
    createToggle(parent.Content, id, label, default)
    if callback then
        State.Listeners[id] = State.Listeners[id] or {}
        table.insert(State.Listeners[id], callback)
    end
end

function Kenn:Slider(parent, id, label, min, max, default, callback)
    createSlider(parent.Content, id, label, min, max, default)
    if callback then
        State.Listeners[id] = State.Listeners[id] or {}
        table.insert(State.Listeners[id], callback)
    end
end

function Kenn:Label(parent, text)
    createLabel(parent.Content, text)
end

function Kenn:Button(parent, label, callback)
    createButton(parent.Content, label, callback)
end

function Kenn:GetToggle(id)
    return State.Toggles[id] == true
end

function Kenn:GetSlider(id)
    return State.Sliders[id]
end

--=====================================================================
-- EXAMPLE TABS & FEATURES (isi sendiri sesuai game)
--=====================================================================
setProgress(6, 10, "Loading features...")

local FarmTab = Kenn:CreateTab("Farm")
Kenn:Label(FarmTab, "Auto Steal")
Kenn:Toggle(FarmTab, "auto_steal", "Auto Steal", false, function(v)
    print("[Kenn Hub] Auto Steal:", v)
end)
Kenn:Slider(FarmTab, "steal_speed", "Steal Speed", 100, 500, 300, function(v)
    print("[Kenn Hub] Steal Speed:", v)
end)
Kenn:Button(FarmTab, "Steal Now", function()
    print("[Kenn Hub] Steal Now clicked")
end)

local PlayerTab = Kenn:CreateTab("Player")
Kenn:Label(PlayerTab, "Movement")
Kenn:Toggle(PlayerTab, "speed_boost", "Speed Boost", false, function(v)
    local char = game:GetService("Players").LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = v and 100 or 16
    end
end)
Kenn:Slider(PlayerTab, "boost_speed", "Boost Speed", 20, 300, 100, function(v)
    if Kenn:GetToggle("speed_boost") then
        local char = game:GetService("Players").LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)

local MiscTab = Kenn:CreateTab("Misc")
Kenn:Label(MiscTab, "Utility")
Kenn:Button(MiscTab, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end)

--=====================================================================
-- DRAG WINDOW
--=====================================================================
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--=====================================================================
-- TOGGLE KEY (RightShift)
--=====================================================================
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        HubGui.Enabled = not HubGui.Enabled
    end
end)

--=====================================================================
-- FINISH LOADING
--=====================================================================
setProgress(10, 10, "Ready")
task.wait(0.6)
LoadingGui:Destroy()

if CurrentTab == nil and #Tabs > 0 then
    Tabs[1].Button:Fire? -- placeholder
end

-- Auto-select first tab
if #Tabs > 0 then
    local firstBtn = Tabs[1].Button
    firstBtn.BackgroundColor3 = Theme.Accent
    firstBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tabs[1].Content.Visible = true
    CurrentTab = Tabs[1]
end

print("[Kenn Hub] Loaded. Press RightShift to toggle menu.")