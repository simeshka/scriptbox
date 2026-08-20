local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local LogService=game:GetService("LogService")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local old=playerGui:FindFirstChild("RuntimeExplorer")
if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="RuntimeExplorer"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent=playerGui
local BLUE=Color3.fromRGB(0,120,255)
local MAX_CHILDREN=200
local selectedObject
local selectedStroke
local nodeByObject={}
local properties=Instance.new("Frame")
properties.Name="Properties"
properties.Position=UDim2.fromScale(0,0)
properties.Size=UDim2.fromScale(0.2,1)
properties.BackgroundColor3=Color3.fromRGB(28,28,28)
properties.BorderSizePixel=0
properties.Parent=gui
local propertiesTitle=Instance.new("TextLabel")
propertiesTitle.Size=UDim2.new(1,0,0,30)
propertiesTitle.BackgroundColor3=Color3.fromRGB(40,40,40)
propertiesTitle.BorderSizePixel=0
propertiesTitle.Text="Properties"
propertiesTitle.TextColor3=Color3.new(1,1,1)
propertiesTitle.Font=Enum.Font.SourceSansBold
propertiesTitle.TextSize=18
propertiesTitle.Parent=properties
local selectedTitle=Instance.new("TextLabel")
selectedTitle.Position=UDim2.new(0,0,0,30)
selectedTitle.Size=UDim2.new(1,0,0,25)
selectedTitle.BackgroundColor3=Color3.fromRGB(34,34,34)
selectedTitle.BorderSizePixel=0
selectedTitle.Text="Nothing selected"
selectedTitle.TextColor3=Color3.fromRGB(190,190,190)
selectedTitle.Font=Enum.Font.SourceSans
selectedTitle.TextSize=14
selectedTitle.TextTruncate=Enum.TextTruncate.AtEnd
selectedTitle.Parent=properties
local propertyScroll=Instance.new("ScrollingFrame")
propertyScroll.Position=UDim2.new(0,0,0,55)
propertyScroll.Size=UDim2.new(1,0,1,-55)
propertyScroll.BackgroundTransparency=1
propertyScroll.BorderSizePixel=0
propertyScroll.ScrollBarThickness=5
propertyScroll.CanvasSize=UDim2.new()
propertyScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
propertyScroll.Parent=properties
local propertyLayout=Instance.new("UIListLayout")
propertyLayout.SortOrder=Enum.SortOrder.LayoutOrder
propertyLayout.Parent=propertyScroll
local propertyNames={
"Name","Parent","Archivable","Position","Orientation","Rotation","CFrame","PivotOffset","Size","Anchored","CanCollide","CanTouch","CanQuery","Massless","RootPriority","Locked","Transparency","Reflectance","Color","BrickColor","Material","MaterialVariant","CastShadow","CollisionGroup","Shape","AssemblyLinearVelocity","AssemblyAngularVelocity","AssemblyMass","AssemblyCenterOfMass","PrimaryPart","WorldPivot","Health","MaxHealth","WalkSpeed","JumpPower","JumpHeight","HipHeight","AutoRotate","Sit","PlatformStand","UseJumpPower","BreakJointsOnDeath","CameraOffset","DisplayName","UserId","AccountAge","Team","TeamColor","Neutral","CharacterAppearanceId","CameraMode","CameraMinZoomDistance","CameraMaxZoomDistance","FieldOfView","CameraType","CameraSubject","Focus","Visible","Active","Interactable","Selectable","AnchorPoint","AbsolutePosition","AbsoluteSize","AutomaticSize","BackgroundColor3","BackgroundTransparency","BorderColor3","BorderSizePixel","ClipsDescendants","LayoutOrder","SizeConstraint","ZIndex","Text","TextSize","TextColor3","TextTransparency","TextStrokeColor3","TextStrokeTransparency","TextWrapped","TextScaled","RichText","TextXAlignment","TextYAlignment","Font","PlaceholderText","PlaceholderColor3","ClearTextOnFocus","MultiLine","TextEditable","Image","ImageColor3","ImageTransparency","ScaleType","TileSize","AutoButtonColor","Modal","Selected","Enabled","Brightness","Range","Shadows","ClockTime","TimeOfDay","GeographicLatitude","Ambient","OutdoorAmbient","FogColor","FogStart","FogEnd","ExposureCompensation","EnvironmentDiffuseScale","EnvironmentSpecularScale","GlobalShadows","Gravity","FallenPartsDestroyHeight","PlaybackSpeed","Volume","Looped","Playing","TimePosition","SoundId","EmitterSize","RollOffMaxDistance","RollOffMinDistance","RollOffMode","Texture","TextureID","TextureId","MeshId","MeshID","Scale","Offset","VertexColor","Value","Disabled","RunContext","AlwaysOnTop","LightInfluence","MaxDistance","StudsOffset","StudsOffsetWorldSpace","Adornee","Face","FillColor","FillTransparency","OutlineColor","OutlineTransparency","DepthMode","Lifetime","Rate","Speed","SpreadAngle","Acceleration","Drag","EmissionDirection","LightEmission","LockedToPart","VelocityInheritance","ZOffset","Attachment0","Attachment1","LimitsEnabled","UpperAngle","LowerAngle","ActuatorType","AngularSpeed","AngularVelocity","MotorMaxTorque","TargetAngle","TargetPosition","Force","Torque","MaxForce","MaxTorque","Responsiveness","RigidityEnabled","ApplyAtCenterOfMass","CurrentAngle","DesiredAngle","MaxVelocity","Part0","Part1","C0","C1","Transform","RequiresHandle","CanBeDropped","ToolTip","Grip","GripForward","GripPos","GripRight","GripUp"
}
do
	local seen={}
	local new={}
	for _,v in ipairs(propertyNames) do
		if not seen[v] then
			seen[v]=true
			table.insert(new,v)
		end
	end
	table.sort(new)
	propertyNames=new
