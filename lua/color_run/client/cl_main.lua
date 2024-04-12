local surface = surface
local draw = draw

local background = Material( "color_run/background.png", "noclamp smooth" )
local wave1 = Material( "color_run/wave1.png", "noclamp smooth" )
local wave2 = Material( "color_run/wave2.png", "noclamp smooth" )
local wave3 = Material( "color_run/wave3.png", "noclamp smooth" )
local logo = Material( "color_run/logo.png", "noclamp smooth" )
local kickicon = Material( "color_run/kick.png", "noclamp smooth" )

local function SearchPlayerFrame()
    local frame = vgui.Create( "DFrame" )
    frame:DockPadding( 0, 0, 0, 0 )
    frame:SetSize( #player.GetAll() > 16 and ScrW() / 1.1 or ScrW() / 1.5, #player.GetAll() > 16 and ScrH() / 1.1 or ScrH() / 1.5 )
    frame:Center()
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:MakePopup()
    local start = SysTime()
    function frame:Paint( w, h )
        Derma_DrawBackgroundBlur( self, start )

        draw.RoundedBox( 8, 0, 0, w, h, Color( 42, 42, 42 ) )
    end

    local title = vgui.Create( "DLabel", frame )
    title:SetText( ColorRun:GetTranslation( "invite_member" ) )
    title:SetFont( "ColorRun:32" )
    title:Dock( TOP )
    title:DockMargin( 16, 16, 16, 16 )
    title:SizeToContents()
    title:SetTextColor( Color( 255, 255, 255 ) )
    title:SetContentAlignment( 5 )

    local button = vgui.Create( "DButton", frame )
    button:Dock( BOTTOM )
    button:SetTall( 50 )
    button:SetText( "" )
    function button:DoClick()
        frame:Close()
    end
    function button:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, self:IsHovered() and Color( 72, 72, 72 ) or Color( 62, 62, 62 ) )
        draw.SimpleText( ColorRun:GetTranslation( "exit" ), "ColorRun:32", w / 2, h / 2, Color( 255, 255, 255 ), 1, 1 )
    end

    local tbl = {}
    local search = vgui.Create( "DTextEntry", frame )
    search:Dock( TOP )
    search:DockMargin( 16, 0, 16, 5 )
    search:SetTall( 30 )
    search:SetDrawLanguageID( false )
    function search:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 62, 62, 62 ) )
        self:DrawTextEntryText( Color( 255, 255, 255 ), Color( 255, 0, 0 ), Color( 255, 255, 255 ) )
    end
    function search:OnChange()
        local iterate = 1

        while tbl[iterate] and iterate <= player.GetCount() do
            if string.find( tbl[iterate].name:lower(), search:GetText():lower() ) then
                tbl[iterate]:SetVisible( true )
            else
                tbl[iterate]:SetVisible( false )
            end
            iterate = iterate + 1
        end
    end

    for k, v in pairs( player.GetAll() ) do
        if v == LocalPlayer() then continue end
        local card = vgui.Create( "DPanel", frame )
        local x, y = math.random( 0, frame:GetWide() - 120 ), math.random( 120, frame:GetTall() - 220 )
        card:SetPos( x, y )
        card:SetSize( 120, 158 )
        card.OldPosX = x
        card.OldPosY = y
        card.PosX = x
        card.PosY = y
        card.SizeX = 120
        card.SizeY = 158
        card.name = v:Name()
        function card:Paint( w, h )
            if self:IsHovered() or card:GetChildren()[3]:IsHovered() then
                draw.RoundedBox( 8, 0, 0, w, h, Color( 249, 107, 107 ) )
            end
            draw.RoundedBox( 8, 2, 2, w - 4, h - 4, Color( 52, 52, 52 ) )
        end
        function card:Think()
            if self:IsHovered() or card:GetChildren()[3]:IsHovered() then
                self.SizeX = Lerp( FrameTime() * 8, self.SizeX, 150 )
                self.SizeY = Lerp( FrameTime() * 8, self.SizeY, 188 )
                self.PosX = Lerp( FrameTime() * 8, self.PosX, self.OldPosX - 20 )
                self.PosY = Lerp( FrameTime() * 8, self.PosY, self.OldPosY - 20 )
                self:SetZPos(1)
                card:GetChildren()[3]:SetSize( self.SizeX, self.SizeY )
            else
                self.SizeX = Lerp( FrameTime() * 8, self.SizeX, 120 )
                self.SizeY = Lerp( FrameTime() * 8, self.SizeY, 158 )
                self.PosX = Lerp( FrameTime() * 8, self.PosX, self.OldPosX )
                self.PosY = Lerp( FrameTime() * 8, self.PosY, self.OldPosY )
                self:SetZPos(0)
            end
            self:SetSize( self.SizeX, self.SizeY )
            self:SetPos( self.PosX, self.PosY )
        end
        tbl[#tbl + 1] = card

        local avatar = vgui.Create( "AvatarImage", card )
        avatar:Dock( TOP )
        avatar:DockMargin( 5, 5, 5, 0 )
        avatar:SetPlayer( v, 128 )
        avatar:SetTall( 110 )

        local name = vgui.Create( "DLabel", card )
        name:SetText( v:Name() )
        name:SetFont( "ColorRun:32" )
        name:Dock( FILL )
        name:DockMargin( 16, 0, 16, 0 )
        name:SizeToContents()
        name:SetTextColor( Color( 255, 255, 255 ) )
        name:SetContentAlignment( 5 )

        local button = vgui.Create( "DButton", card )
        button:SetPos( 0, 0 )
        button:SetSize( card:GetWide(), card:GetTall() )
        button:SetText( "" )
        function button:Paint() end
        function button:DoClick()
            frame:Close()
            ColorRun:SendNet( ColorRun.ENUMS.InviteTeam, function() net.WriteEntity( v ) end )
        end
    end
end

local function ShowCreateGame( left, frame )
    local panel = vgui.Create( "DPanel", left )
    panel:Dock( FILL )
    function panel:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 52, 52, 52 ) )
    end

    local title = vgui.Create( "DLabel", panel )
    title:SetText( ColorRun:GetTranslation( "create_game" ) )
    title:SetFont( "ColorRun:54" )
    title:Dock( TOP )
    title:DockMargin( 32, 32, 32, 32 )
    title:SizeToContents()
    title:SetTextColor( Color( 255, 255, 255 ) )
    title:SetContentAlignment( 5 )

    local function label( str, pnl )
        local thegui = vgui.Create( "DLabel", pnl or panel )
        thegui:SetText( str )
        thegui:SetFont( "ColorRun:32" )
        thegui:Dock( TOP )
        thegui:DockMargin( 21, 0, 0, 0 )
        thegui:SizeToContents()
        thegui:SetTextColor( Color( 255, 255, 255 ) )
        thegui:SetContentAlignment( 1 )
        function thegui:Paint( w, h )
            surface.SetFont( "ColorRun:32" )
            local sizex = surface.GetTextSize( self:GetText() )
            surface.SetDrawColor( Color( 249, 107, 107 ) )
            surface.DrawRect( 0, h / 1.05, sizex, h / 8 )
        end
        return thegui
    end

    local checked = {
        [1] = {
            name = "Color Shuffle",
            checked = false
        },
        [2] = {
            name = "Color Conquest",
            checked = false
        },
        [3] = {
            name = "Color Fade",
            checked = false
        },
        [4] = {
            name = "Color Tron",
            checked = false
        }
    }
    local pmax = 0
    local rnum = 0
    local bround = false
    local duomode = false

    local create = vgui.Create( "DButton", panel )
    create:Dock( BOTTOM )
    create:DockMargin( 21, 16, 21, 16 )
    create:SetText( "" )
    create:SetTall( 50 )
    create:SetVisible( false )
    create:SetAlpha( 0 )
    function create:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, self:IsHovered() and Color( 72, 72, 72 ) or Color( 62, 62, 62 ) )
        draw.SimpleText( ColorRun:GetTranslation("create_game"), "ColorRun:32", w / 2, h / 2, Color( 255, 255, 255 ), 1, 1 )
    end
    function create:DoClick()
        ColorRun:SendNet( ColorRun.ENUMS.CreateGame, function()
            ColorRun:WriteTable( {
                ["gamemodes"] = {
                    [1] = checked[1]["checked"] and 1 or 0,
                    [2] = checked[2]["checked"] and 1 or 0,
                    [3] = checked[3]["checked"] and 1 or 0,
                    [4] = checked[4]["checked"] and 1 or 0,
                },
                ["round_amount"] = rnum,
                ["players_max"] = pmax,
                ["bonuses"] = bround and 1 or 0,
                ["duos"] = duomode and 1 or 0,
            } )
        end )
    end

    local function SizeLeft()
        left:SizeTo( left:GetWide(), ScrH() <= 900 and frame:GetTall() / 1.3 + 50 or frame:GetTall() / 1.9 + 50, 0.5, 0, -1, function()
            create:SetVisible( true )
            create:AlphaTo( 255, 0.1, 0 )
        end )
    end
    local function ResizeLeft()
        left:SizeTo( left:GetWide(), ScrH() <= 900 and frame:GetTall() / 1.3 or frame:GetTall() / 1.9, 0.5, 0, -1, function()
            create:SetVisible( false )
            create:AlphaTo( 0, 0.1, 0 )
        end )
    end

    local gamemodes = label( ColorRun:GetTranslation( "gamemodes" ) )

    local invisible_top = vgui.Create( "DPanel", panel )
    invisible_top:Dock( TOP )
    invisible_top:DockMargin( 16, 8, 16, 8 )
    invisible_top:SetTall( frame:GetTall() / 9.7 )
    function invisible_top:Paint() end

    local icon = vgui.Create( "DIconLayout", invisible_top )
    icon:Dock( FILL )
    icon:DockMargin( 5, 5, 5, 5 )
    icon:SetSpaceX( 10 )
    icon:SetSpaceY( 5 )

    for k, v in ipairs( checked ) do
        local panel = vgui.Create( "DPanel", icon )
        panel:SetSize( frame:GetWide() / 2.2 / 2.2, frame:GetWide() / 10 / 4 )
        function panel:Paint( w, h )
            draw.SimpleText( v.name, "ColorRun:32", w / 7, h / 2, self:GetChildren()[1]:GetChecked() and Color( 249, 107, 107 ) or Color( 255, 255, 255 ), 0, 1 )
        end
    
        local checkbox = vgui.Create( "DCheckBox", panel )
        checkbox:Dock( LEFT )
        checkbox:SetWide( panel:GetTall() )
        function checkbox:Paint( w, h )
            draw.RoundedBox( 8, self:GetChecked() and 0 or 4, self:GetChecked() and 0 or 4, self:GetChecked() and w or w - 8, self:GetChecked() and h or h - 8, self:GetChecked() and Color( 249, 107, 107 ) or Color( 62, 62, 62 ) )
        end
        function checkbox:OnChange( val )
            checked[k]["checked"] = val
            if ( checked[1]["checked"] or checked[2]["checked"] or checked[3]["checked"] or checked[4]["checked"] ) and pmax > 1 and rnum > 0 then
                SizeLeft()
            else
                ResizeLeft()
            end
        end
    end

    local invisible_top = vgui.Create( "DPanel", panel )
    invisible_top:Dock( TOP )
    invisible_top:SetTall( frame:GetTall() / 10 )
    function invisible_top:Paint() end

    local pnlleft = vgui.Create( "DPanel", invisible_top )
    pnlleft:Dock( LEFT )
    pnlleft:SetWide( frame:GetWide() / 2.2 / 2.2 )
    function pnlleft:Paint() end

    local playermax = label( ColorRun:GetTranslation( "players_max" ), pnlleft )

    local players = vgui.Create( "DNumberWang", pnlleft )
    players:Dock( TOP )
    players:SetTall( 45 )
    players:DockMargin( 21, 16, 21, 16 )
    players:SetDrawLanguageID( false )
    function players:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 62, 62, 62 ) )
        self:DrawTextEntryText( Color( 255, 255, 255 ), Color( 0, 125, 225 ), Color( 255, 255, 255 ) )
    end
    function players:OnValueChanged( val )
        pmax = tonumber( val )
        if ( checked[1]["checked"] or checked[2]["checked"] or checked[3]["checked"] or checked[4]["checked"] ) and pmax > 1 and rnum > 0 then
            SizeLeft()
        else
            ResizeLeft()
        end
    end

    local right = vgui.Create( "DPanel", invisible_top )
    right:Dock( LEFT )
    right:DockMargin( 12, 0, 0, 0 )
    right:SetWide( frame:GetWide() / 2.2 / 2.2 )
    function right:Paint() end

    local rounds = label( ColorRun:GetTranslation( "rounds_number" ), right )

    local numbers = vgui.Create( "DNumberWang", right )
    numbers:Dock( TOP )
    numbers:SetTall( 45 )
    numbers:DockMargin( 21, 16, 21, 16 )
    numbers:SetDrawLanguageID( false )
    function numbers:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 62, 62, 62 ) )
        self:DrawTextEntryText( Color( 255, 255, 255 ), Color( 0, 125, 225 ), Color( 255, 255, 255 ) )
    end
    function numbers:OnValueChanged( val )
        rnum = tonumber( val )
        if ( checked[1]["checked"] or checked[2]["checked"] or checked[3]["checked"] or checked[4]["checked"] ) and pmax > 1 and rnum > 0 then
            SizeLeft()
        else
            ResizeLeft()
        end
    end

    local top = vgui.Create( "DPanel", panel )
    top:Dock( TOP )
    top:DockMargin( 21, 16, 21, 16 )
    top:SetTall( frame:GetTall() / 22 )
    function top:Paint( w, h )
        draw.SimpleText( ColorRun:GetTranslation( "enable_bonuses" ), "ColorRun:32", w / 14, h / 2, self:GetChildren()[1]:GetChecked() and Color( 249, 107, 107 ) or Color( 255, 255, 255 ), 0, 1 )
    end

    local checkbox = vgui.Create( "DCheckBox", top )
    checkbox:Dock( LEFT )
    checkbox:SetWide( top:GetTall() )
    function checkbox:Paint( w, h )
        draw.RoundedBox( 8, self:GetChecked() and 0 or 4, self:GetChecked() and 0 or 4, self:GetChecked() and w or w - 8, self:GetChecked() and h or h - 8, self:GetChecked() and Color( 249, 107, 107 ) or Color( 62, 62, 62 ) )
    end
    function checkbox:OnChange( val )
        bround = val
        if ( checked[1]["checked"] or checked[2]["checked"] or checked[3]["checked"] or checked[4]["checked"] ) and pmax > 1 and rnum > 0 then
            SizeLeft()
        else
            ResizeLeft()
        end
    end

    local topt = vgui.Create( "DPanel", panel )
    topt:Dock( TOP )
    topt:DockMargin( 21, 0, 21, 16 )
    topt:SetTall( frame:GetTall() / 22 )
    function topt:Paint( w, h )
        draw.SimpleText( ColorRun:GetTranslation( "duo_mode" ), "ColorRun:32", w / 14, h / 2, self:GetChildren()[1]:GetChecked() and Color( 249, 107, 107 ) or Color( 255, 255, 255 ), 0, 1 )
    end

    local checkbox = vgui.Create( "DCheckBox", topt )
    checkbox:Dock( LEFT )
    checkbox:SetWide( topt:GetTall() )
    function checkbox:Paint( w, h )
        draw.RoundedBox( 8, self:GetChecked() and 0 or 4, self:GetChecked() and 0 or 4, self:GetChecked() and w or w - 8, self:GetChecked() and h or h - 8, self:GetChecked() and Color( 249, 107, 107 ) or Color( 62, 62, 62 ) )
    end
    function checkbox:OnChange( val )
        duomode = val
        if ( checked[1]["checked"] or checked[2]["checked"] or checked[3]["checked"] or checked[4]["checked"] ) and pmax > 1 and rnum > 0 then
            SizeLeft()
        else
            ResizeLeft()
        end
    end

    local close = vgui.Create( "DButton", panel )
    close:SetPos( frame:GetWide() / 2.2 / 1.06, 10 )
    close:SetSize( 40, 20 )
    close:SetText( "" )
    function close:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, self:IsHovered() and Color( 255, 117, 117 ) or Color( 249, 107, 107 ) )
    end
    function close:DoClick()
        left:MoveTo( -frame:GetWide() / 2.2, frame:GetTall() / 5, 0.5, 0, -1, function()
            left:Clear()
            left:SetTall( ScrH() <= 900 and frame:GetTall() / 1.3 + 50 or frame:GetTall() / 1.9 )
            ColorRun:ShowActions( left, frame )
            left:MoveTo( frame:GetWide() / 20, frame:GetTall() / 5, 0.5, 0, -1 )
        end )
    end
