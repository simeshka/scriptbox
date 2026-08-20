local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

local selectedObject = nil
local selectedRow = nil
local selectedStroke = nil
local nodeByObject = {}

local BLUE = Color3.fromRGB(0,120,255)
local MAX_CHILDREN = 200

-- PROPERTIES

local properties = Instance.new("Frame")
properties.Name = "Properties"
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

local selectedTitle = Instance.new("TextLabel")
selectedTitle.Position = UDim2.new(0,0,0,30)
selectedTitle.Size = UDim2.new(1,0,0,25)
selectedTitle.BackgroundColor3 = Color3.fromRGB(35,35,35)
selectedTitle.BorderSizePixel = 0
selectedTitle.Text = "Nothing selected"
selectedTitle.TextColor3 = Color3.fromRGB(190,190,190)
selectedTitle.Font = Enum.Font.SourceSans
selectedTitle.TextSize = 14
selectedTitle.TextTruncate = Enum.TextTruncate.AtEnd
selectedTitle.Parent = properties

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
propLayout.SortOrder = Enum.SortOrder.LayoutOrder
propLayout.Parent = propScroll

local propertyNames = {
	"Name","Archivable","Parent",
	"Position","Orientation","Rotation","CFrame","PivotOffset",
	"Size","Anchored","CanCollide","CanTouch","CanQuery",
	"Massless","RootPriority","Transparency","Reflectance",
	"Color","BrickColor","Material","MaterialVariant",
	"CastShadow","CollisionGroup","Shape",
	"AssemblyLinearVelocity","AssemblyAngularVelocity",
	"AssemblyMass","AssemblyCenterOfMass",
	"PrimaryPart","WorldPivot",
	"Health","MaxHealth","WalkSpeed","JumpPower","JumpHeight",
	"HipHeight","AutoRotate","Sit","PlatformStand",
	"UseJumpPower","BreakJointsOnDeath","DisplayDistanceType",
	"CameraOffset","RigType","HealthDisplayType","NameDisplayDistance",
	"DisplayName","UserId","AccountAge","Team","TeamColor",
	"Neutral","CharacterAppearanceId","CameraMode",
	"CameraMinZoomDistance","CameraMaxZoomDistance",
	"FieldOfView","CameraType","CameraSubject","Focus",
	"ViewportSize","DiagonalFieldOfView","MaxAxisFieldOfView",
	"Visible","Active","Interactable","Selectable",
	"AnchorPoint","AbsolutePosition","AbsoluteSize",
	"AutomaticSize","BackgroundColor3","BackgroundTransparency",
	"BorderColor3","BorderSizePixel","ClipsDescendants",
	"LayoutOrder","NextSelectionDown","NextSelectionLeft",
	"NextSelectionRight","NextSelectionUp","SelectionOrder",
	"SizeConstraint","ZIndex",
	"Text","TextSize","TextColor3","TextTransparency",
	"TextStrokeColor3","TextStrokeTransparency",
	"TextWrapped","TextScaled","RichText",
	"TextXAlignment","TextYAlignment","Font","FontFace",
	"PlaceholderText","PlaceholderColor3","ClearTextOnFocus",
	"MultiLine","TextEditable","CursorPosition",
	"Image","ImageColor3","ImageTransparency","ScaleType",
	"SliceCenter","TileSize","ResampleMode",
	"AutoButtonColor","Modal","Selected",
	"Enabled","Brightness","Range","Shadows",
	"ClockTime","TimeOfDay","GeographicLatitude",
	"Ambient","OutdoorAmbient","FogColor","FogStart","FogEnd",
	"ExposureCompensation","EnvironmentDiffuseScale",
	"EnvironmentSpecularScale","GlobalShadows",
	"Gravity","FallenPartsDestroyHeight",
	"StreamingEnabled","StreamingMinRadius","StreamingTargetRadius",
	"PlaybackSpeed","Volume","Looped","Playing","TimePosition",
	"RollOffMaxDistance","RollOffMinDistance","RollOffMode",
	"SoundId","EmitterSize",
	"Texture","TextureID","MeshId","MeshID",
	"Scale","Offset","VertexColor",
	"Value","Disabled","RunContext",
	"LightInfluence","AlwaysOnTop","MaxDistance",
	"StudsOffset","StudsOffsetWorldSpace",
	"Adornee","Face",
	"FillColor","FillTransparency",
	"OutlineColor","OutlineTransparency","DepthMode",
	"Enabled","Lifetime","Rate","Speed","SpreadAngle",
	"Acceleration","Drag","EmissionDirection","LightEmission",
	"LightInfluence","LockedToPart","Orientation",
	"RotSpeed","Size","Squash","Texture","Transparency",
	"VelocityInheritance","ZOffset",
	"Attachment0","Attachment1","LimitsEnabled",
	"UpperAngle","LowerAngle","ActuatorType",
	"AngularSpeed","AngularVelocity","MotorMaxTorque",
	"TargetAngle","TargetPosition",
	"Force","Torque","MaxForce","MaxTorque",
	"Responsiveness","RigidityEnabled","ApplyAtCenterOfMass",
	"LineThickness","Visible","Color3",
	"CurrentAngle","DesiredAngle","MaxVelocity",
	"Part0","Part1","C0","C1","Transform",
	"RequiresHandle","CanBeDropped","ToolTip",
	"TextureId","Grip","GripForward","GripPos","GripRight","GripUp",
}

