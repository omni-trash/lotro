--[[
    Terminal Utils
]]
terminal = terminal or {};

-- termina.write("Hallo {Name}", {Name = "Welt"});
function terminal.write(format, params)
    Turbine.Shell.WriteLine(string.render(format, params));
end
