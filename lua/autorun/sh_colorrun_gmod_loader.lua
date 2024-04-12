ColorRun = ColorRun or {}
ColorRun.Plates = ColorRun.Plates or {}
ColorRun.ZonePos = ColorRun.ZonePos or {}

ColorRun.ENUMS = ColorRun.ENUMS or {}
ColorRun.ENUMS.JoinQueue = 1
ColorRun.ENUMS.CreateGame = 2
ColorRun.ENUMS.InviteTeam = 3
ColorRun.ENUMS.ReceiveInvitation = 4
ColorRun.ENUMS.Notify = 5
ColorRun.ENUMS.CancelInvite = 6
ColorRun.ENUMS.AcceptInvite = 7
ColorRun.ENUMS.OpenMenu = 8
ColorRun.ENUMS.KickMember = 9
ColorRun.ENUMS.CreateZone = 10
ColorRun.ENUMS.Debug = 11
ColorRun.ENUMS.InitGame = 12
ColorRun.ENUMS.ColorToGO = 13
ColorRun.ENUMS.StartRound = 14
ColorRun.ENUMS.Points = 15
ColorRun.ENUMS.EndGame = 16

AddCSLuaFile( "color_run/shared/sh_networking.lua" )
include( "color_run/shared/sh_networking.lua" )


local function loadfolder( path )
    local files, folders = file.Find( path .. "*", "LUA" )
    
    for k, v in pairs( files ) do
        if v == "sh_networking.lua" then continue end
        if SERVER then
            if string.find( v, "cl_") or string.find(v, "sh_" ) then
                AddCSLuaFile( path .. v )
            end

            if string.find( v, "sv_" ) or string.find( v, "sh_" ) then
                include( path .. v )
            end
        else
            include( path .. v )
        end
    end

    for k, v in pairs( folders ) do
        loadfolder( path .. v .. "/" )
    end
end

if SERVER then 
    local function loadfastdl( path )
        local files, dirs = file.Find( path .."*", "GAME" )
        
        for k, v in pairs( files ) do
            resource.AddSingleFile( path ..v )
        end
        
        for _, dir in ipairs( dirs ) do
            loadfastdl( path .. dir .. "/")
        end
    end

    loadfastdl( "materials/color_run/" )
    loadfastdl( "sound/color_run/" )
end

loadfolder( "color_run/" )