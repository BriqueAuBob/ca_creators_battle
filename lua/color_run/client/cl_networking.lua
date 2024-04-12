net.Receive( "ColorRun:Networking", function()
    local netid = net.ReadInt(6)
    if not netid then return end
    if not ColorRun.netsCallbacks[netid] then return end

    ColorRun.netsCallbacks[netid]()
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.InitGame, function()
    local tbl = ColorRun:ReadTable()

    if tbl.mate and IsValid( tbl.mate ) then
        LocalPlayer().mate = tbl.mate
    end
    ColorRun.GamemodesUtils = ColorRun.GamemodesUtils or {}
    ColorRun.GamemodesUtils["gameSettings"] = tbl["gameSettings"]

    ColorRun.CLIENT = ColorRun.CLIENT or {}
    ColorRun.CLIENT.InGame = true
end)

ColorRun:RegisterCallback( ColorRun.ENUMS.StartRound, function()
    local tbl = ColorRun:ReadTable()

    ColorRun.GamemodesUtils = ColorRun.GamemodesUtils or {}
    ColorRun.GamemodesUtils["gamemode"] = tbl.gamemode
    ColorRun.GamemodesUtils["currentRound"] = tbl.roundid

    ColorRun.GamemodesUtils["general"] = ColorRun.GamemodesUtils["general"] or {}
    ColorRun.GamemodesUtils["general"]["launched_time"] = CurTime()
    ColorRun.GamemodesUtils["general"]["countdown"] = CurTime()
end)

ColorRun:RegisterCallback( ColorRun.ENUMS.EndGame, function()
    ColorRun.CLIENT.InGame = false
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.Debug, function()
    local tbl = net.ReadTable()
    for k,v in pairs(tbl) do
        if istable(v) then
            PrintTable(v)
        else
            print(tostring(v))
        end
    end
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.ColorToGO, function()
    local col = net.ReadColor()

    ColorRun.GamemodesUtils = ColorRun.GamemodesUtils or {}
    ColorRun.GamemodesUtils[1] = ColorRun.GamemodesUtils[1] or {}
    ColorRun.GamemodesUtils[1]["ColorToGo"] = col
end )

-- concommand.Add( "creategame", function()
--     ColorRun:SendNet( ColorRun.ENUMS.CreateGame, function() 
--         ColorRun:WriteTable( net.WriteTable({
--                 type = 1,
--                 amount = 3,
--                 bonuses = true            
--         }) )
--     end, ply )
-- end )

concommand.Add( "joinqueue", function()
    ColorRun:SendNet( ColorRun.ENUMS.JoinQueue, function()    
        net.WriteInt(1,3)
    end, ply )
end )


concommand.Add( "quitqueue", function()
    ColorRun:SendNet( ColorRun.ENUMS.JoinQueue, function()    
        net.WriteInt(2,3)
    end, ply )
end )

ColorRun:RegisterCallback( 22, function()
    RunConsoleCommand("stopsound")
    local rand = table.Random(ColorRun.Config.Musics )

    -- EmitSound( rand, LocalPlayer():GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
    surface.PlaySound( rand )
end )
