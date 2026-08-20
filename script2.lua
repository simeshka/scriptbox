local RunService = game:GetService("RunService")
local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

humanoid.AutoRotate = false

RunService.RenderStepped:Connect(function(dt)
	root.CFrame *= CFrame.Angles(0, math.rad(360 * 50) * dt, 0)
end)
