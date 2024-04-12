include( "shared.lua" )

function ENT:Draw()
	self:DrawModel()

	local trace = LocalPlayer():GetEyeTrace()
	
	if not trace.Entity or not IsValid(trace.Entity) then return end
	if trace.Entity:GetClass() ~= self:GetClass() then return end

	-- cam.Start3D2D(self:GetPos() + self:GetUp() * 70 + self:GetRight() + self:GetForward(), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
	-- 	draw.RoundedBox(20, -500, -500, 1000, 1000, Color(232, 0, 143,255))
	-- cam.End3D2D()
end
