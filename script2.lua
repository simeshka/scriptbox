local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

humanoid.AutoRotate = false

local speed = math.rad(360 * 50)

RunService.RenderStepped:Connect(function(dt)
	root.CFrame *= CFrame.Angles(
		speed * dt,
		speed * dt,
		speed * dt
	)
end)
