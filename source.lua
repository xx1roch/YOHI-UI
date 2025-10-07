-- YOHI UI v2 (Nothing UI стиль, улучшенный)
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
    Background = Color3.fromRGB(20,20,20),
    Secondary = Color3.fromRGB(50,50,50),
    Accent = Color3.fromRGB(200,200,200),
    Text = Color3.fromRGB(230,230,230),
    Hover = Color3.fromRGB(200,200,200),
    BorderRadius = 8
}
-- Tween helper
local function tween(obj, props, time)
    local tweenInfo = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    return TweenService:Create(obj, tweenInfo, props)
end
-- Button helper with fill animation
local function createButton(props)
    local btn = new("TextButton", props)
    local fill = new("Frame", {
        Parent = btn,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Yohi.Theme.Hover,
        ZIndex = btn.ZIndex - 1
    })
    btn.MouseEnter:Connect(function()
        tween(fill, {Size = UDim2.new(1, 0, 1, 0)}, 0.15):Play()
    end)
    btn.MouseLeave:Connect(function()
        tween(fill, {Size = UDim2.new(0, 0, 1, 0)}, 0.15):Play()
    end)
    return btn
end
-- Main constructor
function Yohi.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Yohi)
    self.Title = cfg.Title or "YOHI UI"
    self.Logo = cfg.Logo or "https://raw.githubusercontent.com/xx1roch/YOHI-UI/main/logo/yohi-logo-main.png"
    self.Keybind = cfg.Keybind or Enum.KeyCode.RightControl
    self.Tabs = {}
    self.currentTab = nil
    self.Minimized = false
    self.isAnimating = false
    -- ScreenGui
    self.ScreenGui = new("ScreenGui",{Name="YOHI_UI", ResetOnSpawn=false, Parent=game:GetService("CoreGui")})
    -- Window
    self.Window = new("Frame",{
        Name="Window",
        Parent=self.ScreenGui,
        Size=UDim2.new(0,800,0,450),
        Position=UDim2.new(0.5,0,0.5,0),
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=Yohi.Theme.Background,
        BorderSizePixel=0,
        ClipsDescendants=true
    })
    new("UICorner",{Parent=self.Window, CornerRadius=UDim.new(0,Yohi.Theme.BorderRadius)})
    self.ScreenGui.Enabled = false
    self.Window.Size = UDim2.new(0,800,0,0)
    self:OpenTween()
    -- Header
    local header = new("Frame",{Name="Header", Parent=self.Window, Size=UDim2.new(1,0,0,60), BackgroundTransparency=1})
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:DragWindow(header)
        end
    end)
    new("ImageLabel",{Parent=header, Size=UDim2.new(0,48,0,48), Position=UDim2.new(0,10,0,6), BackgroundTransparency=1, Image=self.Logo})
    new("TextLabel",{Parent=header, Text=self.Title, Size=UDim2.new(0,200,1,0), Position=UDim2.new(0,70,0,0), BackgroundTransparency=1, TextColor3=Yohi.Theme.Text, Font=Enum.Font.GothamBold, TextSize=20, TextXAlignment=Enum.TextXAlignment.Left})
    -- Sidebar
    local sidebar = new("Frame",{Parent=self.Window, Size=UDim2.new(0,180,1,-60), Position=UDim2.new(0,0,0,60), BackgroundColor3=Yohi.Theme.Secondary})
    new("UICorner",{Parent=sidebar, CornerRadius=UDim.new(0,Yohi.Theme.BorderRadius)})
    -- Content
    local content = new("Frame",{Parent=self.Window, Size=UDim2.new(1,-180,1,-60), Position=UDim2.new(0,180,0,60), BackgroundColor3=Yohi.Theme.Background, ClipsDescendants = true})
    new("UICorner",{Parent=content, CornerRadius=UDim.new(0,Yohi.Theme.BorderRadius)})
    self._ui = {Header=header, Sidebar=sidebar, Content=content}
    -- Toggle GUI with keybind
    UserInputService.InputBegan:Connect(function(input,gameProcessed)
        if gameProcessed then return end
        if input.KeyCode==self.Keybind and not self.isAnimating then
            if self.Minimized then
                self:OpenTween()
            else
                self:CloseTween()
            end
        end
    end)
    return self