do
	local seen = {}
	local clean = {}

	for _,name in ipairs(propertyNames) do
		if not seen[name] then
			seen[name] = true
			table.insert(clean,name)
		end
	end

	propertyNames = clean
	table.sort(propertyNames)
end

local function clearProperties()
	for _,child in ipairs(propScroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function valueToString(value)
	local t = typeof(value)

	if t == "Color3" then
		return string.format(
			"%d, %d, %d",
			math.round(value.R * 255),
			math.round(value.G * 255),
			math.round(value.B * 255)
		)
	elseif t == "Vector3" then
		return string.format("%.4f, %.4f, %.4f",value.X,value.Y,value.Z)
	elseif t == "Vector2" then
		return string.format("%.4f, %.4f",value.X,value.Y)
	elseif t == "UDim" then
		return string.format("%g, %g",value.Scale,value.Offset)
	elseif t == "UDim2" then
		return string.format(
			"%g, %g, %g, %g",
			value.X.Scale,
			value.X.Offset,
			value.Y.Scale,
			value.Y.Offset
		)
	elseif t == "CFrame" then
		local values = {value:GetComponents()}
		for i,v in ipairs(values) do
			values[i] = string.format("%.4f",v)
		end
		return table.concat(values,", ")
	elseif t == "Instance" then
		return value and value:GetFullName() or "nil"
	else
		return tostring(value)
	end
end

local function splitNumbers(text)
	local result = {}

	for number in string.gmatch(text,"[-+]?[%d%.]+") do
		table.insert(result,tonumber(number))
	end

	return result
end

local function parseValue(text,current)
	local t = typeof(current)

	if t == "string" then
		return true,text
	end

	if t == "number" then
		local n = tonumber(text)
		return n ~= nil,n
	end

	if t == "boolean" then
		text = string.lower(text)

		if text == "true" or text == "1" then
			return true,true
		elseif text == "false" or text == "0" then
			return true,false
		end

		return false
	end

	if t == "Vector3" then
		local n = splitNumbers(text)
		if #n >= 3 then
			return true,Vector3.new(n[1],n[2],n[3])
		end
	end

	if t == "Vector2" then
		local n = splitNumbers(text)
		if #n >= 2 then
			return true,Vector2.new(n[1],n[2])
		end
	end

	if t == "Color3" then
		local n = splitNumbers(text)

		if #n >= 3 then
			if n[1] > 1 or n[2] > 1 or n[3] > 1 then
				return true,Color3.fromRGB(
					math.clamp(n[1],0,255),
					math.clamp(n[2],0,255),
					math.clamp(n[3],0,255)
				)
			else
				return true,Color3.new(
					math.clamp(n[1],0,1),
					math.clamp(n[2],0,1),
					math.clamp(n[3],0,1)
				)
			end
		end
	end

	if t == "UDim" then
		local n = splitNumbers(text)
		if #n >= 2 then
			return true,UDim.new(n[1],n[2])
		end
	end

	if t == "UDim2" then
		local n = splitNumbers(text)
		if #n >= 4 then
			return true,UDim2.new(n[1],n[2],n[3],n[4])
		end
	end

	if t == "CFrame" then
		local n = splitNumbers(text)

		if #n >= 12 then
			return true,CFrame.new(
				n[1],n[2],n[3],
				n[4],n[5],n[6],
				n[7],n[8],n[9],
				n[10],n[11],n[12]
			)
		elseif #n >= 3 then
			return true,CFrame.new(n[1],n[2],n[3])
		end
	end

	if t == "EnumItem" then
		local enumName,itemName = tostring(current):match("^Enum%.([^%.]+)%.(.+)$")

		if enumName and Enum[enumName] then
			local wanted = text:match("([^%.]+)$")

			local ok,result = pcall(function()
				return Enum[enumName][wanted]
			end)

			if ok and result then
				return true,result
			end
		end
	end

	if t == "BrickColor" then
		local ok,result = pcall(function()
			return BrickColor.new(text)
		end)

		if ok then
			return true,result
		end
	end

	return false
end

local function canEditType(value)
	local t = typeof(value)

	return
		t == "string" or
		t == "number" or
		t == "boolean" or
		t == "Vector2" or
		t == "Vector3" or
		t == "Color3" or
		t == "UDim" or
		t == "UDim2" or
		t == "CFrame" or
		t == "EnumItem" or
		t == "BrickColor"
end

local function addProperty(obj,name,value)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,24)
	row.BackgroundTransparency = 1
	row.Parent = propScroll

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.43,0,1,0)
	nameLabel.BackgroundColor3 = Color3.fromRGB(38,38,38)
	nameLabel.BorderSizePixel = 0
	nameLabel.Text = "  "..name
	nameLabel.TextColor3 = Color3.fromRGB(215,215,215)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextSize = 14
	nameLabel.Parent = row

	local valueBox = Instance.new("TextBox")
	valueBox.Position = UDim2.new(0.43,0,0,0)
	valueBox.Size = UDim2.new(0.57,0,1,0)
	valueBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
	valueBox.BorderSizePixel = 0
	valueBox.Text = valueToString(value)
	valueBox.TextColor3 = Color3.fromRGB(230,230,230)
	valueBox.TextXAlignment = Enum.TextXAlignment.Left
	valueBox.TextTruncate = Enum.TextTruncate.AtEnd
	valueBox.ClearTextOnFocus = false
	valueBox.Font = Enum.Font.SourceSans
	valueBox.TextSize = 14
	valueBox.TextEditable = canEditType(value)
	valueBox.Parent = row

	if not canEditType(value) then
		valueBox.TextColor3 = Color3.fromRGB(150,150,150)
	end

	if canEditType(value) then
		valueBox.FocusLost:Connect(function(enterPressed)
			if not obj or not obj.Parent then
				return
			end

			if not enterPressed then
				local ok,current = pcall(function()
					return obj[name]
				end)

				if ok then
					valueBox.Text = valueToString(current)
				end

				return
			end

			local ok,current = pcall(function()
				return obj[name]
			end)

			if not ok then
				return
			end

			local parsed,newValue = parseValue(valueBox.Text,current)

			if not parsed then
				valueBox.Text = valueToString(current)
				return
			end

			local setOk = pcall(function()
				obj[name] = newValue
			end)

			if setOk then
				local readOk,updated = pcall(function()
					return obj[name]
				end)

				if readOk then
					valueBox.Text = valueToString(updated)
				end

				if name == "Name" then
					selectedTitle.Text = obj.Name.." ["..obj.ClassName.."]"

					local node = nodeByObject[obj]
					if node and node.update then
						node.update()
					end
				end
			else
				valueBox.Text = valueToString(current)
			end
		end)
	end
