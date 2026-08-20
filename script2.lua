local Players = game:GetService("Players")

local function highlightCharacter(character)
	if character:FindFirstChild("PlayerHighlight") then return end

	local h = Instance.new("Highlight")
	h.Name = "PlayerHighlight"
	h.FillTransparency = 0.5
	h.OutlineTransparency = 0
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Adornee = character
	h.Parent = character
end

local function setupPlayer(player)
	if player.Character then
		highlightCharacter(player.Character)
	end

	player.CharacterAdded:Connect(highlightCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= Players.LocalPlayer then
		setupPlayer(player)
	end
end

Players.PlayerAdded:Connect(function(player)
	setupPlayer(player)
end)
