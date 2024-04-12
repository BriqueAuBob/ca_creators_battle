local function Circle( x, y, radius ) -- 
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, 360 do
		local a = math.rad( ( i / 360 ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 )
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    draw.NoTexture()
	surface.DrawPoly( cir )
end


hook.Add("HUDShouldDraw", "ColorRun:Hooks:HUDShouldDraw", function( name )
    if not ColorRun.CLIENT or not ColorRun.CLIENT.InGame then return end
    if name == "CHudChat"  then return end
    return false
end)

local function HUDComponent_Card( str, subtext, posx, posy, sizex, sizey )
    if str then
        draw.RoundedBox( 8, posx, posy, sizex, sizey, Color( 52, 52, 52 ) )
        surface.SetDrawColor( Color( 249, 107, 107, 100 ) )
        surface.DrawRect( posx + 15, posy + 30, sizex - 30, sizey - 110 )
        draw.SimpleText( str, "ColorRun:32", posx + sizex / 2, posy + 25, Color( 255, 255, 255 ), 1, 1 )
        draw.SimpleText( subtext, "ColorRun:54", posx + sizex / 2, posy + 80, Color( 255, 255, 255 ), 1, 1 )
    else
        surface.SetFont( "ColorRun:54" )
        local sx = surface.GetTextSize( subtext )

        draw.RoundedBox( 8, posx + sizex - sx - 20, posy, sx + 20, sizey, Color( 52, 52, 52 ) )
        draw.SimpleText( subtext, "ColorRun:54", posx + sizex - 10, posy + 31, Color( 255, 255, 255 ), 2, 1 )
    end
end

local speak = Material( "color_run/speak.png" )
local LerpPos = {}
local LerpAlpha = {}
LerpPos[1] = 0
LerpPos[2] = 0
LerpAlpha[1] = 0
LerpAlpha[2] = 0

local function HUDComponent_Player( player, posx, posy, sizex, sizey, id )
    if player:IsSpeaking() then
        LerpPos[id] = Lerp( FrameTime() * 16, LerpPos[id], posx + 70 )
        LerpAlpha[id] = Lerp( FrameTime() * 16, LerpAlpha[id], 255 )
    else
        LerpPos[id] = Lerp( FrameTime() * 4, LerpPos[id], posx )
        LerpAlpha[id] = Lerp( FrameTime() * 4, LerpAlpha[id], 0 )
    end

    surface.SetFont( "ColorRun:32" )
    local sx = surface.GetTextSize( player:Name() )

    draw.RoundedBox( 8, LerpPos[id], posy, sizex, sizey, Color( 52, 52, 52 ) )
    draw.SimpleText( DarkRP and player:SteamName() or player:Name(), "ColorRun:32", LerpPos[id] + 20, posy + sizey / 2, Color( 255, 255, 255 ), 0, 1 )

    surface.SetDrawColor( Color( 255, 255, 255, LerpAlpha[id] ) )
    surface.SetMaterial( speak )
    surface.DrawTexturedRect( posx, posy, sizey, sizey )
end

local function CreateClock( str, posx, posy, radius, col )
    surface.SetDrawColor( col )
    Circle( posx, posy, radius )

    draw.RoundedBoxEx( 6, posx - radius * 1.5, posy, radius, 20, col, true, false, true, false )
    draw.RoundedBoxEx( 6, posx + radius / 2, posy, radius, 20, col, false, true, false, true )
    draw.SimpleText( str, "ColorRun:24", posx, posy + 30, Color( 255, 255, 255 ), 1, 1 )
end

local gamemodes = {
    [1] = {
        name = "Color Shuffle",
        time = true,
        resettime = true,
        CustomHud = function( w, h )
            surface.SetDrawColor( Color( 52, 52, 52 ) )
            Circle( w / 2, h - 10, 90 )
            surface.SetDrawColor( ColorRun.GamemodesUtils and ColorRun.GamemodesUtils[1] and ColorRun.GamemodesUtils[1]["ColorToGo"] or Color( 255, 0, 255 ) )
            Circle( w / 2, h - 10, 80 )
            draw.SimpleText( "GO", "ColorRun:54", w / 2, h - 35, Color( 255, 255, 255 ), 1, 1 )
        end
    },
    [2] = {
        name = "Color Conquest",
        time = true,
        CustomHud = function( w, h )
            draw.RoundedBox( 8, w - 335, 10, 325, 280, Color( 52, 52, 52 ) )
            draw.SimpleText( "TOP 3", "ColorRun:32", w - 167.5, 46, Color( 255, 255, 255 ), 1, 1 )
            
            for i=0, 2 do
                draw.RoundedBox( 8, w - 325, 80 + i * 70, 305, 60, Color( 62, 62, 62 ) )
                surface.SetDrawColor( Color( 249, 107, 107 ) )
                Circle( w - 300, 80 + i * 70 + 30, 10 )

                draw.SimpleText( "Wabel", "ColorRun:24", w - 275, 80 + i * 70 +  22, Color( 255, 255, 255 ), 0, 1 )
                draw.SimpleText( "Pilot", "ColorRun:24", w - 275, 80 + i * 70 +  43, Color( 255, 255, 255 ), 0, 1 )

                draw.SimpleText( "33%", "ColorRun:32", w - 35, 80 + i * 70 +  30, Color( 255, 255, 255 ), 2, 1 )
            end
        end
    },
    [3] = {
        name = "Color Fade",
        time = true,
    },
    [4] = {
        name = "Color Tron",
        time = false,
    }
}

hook.Add( "PostDrawHUD", "ColorRun:Hooks:HudPaintHud", function()
    if not ColorRun.CLIENT or not ColorRun.CLIENT.InGame then return end
    local w, h = ScrW(), ScrH()

    CreateClock( "2 pts", w / 2, -8, 65, Color( 52, 52, 52 ) )

    HUDComponent_Card( "Round", ( ColorRun.GamemodesUtils["currentRound"] or "y" ) .." / " ..( ColorRun.GamemodesUtils["gameSettings"] and ColorRun.GamemodesUtils["gameSettings"]["round_amount"] or "x" ), 10, h - 130, 160, 120 )
    if gamemodes[ColorRun.GamemodesUtils["gamemode"]]["time"] then
        if gamemodes[ColorRun.GamemodesUtils["gamemode"]]["resettime"] then
            if math.max( 0, math.Round( ( ColorRun.GamemodesUtils["general"]["launched_time"] ) + 6 - CurTime() ) ) == -2 then
                ColorRun.GamemodesUtils["general"]["launched_time"] = CurTime()
            end
        end
        HUDComponent_Card( "Temps restant", math.max( 0, math.Round( ( ColorRun.GamemodesUtils["general"]["launched_time"] ) + 6 - CurTime() ) ) .."s", 180, h - 130, 230, 120 )
    else
        HUDComponent_Card( "Temps joué", math.Round( CurTime() - ColorRun.GamemodesUtils["general"]["launched_time"] ) .."s", 180, h - 130, 230, 120 )
    end

    HUDComponent_Player( LocalPlayer(), 10, 10, 120, 60, 1 )
    if LocalPlayer().mate and IsValid( LocalPlayer().mate ) and LocalPlayer().mate:IsPlayer() then
        HUDComponent_Player( LocalPlayer().mate, 10, 80, 120, 60, 2 )
    end

    HUDComponent_Card( nil, ( gamemodes[ColorRun.GamemodesUtils["gamemode"]] and gamemodes[ColorRun.GamemodesUtils["gamemode"]]["name"] or "nil" ), w - 220, h - 70, 210, 60, 30 )

    if gamemodes[ColorRun.GamemodesUtils["gamemode"]] and isfunction( gamemodes[ColorRun.GamemodesUtils["gamemode"]]["CustomHud"] ) then
        gamemodes[ColorRun.GamemodesUtils["gamemode"]]["CustomHud"]( w, h )
    end

    if ColorRun.GamemodesUtils["general"] and ColorRun.GamemodesUtils["general"]["countdown"] and ( ColorRun.GamemodesUtils["general"]["countdown"] + 3 ) >= CurTime() then
        local timeleft = math.Round( ColorRun.GamemodesUtils["general"]["countdown"] + 3 - CurTime() )

        surface.SetDrawColor( Color( 0, 0, 0, 240 ) )
        surface.DrawRect( -2, -2, w + 4, h + 4 )
        draw.SimpleText( timeleft == 0 and "GO" or timeleft, "ColorRun:84", w / 2, h / 2, Color( 249, 107, 107 ), 1, 1 )
    end
end)