end
local function clearProperties()
	for _,v in ipairs(propertyScroll:GetChildren()) do
		if v:IsA("GuiObject") then v:Destroy() end
	end
end
local function valueToString(value)
	local t=typeof(value)
	if t=="Color3" then
		return string.format("%d, %d, %d",math.round(value.R*255),math.round(value.G*255),math.round(value.B*255))
	elseif t=="Vector3" then
		return string.format("%.4f, %.4f, %.4f",value.X,value.Y,value.Z)
	elseif t=="Vector2" then
		return string.format("%.4f, %.4f",value.X,value.Y)
	elseif t=="UDim" then
		return string.format("%g, %g",value.Scale,value.Offset)
	elseif t=="UDim2" then
		return string.format("%g, %g, %g, %g",value.X.Scale,value.X.Offset,value.Y.Scale,value.Y.Offset)
	elseif t=="CFrame" then
		local a={value:GetComponents()}
		for i,v in ipairs(a) do a[i]=string.format("%.4f",v) end
		return table.concat(a,", ")
	elseif t=="Instance" then
		return value and value:GetFullName() or "nil"
	end
	return tostring(value)
end
local function splitNumbers(text)
	local a={}
	for n in string.gmatch(text,"[-+]?%d*%.?%d+") do table.insert(a,tonumber(n)) end
	return a
end
local function resolveInstance(text)
	text=text:gsub("^%s+",""):gsub("%s+$","")
	if text:lower()=="nil" then return true,nil end
	text=text:gsub("^game%.",""):gsub("^Game%.","")
	local current=game
	for name in string.gmatch(text,"[^%.]+") do
		local child=current:FindFirstChild(name)
		if not child then return false end
		current=child
	end
	return true,current
