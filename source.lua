-- YOHI UI Library
-- Author: xx1roch
-- Inspired by Nothing UI
-- Version: 1.0

local Yohi = {}
Yohi.__index = Yohi

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- helper function to simplify Instance creation
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- Notification system (placeholder for now)
local Notification = {}
Notification.__index = Notification
function Notification.new(config)
    local cfg = config or {}
    print("[YOHI Notification] " .. (cfg.Title or "NoTitle") .. ": " .. (cfg.Description or ""))
end

-- Main UI Constructor
function Yohi.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Yohi)

    self.Title = cfg.Title or "YOHI UI"
    self.Description = cfg.Description or ""
    self.Keybind = cfg.Keybind or Enum.KeyCode.RightControl
    self.Logo = cfg.Logo or "https://raw.githubusercontent.com/xx1roch/YOHI-UI/main/logo/yohi-logo-main.png"
    self.Tabs = {}

    -- ScreenGui
    self.ScreenGui = new("ScreenGui", {
        Name = "YOHI_UI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })

    -- Main window
    self.Window = new("Frame", {
        Name = "Window",
        Parent = self.ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 800, 0, 450),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
    })

    -- Header
    local header = new("Frame", {
        Name = "Header",
        Parent = self.Window,
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
    })

    -- Logo
    if self.Logo then
        new("ImageLabel", {
            Name = "Logo",
            Parent = header,
            Size = UDim2.new(0, 48, 0, 48),
            Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            Image = self.Logo,
        })
    end

    -- Title text
    new("TextLabel", {
        Name = "Title",
        Parent = header,
        Text = self.Title,
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(0, 72, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Sidebar
    local sidebar = new("Frame", {
        Name = "Sidebar",
        Parent = self.Window,
        Size = UDim2.new(0, 200, 1, -64),
        Position = UDim2.new(0, 0, 0, 64),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
    })

    -- Content area
    local content = new("Frame", {
        Name = "Content",
        Parent = self.Window,
        Size = UDim2.new(1, -200, 1, -64),
        Position = UDim2.new(0, 200, 0, 64),
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        BorderSizePixel = 0,
    })

    -- Save UI references
    self._ui = {
        Header = header,
        Sidebar = sidebar,
        Content = content,
    }

    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.Keybind then
            self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        end
    end)

    return self
end

-- Create new tab
function Yohi.newTab(self, tabcfg)
    tabcfg = tabcfg or {}
    local tab = {
        Title = tabcfg.Title or "Tab",
        Description = tabcfg.Description or "",
        Icon = tabcfg.Icon or nil,
        Sections = {},
    }

    -- Tab button in sidebar
    local btn = new("TextButton", {
        Parent = self._ui.Sidebar,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Text = tab.Title,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.Gotham,
        TextSize = 16,
    })

    -- On click - open tab
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self._ui.Content:GetChildren()) do
            v:Destroy()
        end

        new("TextLabel", {
            Parent = self._ui.Content,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tab.Title .. "\n" .. tab.Description,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.Gotham,
            TextSize = 18,
        })
    end)

    table.insert(self.Tabs, tab)
    return tab
end

-- Compatibility with Nothing UI style
Yohi.Notification = function() return Notification end
function Yohi:NewTab(cfg) return self:newTab(cfg) end

return Yohi
