
--// YOHI UI LIBRARY (BASED ON NOTHING UI)

local Yohi = {}
Yohi.__index = Yohi

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Helpers
local function create(instance, properties)
    local obj = Instance.new(instance)
    for i, v in pairs(properties) do
        obj[i] = v
    end
    return obj
end

local function tween(obj, props, time)
    local info = TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

-- Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(160, 160, 160),
    Text = Color3.fromRGB(230, 230, 230),
    Hover = Color3.fromRGB(100, 100, 100),
    ToggleOn = Color3.fromRGB(255,255,255),
    ToggleOff = Color3.fromRGB(130,130,130),
    ToggleBackOn = Color3.fromRGB(170,170,170),
    ToggleBackOff = Color3.fromRGB(50,50,50)
}

-- Init
function Yohi.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Yohi)
    self.Title = cfg.Title or "YOHI HUB"
    self.Keybind = cfg.Keybind or Enum.KeyCode.RightControl
    self.Tabs = {}
    self.Animating = false
    self.Open = true

    -- Gui
    self.Gui = create("ScreenGui", {
        Name = "YOHI_UI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Enabled = true
    })

    self.Main = create("Frame", {
        Parent = self.Gui,
        Size = UDim2.new(0, 800, 0, 450),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = self.Main, CornerRadius = UDim.new(0, 8)})

    -- Drag
    local dragging, dragInput, dragStart, startPos
    self.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    self.Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    self.Sidebar = create("Frame", {
        Parent = self.Main,
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = self.Sidebar, CornerRadius = UDim.new(0, 8)})

    -- Content
    self.Content = create("Frame", {
        Parent = self.Main,
        Position = UDim2.new(0, 180, 0, 0),
        Size = UDim2.new(1, -180, 1, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = self.Content, CornerRadius = UDim.new(0, 8)})

    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.Keybind and not self.Animating then
            self.Animating = true
            if self.Open then
                tween(self.Main, {Size = UDim2.new(0, 800, 0, 0)}, 0.25)
                task.delay(0.25, function()
                    self.Gui.Enabled = false
                    self.Open = false
                    self.Animating = false
                end)
            else
                self.Gui.Enabled = true
                tween(self.Main, {Size = UDim2.new(0, 800, 0, 450)}, 0.25)
                task.delay(0.25, function()
                    self.Open = true
                    self.Animating = false
                end)
            end
        end
    end)

    return self
end

-- New Tab
function Yohi:NewTab(data)
    local Tab = {}
    Tab.Button = create("TextButton", {
        Parent = self.Sidebar,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Text = data.Title or "Tab",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16
    })
    local tabFrame = create("ScrollingFrame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = #self.Tabs == 0,
        ScrollBarThickness = 4
    })
    Tab.Frame = tabFrame

    Tab.Button.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Frame.Visible = false
        end
        tabFrame.Visible = true
    end)

    function Tab:CreateButton(cfg)
        local btn = create("TextButton", {
            Parent = tabFrame,
            Size = UDim2.new(0, 200, 0, 30),
            Position = UDim2.new(0, 10, 0, #tabFrame:GetChildren() * 35),
            BackgroundColor3 = Theme.Sidebar,
            BorderSizePixel = 0,
            Text = cfg.Title or "Button",
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.Hover}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.Sidebar}, 0.2)
        end)
        btn.MouseButton1Click:Connect(function()
            if cfg.Callback then cfg.Callback() end
        end)
    end

    function Tab:CreateToggle(cfg)
        local state = cfg.Default or false
        local toggleBack = create("Frame", {
            Parent = tabFrame,
            Size = UDim2.new(0, 50, 0, 25),
            Position = UDim2.new(0, 10, 0, #tabFrame:GetChildren() * 35),
            BackgroundColor3 = Theme.ToggleBackOff,
            BorderSizePixel = 0
        })
        create("UICorner", {Parent = toggleBack, CornerRadius = UDim.new(1, 0)})

        local knob = create("Frame", {
            Parent = toggleBack,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 3, 0, 2),
            BackgroundColor3 = Theme.ToggleOff,
            BorderSizePixel = 0
        })
        create("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})

        local function refresh()
            if state then
                tween(knob, {Position = UDim2.new(0, 27, 0, 2)}, 0.2)
                toggleBack.BackgroundColor3 = Theme.ToggleBackOn
                knob.BackgroundColor3 = Theme.ToggleOn
            else
                tween(knob, {Position = UDim2.new(0, 3, 0, 2)}, 0.2)
                toggleBack.BackgroundColor3 = Theme.ToggleBackOff
                knob.BackgroundColor3 = Theme.ToggleOff
            end
        end

        toggleBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                refresh()
                if cfg.Callback then cfg.Callback(state) end
            end
        end)

        refresh()
    end

    table.insert(self.Tabs, Tab)
    return Tab
end

return Yohi
