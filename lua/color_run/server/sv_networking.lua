util.AddNetworkString( "ColorRun:Networking" )

net.Receive( "ColorRun:Networking", function( len, ply )
    local netid = net.ReadInt(6)
    if not netid then return end
    if not ColorRun.netsCallbacks[netid] then return end

    ColorRun.netsCallbacks[netid]( ply )
end )