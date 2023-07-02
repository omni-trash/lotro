--[[
    Table Utils
]]
table = table or {};

-- pack support
table.pack = table.pack or function(...)
    local args = {...};
    return args;
end

-- deep copy
-- note: 
-- we are not clone instances, only 
-- the values.
-- so we can copy a Turbine.UI.Color
-- and the copy will hold the values
-- but the copy is not an instance of
-- Turbine.UI.Color (!)
function table.copy(source)
    local values = {};

    for k, v in pairs(source) do
        if (type(v) == "table") then
            v = table.copy(v);
        end

        values[k] = v;
    end

    return values;
end

-- Turbine.PluginData.Save
-- Workaround for Turbine localization bug with numbers
function table.export(source)
    local values = {};

    for k, v in pairs(source) do
        if (type(v) == "number") then
            -- "1.234" instead of 1,234 (unable to load)
            v = tostring(v);
        elseif (type(v) == "table") then
            -- deep copy
            v = table.export(v);
        end

        values[tostring(k)] = v;
    end

    return values;
end

-- Turbine.PluginData.Load
-- Workaround for Turbine localization bug with numbers
function table.import(target, values)
    if (not values) then 
        return;
    end

    -------------------------------------------------
    -- Note: we cannot read and assign with indexes
    -------------------------------------------------

    -- we only apply values to fields we have in target
    for k, v in pairs(target) do
        local val = values[k];

        if (val ~= nil) then
            if (type(v) == "number") then
                -- target field is a number
                target[k] = tonumber(val);
            elseif (type(v) == "table") then
                -- deep apply
                table.import(v, val);
            else
                -- apply as is
                target[k] = val;
            end
        end
    end
end
