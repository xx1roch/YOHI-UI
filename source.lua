-- source.lua (YOHI UI) — минимальный скелет
local Yohi = {}
Yohi.__index = Yohi

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- helper for creating Roblox UI instances quickly
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- Notification submodule (very small)
local Notification = {}
Notification.__index = Notification
function Notification.new(config)
    local cfg = config or {}
    -- simple print fallback
    print("[YOHI Notification] "..(cfg.Title or "NoTitle")..": "..(cfg.Description or ""))
end

-- Main constructor
function Yohi.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Yohi)
    self.Title = cfg.Title or "YOHI UI"
    self.Description = cfg.Description or ""
    self.Keybind = cfg.Keybind or Enum.KeyCode.LeftControl
    self.Logo = cfg.Logo or nil
    self.Tabs = {}

    -- create ScreenGui
    self.ScreenGui = new("ScreenGui", {Name = "YOHI_UI", ResetOnSpawn = false, Parent = game:GetService("CoreGui")})
    -- main frame
    self.Window = new("Frame", {
        Name = "Window",
        Parent = self.ScreenGui,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0.5,0,0),
        Size = UDim2.new(0,800,0,450),
        BackgroundColor3 = Color3.fromRGB(18,18,18),
        BorderSizePixel = 0,
    })
    -- header (top)
    local header = new("Frame", {
        Name = "Header",
        Parent = self.Window,
        Size = UDim2.new(1,0,0,64),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
    })
    local titleLabel = new("TextLabel", {
        Name = "Title",
        Parent = header,
        Text = self.Title,
        Size = UDim2.new(0,300,1,0),
        Position = UDim2.new(0,72,0,0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(230,230,230),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    -- logo (left of header)
    if self.Logo then
        local logoImg = new("ImageLabel", {
            Name = "Logo",
            Parent = header,
            Size = UDim2.new(0,48,0,48),
            Position = UDim2.new(0,12,0,8),
            BackgroundTransparency = 1,
            Image = self.Logo,
        })
    else
        local placeholder = new("Frame", {
            Name = "LogoPlaceholder",
            Parent = header,
            Size = UDim2.new(0,48,0,48),
            Position = UDim2.new(0,12,0,8),
            BackgroundColor3 = Color3.fromRGB(40,40,40),
            BorderSizePixel = 0,
        })
    end

    -- left sidebar (tabs)
    local sidebar = new("Frame", {
        Name = "Sidebar",
        Parent = self.Window,
        Size = UDim2.new(0,200,1,-64),
        Position = UDim2.new(0,0,0,64),
        BackgroundColor3 = Color3.fromRGB(24,24,24),
        BorderSizePixel = 0,
    })

    -- right content area
    local content = new("Frame", {
        Name = "Content",
        Parent = self.Window,
        Size = UDim2.new(1,-200,1,-64),
        Position = UDim2.new(0,200,0,64),
        BackgroundColor3 = Color3.fromRGB(16,16,16),
        BorderSizePixel = 0,
    })

    self._ui = {
        Header = header,
        Sidebar = sidebar,
        Content = content,
    }

    -- keybind to toggle visibility
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.Keybind then
            self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        end
    end)

    return self
end

-- create new tab
function Yohi.newTab(self, tabcfg)
    tabcfg = tabcfg or {}
    local tab = {
        Title = tabcfg.Title or "Tab",
        Description = tabcfg.Description or "",
        Icon = tabcfg.Icon or nil,
        Sections = {},
    }
    -- UI: add button to sidebar
    local btn = new("TextButton", {
        Parent = self._ui.Sidebar,
        Size = UDim2.new(1,0,0,48),
        BackgroundTransparency = 1,
        Text = tab.Title,
        TextColor3 = Color3.fromRGB(220,220,220),
        Font = Enum.Font.Gotham,
        TextSize = 16,
    })
    -- when click, show this tab's page (simple implementation)
    btn.MouseButton1Click:Connect(function()
        -- clear content
        for _,v in pairs(self._ui.Content:GetChildren()) do
            v:Destroy()
        end
        -- create a simple label as placeholder
        local lbl = new("TextLabel", {
            Parent = self._ui.Content,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Text = tab.Title.."\n"..tab.Description,
            TextColor3 = Color3.fromRGB(200,200,200),
            Font = Enum.Font.Gotham,
            TextSize = 18,
        })
    end)

    table.insert(self.Tabs, tab)
    return tab
end

-- alias for compatibility with NOTHING naming
Yohi.new = Yohi.new
Yohi.Notification = function() return Notification end
-- expose NewTab method with compatibility name
Yohi.new.__index = Yohi
function Yohi:NewTab(cfg) return self:newTab(cfg) end

return Yohi