end
local function parseValue(text,current)
	local t=typeof(current)
	if t=="string" then return true,text end
	if t=="number" then
		local n=tonumber(text)
		return n~=nil,n
	end
	if t=="boolean" then
		local s=text:lower()
		if s=="true" or s=="1" then return true,true end
		if s=="false" or s=="0" then return true,false end
		return false
	end
	if t=="Vector3" then
		local n=splitNumbers(text)
		if #n>=3 then return true,Vector3.new(n[1],n[2],n[3]) end
	end
	if t=="Vector2" then
		local n=splitNumbers(text)
		if #n>=2 then return true,Vector2.new(n[1],n[2]) end
	end
	if t=="Color3" then
		local n=splitNumbers(text)
		if #n>=3 then
			if n[1]>1 or n[2]>1 or n[3]>1 then
				return true,Color3.fromRGB(math.clamp(n[1],0,255),math.clamp(n[2],0,255),math.clamp(n[3],0,255))
			else
				return true,Color3.new(math.clamp(n[1],0,1),math.clamp(n[2],0,1),math.clamp(n[3],0,1))
			end
		end
	end
	if t=="UDim" then
		local n=splitNumbers(text)
		if #n>=2 then return true,UDim.new(n[1],n[2]) end
	end
	if t=="UDim2" then
		local n=splitNumbers(text)
		if #n>=4 then return true,UDim2.new(n[1],n[2],n[3],n[4]) end
	end
	if t=="CFrame" then
		local n=splitNumbers(text)
		if #n>=12 then
			return true,CFrame.new(n[1],n[2],n[3],n[4],n[5],n[6],n[7],n[8],n[9],n[10],n[11],n[12])
		elseif #n>=3 then
			return true,CFrame.new(n[1],n[2],n[3])
		end
	end
	if t=="EnumItem" then
		local enumName=tostring(current):match("^Enum%.([^%.]+)%.")
		local item=text:match("([^%.]+)$")
		if enumName and Enum[enumName] then
			local ok,v=pcall(function() return Enum[enumName][item] end)
			if ok and v then return true,v end
		end
	end
	if t=="BrickColor" then
		local ok,v=pcall(function() return BrickColor.new(text) end)
		if ok then return true,v end
	end
	if t=="Instance" then return resolveInstance(text) end
	return false
end
local function canEdit(value)
	local t=typeof(value)
	return t=="string" or t=="number" or t=="boolean" or t=="Vector3" or t=="Vector2" or t=="Color3" or t=="UDim" or t=="UDim2" or t=="CFrame" or t=="EnumItem" or t=="BrickColor" or t=="Instance"
end
local function addProperty(obj,name,value)
	local row=Instance.new("Frame")
	row.Size=UDim2.new(1,0,0,24)
	row.BackgroundTransparency=1
	row.Parent=propertyScroll
	local n=Instance.new("TextLabel")
	n.Size=UDim2.new(0.42,0,1,0)
	n.BackgroundColor3=Color3.fromRGB(38,38,38)
	n.BorderSizePixel=0
	n.Text="  "..name
	n.TextColor3=Color3.fromRGB(215,215,215)
	n.TextXAlignment=Enum.TextXAlignment.Left
	n.TextTruncate=Enum.TextTruncate.AtEnd
	n.Font=Enum.Font.SourceSans
	n.TextSize=14
	n.Parent=row
	local box=Instance.new("TextBox")
	box.Position=UDim2.new(0.42,0,0,0)
	box.Size=UDim2.new(0.58,0,1,0)
	box.BackgroundColor3=Color3.fromRGB(45,45,45)
	box.BorderSizePixel=0
	box.Text=valueToString(value)
	box.TextColor3=canEdit(value) and Color3.fromRGB(230,230,230) or Color3.fromRGB(140,140,140)
	box.TextXAlignment=Enum.TextXAlignment.Left
	box.TextTruncate=Enum.TextTruncate.AtEnd
	box.ClearTextOnFocus=false
	box.Font=Enum.Font.SourceSans
	box.TextSize=14
	box.TextEditable=canEdit(value)
	box.Parent=row
	box.FocusLost:Connect(function(enterPressed)
		if not enterPressed then
			local ok,current=pcall(function() return obj[name] end)
			if ok then box.Text=valueToString(current) end
			return
		end
		local ok,current=pcall(function() return obj[name] end)
		if not ok then return end
		local parsed,newValue=parseValue(box.Text,current)
		if not parsed then
			box.Text=valueToString(current)
			return
		end
		local writeOk=pcall(function() obj[name]=newValue end)
		if writeOk then
			box.BackgroundColor3=Color3.fromRGB(35,75,45)
			task.delay(0.2,function()
				if box.Parent then box.BackgroundColor3=Color3.fromRGB(45,45,45) end
			end)
			local readOk,real=pcall(function() return obj[name] end)
			if readOk then box.Text=valueToString(real) end
			if name=="Name" then
				selectedTitle.Text=obj.Name.." ["..obj.ClassName.."]"
				local nd=nodeByObject[obj]
				if nd then nd.update() end
			end
		else
			box.BackgroundColor3=Color3.fromRGB(95,35,35)
			task.delay(0.3,function()
				if box.Parent then box.BackgroundColor3=Color3.fromRGB(45,45,45) end
			end)
			box.Text=valueToString(current)
		end
	end)