end
-- Open/Close with animation lock
function Yohi:OpenTween()
    self.Minimized=false
    self.isAnimating=true
    self.ScreenGui.Enabled=true
    local tw = tween(self.Window,{Size=UDim2.new(0,800,0,450)},0.3)
    tw:Play()
    tw.Completed:Connect(function() self.isAnimating=false end)
end
function Yohi:CloseTween()
    self.Minimized=true
    self.isAnimating=true
    local tw = tween(self.Window,{Size=UDim2.new(0,800,0,0)},0.3)
    tw:Play()
    tw.Completed:Connect(function() self.ScreenGui.Enabled=false self.isAnimating=false end)
end
-- Drag window smoothly
function Yohi:DragWindow(frame)
    local mouse = Players.LocalPlayer:GetMouse()
    local startPos = self.Window.Position
    local startX,startY = mouse.X, mouse.Y
    local conn,upConn
    conn=mouse.Move:Connect(function()
        local deltaX=mouse.X-startX
        local deltaY=mouse.Y-startY
        self.Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+deltaX,startPos.Y.Scale,startPos.Y.Offset+deltaY)
    end)
    upConn=mouse.Button1Up:Connect(function() conn:Disconnect() upConn:Disconnect() end)
end
-- Create Tab with frame, active line and animation
function Yohi:newTab(cfg)
    cfg=cfg or {}
    local tab={Title=cfg.Title or "Tab", Sections={}}
    local btn=createButton({Parent=self._ui.Sidebar, Size=UDim2.new(1,0,0,40), BackgroundColor3=Yohi.Theme.Secondary, Text=tab.Title, TextColor3=Yohi.Theme.Text, Font=Enum.Font.Gotham, TextSize=16, BorderSizePixel=0, AutoButtonColor = false})
    new("UIStroke", {Parent = btn, Color = Color3.fromRGB(100, 100, 100), Thickness = 1})
    local activeLine=new("Frame",{Parent=btn, Size=UDim2.new(0,0,0,3), Position=UDim2.new(0.5, -30, 1, 0), BackgroundColor3=Yohi.Theme.Accent})
    new("UICorner",{Parent=activeLine, CornerRadius=UDim.new(0,2)})
    tab.Frame = new("ScrollingFrame", {Parent = self._ui.Content, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 0, Position = UDim2.new(1, 0, 0, 0)})
    local list = new("UIListLayout", {Parent = tab.Frame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    list.Changed:Connect(function(p)
        if p == "AbsoluteContentSize" then
            tab.Frame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
        end
    end)
    -- On click switch tab with animation
    btn.MouseButton1Click:Connect(function()
        local previous = self.currentTab
        self.currentTab = tab
        if previous then
            local outTw = tween(previous.Frame, {Position = UDim2.new(-1, 0, 0, 0)}, 0.3)
            outTw:Play()
            outTw.Completed:Connect(function() previous.Frame.Visible = false end)
        end
        tab.Frame.Position = UDim2.new(1, 0, 0, 0)
        tab.Frame.Visible = true
        local inTw = tween(tab.Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        inTw:Play()
        -- Animate active line
        for _,b in pairs(self._ui.Sidebar:GetChildren()) do
            if b:IsA("TextButton") and b:FindFirstChildOfClass("Frame") then
                tween(b:FindFirstChildOfClass("Frame"),{Size=UDim2.new(0,0,0,3)},0.2):Play()
            end
        end
        tween(activeLine,{Size=UDim2.new(0,60,0,3)},0.2):Play()
    end)
    function tab:NewToggle(cfg)
        local toggleFrame=new("Frame",{Parent=self.Frame, Size=UDim2.new(0,60,0,30), BackgroundColor3=Color3.fromRGB(80,80,80)})
        new("UICorner",{Parent=toggleFrame, CornerRadius=UDim.new(0,15)})
        local circle=new("Frame",{Parent=toggleFrame, Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,2,0,2), BackgroundColor3=Color3.fromRGB(120,120,120)})
        new("UICorner",{Parent=circle, CornerRadius=UDim.new(1,0)})
        local state=cfg.Default or false
        if state then
            circle.Position = UDim2.new(0,32,0,2)
            circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(200,200,200)
        end
        toggleFrame.MouseButton1Click:Connect(function()
            state=not state
            if state then
                tween(circle,{Position=UDim2.new(0,32,0,2), BackgroundColor3=Color3.fromRGB(255,255,255)},0.2):Play()
                tween(toggleFrame,{BackgroundColor3=Color3.fromRGB(200,200,200)},0.2):Play()
            else
                tween(circle,{Position=UDim2.new(0,2,0,2), BackgroundColor3=Color3.fromRGB(120,120,120)},0.2):Play()
                tween(toggleFrame,{BackgroundColor3=Color3.fromRGB(80,80,80)},0.2):Play()
            end
            if cfg.Callback then cfg.Callback(state) end
        end)
        return toggleFrame
    end
    function tab:NewButton(cfg)
        local btn=createButton({Parent=self.Frame, Size=UDim2.new(0,180,0,30), BackgroundColor3=Yohi.Theme.Secondary, Text=cfg.Title, TextColor3=Yohi.Theme.Text, Font=Enum.Font.Gotham, TextSize=16, BorderSizePixel=0, AutoButtonColor = false})
        btn.MouseButton1Click:Connect(function() if cfg.Callback then cfg.Callback() end end)
        return btn
    end
    function tab:NewSlider(cfg)
        local sliderBG=new("Frame",{Parent=self.Frame, Size=UDim2.new(0,180,0,20), BackgroundColor3=Color3.fromRGB(50,50,50)})
        local sliderTop=new("Frame",{Parent=sliderBG, Size=UDim2.new((cfg.Default-cfg.Min)/(cfg.Max-cfg.Min),0,1,0), BackgroundColor3=Color3.fromRGB(200,200,200)})
        sliderBG.MouseButton1Down:Connect(function()
            local mouse = Players.LocalPlayer:GetMouse()
            local conn
            conn = mouse.Move:Connect(function()
                local pos = math.clamp(mouse.X-sliderBG.AbsolutePosition.X,0,sliderBG.AbsoluteSize.X)
                sliderTop.Size=UDim2.new(pos/sliderBG.AbsoluteSize.X,0,1,0)
                if cfg.Callback then
                    cfg.Callback(cfg.Min+(pos/sliderBG.AbsoluteSize.X)*(cfg.Max-cfg.Min))
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
    function tab:NewDropdown(cfg)
        local drop=createButton({Parent=self.Frame, Size=UDim2.new(0,180,0,30), BackgroundColor3=Yohi.Theme.Secondary, Text=cfg.Title, TextColor3=Yohi.Theme.Text, Font=Enum.Font.Gotham, TextSize=16, BorderSizePixel=0, AutoButtonColor = false})
        local expanded=false
        local optionsFrame=new("Frame",{Parent=drop, Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,1,0), BackgroundColor3=Yohi.Theme.Secondary, ClipsDescendants=true})
        for i, v in ipairs(cfg.Data) do
            local optBtn = createButton({Parent = optionsFrame, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, (i-1)*30), BackgroundColor3 = Yohi.Theme.Secondary, Text = tostring(v), TextColor3 = Yohi.Theme.Text, Font = Enum.Font.Gotham, TextSize = 16, BorderSizePixel = 0, AutoButtonColor = false})
            optBtn.MouseButton1Click:Connect(function()
                drop.Text = tostring(v)
                expanded = false
                tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2):Play()
                if cfg.Callback then cfg.Callback(v) end
            end)
        end
        drop.MouseButton1Click:Connect(function()
            expanded = not expanded
            tween(optionsFrame,{Size=expanded and UDim2.new(1,0,0,#cfg.Data*30) or UDim2.new(1,0,0,0)},0.2):Play()
        end)
        return drop
    end
    function tab:NewKeybind(cfg)
        local keyBtn=createButton({Parent=self.Frame, Size=UDim2.new(0,180,0,30), BackgroundColor3=Yohi.Theme.Secondary, Text=cfg.Title..": "..tostring(cfg.Default), TextColor3=Yohi.Theme.Text, Font=Enum.Font.Gotham, TextSize=16, BorderSizePixel=0, AutoButtonColor = false})
        keyBtn.MouseButton1Click:Connect(function()
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.Keyboard then
                    keyBtn.Text=cfg.Title..": "..tostring(input.KeyCode)
                    if cfg.Callback then cfg.Callback(input.KeyCode) end
                    connection:Disconnect()
                end
            end)
        end)
        return keyBtn
    end
    table.insert(self.Tabs,tab)
    return tab
end
return Yohi
