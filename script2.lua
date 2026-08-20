local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "RuntimeExplorer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Position = UDim2.fromScale(0.8, 0)
frame.Size = UDim2.fromScale(0.2, 1)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)
title.BorderSizePixel = 0
title.Text = "Explorer"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local scrolling = Instance.new("ScrollingFrame")
scrolling.Position = UDim2.fromOffset(0,30)
scrolling.Size = UDim2.new(1,0,1,-30)
scrolling.BackgroundTransparency = 1
scrolling.BorderSizePixel = 0
scrolling.ScrollBarThickness = 5
scrolling.CanvasSize = UDim2.new()
scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrolling.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = scrolling

local expanded = {}
expanded[game] = true

local refreshing = false

local function refresh()
	if refreshing then return end
	refreshing = true

	for _,v in ipairs(scrolling:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end

	local order = 0

	local function add(obj,depth)
		if obj == gui or obj:IsDescendantOf(gui) then
			return
		end

		order += 1

		local children = obj:GetChildren()
		local open = expanded[obj]
		local hasChildren = #children > 0

		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1,0,0,22)
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 0
		button.TextColor3 = Color3.fromRGB(220,220,220)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Font = Enum.Font.SourceSans
		button.TextSize = 14
		button.LayoutOrder = order

		local arrow = ""

		if hasChildren then
			if open then
				arrow = "▼ "
			else
				arrow = "▶ "
			end
		end

		button.Text = string.rep("   ",depth)..arrow..obj.Name
		button.Parent = scrolling

		button.MouseButton1Click:Connect(function()
			if hasChildren then
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

	refreshing = false
end

refresh()

local queued = false

local function requestRefresh(obj)
	if obj == gui or obj:IsDescendantOf(gui) then
		return
	end

	if queued then return end
	queued = true

	task.delay(0.1,function()
		queued = false
		refresh()
	end)
end

game.DescendantAdded:Connect(requestRefresh)

game.DescendantRemoving:Connect(function(obj)
	if obj == gui or obj:IsDescendantOf(gui) then
		return
	end

	if queued then return end
	queued = true

	task.delay(0.1,function()
		queued = false
		refresh()
	end)
end)