end
local function showProperties(obj)
	clearProperties()
	if not obj then
		selectedTitle.Text="Nothing selected"
		return
	end
	selectedTitle.Text=obj.Name.." ["..obj.ClassName.."]"
	for _,name in ipairs(propertyNames) do
		local ok,value=pcall(function() return obj[name] end)
		if ok and value~=nil then
			local t=typeof(value)
			if t~="RBXScriptSignal" and t~="function" and t~="table" then
				addProperty(obj,name,value)
			end
		end
	end
end
local explorer=Instance.new("Frame")
explorer.Name="Explorer"
explorer.Position=UDim2.fromScale(0.8,0)
explorer.Size=UDim2.fromScale(0.2,1)
explorer.BackgroundColor3=Color3.fromRGB(28,28,28)
explorer.BorderSizePixel=0
explorer.Parent=gui
local explorerTitle=Instance.new("TextLabel")
explorerTitle.Size=UDim2.new(1,0,0,30)
explorerTitle.BackgroundColor3=Color3.fromRGB(40,40,40)
explorerTitle.BorderSizePixel=0
explorerTitle.Text="Explorer"
explorerTitle.TextColor3=Color3.new(1,1,1)
explorerTitle.Font=Enum.Font.SourceSansBold
explorerTitle.TextSize=18
explorerTitle.Parent=explorer
local explorerScroll=Instance.new("ScrollingFrame")
explorerScroll.Position=UDim2.new(0,0,0,30)
explorerScroll.Size=UDim2.new(1,0,1,-30)
explorerScroll.BackgroundTransparency=1
explorerScroll.BorderSizePixel=0
explorerScroll.ScrollBarThickness=5
explorerScroll.CanvasSize=UDim2.new()
explorerScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
explorerScroll.Parent=explorer
local explorerLayout=Instance.new("UIListLayout")
explorerLayout.SortOrder=Enum.SortOrder.LayoutOrder
explorerLayout.Parent=explorerScroll
local function safeChildren(obj)
	local a={}
	for _,child in ipairs(obj:GetChildren()) do
		if child~=gui and not child:IsDescendantOf(gui) then table.insert(a,child) end
	end
	return a
end
local makeNode
local function selectObject(obj,stroke)
	if selectedStroke and selectedStroke.Parent then selectedStroke.Enabled=false end
	selectedObject=obj
	selectedStroke=stroke
	stroke.Enabled=true
	showProperties(obj)