end

function ColorRun:ShowActions( left, frame )
    local actions = {
        [1] = {
            name = ColorRun:GetTranslation( "create_game" ),
            action = function()
                left:MoveTo( -frame:GetWide() / 2.2, frame:GetTall() / 5, 0.5, 0, -1, function()
                    left:Clear()
                    ShowCreateGame( left, frame )
                    left:MoveTo( frame:GetWide() / 20, frame:GetTall() / 5, 0.5, 0, -1 )
                end )
            end,
        },
        [2] = {
            name = ColorRun:GetTranslation( "join_queue" ), 
            action = function() end,
        },
        [3] = {
            name = ColorRun:GetTranslation( "exit" ),
            action = function() frame:AlphaTo( 0, 0.2, 0, function() frame:Close() end ) end,
        }
    }

    for k, v in ipairs( actions ) do
        local button = vgui.Create( "DButton", left )
        button:Dock( TOP )
        button:DockMargin( 0, 10, 0, 0 )
        button:SetTall( 72 )
        button:SetText( "" )
        button.Lerp = 42
        function button:Paint( w, h )
            if self:IsHovered() then
                self.Lerp = Lerp( FrameTime() * 8, self.Lerp, 255 )
            else
                self.Lerp = Lerp( FrameTime() * 8, self.Lerp, 100 )
            end
            draw.SimpleText( v["name"], "ColorRun:54", w / 60, h / 2, Color( self.Lerp, self.Lerp, self.Lerp ), 0, 1 )
        end
        function button:DoClick()
            v["action"]()
        end
    end
