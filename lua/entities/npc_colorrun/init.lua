AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ColorRun.NPC = ColorRun.NPC or {}
ColorRun.NPC.TPPos = Vector( 0, 0, 0 )

function ENT:Initialize( )
	self:SetModel( "models/gman_high.mdl" )
    self:SetHullType( HULL_HUMAN )
    self:SetHullSizeNormal()
    self:SetNPCState( NPC_STATE_SCRIPT )
    self:SetSolid( SOLID_BBOX )
    self:CapabilitiesAdd( CAP_ANIMATEDFACE )
    self:SetUseType( SIMPLE_USE )
    self:DropToFloor()
end

function ENT:OnRemove()   
end

function ENT:SpawnFunction(ply, tr, class)
    if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create( class )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
    
    ColorRun.NPC.TPPos = ent:GetPos() + ent:GetRight() * 15
    return ent
end

function ENT:AcceptInput( name, ply )
    if name ~= "Use" then return end
    ColorRun:SendNet(ColorRun.ENUMS.OpenMenu, function()
        local table = ColorRun:GetPlayerTeam( ply:SteamID64() )        
        net.WriteTable(table)
        net.WriteBool(ColorRun.queue["players"] and ColorRun.queue["players"][ply] or false)
    end, ply)
end