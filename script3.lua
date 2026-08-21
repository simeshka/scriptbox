local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

if Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
    return
end

local DinoAnimation = Instance.new("Animation")
DinoAnimation.AnimationId = "rbxassetid://20432871"
local LoadedDinoAnim = Humanoid:LoadAnimation(DinoAnimation)

local PunchAnimation = Instance.new("Animation")
PunchAnimation.AnimationId = "rbxassetid://84674780"
local LoadedPunchAnim = Humanoid:LoadAnimation(PunchAnimation)

local FlingAnimation = Instance.new("Animation")
FlingAnimation.AnimationId = "rbxassetid://204062532"
local LoadedFlingAnim = Humanoid:LoadAnimation(FlingAnimation)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "1"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function CreateButton(name, text, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 89, 0, 49)
    button.Position = position
    button.BorderSizePixel = 0
    button.Font = Enum.Font.SourceSans
    button.TextScaled = true
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(224, 111, 64)
    button.Parent = ScreenGui
    return button
end

local DinoButton = CreateButton("DinoButton", "Dino Anim (Off)", UDim2.new(0, 0, 0, 0))
local PunchButton = CreateButton("PunchButton", "Punch Anim (Off)", UDim2.new(0, 0, 0, 50))
local FlingButton = CreateButton("FlingButton", "Fling (Off)", UDim2.new(0, 0, 0, 100))

local isDinoActive = false
local isPunchActive = false
local isFlingActive = false

DinoButton.MouseButton1Click:Connect(function()
    isDinoActive = not isDinoActive
    if isDinoActive then
        DinoButton.Text = "Dino Anim (On)"
        DinoButton.BackgroundColor3 = Color3.fromRGB(111, 224, 64)
        LoadedDinoAnim:Play()
    else
        DinoButton.Text = "Dino Anim (Off)"
        DinoButton.BackgroundColor3 = Color3.fromRGB(224, 111, 64)
        LoadedDinoAnim:Stop()
    end
end)

PunchButton.MouseButton1Click:Connect(function()
    isPunchActive = not isPunchActive
    if isPunchActive then
        PunchButton.Text = "Punch Anim (On)"
        PunchButton.BackgroundColor3 = Color3.fromRGB(111, 224, 64)
        LoadedPunchAnim:Play()
    else
        PunchButton.Text = "Punch Anim (Off)"
        PunchButton.BackgroundColor3 = Color3.fromRGB(224, 111, 64)
        LoadedPunchAnim:Stop()
    end
end)

FlingButton.MouseButton1Click:Connect(function()
    isFlingActive = not isFlingActive
    if isFlingActive then
        FlingButton.Text = "Fling (On)"
        FlingButton.BackgroundColor3 = Color3.fromRGB(111, 224, 64)
        LoadedFlingAnim:Play()
    else
        FlingButton.Text = "Fling (Off)"
        FlingButton.BackgroundColor3 = Color3.fromRGB(224, 111, 64)
        LoadedFlingAnim:Stop()
    end
end)

local isDragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    ScreenGui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ScreenGui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = ScreenGui.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

ScreenGui.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        updateInput(input)
    end
end)
