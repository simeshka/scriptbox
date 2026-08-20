local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "RuntimeExplorer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- PROPERTIES WINDOW

local properties = Instance.new("Frame")
properties.Name = "Properties"
properties.Position = UDim2.fromScale(0,0)
properties.Size = UDim2.fromScale(0.2,1)
properties.BackgroundColor3 = Color3.fromRGB(30,30,30)
properties.BorderSizePixel = 0
properties.Parent = gui

local propertiesTitle = Instance.new("TextLabel")
propertiesTitle.Size = UDim2.new(1,0,0,30)
propertiesTitle.BackgroundColor3 = Color3.fromRGB(40,40,40)
propertiesTitle.BorderSizePixel = 0
propertiesTitle.Text = "Properties"
propertiesTitle.TextColor3 = Color3.new(1,1,1)
propertiesTitle.Font = Enum.Font.SourceSansBold
propertiesTitle.TextSize = 18
propertiesTitle.Parent = properties

local selectedTitle = Instance.new("TextLabel")
selectedTitle.Position = UDim2.new(0,0,0,30)
selectedTitle.Size = UDim2.new(1,0,0,25)
selectedTitle.BackgroundColor3 = Color3.fromRGB(35,35,35)
selectedTitle.BorderSizePixel = 0
selectedTitle.Text = "Nothing selected"
selectedTitle.TextColor3 = Color3.fromRGB(180,180,180)
selectedTitle.Font = Enum.Font.SourceSans
selectedTitle.TextSize = 14
selectedTitle.TextTruncate = Enum.TextTruncate.AtEnd
selectedTitle.Parent = properties

local propertyScroll = Instance.new("ScrollingFrame")
propertyScroll.Position = UDim2.new(0,0,0,55)
propertyScroll.Size = UDim2.new(1,0,1,-55)
propertyScroll.BackgroundTransparency = 1
propertyScroll.BorderSizePixel = 0
propertyScroll.ScrollBarThickness = 5
propertyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
propertyScroll.CanvasSize = UDim2.new()
propertyScroll.Parent = properties

local propertyLayout = Instance.new("UIListLayout")
propertyLayout.SortOrder = Enum.SortOrder.LayoutOrder
propertyLayout.Parent = propertyScroll

local function addProperty(name,value)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,25)
	row.BackgroundTransparency = 1
	row.Parent = propertyScroll

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.45,0,1,0)
	nameLabel.BackgroundColor3 = Color3.fromRGB(38,38,38)
	nameLabel.BorderSizePixel = 0
	nameLabel.Text = "  "..name
	nameLabel.TextColor3 = Color3.fromRGB(210,210,210)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextSize = 14
	nameLabel.Parent = row

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Position = UDim2.new(0.45,0,0,0)
	valueLabel.Size = UDim2.new(0.55,0,1,0)
	valueLabel.BackgroundColor3 = Color3.fromRGB(45,45,45)
	valueLabel.BorderSizePixel = 0
	valueLabel.Text = "  "..tostring(value)
	valueLabel.TextColor3 = Color3.fromRGB(225,225,225)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
	valueLabel.Font = Enum.Font.SourceSans
	valueLabel.TextSize = 14
	valueLabel.Parent = row
end

local function showProperties(obj)
	for _,v in ipairs(propertyScroll:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end

	selectedTitle.Text = obj.Name.."  ["..obj.ClassName.."]"

	addProperty("Name",obj.Name)
	addProperty("ClassName",obj.ClassName)
	addProperty("Parent",obj.Parent and obj.Parent.Name or "nil")

	if obj:IsA("BasePart") then
		addProperty("Position",obj.Position)
		addProperty("Orientation",obj.Orientation)
		addProperty("Size",obj.Size)
		addProperty("Transparency",obj.Transparency)
		addProperty("Anchored",obj.Anchored)
		addProperty("CanCollide",obj.CanCollide)
		addProperty("CanTouch",obj.CanTouch)
		addProperty("CanQuery",obj.CanQuery)
		addProperty("Material",obj.Material)
		addProperty("Color",obj.Color)
		addProperty("AssemblyLinearVelocity",obj.AssemblyLinearVelocity)
		addProperty("AssemblyAngularVelocity",obj.AssemblyAngularVelocity)
	end

	if obj:IsA("Humanoid") then
		addProperty("Health",obj.Health)
		addProperty("MaxHealth",obj.MaxHealth)
		addProperty("WalkSpeed",obj.WalkSpeed)
		addProperty("JumpPower",obj.JumpPower)
		addProperty("AutoRotate",obj.AutoRotate)
		addProperty("HipHeight",obj.HipHeight)
		addProperty("Sit",obj.Sit)
	end

	if obj:IsA("GuiObject") then
		addProperty("Visible",obj.Visible)
		addProperty("Position",obj.Position)
		addProperty("Size",obj.Size)
		addProperty("Rotation",obj.Rotation)
		addProperty("ZIndex",obj.ZIndex)
	end

	if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		addProperty("Text",obj.Text)
		addProperty("TextSize",obj.TextSize)
		addProperty("TextColor3",obj.TextColor3)
	end

	if obj:IsA("Model") then
		addProperty("PrimaryPart",obj.PrimaryPart and obj.PrimaryPart.Name or "nil")
	end

	if obj:IsA("Camera") then
		addProperty("FieldOfView",obj.FieldOfView)
		addProperty("CameraType",obj.CameraType)
		addProperty("CFrame",obj.CFrame)
	end

	if obj:IsA("Player") then
		addProperty("UserId",obj.UserId)
		addProperty("DisplayName",obj.DisplayName)
		addProperty("Team",obj.Team and obj.Team.Name or "nil")
	end
end

-- EXPLORER WINDOW

local explorer = Instance.new("Frame")
explorer.Name = "Explorer"
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

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
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

	local order = 0

	local function add(obj,depth)
		if obj == gui or obj:IsDescendantOf(gui) then
			return
		end

		order += 1

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
		button.LayoutOrder = order

		local arrow = ""

		if #children > 0 then
			arrow = open and "▼ " or "▶ "
		end

		button.Text = string.rep("    ",depth)..arrow..obj.Name
		button.Parent = scroll

		button.MouseButton1Click:Connect(function()
			showProperties(obj)

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
