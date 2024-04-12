ColorRun.netsCallbacks = ColorRun.netsCallbacks or {}

function ColorRun:SendNet( id, func, sendto )
    if not id or not isnumber( id ) then error( "Id is not passed to the registerCallback function or isn't an number." ) return end
    net.Start( "ColorRun:Networking" )
    net.WriteInt( id, 6 )
    if isfunction( func ) then
        func()
    end
    if SERVER then
        if sendto:IsPlayer() then
            net.Send( sendto )
        end
    else
        net.SendToServer()
    end
end

function ColorRun:RegisterCallback( id, callback )
    if not id or not isnumber( id ) then error( "Id is not passed to the registerCallback function or isn't an number." ) return end
    if not callback or not isfunction( callback ) then error( "Callback is not passed to the registerCallback function or isn't an function." ) return end

    ColorRun.netsCallbacks[id] = callback
end

function ColorRun:WriteTable( tbl )
    local compress = util.Compress( util.TableToJSON( tbl ) )

    net.WriteInt( #compress, 32 )
    net.WriteData( compress, #compress )
end

function ColorRun:ReadTable()
    local len = net.ReadInt( 32 )
    local data = net.ReadData( len )
    local tbl = util.JSONToTable( util.Decompress( data ) )
    
    return tbl
end