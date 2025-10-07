-- YohiGui.lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Проверяем, есть ли уже GUI
if PlayerGui:FindFirstChild("YOHI_GUI") then
    PlayerGui:FindFirstChild("YOHI_GUI"):Destroy()
end

-- Создаём ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YOHI_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Главный фрейм GUI (под стиль Nothing Lib)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Вставляем твой логотип
local logo = Instance.new("ImageLabel")
logo.Name = "YOHI_Logo"
logo.Parent = mainFrame
logo.Size = UDim2.new(0, 250, 0, 100)
logo.Position = UDim2.new(0.5, -125, 0, 10)
logo.Image = "rbxassetid://14420982702"  -- сюда вставь свой Roblox Asset ID логотипа
logo.BackgroundTransparency = 1
logo.ZIndex = 5

-- Пример кнопки из Nothing Lib
local button = Instance.new("TextButton")
button.Parent = mainFrame
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0, 150)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "Нажми меня"
button.Font = Enum.Font.Gotham
button.TextScaled = true

button.MouseButton1Click:Connect(function()
    print("Кнопка нажата!")
end)
