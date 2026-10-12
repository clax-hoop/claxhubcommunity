-- Deobfuscated by deobf (dynamic trace)
-- source: obfuscated.txt
-- NOTE: reconstructed from observed behaviour; branches that were not taken
--       during the trace are missing and conditions are only noted in comments.
-- run status: finished
-- 126 statements recorded in 0.08s
-- non-standard globals touched: syn

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RubuHopGUI = Instance.new("ScreenGui")
RubuHopGUI.Name = "RubuHopGUI"
RubuHopGUI.ResetOnSpawn = false
syn.protect_gui(RubuHopGUI)
RubuHopGUI.Parent = game.CoreGui
local Frame = Instance.new("Frame", RubuHopGUI)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.5, -160, 0.5, -125)
Frame.Size = UDim2.new(0, 320, 0, 250)
Frame.Active = true
Frame.Draggable = true
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(100, 200, 255)
UIStroke.Thickness = 1.5
local TextLabel = Instance.new("TextLabel", Frame)
TextLabel.Size = UDim2.new(1, 0, 0, 40)
TextLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
TextLabel.BorderSizePixel = 0
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "🎮 Rubu Hop Server Ít Người"
TextLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
TextLabel.TextSize = 16
local UICorner2 = Instance.new("UICorner", TextLabel)
UICorner2.CornerRadius = UDim.new(0, 10)
local TextButton = Instance.new("TextButton", Frame)
TextButton.BackgroundTransparency = 1
TextButton.Position = UDim2.new(1, -30, 0, 8)
TextButton.Size = UDim2.new(0, 24, 0, 24)
TextButton.Font = Enum.Font.GothamBold
TextButton.Text = "✕"
TextButton.TextColor3 = Color3.fromRGB(255, 70, 70)
TextButton.TextSize = 14

TextButton.MouseButton1Click:Connect(function()
	RubuHopGUI:Destroy()
end)

local TextLabel2 = Instance.new("TextLabel", Frame)
TextLabel2.Position = UDim2.new(0, 12, 0, 50)
TextLabel2.Size = UDim2.new(1, -24, 0, 24)
TextLabel2.BackgroundTransparency = 1
TextLabel2.Font = Enum.Font.GothamBold
TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
TextLabel2.TextColor3 = Color3.fromRGB(100, 220, 100)
TextLabel2.TextSize = 14
local TextLabel3 = Instance.new("TextLabel", Frame)
TextLabel3.Position = UDim2.new(0, 12, 0, 78)
TextLabel3.Size = UDim2.new(1, -24, 0, 32)
TextLabel3.BackgroundTransparency = 1
TextLabel3.Font = Enum.Font.Gotham
TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
TextLabel3.TextColor3 = Color3.fromRGB(180, 180, 180)
TextLabel3.TextSize = 12
TextLabel3.TextWrapped = true
local TextLabel4 = Instance.new("TextLabel", Frame)
TextLabel4.Position = UDim2.new(0, 12, 0, 115)
TextLabel4.Size = UDim2.new(1, -24, 0, 20)
TextLabel4.BackgroundTransparency = 1
TextLabel4.Font = Enum.Font.Gotham
TextLabel4.TextXAlignment = Enum.TextXAlignment.Left
TextLabel4.TextColor3 = Color3.fromRGB(160, 160, 160)
TextLabel4.TextSize = 12
TextLabel4.Text = "🎯 Hop nếu server này có NHIỀU HƠN:"
local TextBox = Instance.new("TextBox", Frame)
TextBox.Position = UDim2.new(0, 12, 0, 138)
TextBox.Size = UDim2.new(1, -24, 0, 30)
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
TextBox.BorderSizePixel = 0
TextBox.Font = Enum.Font.GothamBold
TextBox.Text = "1"
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 15
TextBox.ClearTextOnFocus = false
local UICorner3 = Instance.new("UICorner", TextBox)
UICorner3.CornerRadius = UDim.new(0, 8)
local Frame2 = Instance.new("Frame", Frame)
Frame2.Position = UDim2.new(0, 12, 0, 178)
Frame2.Size = UDim2.new(1, -24, 0, 55)
Frame2.BackgroundTransparency = 1
local TextButton2 = Instance.new("TextButton", Frame2)
TextButton2.Size = UDim2.new(0, 140, 0, 50)
TextButton2.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
TextButton2.BorderSizePixel = 0
TextButton2.Font = Enum.Font.GothamBold
TextButton2.Text = "🚀 Hop 1 Lần"
TextButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton2.TextSize = 14
local UICorner4 = Instance.new("UICorner", TextButton2)
UICorner4.CornerRadius = UDim.new(0, 8)
local TextButton3 = Instance.new("TextButton", Frame2)
TextButton3.Position = UDim2.new(0, 150, 0, 0)
TextButton3.Size = UDim2.new(0, 150, 0, 50)
TextButton3.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
TextButton3.BorderSizePixel = 0
TextButton3.Font = Enum.Font.GothamBold
TextButton3.Text = "🔄 Auto: TẮT"
TextButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton3.TextSize = 14
local UICorner5 = Instance.new("UICorner", TextButton3)
UICorner5.CornerRadius = UDim.new(0, 8)

task.spawn(function()
	Players:GetPlayers()
	TextLabel2.Text = "👥 Người chơi hiện tại: 1"
	task.wait(1)
	Players:GetPlayers()
	TextLabel2.Text = "👥 Người chơi hiện tại: 1"
	task.wait(1)
	-- [envlog] the statements above repeat forever (loop)
end)

TextButton2.MouseButton1Click:Connect(function()
	TextButton2.Active = false
	Players:GetPlayers()
	TextLabel3.Text = "✅ Server này đã 1 người. Không cần hop."
	TextLabel3.TextColor3 = Color3.fromRGB(100, 220, 100)
	task.wait(2)
	TextButton2.Active = true
end)

TextButton3.MouseButton1Click:Connect(function()
	TextButton3.Text = "🔄 Auto: BẬT"
	TextButton3.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

	task.spawn(function()
	end)
end)

TextLabel3.Text = "✨ Sẵn sàng. Nhập số người rồi nhấn Hop."
TextLabel3.TextColor3 = Color3.fromRGB(180, 180, 180)
