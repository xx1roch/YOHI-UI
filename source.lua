-- YOHI UI (Nothing UI стиль)
local Yohi = {}
Yohi.__index = Yohi

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Helper to create UI elements
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- Theme (Nothing UI style)
Yohi.Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(95, 155, 255),
    Text = Color3.fromRGB(230,230,230),
    Secondary = Color3.fromRGB(30, 30, 30),
    Hover = Color3.fromRGB(50, 50, 50),
    BorderRadius = 6
}

-- Tween helper
local function tween(obj, props, time)
    local tweenInfo = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, tweenInfo, props):Play()
end

-- Main UI constructor
function Yohi.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Yohi)
    self.Title = cfg.Title or "YOHI UI"
    self.Logo = cfg.Logo or "https://raw.githubusercontent.com/xx1roch/YOHI-UI/main/logo/yohi-logo-main.png"
    self.Keybind = cfg.Keybind or Enum.KeyCode.RightControl
    self.Tabs = {}

    -- ScreenGui
    self.ScreenGui = new("ScreenGui", {
        Name = "YOHI_UI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })

    -- Main Window
    self.Window = new("Frame", {
        Name = "Window",
        Parent = self.ScreenGui,
        Size = UDim2.new(0,800,0,450),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Yohi.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    -- Smooth open/close
    self.ScreenGui.Enabled = false
    self.Window.Size = UDim2.new(0,800,0,0)
    self:OpenTween()

    -- Header
    local header = new("Frame", {
        Name = "Header",
        Parent = self.Window,
        Size = UDim2.new(1,0,0,60),
        BackgroundTransparency = 1
    })
    new("ImageLabel", {
        Name = "Logo",
        Parent = header,
        Size = UDim2.new(0,48,0,48),
        Position = UDim2.new(0,10,0,6),
        BackgroundTransparency = 1,
        Image = self.Logo
    })
    new("TextLabel", {
        Name = "Title",
        Parent = header,
        Text = self.Title,
        Size = UDim2.new(0,200,1,0),
        Position = UDim2.new(0,70,0,0),
        BackgroundTransparency = 1,
        TextColor3 = Yohi.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Sidebar (tabs)
    local sidebar = new("Frame", {
        Name = "Sidebar",
        Parent = self.Window,
        Size = UDim2.new(0,200,1,-60),
        Position = UDim2.new(0,0,0,60),
        BackgroundColor3 = Yohi.Theme.Secondary
    })

    -- Content Area
    local content = new("Frame", {
        Name = "Content",
        Parent = self.Window,
        Size = UDim2.new(1,-200,1,-60),
        Position = UDim2.new(0,200,0,60),
        BackgroundColor3 = Yohi.Theme.Background
    })

    self._ui = {Header = header, Sidebar = sidebar, Content = content}

    -- Toggle GUI with key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.Keybind then
            if self.ScreenGui.Enabled then
                self:CloseTween()
            else
                self:OpenTween()
            end
        end
    end)

    return self
end

-- Open/Close animation
function Yohi:OpenTween()
    self.ScreenGui.Enabled = true
    tween(self.Window, {Size = UDim2.new(0,800,0,450)},0.3)
end
function Yohi:CloseTween()
    tween(self.Window, {Size = UDim2.new(0,800,0,0)},0.3)
    delay(0.3,function()
        self.ScreenGui.Enabled = false
    end)
end

-- Create Tab
function Yohi.newTab(self,tabcfg)
    tabcfg = tabcfg or {}
    local tab = {Title = tabcfg.Title or "Tab", Sections = {}}

    local btn = new("TextButton",{
        Parent = self._ui.Sidebar,
        Size = UDim2.new(1,0,0,40),
        BackgroundColor3 = Yohi.Theme.Secondary,
        Text = tab.Title,
        TextColor3 = Yohi.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        BorderSizePixel = 0
    })

    -- Hover animation
    btn.MouseEnter:Connect(function()
        tween(btn,{BackgroundColor3 = Yohi.Theme.Hover},0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn,{BackgroundColor3 = Yohi.Theme.Secondary},0.15)
    end)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(self._ui.Content:GetChildren()) do v:Destroy() end
        local frame = new("Frame",{
            Parent = self._ui.Content,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1
        })
        tab._frame = frame
        -- Example elements
        self:AddExampleElements(frame)
    end)

    table.insert(self.Tabs,tab)
    return tab
end

-- Add example UI elements
function Yohi:AddExampleElements(parent)
    local y = 10

    -- Toggle
    local toggle = new("TextButton",{
        Parent = parent,
        Size = UDim2.new(0,180,0,30),
        Position = UDim2.new(0,10,0,y),
        BackgroundColor3 = Yohi.Theme.Secondary,
        Text = "Toggle: OFF",
        TextColor3 = Yohi.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        BorderSizePixel = 0
    })
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = "Toggle: "..(state and "ON" or "OFF")
    end)
    y=y+40

    -- Slider
    local sliderBg = new("Frame",{
        Parent = parent,
        Size = UDim2.new(0,180,0,30),
        Position = UDim2.new(0,10,0,y),
        BackgroundColor3 = Yohi.Theme.Secondary
    })
    local slider = new("Frame",{
        Parent = sliderBg,
        Size = UDim2.new(0,0,1,0),
        BackgroundColor3 = Yohi.Theme.Accent
    })
    sliderBg.MouseButton1Down:Connect(function(x)
        local mouse = game.Players.LocalPlayer:GetMouse()
        local conn
        conn = mouse.Move:Connect(function()
            local pos = math.clamp(mouse.X - sliderBg.AbsolutePosition.X,0,sliderBg.AbsoluteSize.X)
            slider.Size = UDim2.new(0,pos,1,0)
        end)
        local upConn
        upConn = mouse.Button1Up:Connect(function()
            conn:Disconnect()
            upConn:Disconnect()
        end)
    end)
    y=y+40

    -- Button
    local btn = new("TextButton",{
        Parent = parent,
        Size = UDim2.new(0,180,0,30),
        Position = UDim2.new(0,10,0,y),
        BackgroundColor3 = Yohi.Theme.Accent,
        Text = "Button",
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.Gotham,
        TextSize = 16,
        BorderSizePixel = 0
    })
    btn.MouseEnter:Connect(function() tween(btn,{BackgroundColor3 = Yohi.Theme.Hover},0.15) end)
    btn.MouseLeave:Connect(function() tween(btn,{BackgroundColor3 = Yohi.Theme.Accent},0.15) end)
    btn.MouseButton1Click:Connect(function() print("Button pressed!") end)
    y=y+40

    -- Dropdown (basic)
    local drop = new("TextButton",{
        Parent = parent,
        Size = UDim2.new(0,180,0,30),
        Position = UDim2.new(0,10,0,y),
        BackgroundColor3 = Yohi.Theme.Secondary,
        Text = "Dropdown",
        TextColor3 = Yohi.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        BorderSizePixel = 0
    })
    local optionsFrame = new("Frame",{
        Parent = drop,
        Size = UDim2.new(1,0,0,0),
        Position = UDim2.new(0,0,1,0),
        BackgroundColor3 = Yohi.Theme.Secondary,
        ClipsDescendants = true
    })
    local expanded = false
    drop.MouseButton1Click:Connect(function()
        expanded = not expanded
        tween(optionsFrame,{Size = expanded and UDim2.new(1,0,0,60) or UDim2.new(1,0,0,0)},0.2)
    end)
    y=y+70

    -- TextBox
    local tb = new("TextBox",{
        Parent = parent,
        Size = UDim2.new(0,180,0,30),
        Position = UDim2.new(0,10,0,y),
        BackgroundColor3 = Yohi.Theme.Secondary,
        TextColor3 = Yohi.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        PlaceholderText = "Input text",
        BorderSizePixel = 0
    })
end

-- Alias
Yohi.Notification = function() return {} end
function Yohi:NewTab(cfg) return self:newTab(cfg) end

return Yohi