end

local function showProperties(obj)
	clearProperties()

	if not obj then
		selectedTitle.Text = "Nothing selected"
		return
	end

	selectedTitle.Text = obj.Name.." ["..obj.ClassName.."]"

	local shown = {}

	for _,name in ipairs(propertyNames) do
		local ok,value = pcall(function()
			return obj[name]
		end)

		if ok and value ~= nil then
			local t = typeof(value)

			if
				t ~= "RBXScriptSignal" and
				t ~= "function" and
				t ~= "table"
			then
				shown[name] = true
				addProperty(obj,name,value)
			end
		end
	end

	if not shown.Name then
		addProperty(obj,"Name",obj.Name)
	end

	if not shown.Parent then
		addProperty(obj,"Parent",obj.Parent)
	end
end

-- EXPLORER

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

local rootLayout = Instance.new("UIListLayout")
rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
rootLayout.Parent = scroll

local function safeChildren(obj)
	local result = {}

	for _,child in ipairs(obj:GetChildren()) do
		if child ~= gui and not child:IsDescendantOf(gui) then
			table.insert(result,child)
		end
	end

	return result
end

local makeNode

local function selectObject(obj,row,stroke)
	if selectedStroke then
		selectedStroke.Enabled = false
	end

	selectedObject = obj
	selectedRow = row
	selectedStroke = stroke

	stroke.Enabled = true
	showProperties(obj)
