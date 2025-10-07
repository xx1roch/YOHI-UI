-- source.lua (compact)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local hasWrite = type(writefile) == "function" and type(readfile) == "function"
local hasList = type(listfiles) == "function"
local FILE_DIR = "yohi_configs"

local function create(class, props)
local obj = Instance.new(class)
if props then for k,v in pairs(props) do pcall(function() obj[k]=v end) end end
return obj
end

local function tween(obj, props, t)
local ti = TweenInfo.new(t or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tw = TweenService:Create(obj, ti, props)
tw:Play()
return tw
end

local Themes = {
Default = {
Background = Color3.fromRGB(18,18,18),
Sidebar = Color3.fromRGB(40,40,40),
Accent = Color3.fromRGB(160,160,160),
Text = Color3.fromRGB(230,230,230),
Button = Color3.fromRGB(120,120,120),
HoverFill = Color3.fromRGB(200,200,200),
ToggleKnobOn = Color3.fromRGB(255,255,255),
ToggleKnobOff = Color3.fromRGB(140,140,140),
ToggleBackOn = Color3.fromRGB(220,220,220),
ToggleBackOff = Color3.fromRGB(70,70,70),
Indicator = Color3.fromRGB(160,160,160)
},
Blue = { Background = Color3.fromRGB(18,18,22), Sidebar = Color3.fromRGB(25,30,50), Accent = Color3.fromRGB(95,160,255), Text = Color3.fromRGB(230,230,230), Button = Color3.fromRGB(80,100,140), HoverFill = Color3.fromRGB(170,200,255), ToggleKnobOn = Color3.fromRGB(255,255,255), ToggleKnobOff = Color3.fromRGB(140,140,140), ToggleBackOn = Color3.fromRGB(180,210,255), ToggleBackOff = Color3.fromRGB(40,50,80), Indicator = Color3.fromRGB(95,160,255) }
}

local Module = {}
Module.__index = Module

-- Simple config system
local Config = {
controls = {}, -- id -> {get,set}
folder = FILE_DIR
}

function Config:Register(id, getfn, setfn)
if not id or type(getfn)~="function" or type(setfn)~="function" then return end
self.controls[id] = {get = getfn, set = setfn}
end

local function ensureFolder()
if hasWrite and type(isfolder) == "function" and not isfolder(Config.folder) then
pcall(function() makefolder(Config.folder) end)
end
end

local function writeLocal(name, json)
if not hasWrite then return false, "no writefile" end
ensureFolder()
local path = Config.folder.."/"..name..".json"
local ok, err = pcall(function() writefile(path, json) end)
return ok, err
end

local function readLocal(name)
if not hasWrite then return nil end
local path = Config.folder.."/"..name..".json"
if pcall(function() return readfile(path) end) then
local ok, content = pcall(readfile, path)
if ok then return content end
end
return nil
end

local function saveToAttr(name, json)
if not LocalPlayer then return false end
local ok, err = pcall(function() LocalPlayer:SetAttribute("yohi_cfg_"..name, json) end)
return ok, err
end

local function loadFromAttr(name)
if not LocalPlayer then return nil end
local ok, val = pcall(function() return LocalPlayer:GetAttribute("yohi_cfg_"..name) end)
if ok then return val end
return nil
end

function Config:Save(name)
if not name or name == "" then return false, "empty name" end
local snap = {}
for id, c in pairs(self.controls) do
local ok, v = pcall(c.get)
if ok then snap[id] = v end
end
local payload = HttpService:JSONEncode({meta = {name = name, time = os.time()}, data = snap})
if hasWrite then
local ok,err = writeLocal(name, payload)
if ok then return true end
end
local ok,err = saveToAttr(name, payload)
if ok then return true end
return false, "no method"
end

function Config:Load(name)
if not name or name=="" then return false, "empty name" end
local json = nil
if hasWrite then json = readLocal(name) end
if not json then json = loadFromAttr(name) end
if not json then return false, "not found" end
local ok,p = pcall(function() return HttpService:JSONDecode(json) end)
if not ok or type(p)~="table" then return false, "invalid" end
local data = p.data or {}
for id, val in pairs(data) do
local c = self.controls[id]
if c and type(c.set)=="function" then pcall(c.set, val) end
end
return true
end

function Config:ListLocal()
local names = {}
if hasList then
pcall(function()
for _,f in ipairs(listfiles(Config.folder)) do
local n = f:match("([^/\]+)%.json$")
if n then table.insert(names, n) end
end
end)
end
return names
end

-- Module constructor
function Module.new(opts)
opts = opts or {}
local self = setmetatable({}, Module)
self.Keybind = opts.Keybind or Enum.KeyCode.RightControl
self.Theme = Themes[opts.Theme or "Default"] or Themes.Default
self.Animating = false
self.Open = true
self.Tabs = {}
self.Config = Config

```
-- GUI
local sg = create("ScreenGui",{Name="YOHI_UI",ResetOnSpawn=false,Parent=game:GetService("CoreGui"),ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
self.Gui = sg

local main = create("Frame",{Parent=sg,Size=UDim2.new(0,800,0,450),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=self.Theme.Background,BorderSizePixel=0})
create("UICorner",{Parent=main,CornerRadius=UDim.new(0,8)})
self.Main = main

-- Top bar
local top = create("Frame",{Parent=main,Size=UDim2.new(1,0,0,64),BackgroundTransparency=1})
local logo = create("ImageLabel",{Parent=top,Size=UDim2.new(0,48,0,48),Position=UDim2.new(0,16,0,8),BackgroundTransparency=1,Image="https://raw.githubusercontent.com/xx1roch/YOHI-UI/main/yohi-logo-main.png",ScaleType=Enum.ScaleType.Fit})
local title = create("TextLabel",{Parent=top,Size=UDim2.new(0,300,0,48),Position=UDim2.new(0,80,0,8),BackgroundTransparency=1,Text="yoxi-gamename",TextColor3=self.Theme.Text,Font=Enum.Font.GothamBold,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left})

-- Sidebar + Content
local sidebar = create("Frame",{Parent=main,Size=UDim2.new(0,180,1,-64),Position=UDim2.new(0,0,0,64),BackgroundColor3=self.Theme.Sidebar,BorderSizePixel=0})
create("UICorner",{Parent=sidebar,CornerRadius=UDim.new(0,8)})
local content = create("Frame",{Parent=main,Position=UDim2.new(0,180,0,64),Size=UDim2.new(1,-180,1,-64),BackgroundColor3=self.Theme.Background,BorderSizePixel=0})
create("UICorner",{Parent=content,CornerRadius=UDim.new(0,8)})
local pages = create("Frame",{Parent=content,Size=UDim2.new(1,1,1,0),BackgroundTransparency=1})
self.Sidebar = sidebar
self.Pages = pages

-- Drag fix
do
    local dragging, start, startPos
    main.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = inp.Position
            startPos = main.AbsolutePosition
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - start
            main.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)
end

-- Keybind toggle (animation lock)
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == self.Keybind then
        if self.Animating then return end
        self.Animating = true
        if self.Open then
            local tw = tween(main, {Size = UDim2.new(0,800,0,0)}, 0.22)
            tw.Completed:Connect(function()
                self.Gui.Enabled = false
                self.Open = false
                self.Animating = false
            end)
        else
            self.Gui.Enabled = true
            local tw = tween(main, {Size = UDim2.new(0,800,0,450)}, 0.22)
            tw.Completed:Connect(function()
                self.Open = true
                self.Animating = false
            end)
        end
    end
end)

-- create base tabs
for _,name in ipairs({"Main","Info","Config","Settings"}) do
    self:NewTab(name)
end

return self
```

end

function Module:ApplyTheme()
self.Theme = self.Theme or Themes.Default
self.Main.BackgroundColor3 = self.Theme.Background
self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
for _,t in ipairs(self.Tabs) do
if t.Button then t.Button.TextColor3 = self.Theme.Text; t.Button.BackgroundColor3 = self.Theme.Sidebar end
end
end

function Module:SetTheme(name)
if Themes[name] then
self.Theme = Themes[name]
self:ApplyTheme()
end
end

-- NewTab simple: creates sidebar button + page
function Module:NewTab(title)
local btn = create("TextButton",{Parent=self.Sidebar,Size=UDim2.new(1,0,0,46),BackgroundColor3=self.Theme.Sidebar,BorderSizePixel=0,Text=""})
create("UICorner",{Parent=btn,CornerRadius=UDim.new(0,6)})
local label = create("TextLabel",{Parent=btn,Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=title,TextColor3=self.Theme.Text,Font=Enum.Font.Gotham,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left})
local fill = create("Frame",{Parent=btn,Size=UDim2.new(0,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=self.Theme.HoverFill,BorderSizePixel=0,ZIndex=btn.ZIndex-1})
create("UICorner",{Parent=fill,CornerRadius=UDim.new(0,6)})
fill.BackgroundTransparency = 0.8
local indicator = create("Frame",{Parent=btn,Size=UDim2.new(0.3,0,0,4),Position=UDim2.new(0.5,0,1,-4),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=self.Theme.Indicator,Visible=false})
create("UICorner",{Parent=indicator,CornerRadius=UDim.new(0,4)})

```
local page = create("ScrollingFrame",{Parent=self.Pages,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),BackgroundTransparency=1,Visible=false,ScrollBarThickness=6})
table.insert(self.Tabs, {Button = btn, Page = page, Indicator = indicator, Title = title})

btn.MouseEnter:Connect(function() tween(fill,{Size=UDim2.new(1,0,1,0)},0.22) end)
btn.MouseLeave:Connect(function() tween(fill,{Size=UDim2.new(0,0,1,0)},0.22) end)
btn.MouseButton1Click:Connect(function()
    if self.Animating then return end
    self.Animating = true
    for _,t in ipairs(self.Tabs) do
        if t.Page.Visible and t.Page ~= page then
            t.Page.Visible = false
            if t.Indicator then t.Indicator.Visible = false end
        end
        if t.Button and t.Button ~= btn then tween(t.Button,{BackgroundColor3=self.Theme.Sidebar},0.12) end
    end
    page.Visible = true
    page.Position = UDim2.new(1,0,0,0)
    tween(page,{Position=UDim2.new(0,0,0,0)},0.25).Completed:Connect(function() self.Animating = false end)
    if indicator then indicator.Visible = true end
    tween(btn,{BackgroundColor3=Color3.fromRGB(50,50,50)},0.12)
end)

-- open first tab by default
local any = false
for _,t in ipairs(self.Tabs) do if t.Page.Visible then any = true end end
if not any then page.Visible = true; indicator.Visible = true end

-- Tab API
local Tab = {}
function Tab:CreateButton(cfg)
    cfg = cfg or {}
    local b = create("TextButton",{Parent=page,Size=UDim2.new(0,300,0,32),Position=UDim2.new(0,12,0,#page:GetChildren()*40),BackgroundColor3=self.Theme.Button,BorderSizePixel=0,Text=cfg.Text or "Button",TextColor3=self.Theme.Text,Font=Enum.Font.Gotham,TextSize=14,AutoButtonColor=false})
    create("UICorner",{Parent=b,CornerRadius=UDim.new(0,6)})
    local overlay = create("Frame",{Parent=b,Size=UDim2.new(0,0,1,0),BackgroundColor3=self.Theme.HoverFill,ZIndex=b.ZIndex-1})
    create("UICorner",{Parent=overlay,CornerRadius=UDim.new(0,6)})
    b.MouseEnter:Connect(function() tween(overlay,{Size=UDim2.new(1,0,1,0)},0.22) end)
    b.MouseLeave:Connect(function() tween(overlay,{Size=UDim2.new(0,0,1,0)},0.22) end)
    b.MouseButton1Click:Connect(function() if cfg.Callback then pcall(cfg.Callback) end end)
    return b
end

function Tab:CreateToggle(cfg)
    cfg = cfg or {}
    assert(cfg.Id, "Toggle requires Id")
    local state = cfg.Default and true or false
    local cont = create("Frame",{Parent=page,Size=UDim2.new(0,140,0,32),Position=UDim2.new(0,12,0,#page:GetChildren()*40),BackgroundTransparency=1})
    local back = create("Frame",{Parent=cont,Size=UDim2.new(0,48,0,24),Position=UDim2.new(0,0,0,4),BackgroundColor3=self.Theme.ToggleBackOff,BorderSizePixel=0})
    create("UICorner",{Parent=back,CornerRadius=UDim.new(1,0)})
    local knob = create("Frame",{Parent=back,Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,3,0,2),BackgroundColor3=self.Theme.ToggleKnobOff,BorderSizePixel=0})
    create("UICorner",{Parent=knob,CornerRadius=UDim.new(1,0)})
    local label = create("TextLabel",{Parent=cont,Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,60,0,0),BackgroundTransparency=1,Text=cfg.Label or cfg.Id,TextColor3=self.Theme.Text,Font=Enum.Font.Gotham,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left})
    local function refresh()
        if state then tween(knob,{Position=UDim2.new(0,27,0,2)},0.18); back.BackgroundColor3=self.Theme.ToggleBackOn; knob.BackgroundColor3=self.Theme.ToggleKnobOn
        else tween(knob,{Position=UDim2.new(0,3,0,2)},0.18); back.BackgroundColor3=self.Theme.ToggleBackOff; knob.BackgroundColor3=self.Theme.ToggleKnobOff end
    end
    back.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then state = not state; refresh(); if cfg.Callback then pcall(cfg.Callback,state) end end end)
    refresh()
    self.Config:Register(cfg.Id, function() return state end, function(v) state = v; refresh() end)
    return {Get=function() return state end, Set=function(v) state = v; refresh() end}
end

function Tab:CreateSlider(cfg)
    cfg = cfg or {}
    assert(cfg.Id, "Slider requires Id")
    local min = cfg.Min or 0 local max = cfg.Max or 100
    local value = cfg.Default or min
    local frame = create("Frame",{Parent=page,Size=UDim2.new(0,320,0,48),Position=UDim2.new(0,12,0,#page:GetChildren()*48),BackgroundTransparency=1})
    local top = create("Frame",{Parent=frame,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,8),BackgroundColor3=self.Theme.Accent,BorderSizePixel=0})
    create("UICorner",{Parent=top,CornerRadius=UDim.new(0,6)})
    local bottom = create("Frame",{Parent=frame,Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,0,20),BackgroundColor3=self.Theme.Accent:lerp(Color3.new(0,0,0),0.05),BorderSizePixel=0})
    create("UICorner",{Parent=bottom,CornerRadius=UDim.new(0,4)})
    local knob = create("Frame",{Parent=frame,Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,0,0,6),BackgroundColor3=self.Theme.ToggleKnobOn,BorderSizePixel=0})
    create("UICorner",{Parent=knob,CornerRadius=UDim.new(1,0)})
    local dragging = false
    local function setFromX(x)
        local abs = frame.AbsolutePosition.X local w = frame.AbsoluteSize.X
        local rel = math.clamp((x - abs) / w, 0, 1)
        value = min + rel * (max - min)
        knob.Position = UDim2.new(rel, -7, 0, 6)
        if cfg.Callback then pcall(cfg.Callback, value) end
    end
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end end)
    local function refresh() local rel = (value - min)/(max - min); knob.Position = UDim2.new(rel, -7, 0, 6); if cfg.Callback then pcall(cfg.Callback, value) end end
    refresh()
    self.Config:Register(cfg.Id, function() return value end, function(v) value = tonumber(v) or value; refresh() end)
    return {Get=function() return value end, Set=function(v) value = tonumber(v) or value; refresh() end}
end

-- Expose Tab creation for external use
return Tab
```

end

return setmetatable({}, { __call = function(_,opts) return Module.new(opts) end })
