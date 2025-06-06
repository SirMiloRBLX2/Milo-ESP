local AutoClick = {}

AutoClick.Speed = 2
AutoClick.Fire = false
AutoClick.Target = nil

local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

function AutoClick:GetGuiCenter(gui)
	if not gui or not gui:IsA("GuiObject") then return nil end
	local absPos = gui.AbsolutePosition
	local absSize = gui.AbsoluteSize
	return Vector2.new(absPos.X + absSize.X / 2, absPos.Y + absSize.Y / 2)
end

RunService.RenderStepped:Connect(function(dt)
	if AutoClick.Fire and AutoClick.Target then
		AutoClick._timer = (AutoClick._timer or 0) + dt
		if AutoClick._timer >= (1 / AutoClick.Speed) then
			AutoClick._timer = 0
			local center = AutoClick:GetGuiCenter(AutoClick.Target)
			if center then
				VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
				VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
			end
		end
	end
end)

return AutoClick