end

local function ShowTeam( frame, tbl )
    local team = vgui.Create( "DPanel", frame )
    team:SetPos( frame:GetWide(), frame:GetTall() / 5 )
    team:SetWide( frame:GetWide() / 2.6 )
    team:SetTall( ScrH() <= 900 and frame:GetTall() / 1.3 or frame:GetTall() / 1.9 )
    team:MoveTo( frame:GetWide() / 1.75, frame:GetTall() / 5, 0.705, 0, -1 )
    function team:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 52, 52, 52 ) )
    end

    local title = vgui.Create( "DLabel", team )
    title:SetText( ColorRun:GetTranslation( "my_team" ) )
    title:SetFont( "ColorRun:54" )
    title:Dock( TOP )
    title:DockMargin( 32, 32, 32, 32 )
    title:SizeToContents()
    title:SetTextColor( Color( 255, 255, 255 ) )
    title:SetContentAlignment( 5 )
    if table.Count( tbl ) == 0 then
        tbl = {
            [LocalPlayer():SteamID64()] = "owner"
        }
    end
    for k, v in pairs( tbl ) do
        local ply = player.GetBySteamID64( k )

        local member = vgui.Create( "DPanel", team )
        member:Dock(TOP)
        member:DockMargin( 16, 0, 16, 16 )
        member:SetTall( 200 )
        function member:Paint( w, h )
            draw.RoundedBox( 8, 0, 0, w, h, Color( 62, 62, 62 ) )
        end

        local avatar = vgui.Create( "AvatarImage", member )
        avatar:Dock(LEFT)
        avatar:DockMargin( 16, 16, 16, 16 )
        avatar:SetWide( 168 )
        avatar:SetPlayer( ply, 256 )

        local name = vgui.Create( "DLabel", member )
        name:SetText( ply:Name() )
        name:SetFont( "ColorRun:54" )
        name:Dock( TOP )
        name:DockMargin( 32, 50, 32, 50 )
        name:SizeToContents()
        name:SetTextColor( Color( 255, 255, 255 ) )
        name:SetContentAlignment( 4 )

        local role = vgui.Create( "DLabel", member )
        role:SetText( ColorRun:GetTranslation( v ) )
        role:SetFont( "ColorRun:32" )
        role:Dock( BOTTOM )
        role:DockMargin( 32, 50, 32, 50 )
        role:SizeToContents()
        role:SetTextColor( Color( 255, 255, 255 ) )
        role:SetContentAlignment( 4 )
        if v ~= "owner" then
            local kick = vgui.Create( "DButton", member )
            kick:SetPos( frame:GetWide() / 2.71 - 40, 160 )
            kick:SetSize( 40, 40 )
            kick:SetText( "" )
            kick.Lerp = 200
            function kick:Paint( w, h )
                if self:IsHovered() then
                    self.Lerp = Lerp( FrameTime() * 10, self.Lerp, 255 )
                else
                    self.Lerp = Lerp( FrameTime() * 10, self.Lerp, 200 )
                end
                surface.SetDrawColor( Color( self.Lerp, self.Lerp, self.Lerp ) )
                surface.SetMaterial( kickicon )
                surface.DrawTexturedRect( 0, 0, w, h )
            end
            function kick:DoClick()
                member:Remove()
                ColorRun:SendNet( ColorRun.ENUMS.KickMember, function() net.WriteInt(v ~= LocalPlayer() and 1 or 2, 3) end )

                local add = vgui.Create( "DButton", team )
                add:Dock(TOP)
                add:DockMargin( 16, 0, 16, 16 )
                add:SetTall( 200 )
                add:SetText( "" )
                add.Lerp = 62
                add.LerpText = 200
                function add:DoClick()
                    SearchPlayerFrame()
                end
                function add:Paint( w, h )
                    if self:IsHovered() then
                        self.Lerp = Lerp( FrameTime() * 10, self.Lerp, 82 )
                        self.LerpText = Lerp( FrameTime() * 10, self.LerpText, 220 )
                    else
                        self.Lerp = Lerp( FrameTime() * 10, self.Lerp, 62 )
                        self.LerpText = Lerp( FrameTime() * 10, self.LerpText, 200 )
                    end

                    draw.RoundedBox( 8, 0, 0, w, h, Color( self.Lerp, self.Lerp, self.Lerp ) )
                    draw.SimpleText( "+", "ColorRun:84", w / 2, h / 2, Color( self.LerpText, self.LerpText, self.LerpText ), 1, 1 )
                end
            end
        end
    end

    if table.Count( tbl ) <= 1 then
        local add = vgui.Create( "DButton", team )
        add:Dock(TOP)
        add:DockMargin( 16, 0, 16, 16 )
        add:SetTall( 200 )
        add:SetText( "" )
        add.Lerp = 62
        add.LerpText = 200
        function add:DoClick()
            SearchPlayerFrame()
        end
        function add:Paint( w, h )
            if self:IsHovered() then
                self.Lerp = Lerp( FrameTime() * 10, self.Lerp, 82 )
                self.LerpText = Lerp( FrameTime() * 10, self.LerpText, 220 )
            else
                self.Lerp = Lerp( FrameTime() * 10, self.Lerp, 62 )
                self.LerpText = Lerp( FrameTime() * 10, self.LerpText, 200 )
            end

            draw.RoundedBox( 8, 0, 0, w, h, Color( self.Lerp, self.Lerp, self.Lerp ) )
            draw.SimpleText( "+", "ColorRun:84", w / 2, h / 2, Color( self.LerpText, self.LerpText, self.LerpText ), 1, 1 )
        end
    end
