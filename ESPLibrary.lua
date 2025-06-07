local ESP_Library = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_Objects = {}

function ESP_Library:ClearOldESP(target)
    if ESP_Objects[target] then
        for _, obj in pairs(ESP_Objects[target]) do
            if typeof(obj) == "table" and obj.Line then
                obj.Line:Remove()
            elseif typeof(obj) == "Instance" then
                obj:Destroy()
            elseif typeof(obj) == "userdata" and obj.Remove then
                obj:Remove()
            end
        end
        ESP_Objects[target] = nil
    end
end

function ESP_Library:CreateESP(target, settings)
    if not target:IsA("Model") then return end
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    self:ClearOldESP(target)
    ESP_Objects[target] = {}

    if settings.Highlight and settings.Highlight.Enabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = target
        highlight.FillColor = settings.Highlight.Color
        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.OutlineTransparency = 1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = target
        table.insert(ESP_Objects[target], highlight)
    end

    if settings.TracerESP and settings.TracerESP.Enabled then
        local tracer = Drawing.new("Line")
        tracer.Thickness = 1.5
        tracer.Color = settings.TracerESP.Color
        tracer.Transparency = 1
        tracer.ZIndex = 2
        tracer.Visible = true
        table.insert(ESP_Objects[target], { Line = tracer, Type = "Tracer" })
    end

    if settings.BoxESP and settings.BoxESP.Enabled then
        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Filled = false
        box.Color = settings.BoxESP.Color
        box.Transparency = 1
        box.ZIndex = 2
        box.Visible = true
        table.insert(ESP_Objects[target], { Line = box, Type = "Box" })
    end

    local skeletonLines = {}
    if settings.SkeletonESP and settings.SkeletonESP.Enabled then
        local bones = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"UpperTorso", "RightUpperArm"},
            {"UpperTorso", "LeftUpperLeg"},
            {"UpperTorso", "RightUpperLeg"},
        }

        for _, bone in ipairs(bones) do
            local p1 = target:FindFirstChild(bone[1])
            local p2 = target:FindFirstChild(bone[2])
            if p1 and p2 then
                local line = Drawing.new("Line")
                line.Thickness = 1.5
                line.Color = settings.SkeletonESP.Color
                line.Transparency = 1
                line.Visible = true
                table.insert(skeletonLines, { Line = line, Part0 = p1, Part1 = p2 })
            end
        end

        ESP_Objects[target].Skeleton = skeletonLines
    end

    if settings.Name.Enabled or settings.Distance.Enabled then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.zero
        billboard.AlwaysOnTop = true
        billboard.Parent = hrp

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextStrokeTransparency = 0.5
        label.TextColor3 = settings.Name.Color
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = settings.Name.Enabled and target.Name or ""
        label.Parent = billboard

        if settings.Distance.Enabled then
            local function updateDistance()
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and hrp then
                    local dist = (myHRP.Position - hrp.Position).Magnitude
                    label.Text = string.format("%s (%.0fm)", target.Name, dist)
                end
            end
            updateDistance()
            RunService.RenderStepped:Connect(updateDistance)
        end

        table.insert(ESP_Objects[target], billboard)
    end

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not target or not target.Parent then conn:Disconnect() return end
        local hrp = target:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local boxSize = Vector2.new(50, 100)
        local boxTopLeft = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)

        for _, item in ipairs(ESP_Objects[target]) do
            if item.Line and item.Type == "Tracer" then
                item.Line.Visible = onScreen
                item.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                item.Line.To = Vector2.new(screenPos.X, screenPos.Y)
            elseif item.Line and item.Type == "Box" then
                item.Line.Visible = onScreen
                item.Line.Size = boxSize
                item.Line.Position = boxTopLeft
            end
        end

        if ESP_Objects[target].Skeleton then
            for _, skel in ipairs(ESP_Objects[target].Skeleton) do
                local p0 = skel.Part0.Position
                local p1 = skel.Part1.Position
                local p0Screen, ok0 = Camera:WorldToViewportPoint(p0)
                local p1Screen, ok1 = Camera:WorldToViewportPoint(p1)

                if ok0 and ok1 then
                    skel.Line.Visible = true
                    skel.Line.From = Vector2.new(p0Screen.X, p0Screen.Y)
                    skel.Line.To = Vector2.new(p1Screen.X, p1Screen.Y)
                else
                    skel.Line.Visible = false
                end
            end
        end
    end)

    table.insert(ESP_Objects[target], conn)
end

return ESP_Library
