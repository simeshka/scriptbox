local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("RuntimeExplorer")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "RuntimeExplorer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- PROPERTIES

local properties = Instance.new("Frame")
properties.Position = UDim2.fromScale(0,0)
properties.Size = UDim2.fromScale(0.2,1)
properties.BackgroundColor3 = Color3.fromRGB(30,30,30)
properties.BorderSizePixel = 0
properties.Parent = gui

local propTitle = Instance.new("TextLabel")
propTitle.Size = UDim2.new(1,0,0,30)
propTitle.BackgroundColor3 = Color3.fromRGB(40,40,40)
propTitle.BorderSizePixel = 0
propTitle.Text = "Properties"
propTitle.TextColor3 = Color3.new(1,1,1)
propTitle.Font = Enum.Font.SourceSansBold
propTitle.TextSize = 18
propTitle.Parent = properties

local selected = Instance.new("TextLabel")
selected.Position = UDim2.new(0,0,0,30)
selected.Size = UDim2.new(1,0,0,25)
selected.BackgroundColor3 = Color3.fromRGB(35,35,35)
selected.BorderSizePixel = 0
selected.Text = "Nothing selected"
selected.TextColor3 = Color3.fromRGB(190,190,190)
selected.TextSize = 14
selected.TextTruncate = Enum.TextTruncate.AtEnd
selected.Parent = properties

local propScroll = Instance.new("ScrollingFrame")
propScroll.Position = UDim2.new(0,0,0,55)
propScroll.Size = UDim2.new(1,0,1,-55)
propScroll.BackgroundTransparency = 1
propScroll.BorderSizePixel = 0
propScroll.ScrollBarThickness = 5
propScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
propScroll.CanvasSize = UDim2.new()
propScroll.Parent = properties

local propLayout = Instance.new("UIListLayout")
propLayout.Parent = propScroll

local function clearProperties()
	for _,v in ipairs(propScroll:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
end

local function property(name,value)
	local row = Instance.new("TextLabel")
	row.Size = UDim2.new(1,0,0,22)
	row.BackgroundTransparency = 1
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.TextColor3 = Color3.fromRGB(220,220,220)
	row.TextSize = 14
	row.Font = Enum.Font.SourceSans
	row.Text = "  "..name.." = "..tostring(value)
	row.TextTruncate = Enum.TextTruncate.AtEnd
	row.Parent = propScroll
end

local function showProperties(obj)
	clearProperties()

	selected.Text = obj.Name.." ["..obj.ClassName.."]"

	property("Name",obj.Name)
	property("ClassName",obj.ClassName)
	property("Parent",obj.Parent and obj.Parent.Name or "nil")

	if obj:IsA("BasePart") then
		property("Position",obj.Position)
		property("Orientation",obj.Orientation)
		property("Size",obj.Size)
		property("Anchored",obj.Anchored)
		property("CanCollide",obj.CanCollide)
		property("Transparency",obj.Transparency)
		property("Material",obj.Material)
		property("Color",obj.Color)
	end

	if obj:IsA("Humanoid") then
		property("Health",obj.Health)
		property("MaxHealth",obj.MaxHealth)
		property("WalkSpeed",obj.WalkSpeed)
		property("JumpPower",obj.JumpPower)
		property("AutoRotate",obj.AutoRotate)
	end

	if obj:IsA("Player") then
		property("UserId",obj.UserId)
		property("DisplayName",obj.DisplayName)
	end

	if obj:IsA("GuiObject") then
		property("Position",obj.Position)
		property("Size",obj.Size)
		property("Visible",obj.Visible)
		property("Rotation",obj.Rotation)
	end
end

-- EXPLORER

local explorer = Instance.new("Frame")
explorer.Position = UDim2.fromScale(0.8,0)
explorer.Size = UDim2.fromScale(0.2,1)
explorer.BackgroundColor3 = Color3.fromRGB(30,30,30)
explorer.BorderSizePixel = 0
explorer.Parent = gui

local explorerTitle = Instance.new("TextLabel")
explorerTitle.Size = UDim2.new(1,0,0,30)
explorerTitle.BackgroundColor3 = Color3.fromRGB(40,40,40)
explorerTitle.BorderSizePixel = 0
explorerTitle.Text = "Explorer"
explorerTitle.TextColor3 = Color3.new(1,1,1)
explorerTitle.Font = Enum.Font.SourceSansBold
explorerTitle.TextSize = 18
explorerTitle.Parent = explorer

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0,0,0,30)
scroll.Size = UDim2.new(1,0,1,-30)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = explorer

local list = Instance.new("UIListLayout")
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local MAX_CHILDREN = 200
local order = 0

local function makeNode(obj,depth)
	order += 1

	local container = Instance.new("Frame")
	container.Name = "Node"
	container.Size = UDim2.new(1,0,0,22)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.BackgroundTransparency = 1
	container.LayoutOrder = order
	container.Parent = scroll

	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1,0,0,22)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.TextColor3 = Color3.fromRGB(220,220,220)
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.Font = Enum.Font.SourceSans
	row.TextSize = 14
	row.AutoButtonColor = false
	row.Parent = container

	local childContainer = Instance.new("Frame")
	childContainer.Position = UDim2.new(0,0,0,22)
	childContainer.Size = UDim2.new(1,0,0,0)
	childContainer.AutomaticSize = Enum.AutomaticSize.Y
	childContainer.BackgroundTransparency = 1
	childContainer.Visible = false
	childContainer.Parent = container

	local childLayout = Instance.new("UIListLayout")
	childLayout.Parent = childContainer

	local opened = false
	local loaded = false

	local function updateText()
		local hasChildren = #obj:GetChildren() > 0
		local arrow = ""

		if hasChildren then
			arrow = opened and "▼ " or "▶ "
		end

		row.Text = string.rep("    ",depth)..arrow..obj.Name
	end

	local function loadChildren()
		if loaded then
			return
		end

		loaded = true

		local children = obj:GetChildren()
		local amount = math.min(#children,MAX_CHILDREN)

		for i = 1,amount do
			makeNode(children[i],depth + 1).Parent = childContainer
		end

		if #children > MAX_CHILDREN then
			local warning = Instance.new("TextLabel")
			warning.Size = UDim2.new(1,0,0,22)
			warning.BackgroundTransparency = 1
			warning.TextColor3 = Color3.fromRGB(255,180,80)
			warning.TextXAlignment = Enum.TextXAlignment.Left
			warning.TextSize = 14
			warning.Text =
				string.rep("    ",depth + 1)
				.."+"..(#children - MAX_CHILDREN)
				.." more hidden"
			warning.Parent = childContainer
		end
	end

	row.MouseButton1Click:Connect(function()
		showProperties(obj)

		if #obj:GetChildren() == 0 then
			return
		end

		if not loaded then
			loadChildren()
		end

		opened = not opened
		childContainer.Visible = opened
		updateText()
	end)

	updateText()

	return container
end

makeNode(game,0)
