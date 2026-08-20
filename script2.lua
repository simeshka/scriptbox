local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "RuntimeExplorer"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Explorer"
frame.Position = UDim2.fromScale(0.8, 0)
frame.Size = UDim2.fromScale(0.2, 1)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.BorderSizePixel = 0
title.Text = "Explorer"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local scrolling = Instance.new("ScrollingFrame")
scrolling.Position = UDim2.fromOffset(0, 30)
scrolling.Size = UDim2.new(1, 0, 1, -30)
scrolling.BackgroundTransparency = 1
scrolling.BorderSizePixel = 0
scrolling.ScrollBarThickness = 6
scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrolling.CanvasSize = UDim2.new()
scrolling.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrolling

local expanded = {
	[game] = true
}

local function refresh()
	for _, v in ipairs(scrolling:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end

	local order = 0

	local function add(instance, depth)
		order += 1

		local children = instance:GetChildren()
		local hasChildren = #children > 0
		local isExpanded = expanded[instance]

		local button = Instance.new("TextButton")
		button.Name = instance.Name
		button.Size = UDim2.new(1, 0, 0, 22)
		button.BackgroundTransparency = 1
		button.TextColor3 = Color3.fromRGB(220, 220, 220)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Font = Enum.Font.SourceSans
		button.TextSize = 14
		button.LayoutOrder = order
		button.AutoButtonColor = false

		local arrow = ""
		if hasChildren then
			arrow = isExpanded and "▼ " or "▶ "
		end

		button.Text = string.rep("    ", depth) .. arrow .. instance.Name
		button.Parent = scrolling

		button.MouseButton1Click:Connect(function()
			if hasChildren then
				expanded[instance] = not expanded[instance]
				refresh()
			end
		end)

		if hasChildren and isExpanded then
			for _, child in ipairs(children) do
				add(child, depth + 1)
			end
		end
	end

	add(game, 0)
end

refresh()

game.DescendantAdded:Connect(function()
	task.defer(refresh)
end)

game.DescendantRemoving:Connect(function()
	task.defer(refresh)
end)