end

local function GameFrame()
    local tbl = net.ReadTable()
    local queue = tostring(net.ReadBool())

    local frame = vgui.Create( "DFrame" )
    frame:DockPadding( 0, 0, 0, 0 )
    frame:SetSize( ScrW(), ScrH() )
    frame:Center()
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:MakePopup()
    frame.LerpWave1 = frame:GetTall()
    frame.LerpWave2 = frame:GetTall()
    frame.LerpWave3 = frame:GetTall()
    frame.LerpBackground = frame:GetWide()
    function frame:Paint( w, h )
        self.LerpWave1 = Lerp( FrameTime() * 2.5, self.LerpWave1, 0 )
        self.LerpWave2 = Lerp( FrameTime() * 2, self.LerpWave2, 0 )
        self.LerpWave3 = Lerp( FrameTime() * 1.5, self.LerpWave3, 0 )
        self.LerpBackground = Lerp( FrameTime() * 4.8, self.LerpBackground, 0 )

        surface.SetDrawColor( Color( 42, 42, 42 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.SetMaterial( background )
        surface.DrawTexturedRect( self.LerpBackground, 0, w, h )
        surface.SetMaterial( wave1 )
        surface.DrawTexturedRect( 0, self.LerpWave1, w, h )
        surface.SetMaterial( wave2 )
        surface.DrawTexturedRect( 0, self.LerpWave2, w, h )
        surface.SetMaterial( wave3 )
        surface.DrawTexturedRect( 0, self.LerpWave3, w, h )
    end

    local head = vgui.Create( "DPanel", frame )
    head:Dock( TOP )
    head:SetTall( 150 )
    function head:Paint( w, h )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.SetMaterial( logo )
        surface.DrawTexturedRect( 48, 48, 200.2, 81.4 )
    end

    local close = vgui.Create( "DButton", head )
    close:Dock( RIGHT )
    close:SetText("x")
    function close:Paint() end
    function close:DoClick()
        frame:Close()
    end

    local left = vgui.Create( "DPanel", frame )
    left:SetPos( frame:GetWide() / 20, frame:GetTall() / 5 )
    left:SetSize( frame:GetWide() / 2.2, ScrH() <= 900 and frame:GetTall() / 1.3 or frame:GetTall() / 1.9 )
    left:DockMargin( 40, 32, 0, 64 )
    function left:Paint() end

    ColorRun:ShowActions( left, frame )
    ShowTeam( frame, tbl )
end
concommand.Add( "color_menu",  GameFrame )
concommand.Add( "color_search", SearchPlayerFrame )

ColorRun:RegisterCallback( ColorRun.ENUMS.OpenMenu, GameFrame )