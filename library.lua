local ESP_Library = {}

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
			if child:IsA("Highlight") or (child:IsA("BillboardGui") and child.Name == "ESP_Billboard") then
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
			local runService = game:GetService("RunService")
			local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

			runService.RenderStepped:Connect(function()
				if not hrp then
					hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				end
				if hrp and part:IsDescendantOf(game.Workspace) then
					local dist = (hrp.Position - part.Position).Magnitude
					distLabel.Text = string.format("(%.0fm)", dist)
				end
			end)
		end
	end
end

return ESP_Library
