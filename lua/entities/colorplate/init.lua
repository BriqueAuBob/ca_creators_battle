AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube075x075x025.mdl" )
	self:SetMaterial("models/debug/debugwhite")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )  
	self:SetModelScale( self:GetModelScale() * 1.014, 1 )
	local phys = self:GetPhysicsObject()
	phys:EnableMotion( false ) 
end

function ENT:CanProperty()
 	return false
end

function ENT:SetToWhite( c )
	if self:GetColor().r == c.r and self:GetColor().g == c.g and self:GetColor().b == c.b then
		ColorRun.game["valid_plates"][#ColorRun.game["valid_plates"] + 1] = self
		return
	end
	self:SetColor( Color( 255, 255, 255 ) )
	self.iswhite = true	
end

function ENT:Touch(ent)
	if not ent:IsPlayer() or not ColorRun.game or table.IsEmpty( ColorRun.game ) or not ColorRun.game["round"] or table.IsEmpty( ColorRun.game["round"] ) or not isnumber( ColorRun.game["round"]["gamemode"] ) then 
		return 
	end
	if self.iswhite then
		ent:Kill()
	end
	--ent:SetPos( ColorRun.NPC.TPPos ) -- player not in game so teleport 
	
	local tbl = ColorRun:GetGamemodesTable()
	if not isfunction( tbl[ColorRun.game["round"]["gamemode"]].plateTouch ) then return end
	
	tbl[ColorRun.game["round"]["gamemode"]].plateTouch( self, ent )
end

hook.Add("CanTool", "ColorRun:Hooks:CanTool", function ( ply, tr, tool )
	if IsValid( tr.Entity ) and tr.Entity:GetClass() == "colorplate" then
	end
end)

hook.Add( "PhysgunPickup", "ColorRun:Hooks:PhysgunPickup", function( ply, ent )
	if ent:GetClass() ~= "colorplate" and ent:GetClass() ~= "colorrun_speaker" then return end
	return false
end )

hook.Add( "Move", "ColorRun:Hooks:Move", function(ply, mv)
    if not ply:GetNWBool("ingame") then return end
    if not ColorRun.ZonePos["vector1"] or not ColorRun.ZonePos["vector2"] then return end

	if not ply:GetPos():WithinAABox(ColorRun.ZonePos["vector1"], ColorRun.ZonePos["vector2"] - Vector(0, 0, 1500)) then
	end
    --     local x, y, z = ColorRun.ZonePos["vector1"]:Unpack()
    --     local a, b, c = ColorRun.ZonePos["vector2"]:Unpack()
    --     local midx, midy, midz = (x + a) / 2, (y + b) / 2, (z + c) / 2
	-- 	local middle = Vector(midx, midy, midz)
	-- 	ply:SetEyeAngles(Angle(90,0,0))
	-- end
	return
end )