end
makeNode=function(obj,depth,parent)
	local node=Instance.new("Frame")
	node.Name="Node"
	node.Size=UDim2.new(1,0,0,22)
	node.AutomaticSize=Enum.AutomaticSize.Y
	node.BackgroundTransparency=1
	node.Parent=parent
	local layout=Instance.new("UIListLayout")
	layout.SortOrder=Enum.SortOrder.LayoutOrder
	layout.Parent=node
	local row=Instance.new("TextButton")
	row.Size=UDim2.new(1,0,0,22)
	row.BackgroundColor3=Color3.fromRGB(31,31,31)
	row.BackgroundTransparency=1
	row.BorderSizePixel=0
	row.TextColor3=Color3.fromRGB(220,220,220)
	row.TextXAlignment=Enum.TextXAlignment.Left
	row.TextTruncate=Enum.TextTruncate.AtEnd
	row.Font=Enum.Font.SourceSans
	row.TextSize=14
	row.AutoButtonColor=false
	row.Parent=node
	local stroke=Instance.new("UIStroke")
	stroke.Color=BLUE
	stroke.Thickness=2
	stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
	stroke.Enabled=false
	stroke.Parent=row
	local childContainer=Instance.new("Frame")
	childContainer.Size=UDim2.new(1,0,0,0)
	childContainer.AutomaticSize=Enum.AutomaticSize.Y
	childContainer.BackgroundTransparency=1
	childContainer.Visible=false
	childContainer.Parent=node
	local childLayout=Instance.new("UIListLayout")
	childLayout.SortOrder=Enum.SortOrder.LayoutOrder
	childLayout.Parent=childContainer
	local opened=false
	local loaded=false
	local function update()
		local children=safeChildren(obj)
		local arrow=#children>0 and (opened and "▼ " or "▶ ") or ""
		row.Text=string.rep("   ",depth)..arrow..obj.Name
	end
	nodeByObject[obj]={frame=node,row=row,stroke=stroke,update=update,parent=obj.Parent}
	local function loadChildren()
		if loaded then return end
		loaded=true
		local children=safeChildren(obj)
		local amount=math.min(#children,MAX_CHILDREN)
		for i=1,amount do makeNode(children[i],depth+1,childContainer) end
		if #children>MAX_CHILDREN then
			local hidden=Instance.new("TextLabel")
			hidden.Size=UDim2.new(1,0,0,22)
			hidden.BackgroundTransparency=1
			hidden.TextColor3=Color3.fromRGB(255,180,80)
			hidden.TextXAlignment=Enum.TextXAlignment.Left
			hidden.Font=Enum.Font.SourceSans
			hidden.TextSize=14
			hidden.Text=string.rep("   ",depth+1).."+"..(#children-MAX_CHILDREN).." more hidden"
			hidden.Parent=childContainer
		end
	end
	row.MouseButton1Click:Connect(function()
		selectObject(obj,stroke)
		local children=safeChildren(obj)
		if #children==0 then return end
		loadChildren()
		opened=not opened
		childContainer.Visible=opened
		update()
	end)
	update()
	return node
end
makeNode(game,0,explorerScroll)
UserInputService.InputBegan:Connect(function(input)
	if UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode~=Enum.KeyCode.F1 then return end
	local obj=selectedObject
	if not obj or not obj.Parent then return end
	if not obj:IsA("BasePart") then return end
	local nodeData=nodeByObject[obj]
	local parentObj=obj.Parent
	selectedObject=nil
	if selectedStroke and selectedStroke.Parent then selectedStroke.Enabled=false end
	selectedStroke=nil
	clearProperties()
	selectedTitle.Text="Nothing selected"
	if nodeData and nodeData.frame then nodeData.frame:Destroy() end
	nodeByObject[obj]=nil
	obj:Destroy()
	local parentData=nodeByObject[parentObj]
	if parentData then parentData.update() end
end)
local console=Instance.new("Frame")
console.Name="Output"
console.Position=UDim2.fromScale(0.2,0.7)
console.Size=UDim2.fromScale(0.6,0.3)
console.BackgroundColor3=Color3.fromRGB(22,22,22)
console.BorderSizePixel=0
console.ClipsDescendants=true
console.Parent=gui
local consoleStroke=Instance.new("UIStroke")
consoleStroke.Color=Color3.fromRGB(70,70,70)
consoleStroke.Thickness=1
consoleStroke.Parent=console
local topBar=Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,28)
topBar.BackgroundColor3=Color3.fromRGB(38,38,38)
topBar.BorderSizePixel=0
topBar.Parent=console
local dragHandle=Instance.new("TextButton")
dragHandle.Size=UDim2.new(1,-65,1,0)
dragHandle.BackgroundTransparency=1
dragHandle.BorderSizePixel=0
dragHandle.Text="Output"
dragHandle.TextColor3=Color3.new(1,1,1)
dragHandle.TextXAlignment=Enum.TextXAlignment.Left
dragHandle.Font=Enum.Font.SourceSansBold
dragHandle.TextSize=16
dragHandle.AutoButtonColor=false
dragHandle.Parent=topBar
local dragPadding=Instance.new("UIPadding")
dragPadding.PaddingLeft=UDim.new(0,8)
dragPadding.Parent=dragHandle
local clearButton=Instance.new("TextButton")
clearButton.AnchorPoint=Vector2.new(1,0.5)
clearButton.Position=UDim2.new(1,-5,0.5,0)
clearButton.Size=UDim2.fromOffset(55,22)
clearButton.BackgroundColor3=Color3.fromRGB(52,52,52)
clearButton.BorderSizePixel=0
clearButton.Text="Clear"
clearButton.TextColor3=Color3.new(1,1,1)
clearButton.Font=Enum.Font.SourceSans
clearButton.TextSize=14
clearButton.Parent=topBar
local outputScroll=Instance.new("ScrollingFrame")
outputScroll.Position=UDim2.new(0,0,0,28)
outputScroll.Size=UDim2.new(1,0,1,-28)
outputScroll.BackgroundColor3=Color3.fromRGB(20,20,20)
outputScroll.BorderSizePixel=0
outputScroll.ScrollBarThickness=6
outputScroll.CanvasSize=UDim2.new()
outputScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
outputScroll.Parent=console
local outputLayout=Instance.new("UIListLayout")
outputLayout.SortOrder=Enum.SortOrder.LayoutOrder
outputLayout.Padding=UDim.new(0,1)
outputLayout.Parent=outputScroll
local logs={}
local MAX_LOGS=300
local function logStyle(messageType)
	if messageType==Enum.MessageType.MessageError then
		return "[ERROR] ",Color3.fromRGB(255,105,105)
	elseif messageType==Enum.MessageType.MessageWarning then
		return "[WARN] ",Color3.fromRGB(255,210,80)
	elseif messageType==Enum.MessageType.MessageInfo then
		return "[INFO] ",Color3.fromRGB(120,190,255)
	end
	return "",Color3.fromRGB(220,220,220)
end
local function addLog(message,messageType)
	local prefix,color=logStyle(messageType)
	local label=Instance.new("TextLabel")
	label.Name="Log"
	label.Size=UDim2.new(1,-10,0,18)
	label.AutomaticSize=Enum.AutomaticSize.Y
	label.BackgroundTransparency=1
	label.Text=prefix..tostring(message)
	label.TextColor3=color
	label.TextXAlignment=Enum.TextXAlignment.Left
	label.TextYAlignment=Enum.TextYAlignment.Top
	label.TextWrapped=true
	label.Font=Enum.Font.Code
	label.TextSize=13
	label.Parent=outputScroll
	table.insert(logs,label)
	while #logs>MAX_LOGS do
		local oldest=table.remove(logs,1)
		if oldest then oldest:Destroy() end
	end
	task.defer(function()
		if not outputScroll.Parent then return end
		local bottom=outputScroll.AbsoluteCanvasSize.Y-outputScroll.AbsoluteSize.Y
		outputScroll.CanvasPosition=Vector2.new(0,math.max(0,bottom))
	end)
end
LogService.MessageOut:Connect(function(message,messageType)
	addLog(message,messageType)
end)
clearButton.MouseButton1Click:Connect(function()
	for _,label in ipairs(logs) do
		if label then label:Destroy() end
	end
	table.clear(logs)
end)
local dragging=false
local dragInput
local dragStart
local startPos
dragHandle.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		dragging=true
		dragStart=input.Position
		startPos=console.Position
		input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then dragging=false end
		end)
	end
