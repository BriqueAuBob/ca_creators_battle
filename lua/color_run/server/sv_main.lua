local waiting_invite = {}

local teams = {
    ["owners"] = {},
    ["members"] = {}
}

ColorRun.queue = ColorRun.queue or {}
ColorRun.game = ColorRun.game or {}

local function InvertTable( tbl )
    local invert = {}
    if table.IsEmpty(tbl) then
        return nil
    end
    for k, v in pairs( tbl ) do
        invert[v] = k
    end
    return invert
end

function ColorRun:GetPlayerTeam( steamid64 )
    if not teams["members"][steamid64] then return {} end

    local team_table = table.Copy( teams )
    local team = {}
    local team_id = team_table["members"][steamid64]
    local owner_id = team_table["owners"][team_id]

    team[steamid64] = owner_id == steamid64 and "owner" or "member"
    
    team_table["members"][steamid64] = nil
    
    local invert = InvertTable( team_table["members"] )
    if not invert then return end
    team[invert[team_id]] = owner_id == invert[team_id] and "owner" or "member"
    
    return team
end

ColorRun:RegisterCallback( ColorRun.ENUMS.InviteTeam, function( ply )
    local entity = net.ReadEntity()
    if entity == ply then return end
    if waiting_invite[ply:SteamID64()] then ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "already_invited" ):format(entity:Nick()), 0, 5 ) return end
    if ply.NextInviteColorRunTeam and ply.NextInviteColorRunTeam >= CurTime() then return end

    ColorRun:NotifyPlayer( entity, ( ColorRun:GetTranslation( "invited_by" ) ):format( ply:Name() ), 1 )
    ColorRun:NotifyPlayer( ply, ( ColorRun:GetTranslation( "invited_who" ) ):format( entity:Name() ), 2, 10 )

    waiting_invite[ply:SteamID64()] = entity:SteamID64()
    ply.NextInviteColorRunTeam = CurTime() + 10
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.CancelInvite, function( ply )
    if not waiting_invite[ply:SteamID64()] then return end

    local player = player.GetBySteamID64( waiting_invite[ply:SteamID64()] )
    waiting_invite[ply:SteamID64()] = nil
    
    if IsValid( player ) and player:IsPlayer() then
        ColorRun:NotifyPlayer( player, ( ColorRun:GetTranslation( "canceled_by" ) ):format( ply:Name() ), 0, 10 )
    end
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.AcceptInvite, function( ply )
    if not table.HasValue( waiting_invite, ply:SteamID64() ) then return end
    local invert = InvertTable( waiting_invite ) -- Reverse the invite to get the "host" steamid
    if not invert[ply:SteamID64()] then return end
    
    local team_id = #teams["owners"] + 1
    teams["owners"][team_id] = invert[ply:SteamID64()]  -- Set the "owner" as owner
    teams["members"][ply:SteamID64()] = team_id         -- Set the "guest" as member
    teams["members"][invert[ply:SteamID64()]] = team_id  -- Set the "owner" as member
    
    waiting_invite[invert[ply:SteamID64()]] = nil
    
    ColorRun:NotifyPlayer( player.GetBySteamID64( teams["owners"][team_id] ), ( ColorRun:GetTranslation( "member_join" ) ):format( ply:Name() ), 0, 5 )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.KickMember, function( ply )
    local type = net.ReadInt(3)

    local team_id = teams["members"][ply:SteamID64()]
    local owner_id = teams["owners"][team_id]
    
    teams["members"][ply:SteamID64()] = nil
    local invert = InvertTable( teams["members"] )
    local victim = invert[team_id]

    teams["members"][victim] = nil
    teams["owners"][team_id] = nil

    local player = player.GetBySteamID64( victim )
    ColorRun:NotifyPlayer( ply, type == 1 and ColorRun:GetTranslation( "you_has_kick" ):format( player:Name() ) or ColorRun:GetTranslation( "you_left_team" ), 0, 5 )
    ColorRun:NotifyPlayer( player, type == 1 and ColorRun:GetTranslation( "you_get_kick" ):format( ply:Name() ) or ColorRun:GetTranslation( "left_team" ):format( ply:Name() ), 0, 5 )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.JoinQueue, function( ply )
    ColorRun:RefreshQueue(ply, net.ReadInt(3))
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.CreateGame, function( ply )
    local receivedGameOptions = ColorRun:ReadTable()

    -- if ColorRun.queue["owner"] then return end 
    ColorRun.queue = {
        ["owner"] = ply,
        ["settings"] = {
            ["gamemodes"] = {
                [1] = receivedGameOptions["gamemodes"][1] == 1 and true or false,
                [2] = receivedGameOptions["gamemodes"][2] == 1 and true or false,
                [3] = receivedGameOptions["gamemodes"][3] == 1 and true or false,
                [4] = receivedGameOptions["gamemodes"][4] == 1 and true or false,
            },
            ["players_max"] = receivedGameOptions.players_max or 8,
            ["round_amount"] = receivedGameOptions.round_amount or 3,
            ["bonuses"] = receivedGameOptions.bonuses == 1 and true or false,
            ["duos"] = receivedGameOptions.duos == 1 and true or false,
        },
        ["players"] = {}
    }

    ColorRun:RefreshQueue( ply, 1, true )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.CreateZone, function( ply )
    local vector1 = net.ReadVector()
    local vector2 = net.ReadVector()

    ColorRun:GenerateNewFloor( vector1 + Vector( 0, 0, 100 ), vector2 + Vector( 0, 0, 100 ) )
    
    if not file.IsDir( "color_run/maps", "DATA" ) then file.CreateDir( "color_run/maps" ) end
    file.Write( "color_run/maps/" ..game.GetMap() ..".json", util.TableToJSON( { ["vector1"] = vector1, ["vector2"] = vector2 } ) )
