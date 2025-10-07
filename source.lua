
-- YOHI UI Updated (Refined)
local Yohi = {}
Yohi.__index = Yohi

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local function new(class, props)
    local obj = Instance.new(class)
    if props then for k,v in pairs(props) do pcall(function() obj[k] = v end) end end
    return obj
end

Yohi.Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(160, 160, 160),
    Text = Color3.fromRGB(230,230,230),
    Secondary = Color3.fromRGB(40, 40, 40),
    Hover = Color3.fromRGB(100, 100, 100),
    BorderRadius = 8
}

local function tween(obj, props, time)
    local tweenInfo = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, tweenInfo, props):Play()
end

function Yohi.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Yohi)
    self.Title = cfg.Title or "YOHI UI"
    self.Keybind = cfg.Keybind or Enum.KeyCode.RightControl
    self.Tabs = {}
    self.Minimized = false
    self.IsAnimating = false

    self.ScreenGui = new("ScreenGui", {Name = "YOHI_UI", ResetOnSpawn = false, Parent = game:GetService("CoreGui")})
    self.Window = new("Frame", {
        Name = "Window",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 800, 0, 0),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Yohi.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    new("UICorner", {Parent = self.Window, CornerRadius = UDim.new(0, Yohi.Theme.BorderRadius)})

    self.ScreenGui.Enabled = false
    self:OpenTween()

    local header = new("Frame", {Name="Header", Parent=self.Window, Size=UDim2.new(1,0,0,60), BackgroundTransparency=1})
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then self:DragWindow(header) end
    end)
    new("TextLabel",{Name="Title", Parent=header, Text=self.Title, Size=UDim2.new(0,200,1,0), Position=UDim2.new(0,70,0,0), BackgroundTransparency=1, TextColor3=Yohi.Theme.Text, Font=Enum.Font.GothamBold, TextSize=20, TextXAlignment=Enum.TextXAlignment.Left})

    local sidebar = new("Frame",{Name="Sidebar", Parent=self.Window, Size=UDim2.new(0,180,1,-60), Position=UDim2.new(0,0,0,60), BackgroundColor3=Yohi.Theme.Secondary})
    new("UICorner",{Parent=sidebar, CornerRadius=UDim.new(0, Yohi.Theme.BorderRadius)})

    local content = new("Frame",{Name="Content", Parent=self.Window, Size=UDim2.new(1,-180,1,-60), Position=UDim2.new(0,180,0,60), BackgroundColor3=Yohi.Theme.Background})
    new("UICorner",{Parent=content, CornerRadius=UDim.new(0, Yohi.Theme.BorderRadius)})

    self._ui = {Header=header, Sidebar=sidebar, Content=content}

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.Keybind then
            if self.Minimized then self:OpenTween() else self:CloseTween() end
        end
    end)

    return self
end

function Yohi:OpenTween()
    if self.IsAnimating then return end
    self.IsAnimating = true
    self.Minimized = false
    self.ScreenGui.Enabled = true
    tween(self.Window,{Size=UDim2.new(0,800,0,450)},0.3)
    delay(0.3,function() self.IsAnimating = false end)
end

function Yohi:CloseTween()
    if self.IsAnimating then return end
    self.IsAnimating = true
    self.Minimized = true
    tween(self.Window,{Size=UDim2.new(0,800,0,0)},0.3)
    delay(0.3,function()
        self.ScreenGui.Enabled = false
        self.IsAnimating = false
    end)
end

function Yohi:DragWindow(frame)
    local mouse = Players.LocalPlayer:GetMouse()
    local startPos = self.Window.Position
    local startX, startY = mouse.X, mouse.Y
    local conn,upConn
    conn = mouse.Move:Connect(function()
        local deltaX = mouse.X - startX
        local deltaY = mouse.Y - startY
        self.Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + deltaX, startPos.Y.Scale, startPos.Y.Offset + deltaY)
    end)
    upConn = mouse.Button1Up:Connect(function()
        conn:Disconnect()
        upConn:Disconnect()
    end)
end

function Yohi:NewTab(cfg)
    cfg = cfg or {}
    local tab = {Title=cfg.Title or "Tab", Sections={}}
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
    btn.MouseEnter:Connect(function()
        local fill = new("Frame", {
            BackgroundColor3 = Yohi.Theme.Hover,
            Size = UDim2.new(0,0,1,0),
            BorderSizePixel = 0,
            Parent = btn,
            ZIndex = 0
        })
        tween(fill, {Size = UDim2.new(1,0,1,0)}, 0.3)
        delay(0.3, function() if fill then fill:Destroy() end end)
    end)
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(self._ui.Content:GetChildren()) do v:Destroy() end
        local frame = new("Frame",{Parent=self._ui.Content, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1})
        tab._frame = frame
    end)
    table.insert(self.Tabs, tab)
    return tab
end

return Yohi
