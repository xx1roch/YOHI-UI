-- YOHI UI Updated (Nothing UI style)
local Yohi = {}
Yohi.__index = Yohi

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Helper
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- Theme
Yohi.Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(95, 155, 255),
    Text = Color3.fromRGB(230,230,230),
    Secondary = Color3.fromRGB(30, 30, 30),
    Hover = Color3.fromRGB(50, 50, 50),
    BorderRadius = 8
}

-- Tween helper
local function tween(obj, props, time)
    local tweenInfo = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, tweenInfo, props):Play()
end

-- Main constructor
function Yohi.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Yohi)
    self.Title = cfg.Title or "YOHI UI"
    self.Logo = cfg.Logo or "https://raw.githubusercontent.com/xx1roch/YOHI-UI/main/logo/yohi-logo-main.png"
    self.Keybind = cfg.Keybind or Enum.KeyCode.RightControl
    self.Tabs = {}
    self.Minimized = false

    -- ScreenGui
    self.ScreenGui = new("ScreenGui", {Name = "YOHI_UI", ResetOnSpawn = false, Parent = game:GetService("CoreGui")})

    -- Window
    self.Window = new("Frame", {
        Name = "Window",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 800, 0, 450),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Yohi.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    self.WindowCorner = new("UICorner", {Parent = self.Window, CornerRadius = UDim.new(0, Yohi.Theme.BorderRadius)})

    -- Smooth open
    self.ScreenGui.Enabled = false
    self.Window.Size = UDim2.new(0,800,0,0)
    self:OpenTween()

    -- Header
    local header = new("Frame", {Name="Header", Parent=self.Window, Size=UDim2.new(1,0,0,60), BackgroundTransparency=1})
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:DragWindow(header)
        end
    end)
    new("ImageLabel",{Name="Logo", Parent=header, Size=UDim2.new(0,48,0,48), Position=UDim2.new(0,10,0,6), BackgroundTransparency=1, Image=self.Logo})
    new("TextLabel",{Name="Title", Parent=header, Text=self.Title, Size=UDim2.new(0,200,1,0), Position=UDim2.new(0,70,0,0), BackgroundTransparency=1, TextColor3=Yohi.Theme.Text, Font=Enum.Font.GothamBold, TextSize=20, TextXAlignment=Enum.TextXAlignment.Left})

    -- Sidebar
    local sidebar = new("Frame",{Name="Sidebar", Parent=self.Window, Size=UDim2.new(0,180,1,-60), Position=UDim2.new(0,0,0,60), BackgroundColor3=Yohi.Theme.Secondary})
    local sidebarCorner = new("UICorner",{Parent=sidebar, CornerRadius=UDim.new(0, Yohi.Theme.BorderRadius)})

    -- Content
    local content = new("Frame",{Name="Content", Parent=self.Window, Size=UDim2.new(1,-180,1,-60), Position=UDim2.new(0,180,0,60), BackgroundColor3=Yohi.Theme.Background})
    local contentCorner = new("UICorner",{Parent=content, CornerRadius=UDim.new(0, Yohi.Theme.BorderRadius)})

    self._ui = {Header=header, Sidebar=sidebar, Content=content}

    -- Toggle GUI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.Keybind then
            if self.Minimized then
                self:OpenTween()
            else
                self:CloseTween()
            end
        end
    end)

    return self
end

-- Open/Close
function Yohi:OpenTween()
    self.Minimized = false
    self.ScreenGui.Enabled = true
    tween(self.Window,{Size=UDim2.new(0,800,0,450)},0.3)
end
function Yohi:CloseTween()
    self.Minimized = true
    tween(self.Window,{Size=UDim2.new(0,800,0,0)},0.3)
    delay(0.3,function() self.ScreenGui.Enabled = false end)
end

-- Dragging
function Yohi:DragWindow(frame)
    local mouse = Players.LocalPlayer:GetMouse()
    local startPos = frame.Position
    local startX, startY = mouse.X, mouse.Y
    local conn,upConn
    conn = mouse.Move:Connect(function()
        local deltaX = mouse.X - startX
        local deltaY = mouse.Y - startY
        tween(self.Window,{Position=UDim2.new(startPos.X.Scale, startPos.X.Offset + deltaX, startPos.Y.Scale, startPos.Y.Offset + deltaY)},0.05)
    end)
    upConn = mouse.Button1Up:Connect(function()
        conn:Disconnect()
        upConn:Disconnect()
    end)
end

-- Create Tab
function Yohi.newTab(self, tabcfg)
    tabcfg = tabcfg or {}
    local tab = {Title=tabcfg.Title or "Tab", Sections={}}

    local btn = new("TextButton",{
        Parent=self._ui.Sidebar,
        Size=UDim2.new(1,0,0,40),
        BackgroundColor3=Yohi.Theme.Secondary,
        Text=tab.Title,
        TextColor3=Yohi.Theme.Text,
        Font=Enum.Font.Gotham,
        TextSize=16,
        BorderSizePixel=0
    })

    btn.MouseEnter:Connect(function() tween(btn,{BackgroundColor3=Yohi.Theme.Hover},0.15) end)
    btn.MouseLeave:Connect(function() tween(btn,{BackgroundColor3=Yohi.Theme.Secondary},0.15) end)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(self._ui.Content:GetChildren()) do v:Destroy() end
        local frame = new("Frame",{Parent=self._ui.Content, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1})
        tab._frame = frame
        self:PopulateTab(frame)
    end)

    table.insert(self.Tabs, tab)
    return tab
end

