include( "shared.lua" )

function ENT:Draw()
	self:DrawShadow( false )
	self:DestroyShadow()
	self:DrawModel(false)
end
