function ColorRun:GetTranslation( str )
    if str and ColorRun.langs[ColorRun.Config.lang][str] then
        return ColorRun.langs[ColorRun.Config.lang][str]
    end
    return "nil"
end
