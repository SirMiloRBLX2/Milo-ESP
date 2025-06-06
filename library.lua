local ESP_Library = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

function ESP_Library:ResolvePart(target)
	if not target then return nil end
	if target:IsA("Model") then
		return target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
	elseif target:IsA("BasePart") then
		return target
	end
	return nil
end

function ESP_Library:ClearOldESP(target)
	if target:IsA("Model") or target:IsA("BasePart") then
		for _, child in ipairs(target:GetChildren()) do
			if child:IsA("Highlight") or (child:IsA("BillboardGui") and child.Name == "ESP_Billboard") or child.Name == "ESP_Box" or child.Name == "ESP_Skeleton" or child.Name == "ESP_Tracer" then
				child:Destroy()
			end
		end
	end
end

function ESP_Library:CreateESP(target, settings)
	local part = self:ResolvePart(target)
	if not part then return end
	
	self:ClearOldESP(target)
	
	if settings.Highlight.Enabled then
		local highlight = Instance.new("Highlight")
		highlight.Adornee = target
		highlight.FillColor = settings.Highlight.Color
		highlight.OutlineTransparency = 1
		highlight.Name = "ESP_Highlight"
		highlight.Parent = target
	end

	if settings.Name.Enabled or settings.Distance.Enabled then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP_Billboard"
		billboard.Adornee = part
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = part

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
		nameLabel.Position = UDim2.new(0, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextStrokeTransparency = 0.5
		nameLabel.TextColor3 = settings.Name.Color
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Text = settings.Name.Enabled and tostring(target.Name) or ""
		nameLabel.Parent = billboard

		local distLabel = Instance.new("TextLabel")
		distLabel.Name = "DistLabel"
		distLabel.Size = UDim2.new(1, 0, 0.5, 0)
		distLabel.Position = UDim2.new(0, 0, 0.5, 0)
		distLabel.BackgroundTransparency = 1
		distLabel.TextStrokeTransparency = 0.5
		distLabel.TextColor3 = settings.Name.Color
		distLabel.TextScaled = true
		distLabel.Font = Enum.Font.GothamBold
		distLabel.Text = settings.Distance.Enabled and "(0m)" or ""
		distLabel.Parent = billboard

		if settings.Distance.Enabled then
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

			local conn
			conn = RunService.RenderStepped:Connect(function()
				if not hrp or not part or not part:IsDescendantOf(workspace) then
					conn:Disconnect()
					return
				end
				local dist = (hrp.Position - part.Position).Magnitude
				distLabel.Text = string.format("(%.0fm)", dist)
			end)
		end
	end

	if settings.BoxESP and settings.BoxESP.Enabled then
		local box = Instance.new("BillboardGui")
		box.Name = "ESP_Box"
		box.Adornee = part
		box.AlwaysOnTop = true
		box.Size = UDim2.new(0, 100, 0, 150)
		box.StudsOffset = Vector3.new(0, 3, 0)
		box.Parent = part

		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.Parent = box

		local border = Instance.new("UICorner")
		border.CornerRadius = UDim.new(0, 6)
		border.Parent = frame

		local outline = Instance.new("UIStroke")
		outline.Thickness = 2
		outline.Color = settings.BoxESP.Color
		outline.Parent = frame
	end
	
	if settings.TracerESP and settings.TracerESP.Enabled then
		local tracer = Instance.new("BillboardGui")
		tracer.Name = "ESP_Tracer"
		tracer.Adornee = part
		tracer.Size = UDim2.new(0, 2, 0, 300)
		tracer.StudsOffset = Vector3.new(0, 1, 0)
		tracer.AlwaysOnTop = true
		tracer.Parent = part

		local line = Instance.new("Frame")
		line.Size = UDim2.new(0, 2, 1, 0)
		line.Position = UDim2.new(0, 0, 0, 0)
		line.BackgroundColor3 = settings.TracerESP.Color
		line.BorderSizePixel = 0
		line.Parent = tracer
	end
	
	if settings.SkeletonESP and settings.SkeletonESP.Enabled and target:IsA("Model") then
		local skeleton = Instance.new("Folder")
		skeleton.Name = "ESP_Skeleton"
		skeleton.Parent = target

		local function createLimbLine(part0, part1)
			local line = Drawing and Drawing.new and Drawing.new("Line") or nil
			if line then
				line.Visible = true
				line.Thickness = 2
				line.Color = settings.SkeletonESP.Color
				return line, part0, part1
			else
				local attachment0 = Instance.new("Attachment", part0)
				local attachment1 = Instance.new("Attachment", part1)
				local beam = Instance.new("Beam")
				beam.Attachment0 = attachment0
				beam.Attachment1 = attachment1
				beam.Width0 = 0.1
				beam.Width1 = 0.1
				beam.FaceCamera = true
				beam.Color = ColorSequence.new(settings.SkeletonESP.Color)
				beam.Parent = skeleton
				return beam, attachment0, attachment1
			end
		end

		local hrp = target:FindFirstChild("HumanoidRootPart")
		local head = target:FindFirstChild("Head")
		local torso = target:FindFirstChild("UpperTorso") or target:FindFirstChild("Torso")
		local leftArm = target:FindFirstChild("LeftUpperArm") or target:FindFirstChild("Left Arm")
		local rightArm = target:FindFirstChild("RightUpperArm") or target:FindFirstChild("Right Arm")
		local leftLeg = target:FindFirstChild("LeftUpperLeg") or target:FindFirstChild("Left Leg")
		local rightLeg = target:FindFirstChild("RightUpperLeg") or target:FindFirstChild("Right Leg")

		if hrp and head and torso and leftArm and rightArm and leftLeg and rightLeg then
			local limbs = {
				{torso, leftArm},
				{torso, rightArm},
				{torso, leftLeg},
				{torso, rightLeg},
				{torso, head},
			}
			for _, pair in ipairs(limbs) do
				createLimbLine(pair[1], pair[2])
			end
		end
	end
end

return ESP_Library
