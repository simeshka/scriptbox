local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")
local hrp=character:WaitForChild("HumanoidRootPart")
local flying=false
local speedLevel=1
local minLevel=1
local antiGravityForce
local noclipEnabled=false
local noclipConnection
local originalCollisions={}
local infJumpEnabled=false
local function onCharacterAdded(char)
	character=char
	humanoid=character:WaitForChild("Humanoid")
	hrp=character:WaitForChild("HumanoidRootPart")
	antiGravityForce=nil
	if noclipConnection then noclipConnection:Disconnect() noclipConnection=nil end
	originalCollisions={}
	noclipEnabled=false
end
player.CharacterAdded:Connect(onCharacterAdded)
local function computeSpeedFromLevel(level)
	local k=level+12
	local sum=k*(k+1)/2
	local extra=(5*k)/2
	local base=sum+extra
	if k<5 then base+=20 end
	return base
end
local gui=Instance.new("ScreenGui")
gui.Name="FlyControlGUI"
gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,130,0,105)
frame.Position=UDim2.new(0.5,-65,0.7,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,20)
frame.BackgroundTransparency=0.2
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
local layout=Instance.new("UIGridLayout")
layout.CellSize=UDim2.new(0.5,-6,1/3,-6)
layout.CellPadding=UDim2.new(0,6,0,6)
layout.FillDirection=Enum.FillDirection.Horizontal
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Parent=frame
local plusButton=Instance.new("TextButton")
plusButton.LayoutOrder=1
plusButton.Text="+"
plusButton.Font=Enum.Font.GothamBold
plusButton.TextSize=20
plusButton.BackgroundColor3=Color3.fromRGB(0,200,100)
plusButton.TextColor3=Color3.new(1,1,1)
plusButton.Parent=frame
Instance.new("UICorner",plusButton).CornerRadius=UDim.new(0,8)
local speedLabel=Instance.new("TextLabel")
speedLabel.LayoutOrder=2
speedLabel.Font=Enum.Font.GothamSemibold
speedLabel.TextSize=12
speedLabel.BackgroundColor3=Color3.fromRGB(40,40,40)
speedLabel.TextColor3=Color3.new(1,1,1)
speedLabel.TextWrapped=true
speedLabel.Parent=frame
Instance.new("UICorner",speedLabel).CornerRadius=UDim.new(0,8)
local minusButton=Instance.new("TextButton")
minusButton.LayoutOrder=3
minusButton.Text="-"
minusButton.Font=Enum.Font.GothamBold
minusButton.TextSize=20
minusButton.BackgroundColor3=Color3.fromRGB(200,80,80)
minusButton.TextColor3=Color3.new(1,1,1)
minusButton.Parent=frame
Instance.new("UICorner",minusButton).CornerRadius=UDim.new(0,8)
local flyButton=Instance.new("TextButton")
flyButton.LayoutOrder=4
flyButton.Text="Fly"
flyButton.Font=Enum.Font.GothamBold
flyButton.TextSize=16
flyButton.BackgroundColor3=Color3.fromRGB(0,140,255)
flyButton.TextColor3=Color3.new(1,1,1)
flyButton.Parent=frame
Instance.new("UICorner",flyButton).CornerRadius=UDim.new(0,8)
local noclipButton=Instance.new("TextButton")
noclipButton.LayoutOrder=5
noclipButton.Text="NoClip"
noclipButton.Font=Enum.Font.GothamBold
noclipButton.TextSize=14
noclipButton.BackgroundColor3=Color3.fromRGB(120,0,200)
noclipButton.TextColor3=Color3.new(1,1,1)
noclipButton.Parent=frame
Instance.new("UICorner",noclipButton).CornerRadius=UDim.new(0,8)
local infJumpButton=Instance.new("TextButton")
infJumpButton.LayoutOrder=6
infJumpButton.Text="InfJump"
infJumpButton.Font=Enum.Font.GothamBold
infJumpButton.TextSize=13
infJumpButton.BackgroundColor3=Color3.fromRGB(0,140,255)
infJumpButton.TextColor3=Color3.new(1,1,1)
infJumpButton.Parent=frame
Instance.new("UICorner",infJumpButton).CornerRadius=UDim.new(0,8)
local function updateSpeedLabel(messageOverride)
	if messageOverride then speedLabel.Text=messageOverride else speedLabel.Text=string.format("Speed: %.1f",speedLevel) end