end

makeNode = function(obj,depth,parent)
	local node = Instance.new("Frame")
	node.Name = "Node"
	node.Size = UDim2.new(1,0,0,22)
	node.AutomaticSize = Enum.AutomaticSize.Y
	node.BackgroundTransparency = 1
	node.Parent = parent

	local row = Instance.new("TextButton")
	row.Name = "Row"
	row.Size = UDim2.new(1,0,0,22)
	row.BackgroundColor3 = Color3.fromRGB(30,30,30)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.TextColor3 = Color3.fromRGB(220,220,220)
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.TextTruncate = Enum.TextTruncate.AtEnd
	row.Font = Enum.Font.SourceSans
	row.TextSize = 14
	row.AutoButtonColor = false
	row.Parent = node

	local stroke = Instance.new("UIStroke")
	stroke.Color = BLUE
	stroke.Thickness = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Enabled = false
	stroke.Parent = row

	local childrenFrame = Instance.new("Frame")
	childrenFrame.Position = UDim2.new(0,0,0,22)
	childrenFrame.Size = UDim2.new(1,0,0,0)
	childrenFrame.AutomaticSize = Enum.AutomaticSize.Y
	childrenFrame.BackgroundTransparency = 1
	childrenFrame.Visible = false
	childrenFrame.Parent = node

	local childrenLayout = Instance.new("UIListLayout")
	childrenLayout.SortOrder = Enum.SortOrder.LayoutOrder
	childrenLayout.Parent = childrenFrame

	local open = false
	local loaded = false

	local function update()
		if not obj then
			return
		end

		local count = #safeChildren(obj)
		local arrow = ""

		if count > 0 then
			arrow = open and "▼ " or "▶ "
		end

		row.Text = string.rep("   ",depth)..arrow..obj.Name
	end

	nodeByObject[obj] = {
		frame = node,
		row = row,
		stroke = stroke,
		update = update
	}

	local function loadChildren()
		if loaded then
			return
		end

		loaded = true

		local children = safeChildren(obj)
		local amount = math.min(#children,MAX_CHILDREN)

		for i = 1,amount do
			makeNode(children[i],depth + 1,childrenFrame)
		end

		if #children > MAX_CHILDREN then
			local more = Instance.new("TextLabel")
			more.Size = UDim2.new(1,0,0,22)
			more.BackgroundTransparency = 1
			more.TextXAlignment = Enum.TextXAlignment.Left
			more.TextColor3 = Color3.fromRGB(255,180,80)
			more.Font = Enum.Font.SourceSans
			more.TextSize = 14
			more.Text =
				string.rep("   ",depth + 1)
				.."+"..(#children - MAX_CHILDREN)
				.." more hidden"
			more.Parent = childrenFrame
		end
	end

	row.MouseButton1Click:Connect(function()
		if not obj then
			return
		end

		selectObject(obj,row,stroke)

		local children = safeChildren(obj)

		if #children > 0 then
			loadChildren()
			open = not open
			childrenFrame.Visible = open
			update()
		end
	end)

	update()

	return node
end

makeNode(game,0,scroll)

-- LOCAL BACKSPACE DELETE

UserInputService.InputBegan:Connect(function(input,gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode ~= Enum.KeyCode.Backspace then
		return
	end

	if UserInputService:GetFocusedTextBox() then
		return
	end

	local obj = selectedObject

	if not obj or not obj.Parent then
		return
	end

	if not obj:IsA("BasePart") then
		return
	end

	local nodeData = nodeByObject[obj]

	selectedObject = nil
	selectedRow = nil
	selectedStroke = nil

	clearProperties()
	selectedTitle.Text = "Nothing selected"

	if nodeData and nodeData.frame then
		nodeData.frame:Destroy()
	end

	nodeByObject[obj] = nil
	obj:Destroy()
end)
