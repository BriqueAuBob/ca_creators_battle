local startofround = true

function ColorRun:NotifyPlayer( ply, text, type, time )
    ColorRun:SendNet( ColorRun.ENUMS.Notify, function() 
        net.WriteString( text ) 
        net.WriteInt( type, 4 )
        net.WriteInt( time and time or 0, 10 )
    end, ply )
end

function ColorRun:Debug( ... )
    local values = ...
    local tbl = {}

    for a, b in pairs(values) do
        tbl[#tbl + 1] = b
    end
    for k, v in pairs(player.GetAll()) do
        ColorRun:SendNet( ColorRun.ENUMS.Debug , function() net.WriteTable(tbl) end, v )
    end
end

function ColorRun:IsInTeam( ply1, ply2 )
    if not ColorRun.game["settings"].duos then return false end
end

function ColorRun:GenerateNewFloor( vector1, vector2 )
    if ColorRun.ZonePos["plates_pos"] then
        for k, v in ipairs( ColorRun.ZonePos["plates_pos"] ) do
            if not IsValid( v ) then continue end
            v:Remove()
        end
    end
    local vector = vector1
    local dist = ( vector2.x - vector1.x )

    dist = math.Round( dist / 34, 0 )

    ColorRun.ZonePos["z"] = nil
    local a = 1
    local plates_pos = {}

    while vector:WithinAABox( vector1, vector2 ) do
        for i = 1, math.abs( dist ) do
            local prop1 = ents.Create( "colorplate" )
            if not IsValid( prop1 ) then return end
            local vecx, vecy = vector:Unpack()
            math.randomseed( vecx and vecx + vecy * os.time() or os.time() * i * 100 )
            prop1:SetColor( Color( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ) ) )
            prop1:SetPos( ColorRun.ZonePos["z"] and Vector( vecx, vecy, ColorRun.ZonePos["z"] ) or vector )
            prop1:SetCollisionGroup( COLLISION_GROUP_PLAYER )
            prop1:Spawn()
            if not ColorRun.ZonePos["z"] then
                prop1:DropToFloor()
                local x, y, w = prop1:GetPos():Unpack()
                ColorRun.ZonePos["z"] = w
            end
            plates_pos[#plates_pos + 1] = prop1

            vector = dist > 0 and vector + Vector( 36, 0, 0 ) or vector - Vector( 36, 0, 0 )
        end

        vector = vector1.y < vector2.y and vector1 + Vector( 0, a * 36, 0 ) or vector1 - Vector( 0, a * 36, 0 )
        a = a + 1
    end

    local x, y, z = vector1:Unpack()
    local a, b, c = vector2:Unpack()
    local midx, midy, midz = (x + a) / 2, (y + b) / 2, (z + c) / 2
    local middle = Vector(midx, midy, midz)

    ColorRun.ZonePos = {
        ["vector1"] = vector1,
        ["vector2"] = vector2,
        ["middle"] = middle,
        ["z"] = ColorRun.ZonePos["z"],
        ["plates_pos"] = plates_pos
    }
end

local function TeleportRandom( ply )
    if not IsValid(ply) then return end
    local x1, y1, z1 = ColorRun.ZonePos["vector1"]:Unpack()
    local x2, y2, z2 = ColorRun.ZonePos["vector2"]:Unpack()
    local rand = Vector( math.Rand(x1,x2), math.Rand(y1,y2), math.Rand(z1,z2) )

    while not rand:WithinAABox( ColorRun.ZonePos["vector1"], ColorRun.ZonePos["vector2"] ) do
        rand = Vector( math.Rand( x1, x2 ), math.Rand( y1, y2 ), ColorRun.ZonePos["z"] + Vector(0,0,10) )
    end
    
    ply:SetPos( rand ) 
end


hook.Remove("Think", "ColorRun:Hooks:Think") -- Debug 
timer.Remove("ColorRun:timers:Round")-- Debug

local function ColorPlates()
    local colors = {
        Color( 249, 107, 107 ), -- primary addon color 
        Color( 241, 196, 15 ), -- yellow 
        Color( 52, 152, 219 ), -- blue 
        Color( 46, 204, 113 ), -- green
        Color( 142, 68, 173 ), -- purple
        Color( 230, 126, 34 ), -- orange
        Color( 243, 104, 224 ), -- pink
        Color( 0, 210, 211 ), -- Turquoise
    }

    local colorU = {} -- Colors which are used
    ColorRun.game["valid_plates"] = {}
    
    local color = colors[math.Round(math.Rand(1, #colors),0)]

    for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
        v.iswhite = false
        math.randomseed( os.time() + k * 100 + CurTime() * 11 + 120 * 12 / math.Rand(1, #colors) * 12 )

        local colort = colors[math.Round(math.Rand(1, #colors), 0)] -- Take a new color into the 48 colors tables  

        while colort.r >= 200 and colort.g >= 200 and colort.b >= 200 do -- Don't want white colors
            colort = colors[math.Round(math.Rand(1, #colors),0)] -- Take a new color to avoid whites colors
        end
        
        if (ColorRun.game["round"].count >= 3) then
            while colort.r == color.r and colort.g == color.g and colort.b == color.b do
                colort = colors[math.Round( math.Rand( 1, #colors ),0 )] -- Take a new color to avoid too much "winning" colors
            end
        end

        v:SetColor( Color( colort.r, colort.g, colort.b ) )
    end

    ColorRun.game["round"].currentcolor = Color( color.r, color.g, color.b ) -- Take a new color to avoid too much "winning" colors

    while ColorRun.game["round"].currentcolor.r >= 200 and ColorRun.game["round"].currentcolor.g >= 200 and ColorRun.game["round"].currentcolor.b >= 200 do -- Don't want white colors
        local c = colors[math.Round(math.Rand(1, #colors),0)]
        ColorRun.game["round"].currentcolor = Color( c.r, c.g, c.b ) -- Take a new color to avoid whites colors
    end

    for i = 1, table.Count( ColorRun.game["players"]["alive"] ) do -- Be sure to have a minimum of "winning" plates 
        local randplate = math.random( 1, #ColorRun.ZonePos["plates_pos"] )
        ColorRun.ZonePos["plates_pos"][randplate]:SetColor( ColorRun.game["round"].currentcolor )
    end
    
    
    for k,v in pairs( ColorRun.game["players"]["all"] ) do
        ColorRun:SendNet( ColorRun.ENUMS.ColorToGO, function() 
            net.WriteColor( ColorRun.game["round"].currentcolor ) 
        end, k )
    end

    ColorRun.game["round"].count = ColorRun.game["round"].count + 1
end

local function ColorRun_addPoints(ply, amount)
    if not ply or not IsValid(ply) or not isnumber(amount) then return end

    ply.points = ply.points + amount

    ColorRun:SendNet( ColorRun.ENUMS.Points, function()
    end, ply )
end

local baseGamemodes = {
    [1] = { -- Color Shuffle
        timerDelay = 6,
        timerRepeats = 0,
        colorPlayer = false,
        firstCallback = function()
            ColorRun.game["round"].count = 1
            ColorPlates()
        end,
        callbackTimer = function()
            for k, v in pairs( ColorRun.game["players"]["alive"] ) do
                k.detected = false
            end

            for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
                v:SetToWhite(ColorRun.game["round"].currentcolor) -- Changes plates color which aren't the good color to black 
            end
            
            local plate = {}
            for k, v in ipairs( ColorRun.game["valid_plates"] ) do -- [1] = ent[1]
                for x, y in pairs( ColorRun.game["players"]["alive"] ) do
                    if x:GetPos():DistToSqr( v:GetPos() ) > 500 then continue end
                    x.detected = true
                end
            end

            for x, y in pairs( ColorRun.game["players"]["alive"] ) do
                if x.detected then continue end
                x:Kill()
                ColorRun.game["players"]["alive"][x] = nil
                ColorRun.game["players"]["died"][x] = true
            end
            
            if table.Count(ColorRun.game["players"]["alive"]) <= 1 then
                local winner = table.KeyFromValue(ColorRun.game["players"]["alive"], true)
                if winner and winner:IsPlayer() then
                    for k, v in pairs( ColorRun.game["players"]["all"] ) do
                        k:ChatPrint( "Round fini. Vainqueur: " .. winner:Nick() )

                        ColorRun.game["players"]["died"][k] = nil
                        ColorRun.game["players"]["alive"][k] = true
                    end

                    ColorRun_addPoints(winner, 4)
                else
                end
                
                startofround = true
                timer.Remove("ColorRun:timers:Round")
            else
                timer.Simple(1, function()
                    ColorPlates()
                end)
            end
        end,
        plateTouch = function( self, ply )
        end
    },
    [2] = { -- Color Conquest 
        timerDelay = ColorRun.Config.colorConquestTime,
        timerRepeats = 1,
        colorPlayer = true,
        firstCallback = function()
        end,
        callbackTimer = function()            
        end,
        plateTouch = function( self, ply )
            self:SetColor( ply.color )
        end     
    },
    [3] = { -- Color Fade
        timerDelay = 1,
        timerRepeats = 0,
        colorPlayer = true,
        firstCallback = function()            
        end,
        callbackTimer = function()            
        end,
        plateTouch = function( self, ply )
              --self:
            
        end         
    },
    [4] = { -- Color Tron
        timerDelay = 1,
        timerRepeats = 0,
        colorPlayer = true,
        firstCallback = function()
            for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
                v.iswhite = false 
                v:SetColor( Color( 255, 255, 255 ) )
            end
        end,
        callbackTimer = function()
        end,
        plateTouch = function( self, ply )
            if ply:IsFrozen() then return end 
            ply:SetVelocity( ply:GetForward() * 40 )
            local eyes = ply:EyeAngles()
            if eyes.x > 60 then
                ply:SetEyeAngles( Angle( 60, eyes.y, eyes.z) )
            elseif eyes.x < -20 then
                ply:SetEyeAngles( Angle( -20, eyes.y, eyes.z) )
            end
            if self:GetColor().r == 255 and self:GetColor().g == 255 and self:GetColor().b == 255 then 
                self:SetColor( ply.color )
            end
            if self:GetColor().r ~= ply.color.r and self:GetColor().g ~= ply.color.r and self:GetColor().b ~= ply.color.r then
                if table.Count(ColorRun.game["players"]["alive"]) > 1 then
                    ply:Kill()
                end
                if table.Count(ColorRun.game["players"]["alive"]) <= 1 then   
                    local winner = table.KeyFromValue(ColorRun.game["players"]["alive"], true)
                    if IsValid(winner) then

                    end 
                    startofround = true
                    timer.Remove("ColorRun:timers:Round")
                end
            end
        end
    },
}

function ColorRun:GetGamemodesTable() 
    return baseGamemodes 
end

local function ColorRun_GenerateRound()
    round = {}
    local gms = {}
    ColorRun.game["round"] = {}         

    math.randomseed(CurTime() * #ColorRun.game["settings"]["gamemodes"])
    local rand = math.random(1, #ColorRun.game["settings"]["gamemodes"])

    while not ColorRun.game["settings"]["gamemodes"][rand] do
        rand = math.random(1, #ColorRun.game["settings"]["gamemodes"])
    end

    round["gamemode"] = rand
    round["id"] = ColorRun.game.roundsCount
    round["settings"] = baseGamemodes[rand]

    ColorRun.game["round"]["gamemode"] = round["gamemode"]

    return round
end

local function FreezeAll()
    for k, v in pairs( ColorRun.game["players"]["all"] ) do
        k:Freeze(true)
    end

    timer.Simple( 3, function()
        for k, v in pairs( ColorRun.game["players"]["all"] ) do
            k:Freeze(false)
        end
    end )
end

local function respawnAll()
    for k,v in pairs( ColorRun.game["players"]["all"] ) do
        k:Spawn()
        TeleportRandom( k )
    end
end

local function ColorRun_GenerateGame()
    timer.Create( "ColorRun:Timers:startGame", ColorRun.Config.queueTime, 1, function()
        if table.Count(ColorRun.queue["players"]) < 2 then
            for k,v in pairs( ColorRun.queue["players"] ) do
                ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "start_delayed" ), 0, 3 )
            end
            return
        end
        
        ColorRun.game = table.Copy(ColorRun.queue)
        ColorRun.queue = {}

        if ColorRun.game["settings"].duos then
            local plyNumInQueue = table.Count(ColorRun.game["players"])
            if ( plyNumInQueue % 2 ) == 0 then
                ColorRun.game["duos"] = {}
                local notTeamed = {}
                local alreadyTeamed = {}
                local i = 1

                for k, v in pairs( ColorRun.game["players"] ) do
                    local team = ColorRun:GetPlayerTeam( k:SteamID64() )
                    local mate = nil

                    if table.IsEmpty( team ) then
                        notTeamed[k] = true
                        continue
                    end

                    for a, b in pairs( team ) do
                        if alreadyTeamed[a] then continue end
                        ColorRun.game["duos"][player.GetBySteamID64(a)] = i

                        if mate then
                            ColorRun:Debug({mate, a})        

                            mate.mate = a -- Set the "mate" mate's as "a" 
                            a.mate = mate -- Set the "a" mate's as "mate" 
                        end

                        alreadyTeamed[a] = true
                        mate = a
                    end
                    i = i + 1
                end

                local ii = 1
                local inc = 1
                local prev = nil

                for k, v in pairs( notTeamed ) do
                    ColorRun.game["duos"][k] = i + ii

                    if prev then                                
                        prev.mate = k
                        k.mate = prev
                        
                        ColorRun:NotifyPlayer( prev, ( ColorRun:GetTranslation("forceduowith") ):format( k:Nick() ) , 0, 5 )
                        ColorRun:NotifyPlayer( k, ( ColorRun:GetTranslation("forceduowith") ):format( prev:Nick() ) , 0, 5 )
                    end
                    
                    prev = k
                    if ( inc % 2 ) == 0 then
                        ii = ii + 1
                        prev = nil
                    end                                    
                    inc = inc + 1
                end
            else
                ColorRun:NotifyPlayer( ColorRun.game["owner"], ColorRun:GetTranslation("forceduowith"), 0, 5 )
            end
        end

        local tbl = {
            ["alive"] = ColorRun.game["players"],
            ["died"] = {},
            ["all"] = table.Copy(ColorRun.game["players"]),
        }

        ColorRun.game["players"] = tbl

        local i = 1
        
        for k, v in pairs( ColorRun.game["players"]["all"] ) do
            local weapons = {}
            for i, y in pairs( k:GetWeapons() ) do
                weapons[#weapons + 1] = y:GetClass()
            end

            k.before = {
                befweapons = weapons,
                befammos = k:GetAmmo(),
                befarmor = k:Armor(),
                befhealth = k:Health()
            }

            k:StripWeapons()
            k:SetArmor(0)
            k:SetHealth(100)

            k.points = 0

            TeleportRandom( k )

            ColorRun:SendNet( ColorRun.ENUMS.InitGame, function()
                ColorRun:WriteTable( {
                    mate = k.mate and k.mate or nil,
                    gameSettings = ColorRun.game["settings"]
                } )
            end, k )
            
            

            math.randomseed( os.time() + i * 1000 + k:UserID() )
            k.color = Color( math.random( 1, 255 ), math.random( 1, 255 ), math.random( 1, 255 ) )

            ColorRun:SendNet(22, _, k )
            ColorRun:NotifyPlayer( k, "La partie commence !" , 0, 3 )

            i = i + 1
        end

        FreezeAll()
        ColorRun.game.roundsCount = 0

        startofround = true
        hook.Add( "Think", "ColorRun:Hooks:Think", function()
            if not startofround then return end
            if not ColorRun.game["players"] then hook.Remove( "Think", "ColorRun:Hooks:Think" ) return end

            if startofround then
                ColorRun.game.roundsCount = ColorRun.game.roundsCount + 1
                local round = ColorRun_GenerateRound()

                ColorRun:Debug({"new rounds", ColorRun.game.roundsCount, round["id"], ColorRun.game["settings"]["round_amount"]})

                if round["id"] <= ColorRun.game["settings"]["round_amount"] then
                    for k, v in pairs( ColorRun.game["players"]["all"] ) do
                        ColorRun:SendNet( ColorRun.ENUMS.StartRound, function()                        
                            ColorRun:WriteTable( {
                                gamemode = round["gamemode"],
                                roundid = round["id"]
                            } )
                        end, k )
                    end

                    local roundS = round["settings"]
                    ColorRun.game["settings"].color = roundS.colorPlayer

                    roundS.firstCallback()
                    respawnAll()
                    FreezeAll()

                    timer.Create( "ColorRun:timers:Round", roundS.timerDelay or 1 + 3, roundS.timerRepeats or 0, function()
                        roundS.callbackTimer()
                    end )

                    startofround = false
                else
                    for k, v in pairs( ColorRun.game["players"]["all"] ) do
                        k:SetArmor( k.before.befarmor )
                        k:SetHealth( k.before.befhealth )
                        for x, y in pairs( k.before.befweapons ) do
                            k:Give( y, true )
                        end
                        for x, y in pairs( k.before.befammos ) do
                            k:GiveAmmo( y, game.GetAmmoName( x ), true )
                        end
                        ColorRun:SendNet( ColorRun.ENUMS.EndGame, _, k )
                        ColorRun:NotifyPlayer( k, "La partie est finie !" , 0, 3 )

                    end
                    hook.Remove( "Think", "ColorRun:Hooks:Think" ) 
                end
            end
        end )
    end )
end

function ColorRun:RefreshQueue( ply, state, bp )
    if state == 1 then
        if not ColorRun.queue["players"] or not bp and table.IsEmpty(ColorRun.queue["players"]) then return end -- The bp is used as bypass when creating a new game
        if ColorRun.queue["players"][ply] then ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "already_in_queue" ), 0, 3 ) return end
        ColorRun.queue["players"][ply] = true -- Add the player in the queue
        ply.mate = nil

        for k,v in pairs( ColorRun.queue["players"] ) do
            ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "joinedqueue" ):format(ply:Nick()), 0, 3 )
        end

        if table.Count(ColorRun.queue["players"]) >= 2 then
            if timer.Exists( "ColorRun:Timers:startGame") then return end
            for k,v in pairs( ColorRun.queue["players"] ) do
                ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "startingin" ):format( ColorRun.Config.queueTime ), 0, 3 ) 
            end
            ColorRun_GenerateGame()
        end
    elseif state == 2 then
        if not ColorRun.queue["players"] or table.IsEmpty(ColorRun.queue["players"]) or not ColorRun.queue["players"][ply] then ColorRun:Debug({ColorRun.queue["players"]}) return end
        
        for k,v in pairs( ColorRun.queue["players"] ) do
            ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "leftqueue" ):format(ply:Nick()), 0, 3 )
        end

        ColorRun:Send( ColorRun.ENUMS.EndGame, _, ply )
        ColorRun.queue["players"][ply] = false
        
        if table.Count(ColorRun.queue["players"]) < 2 then
            if timer.Exists( "ColorRun:Timers:startGame") then
                timer.Remove( "ColorRun:Timers:startGame")
                for k, v in pairs( ColorRun.queue["players"] ) do
                    ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "start_delayed" ), 0, 3 )
                end
            end
        end
    end
end  