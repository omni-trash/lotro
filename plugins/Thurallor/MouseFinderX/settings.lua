--[[
    Plugin Settings
]]

-- "Thurallor.MouseFinderX.settings"
local file     = getfenv(1)._.Name;
-- "ThurallorMouseFinderXsettings".plugindata
local FILENAME = string.gsub(file, "%.", "");

DefaultSettings  = {
    scale            = 0.6;
    showOnlyInCombat = true;
    speed            = 0.5;
    persistTime      = 3;
    -- not a color instance (!), so we can copy table values as is (see reset)
    color            = {R = 0.58, G = 0.64, B = 0.33};
    cycleColors      = true;
    colorCycleSpeed  = 8;
    opacity          = 0.8;
    fpsLimit         = 30;
};

-- convert from RGB to HSV
local H, S, V = color.rgb2hsv(
    DefaultSettings.color.R, 
    DefaultSettings.color.G, 
    DefaultSettings.color.B
);

-- create HSV entry
DefaultSettings.hsv = {
    H = H,
    S = S,
    V = V
};

-- copy default so we can reset settings
settings = settings or table.copy(DefaultSettings);

-----------------------------------------------------------
-- Plugin
-----------------------------------------------------------

local function SaveSettings()
    local values = table.export(settings);
    Turbine.PluginData.Save(Turbine.DataScope.Account, FILENAME, values, function()
    end);
end

local function LoadSettings()
    Turbine.PluginData.Load(Turbine.DataScope.Account, FILENAME, function (values)
        table.import(settings, values);

        -- convert from RGB to HSV
        local H, S, V = color.rgb2hsv(
            settings.color.R,
            settings.color.G,
            settings.color.B
        );

        -- update HSV entry
        settings.hsv.H = H;
        settings.hsv.S = S;
        settings.hsv.V = V;

        callback.raise(events, "SettingsChanged");
    end);
end

Turbine.Plugin.Load   = LoadSettings;
Turbine.Plugin.Unload = SaveSettings;