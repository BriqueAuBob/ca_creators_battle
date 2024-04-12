SWEP.PrintName			= "Color Run Tool"
SWEP.Category = "Color Run"
SWEP.Author			    = ""
SWEP.Instructions		= ""

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

local vector1
local vector2
local spam = 0
function SWEP:PrimaryAttack()
    if SERVER then return end
    if spam >= CurTime() then return end

    if not isvector( vector1 ) and not isvector( vector2 ) then 
        vector1 = self.Owner:GetEyeTrace().HitPos
        spam = CurTime() + 0.5
        return
    end
    if not isvector( vector2 ) and isvector( vector1 ) then
        vector2 = self.Owner:GetEyeTrace().HitPos
        spam = CurTime() + 0.5
        return
    end
end

function SWEP:SecondaryAttack()
    if CLIENT then
        if not vector1 and vector2 or not isvector(vector1) or not isvector(vector2) then return end
        ColorRun:SendNet( ColorRun.ENUMS.CreateZone, function() net.WriteVector( vector1 ) net.WriteVector( vector2 ) end )
        vector1 = nil
        vector2 = nil
    end
end

function SWEP:Reload()
    vector1 = nil
    vector2 = nil
end

hook.Add( "PostDrawOpaqueRenderables", "ColorRun:Hooks:PostDrawOpaqueRenderables:Swep", function()
    local ply = LocalPlayer()

    local ang = Angle( 0, 0, 0 )
    local x, y, z
    local a, b, c
    if isvector( vector1 ) and isvector( vector2 ) then
        x, y, z = vector1:Unpack()
        a, b, c = vector2:Unpack()
    end
    cam.Start3D2D( isvector( vector1 ) and vector1 + Vector( 0, 0, 5 ) or Vector( 0, 0, 0 ), ang, 1 )
        surface.SetDrawColor( Color( 170, 170, 170 ) )
        surface.DrawRect( 0, 0, a and ( a - x ) or 10, b and ( y - b ) or 10 )
    cam.End3D2D()
end )