end )

local function GenerateZone()
    if not file.Exists( "color_run/maps/" ..game.GetMap() ..".json", "DATA" ) then return end

    local json = file.Read( "color_run/maps/" ..game.GetMap() ..".json", "DATA" )
    local unjson = util.JSONToTable( json )

    ColorRun:GenerateNewFloor( unjson["vector1"] + Vector( 0, 0, 100 ), unjson["vector2"] + Vector( 0, 0, 100 ) )
end

hook.Add( "PlayerDeath", "ColorRun:Hooks:PlayerDeath:Spectate", function( ply )
    if not ply:GetNWBool( "ingame" ) or not ColorRun.game["players"]["alive"][ply] then return end

    ColorRun.game["players"]["alive"][ply] = nil
    ColorRun.game["players"]["died"][ply] = true
end )

hook.Add( "InitPostEntity", "ColorRun:Hooks:InitPostEntity:LoadColorRunZone", GenerateZone )

hook.Add( "PostCleanupMap", "ColorRun:Hooks:PostCleanUpMap:LoadColorRunZone", GenerateZone )

hook.Add( "PlayerDisconnected", "ColorRun:Hooks:PlayerDisconnected:QuitTeam", function( ply )
    if waiting_invite[ply:SteamID64()] then table.remove( waiting_invite, ply:SteamID64() ) end
    if teams["members"][ply:SteamID64()] then
        local team_id = teams["members"][ply:SteamID64()]
        teams["members"][ply:SteamID64()] = nil
        teams["owners"][team_id] = nil
        local invert = InvertTable( teams["members"] )
        local playersteamid = invert[team_id]
        teams["members"][playersteamid] = nil
        local player = player.GetBySteamID64( playersteamid )
        if IsValid( player ) and player:IsPlayer() then
            ColorRun:NotifyPlayer( player, ( ColorRun:GetTranslation( "member_disconnect" ) ):format( ply:Name() ), 0, 5 )
        end
    end
end )

hook.Add( "PlayerDisconnected", "ColorRun:Hooks:PlayerDisconnected:RefreshQueue", function( ply )
    if ply.queue then
        ColorRun:RefreshQueue(ply, 2)
    end
end )

hook.Add("PlayerInitialSpawn", "ColorRun:Hooks:PlayerInitialSpawn", function(p)
    p:SetNWBool("ingame", false)
end)

    

hook.Add("PlayerSpawn", "ColorRun:Hooks:PlayerSpawn", function(p)
    if table.IsEmpty(ColorRun.game) then return end
    if not ColorRun.game["players"]["alive"][p] then
        ColorRun.game["players"]["died"][p] = nil
        ColorRun.game["players"]["alive"][p] = true
    end
end)
concommand.Add("a", function(p) p:SetNWBool("ingame", false) end)