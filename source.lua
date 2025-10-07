-- YOHI UI Library (Updated)
local Yohi = {}
Yohi.__index = Yohi

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

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
local Theme = {
    Background = Color3.fromRGB(20,20,20),
    Sidebar = Color3.fromRGB(40,40,40),
    Text = Color3.fromRGB(230,230,230),
    Hover = Color3.fromRGB(100,100,100),
    ToggleOn = Color3.fromRGB(255,255,255),
    ToggleOff = Color3.fromRGB(130,130,130),
    ToggleBackOn = Color3.fromRGB(170,170,170),
    ToggleBackOff = Color3.fromRGB(50,50,50)
}

local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Load/save config
local function loadConfig()
    local cfg = LocalPlayer:FindFirstChild("_YOHI_CONFIG")
    if cfg then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, cfg.Value)
        if ok then return data end
    end
    return {}
end
local function saveConfig(data)
    local cfg = LocalPlayer:FindFirstChild("_YOHI_CONFIG")
    if not cfg then
        cfg = Instance.new("StringValue")
        cfg.Name = "_YOHI_CONFIG"
        cfg.Parent = LocalPlayer
    end
    cfg.Value = HttpService:JSONEncode(data)
end

function Yohi.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Yohi)
    self.Title = cfg.Title or "YOHI HUB"
    self.Keybind = cfg.Keybind or Enum.KeyCode.RightControl
    self.Tabs = {}
    self.Open = true
    self.Animating = false
    self.Config = loadConfig()

    self.Gui = new("ScreenGui",{Name="YOHI_UI",Parent=game:GetService("CoreGui"),ResetOnSpawn=false})
    self.Main = new("Frame",{Parent=self.Gui,Size=UDim2.new(0,800,0,450),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Theme.Background})
    new("UICorner",{Parent=self.Main,CornerRadius=UDim.new(0,8)})

    -- Header
    local header = new("Frame",{Parent=self.Main,Size=UDim2.new(1,0,0,60),BackgroundColor3=Theme.Sidebar})
    new("UICorner",{Parent=header,CornerRadius=UDim.new(0,8)})
    new("ImageLabel",{Parent=header,Size=UDim2.new(0,48,0,48),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Image="https://raw.githubusercontent.com/xx1roch/YOHI-UI/main/yohi-logo-main.png"})
    new("TextLabel",{Parent=header,Text="yoxi-gamename",Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,70,0,0),BackgroundTransparency=1,TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left})

    -- Sidebar and Content
    self.Sidebar = new("Frame",{Parent=self.Main,Size=UDim2.new(0,180,1,-60),Position=UDim2.new(0,0,0,60),BackgroundColor3=Theme.Sidebar})
    new("UICorner",{Parent=self.Sidebar,CornerRadius=UDim.new(0,8)})
    self.Content = new("Frame",{Parent=self.Main,Position=UDim2.new(0,180,0,60),Size=UDim2.new(1,-180,1,-60),BackgroundColor3=Theme.Background})
    new("UICorner",{Parent=self.Content,CornerRadius=UDim.new(0,8)})

    -- Keybind toggle GUI
    UserInputService.InputBegan:Connect(function(input,gpe)
        if not gpe and input.KeyCode==self.Keybind and not self.Animating then
            self.Animating=true
            if self.Open then
                tween(self.Main,{Size=UDim2.new(0,800,0,0)},0.25)
                task.delay(0.25,function() self.Gui.Enabled=false self.Open=false self.Animating=false end)
            else
                self.Gui.Enabled=true
                tween(self.Main,{Size=UDim2.new(0,800,0,450)},0.25)
                task.delay(0.25,function() self.Open=true self.Animating=false end)
            end
        end
    end)

    return self
end

function Yohi:NewTab(data)
    local Tab={}
    local btn=new("TextButton",{Parent=self.Sidebar,Size=UDim2.new(1,0,0,40),BackgroundColor3=Theme.Sidebar,BorderSizePixel=0,Text=data.Title or "Tab",TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=16})
    local tabFrame=new("ScrollingFrame",{Parent=self.Content,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),BackgroundTransparency=1,Visible=#self.Tabs==0})
    Tab.Frame=tabFrame
    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.Tabs) do t.Frame.Visible=false end
        tabFrame.Visible=true
    end)

    function Tab:CreateButton(cfg)
        local b=new("TextButton",{Parent=tabFrame,Size=UDim2.new(0,200,0,30),Position=UDim2.new(0,10,0,#tabFrame:GetChildren()*35),BackgroundColor3=Theme.Sidebar,BorderSizePixel=0,Text=cfg.Title or "Button",TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
        b.MouseEnter:Connect(function() tween(b,{BackgroundColor3=Theme.Hover},0.2) end)
        b.MouseLeave:Connect(function() tween(b,{BackgroundColor3=Theme.Sidebar},0.2) end)
        b.MouseButton1Click:Connect(function() if cfg.Callback then cfg.Callback() end end)
    end

    table.insert(self.Tabs,Tab)
    return Tab
end

return Yohi