end)
dragHandle.InputChanged:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
		dragInput=input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input==dragInput and dragging then
		local delta=input.Position-dragStart
		console.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
	end
end)
local resizeHandle=Instance.new("TextButton")
resizeHandle.Name="Resize"
resizeHandle.AnchorPoint=Vector2.new(1,1)
resizeHandle.Position=UDim2.fromScale(1,1)
resizeHandle.Size=UDim2.fromOffset(20,20)
resizeHandle.BackgroundColor3=Color3.fromRGB(65,65,65)
resizeHandle.BorderSizePixel=0
resizeHandle.Text="◢"
resizeHandle.TextColor3=Color3.fromRGB(230,230,230)
resizeHandle.TextSize=15
resizeHandle.AutoButtonColor=false
resizeHandle.ZIndex=10
resizeHandle.Parent=console
local resizing=false
local resizeInput
local resizeStart
local startAbsoluteSize
resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		resizing=true
		resizeStart=input.Position
		startAbsoluteSize=console.AbsoluteSize
		input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then resizing=false end
		end)
	end
end)
resizeHandle.InputChanged:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
		resizeInput=input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input==resizeInput and resizing then
		local delta=input.Position-resizeStart
		local viewport=workspace.CurrentCamera.ViewportSize
		local width=math.clamp(startAbsoluteSize.X+delta.X,250,viewport.X)
		local height=math.clamp(startAbsoluteSize.Y+delta.Y,120,viewport.Y)
		console.Size=UDim2.fromOffset(width,height)
	end
end)
addLog("Client Output initialized. F1 deletes selected BaseParts locally.",Enum.MessageType.MessageInfo)
