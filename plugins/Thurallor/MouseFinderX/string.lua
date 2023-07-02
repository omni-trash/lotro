--[[
    String Utils
]]
string = string  or {};

-- local s = string.render("Hallo {Name}", {Name = "Welt"});
function string.render(format, params)
    if (type(params) == "table") then
        for k, v in pairs(params) do
            format = string.gsub(format, "{" .. k .. "}", tostring(v));
        end
    end

    return format;
end
