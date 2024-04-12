local notifs = {}

ColorRun:RegisterCallback( ColorRun.ENUMS.Notify, function()
    local text = net.ReadString()
    local type = net.ReadInt( 4 )
    local time = net.ReadInt( 10 )

    notifs[#notifs + 1] = {
        ["text"] = text,
        ["time"] = time > 0 and CurTime() + time or "infinite",
        ["type"] = type
    }
end )

local logo_big = Material( "color_run/logo.png" )
local logo = Material( "color_run/logo_small.png" )
local right = Material( "color_run/notifs_right.png", "noclamp smooth" )

local function ReceiveInvite()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( ScrW() / 4, ScrH() / 5 )
    frame:Center()
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:SetDraggable( false )
    frame:MakePopup()
    function frame:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 52, 52, 52 ) )
        
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.SetMaterial( logo_big )
        surface.DrawTexturedRect( w - 146.5, 10, 136.5, 55.5 )
    end
    
    local title = vgui.Create( "DLabel", frame )
    title:Dock( TOP )
    title:DockMargin( 16, 0, 0, 0 )
    title:SetText( "Invitation" )
    title:SetFont( "ColorRun:32" )
    title:SetContentAlignment( 4 )
    
    local text = vgui.Create( "DLabel", frame )
    text:SetPos( frame:GetWide() / 20, frame:GetTall() / 3 )
    text:SetMultiline( true )
    text:SetText( ( "Acceptez vous de rejoindre l'équipe de \n%s ?" ):format( LocalPlayer():Name() ) )
    text:SetFont( "ColorRun:24" )
    text:SetContentAlignment( 2 )
    text:SizeToContents()

    local panel = vgui.Create( "DPanel", frame )
    panel:Dock( BOTTOM )
    panel:SetTall( 60 )
    panel:SetBackgroundColor( Color( 0, 0, 0, 0 ) )

    local decline = vgui.Create( "DButton", panel )
    decline:Dock( LEFT )
    decline:DockMargin( 10, 10, 10, 10 )
    decline:SetText( "" )
    decline:SetWide( frame:GetWide() / 2.3 )
    function decline:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, not self:IsHovered() and Color( 231, 76, 60 ) or Color( 241, 86, 70 ))
        draw.SimpleText( "Refuser", "ColorRun:24", w / 2, h / 2, Color( 255, 255, 255 ), 1, 1 )
    end
    function decline:DoClick()
        frame:Close()
    end

    local accept = vgui.Create( "DButton", panel )
    accept:Dock( RIGHT )
    accept:DockMargin( 10, 10, 10, 10 )
    accept:SetText( "" )
    accept:SetWide( frame:GetWide() / 2.3 )
    function accept:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, not self:IsHovered() and Color( 46, 204, 113 ) or Color( 56, 214, 123 ))
        draw.SimpleText( "Accepter", "ColorRun:24", w / 2, h / 2, Color( 255, 255, 255 ), 1, 1 )
    end 
    function accept:DoClick()
        ColorRun:SendNet( ColorRun.ENUMS.AcceptInvite )
        frame:Close()
    end
end

local actions = {
    [1] = function() ReceiveInvite() end,
    [2] = function() ColorRun:SendNet( ColorRun.ENUMS.CancelInvite ) end,
}

local time = 0
hook.Add( "DrawOverlay", "Color:Run:Hooks:DrawOverlay:Notify", function()
    local w, h = ScrW(), ScrH()

    for k, v in ipairs( notifs ) do
        if not isstring( v.time) and v.time <= CurTime() then table.remove( notifs, k ) end
        surface.SetFont( "ColorRun:24" )
        local size = math.max( w / 6, surface.GetTextSize( v.text ) + 148 )
        draw.RoundedBoxEx( 8, 0, k * ( h / 12 ) - 70, size, h / 15, Color( 52, 52, 52 ), false, true, false, true )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.SetMaterial( logo )
        surface.DrawTexturedRect( 4, k * ( h / 12 ) - 70, 78, 72 )
        surface.SetMaterial( right )
        surface.DrawTexturedRect( size - 54, k * ( h / 12 ) - 70, 54, 72 )

        draw.SimpleText( v.text, "ColorRun:24", w / 22, k * ( h / 12 ) - 32, Color( 255, 255, 255 ), 0, 1 )

        if gui.MouseX() >= 0 and gui.MouseX() <= size and gui.MouseY() >= k * ( h / 12 ) - ( h / 15 ) and gui.MouseY() <= k * ( h / 12 ) then
            draw.RoundedBoxEx( 8, 0, k * ( h / 12 ) - 70, size, h / 15, Color( 255, 255, 255, 10 ), false, true, false, true )
            if input.IsMouseDown( MOUSE_LEFT ) then
                if time >= CurTime() then return end
                if isfunction( actions[ v.type ] ) then
                    actions[ v.type ]()
                end
                table.remove( notifs, k )
                time = CurTime() + 1
            end
        end
    end
end )
