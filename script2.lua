local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "RuntimeExplorer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Position = UDim2.fromScale(0.8,0)
frame.Size = UDim2.fromScale(0.2,1)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)
title.BorderSizePixel = 0
title.Text = "Explorer"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0,0,0,30)
scroll.Size = UDim2.new(1,0,1,-30)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = scroll

local expanded = {
	[game] = true
}

local function refresh()
	for _,v in ipairs(scroll:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	local function add(obj,depth)
		if obj == gui or obj:IsDescendantOf(gui) then
			return
		end

		local children = obj:GetChildren()
		local open = expanded[obj]

		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1,0,0,22)
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 0
		button.TextColor3 = Color3.fromRGB(220,220,220)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Font = Enum.Font.SourceSans
		button.TextSize = 14
		button.AutoButtonColor = false

		local arrow = ""

		if #children > 0 then
			arrow = open and "▼ " or "▶ "
		end

		button.Text = string.rep("    ",depth)..arrow..obj.Name
		button.Parent = scroll

		button.MouseButton1Click:Connect(function()
			if #obj:GetChildren() > 0 then
				expanded[obj] = not expanded[obj]
				refresh()
			end
		end)

		if open then
			for _,child in ipairs(children) do
				add(child,depth + 1)
			end
		end
	end

	add(game,0)
end

refresh()