end
updateSpeedLabel()
local function enableAntiGravity()
	if not hrp or antiGravityForce then return end
	local bf=Instance.new("BodyForce")
	bf.Name="AntiGravityForce"
	bf.Force=Vector3.new(0,hrp.AssemblyMass*workspace.Gravity,0)
	bf.Parent=hrp
	antiGravityForce=bf
end
local function disableAntiGravity()
	if antiGravityForce then antiGravityForce:Destroy() antiGravityForce=nil end
end
local function setNoClip(state:boolean)
	if state and not noclipEnabled then
		noclipEnabled=true
		originalCollisions={}
		noclipConnection=RunService.Stepped:Connect(function()
			if not character or not character.Parent then return end
			for _,part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					if originalCollisions[part]==nil then originalCollisions[part]=part.CanCollide end
					part.CanCollide=false
				end
			end
		end)
	elseif not state and noclipEnabled then
		noclipEnabled=false
		if noclipConnection then noclipConnection:Disconnect() noclipConnection=nil end
		for part,canCollide in pairs(originalCollisions) do
			if part and part.Parent then part.CanCollide=canCollide end
		end
		originalCollisions={}
	end
end
plusButton.MouseButton1Click:Connect(function()
	speedLevel+=1
	updateSpeedLabel()
end)
minusButton.MouseButton1Click:Connect(function()
	if speedLevel>minLevel then
		speedLevel-=1
		updateSpeedLabel()
	else
		updateSpeedLabel("Speed cannot be below 1")
		task.delay(1.5,function()
			if speedLevel==minLevel then updateSpeedLabel() end
		end)
	end
end)
flyButton.MouseButton1Click:Connect(function()
	flying=not flying
	if flying then
		flyButton.Text="Unfly"
		flyButton.BackgroundColor3=Color3.fromRGB(255,170,0)
		enableAntiGravity()
	else
		flyButton.Text="Fly"
		flyButton.BackgroundColor3=Color3.fromRGB(0,140,255)
		disableAntiGravity()
		if hrp then hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
	end
end)
noclipButton.MouseButton1Click:Connect(function()
	setNoClip(not noclipEnabled)
	if noclipEnabled then
		noclipButton.Text="Clip"
		noclipButton.BackgroundColor3=Color3.fromRGB(200,60,60)
	else
		noclipButton.Text="NoClip"
		noclipButton.BackgroundColor3=Color3.fromRGB(120,0,200)
	end
end)
infJumpButton.MouseButton1Click:Connect(function()
	infJumpEnabled=not infJumpEnabled
	if infJumpEnabled then
		infJumpButton.Text="OneJump"
		infJumpButton.BackgroundColor3=Color3.fromRGB(200,60,60)
	else
		infJumpButton.Text="InfJump"
		infJumpButton.BackgroundColor3=Color3.fromRGB(0,140,255)
	end
end)
UserInputService.JumpRequest:Connect(function()
	if not infJumpEnabled then return end
	if not humanoid or humanoid.Health<=0 then return end
	local state=humanoid:GetState()
	if state~=Enum.HumanoidStateType.Running and state~=Enum.HumanoidStateType.RunningNoPhysics and state~=Enum.HumanoidStateType.Landed then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)
RunService.RenderStepped:Connect(function()
	if not flying then return end
	if not character or not hrp or not humanoid then return end
	local cam=workspace.CurrentCamera
	if not cam then return end
	local moveDir=humanoid.MoveDirection
	if moveDir.Magnitude<0.05 then hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) return end
	local horizontal=Vector3.new(moveDir.X,0,moveDir.Z)
	if horizontal.Magnitude>0 then horizontal=horizontal.Unit end
	local look=cam.CFrame.LookVector
	local camFlat=Vector3.new(look.X,0,look.Z)
	if camFlat.Magnitude>0 then camFlat=camFlat.Unit end
	local forwardAmount=0
	if horizontal.Magnitude>0 and camFlat.Magnitude>0 then forwardAmount=horizontal:Dot(camFlat) end
	local vertical=look.Y*forwardAmount
	local finalDir=Vector3.new(horizontal.X,vertical,horizontal.Z)
	if finalDir.Magnitude<0.05 then hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) return end
	finalDir=finalDir.Unit
	hrp.AssemblyLinearVelocity=finalDir*computeSpeedFromLevel(speedLevel)
end)