-- Populate test tab with elements
function Yohi:PopulateTab(parent)
    local Section = {}

    function Section:NewToggle(cfg)
        local toggle = new("TextButton",{Parent=parent, Size=UDim2.new(0,180,0,30), Position=UDim2.new(0,10,0,10), BackgroundColor3=Yohi.Theme.Secondary, Text=cfg.Title..": OFF", TextColor3=Yohi.Theme.Text, Font=Enum.Font.Gotham, TextSize=16, BorderSizePixel=0})
        local state = cfg.Default or false
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = cfg.Title..": "..(state and "ON" or "OFF")
            if cfg.Callback then cfg.Callback(state) end
        end)
        return toggle
    end

    function Section:NewButton(cfg)
        local btn = new("TextButton",{Parent=parent, Size=UDim2.new(0,180,0,30), Position=UDim2.new(0,10,0,50), BackgroundColor3=Yohi.Theme.Accent, Text=cfg.Title, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.Gotham, TextSize=16, BorderSizePixel=0})
        btn.MouseEnter:Connect(function() tween(btn,{BackgroundColor3=Yohi.Theme.Hover},0.15) end)
        btn.MouseLeave:Connect(function() tween(btn,{BackgroundColor3=Yohi.Theme.Accent},0.15) end)
        btn.MouseButton1Click:Connect(function() if cfg.Callback then cfg.Callback() end end)
        return btn
    end

    function Section:NewSlider(cfg)
        local sliderBG = new("Frame",{Parent=parent, Size=UDim2.new(0,180,0,30), Position=UDim2.new(0,10,0,90), BackgroundColor3=Yohi.Theme.Secondary})
        local sliderFill = new("Frame",{Parent=sliderBG, Size=UDim2.new(0,(cfg.Default-cfg.Min)/(cfg.Max-cfg.Min)*180,1,0), BackgroundColor3=Yohi.Theme.Accent})
        sliderBG.MouseButton1Down:Connect(function(x)
            local mouse = Players.LocalPlayer:GetMouse()
            local conn
            conn = mouse.Move:Connect(function()
                local pos = math.clamp(mouse.X - sliderBG.AbsolutePosition.X,0,sliderBG.AbsoluteSize.X)
                sliderFill.Size = UDim2.new(0,pos,1,0)
                if cfg.Callback then
                    local val = cfg.Min + (pos/sliderBG.AbsoluteSize.X)*(cfg.Max-cfg.Min)
                    cfg.Callback(val)
                end
            end)
            local upConn
            upConn = mouse.Button1Up:Connect(function()
                conn:Disconnect()
                upConn:Disconnect()
            end)
        end)
        return sliderBG
    end

    function Section:NewDropdown(cfg)
        local drop = new("TextButton",{Parent=parent, Size=UDim2.new(0,180,0,30), Position=UDim2.new(0,10,0,130), BackgroundColor3=Yohi.Theme.Secondary, Text=cfg.Title, TextColor3=Yohi.Theme.Text, Font=Enum.Font.Gotham, TextSize=16, BorderSizePixel=0})
        local expanded = false
        local optionsFrame = new("Frame",{Parent=drop, Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,1,0), BackgroundColor3=Yohi.Theme.Secondary, ClipsDescendants=true})
        drop.MouseButton1Click:Connect(function()
            expanded = not expanded
            tween(optionsFrame,{Size = expanded and UDim2.new(1,0,0,#cfg.Data*30) or UDim2.new(1,0,0,0)},0.2)
        end)
        return drop
    end

    function Section:NewKeybind(cfg)
        local keyBtn = new("TextButton",{Parent=parent, Size=UDim2.new(0,180,0,30), Position=UDim2.new(0,10,0,170), BackgroundColor3=Yohi.Theme.Secondary, Text=cfg.Title..": "..tostring(cfg.Default), TextColor3=Yohi.Theme.Text, Font=Enum.Font.Gotham, TextSize=16, BorderSizePixel=0})
        keyBtn.MouseButton1Click:Connect(function()
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    keyBtn.Text = cfg.Title..": "..tostring(input.KeyCode)
                    if cfg.Callback then cfg.Callback(input.KeyCode) end
                    connection:Disconnect()
                end
            end)
        end)
        return keyBtn
    end

    -- Example elements
    Section:NewToggle({Title="Toggle", Default=false, Callback=function(tr) print(tr) end})
    Section:NewToggle({Title="Auto Farm", Default=false, Callback=function(tr) print(tr) end})
    Section:NewButton({Title="Kill All", Callback=function() print("killed") end})
    Section:NewButton({Title="Teleport", Callback=function() print("tp") end})
    Section:NewSlider({Title="Slider", Min=10, Max=50, Default=25, Callback=function(a) print(a) end})
    Section:NewSlider({Title="WalkSpeed", Min=15, Max=50, Default=16, Callback=function(a) print(a) end})
    Section:NewKeybind({Title="Keybind", Default=Enum.KeyCode.RightAlt, Callback=function(a) print(a) end})
    Section:NewKeybind({Title="Auto Combo", Default=Enum.KeyCode.T, Callback=function(a) print(a) end})
    Section:NewDropdown({Title="Dropdown", Data={1,2,3,4,5}, Default=1, Callback=function(a) print(a) end})
    Section:NewDropdown({Title="Method", Data={"Teleport","Locker","Auto"}, Default="Auto", Callback=function(a) print(a) end})
end

-- Alias
Yohi.Notification = function() return {} end
function Yohi:NewTab(cfg) return self:newTab(cfg) end

return Yohi
