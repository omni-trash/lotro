--[[
    Plugin Options Panel
]]

-- "Thurallor.MouseFinderX.demo"
local file   = getfenv(1)._.Name;
-- "Thurallor.MouseFinderX"
local path   = string.gsub(file, "%.[^%.]+$", "");
-- "Thurallor/MouseFinderX"
local assets = string.gsub(path, "%.", "/");
-- "Thurallor/MouseFinderX/assets/theme.jpg"
local theme  = assets.."/assets/theme.jpg";

-----------------------------------------------------------
-- Panel & Controls
-----------------------------------------------------------

-----------------------------------------------------------
-- The mouse finder is only showing when in combat, when
-- this option is enabled.
-----------------------------------------------------------

local showOnlyInCombat = control.checkbox(
    "Show only when in combat",
    function(sender)
        settings.showOnlyInCombat = sender:IsChecked();
        callback.raise(events, "SettingsChanged");
    end
);

-----------------------------------------------------------
-- Rotation speed
-----------------------------------------------------------

local speedLabel = control.label(
    "Rotation speed"
);

local speedSlider = control.slider(
    0, 
    100, 
    function(sender)
        settings.speed = sender:GetValue() / 20;
        callback.raise(events, "SettingsChanged");
    end
);

local speedValue = control.label();

-----------------------------------------------------------
-- The mouse finder is hiding after that time period,
-- when the mouse is not moving.
-----------------------------------------------------------

local persistTimeLabel = control.label(
    "Time to persist when movement stops"
);

local persistTimeSlider = control.slider(
    0, 
    100, 
    function(sender)
        settings.persistTime = sender:GetValue() / 10;
        callback.raise(events, "SettingsChanged");
    end
);

local persistTimeValue = control.label();

-----------------------------------------------------------
-- Mouse finder size
-----------------------------------------------------------

local scaleLabel = control.label("Size");

local scaleSlider = control.slider(
    5,
    100,
    function(sender)
        settings.scale = 2 * sender:GetValue() / 100;
        callback.raise(events, "SettingsChanged");
    end
);

local scaleValue = control.label();

-----------------------------------------------------------
-- The mouse finder iterates over all colors, when this
-- option is enabled, otherwise it use a single color.
-- You can use the S(aturation) and V(alue) slider.
-----------------------------------------------------------

local cycleColors = control.checkbox(
    "Cycle colors continuously",
    function(sender)
        settings.cycleColors = sender:IsChecked();
        callback.raise(events, "SettingsChanged");
    end
);

local colorLabel = control.label("Color");

local colorCycleSpeed = control.slider(
    0, 
    90,
    function(sender)
        settings.colorCycleSpeed = sender:GetValue() / 2;
        callback.raise(events, "SettingsChanged");
    end
);

-----------------------------------------------------------
-- The speed to iterate over all colors. Only valid when
-- cycle colors is enabled.
-----------------------------------------------------------

local colorCycleSpeedValue = control.label();

local resetButton = control.button(
    "Reset to defaults", 
    function()
        settings = table.copy(DefaultSettings);
        callback.raise(events, "SettingsChanged");
    end
);

-----------------------------------------------------------
-- Mouse finder opacity (window)
-----------------------------------------------------------

local opacityLabel = control.label("Opacity");

local opacitySlider = control.slider(
    20,
    100,
    function(sender)
        settings.opacity = sender:GetValue() / 100;
        callback.raise(events, "SettingsChanged");
    end
)

local opacityValue = control.label();

-----------------------------------------------------------
-- Mouse finder FPS draw limit
-----------------------------------------------------------

local fpsLimitLabel = control.label("FPS Limit for constant rotation");

local fpsLimitSlider = control.slider(
    1,
    100,
    function(sender)
        settings.fpsLimit = sender:GetValue();
        callback.raise(events, "SettingsChanged");
    end
)

local fpsLimitValue = control.label();

-----------------------------------------------------------
-- The pin/unpin button allows to switch between the plugin 
-- manager panel and a single floating window.
-- This is only for the options panel.
-----------------------------------------------------------

local unpinButton = control.button(
    "Open in window",
    function(sender)
        if (optionsPanel:GetParent() == optionsHost) then
            -- switch from options host to window
            optionsPanel:SetParent(optionsWindow);
            sender:SetText("Pin to plugin manager");
            optionsWindow:SetVisible(true);
            optionsWindow:SizeChanged();
        else
            -- switch from options window to host
            optionsPanel:SetParent(optionsHost);
            sender:SetText("Open in window");
            optionsWindow:SetVisible(false);
            optionsHost:SizeChanged();
        end
    end
);

-----------------------------------------------------------
-- The image on right side in the options panel.
-----------------------------------------------------------

-- theme
local image = control.image(theme);
image:SetBackColor(Turbine.UI.Color(0.6, 0.6, 0.6));

-- add callback to global event hub
callback.add(events, "SettingsChanged", function()
    showOnlyInCombat:SetChecked(settings.showOnlyInCombat);

    persistTimeSlider:SetValue(settings.persistTime * 10);
    persistTimeValue:SetText(string.format("%0.1f",settings.persistTime));
    
    speedSlider:SetValue(settings.speed * 20);
    speedValue:SetText(string.format("%0.1f", settings.speed));
    
    scaleSlider:SetValue(100 * settings.scale / 2);
    scaleValue:SetText(string.format("%0.2f", settings.scale));

    cycleColors:SetChecked(settings.cycleColors);
    colorCycleSpeed:SetValue(settings.colorCycleSpeed * 2);
    colorCycleSpeedValue:SetText(string.format("%0.1f", settings.colorCycleSpeed));

    opacitySlider:SetValue(100 * settings.opacity);
    opacityValue:SetText(string.format("%0.2f", settings.opacity));

    fpsLimitSlider:SetValue(settings.fpsLimit);
    fpsLimitValue:SetText(string.format("%d", settings.fpsLimit));
end);

-----------------------------------------------------------
-- Layout for the grid layout engine.
-- This is only for the options panel.
-----------------------------------------------------------

-- panel layout
local layout = {
    style = {
        ["padding-left"]   = 10,
        ["padding-top"]    = 10,
        ["padding-right"]  = 10,
        ["padding-bottom"] = 10,
    },
    min_w = 540,
    max_w = 800,
    min_h = 540,
    max_h = 700,
    grid  = {
        "a--------a   p", -- when in combat checkbox
        "             p", -- space
        "b--------b   p", -- rotation speed label
        "c--------c w p", -- rotation speed slider + value
        "             p", -- space
        "d--------d   p", -- fade out time label
        "e--------e v p", -- fade out time slider + value
        "             p", -- space
        "f--------f   p", -- cicle size label
        "g--------g z p", -- cicle size slider + value
        "             P",
        "h--------h   p", -- cycle colors checkbox
        "i--------i   p", -- color speed label
        "j--------j s p", -- color speed slider + value
        "             p", -- space
        "C----------C p", -- color panel
        "             p", -- space
        "H--------H   p", -- opacity label
        "I--------I J p", -- opacity slider + value
        "             p", -- space
        "E--------E   p", -- fps label
        "F--------F G p", -- fps slider + value
        "5----------5 p", -- hr
        "k----k       p", -- reset button
        "             p", -- space
        "U----U       p", -- unpin button
    },
    coldef = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 20, 40, 20, 120},
    rowdef = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 10, 100, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    areas  = {
        -- note: u can use more than one control on an area        
        ["a"] = showOnlyInCombat,
        ["b"] = speedLabel,
        ["c"] = speedSlider,
        ["w"] = speedValue,
        ["d"] = persistTimeLabel,
        ["e"] = persistTimeSlider,
        ["v"] = persistTimeValue,
        ["f"] = scaleLabel,
        ["g"] = scaleSlider,
        ["z"] = scaleValue,
        ["h"] = cycleColors,
        ["i"] = colorLabel,
        ["j"] = colorCycleSpeed,
        ["s"] = colorCycleSpeedValue,
        ["C"] = colorPanel,
        ["5"] = control.hr(),
        ["k"] = resetButton,
        ["U"] = unpinButton,
        ["p"] = image,
        ["H"] = opacityLabel,
        ["I"] = opacitySlider,
        ["J"] = opacityValue,
        ["E"] = fpsLimitLabel,
        ["F"] = fpsLimitSlider,
        ["G"] = fpsLimitValue,
    }
};

-- we use a listbox as scrollviewer
--local panel  = control.panel();
--panel.layout = layout;
--optionsPanel = control.listbox();
--optionsPanel:AddItem(panel);

optionsPanel = control.panel();
optionsPanel.layout = layout;

-----------------------------------------------------------
-- We need a host for the options panel.
-- This host is for the plugin manager panel, so
-- we can detach our options panel and open a new window.
-- The host will be on the plugin manager panel, but the
-- content is swwitched to the floating window.
-----------------------------------------------------------

-- options panel host (plugin manager)
optionsHost = control.control();
optionsPanel:SetParent(optionsHost);

function optionsHost:SizeChanged()
    -- did we have the options panel
    if (optionsPanel:GetParent() == self) then
        optionsPanel:SetPosition(0, 0);
        optionsPanel:SetSize(self:GetSize());
    end
end

-----------------------------------------------------------
-- Options panel floating window
-----------------------------------------------------------

-- options panel window (floating)
optionsWindow = Turbine.UI.Lotro.Window();
optionsWindow:SetText("Mouse Finder");
optionsWindow:SetResizable(true);
optionsWindow:SetSize(600, 640);

-- center window
optionsWindow:SetPosition(
    (Turbine.UI.Display:GetWidth()  - optionsWindow:GetWidth())  / 2,
    (Turbine.UI.Display:GetHeight() - optionsWindow:GetHeight()) / 2
);

function optionsWindow:SizeChanged(args)
    -- did we have the options panel
    if (optionsPanel:GetParent() == self) then
        local w, h = self:GetSize();

        -- we cannot use the complete window for the panel
        -- need some space for window title, corners etc.
        optionsPanel:SetPosition(20, 50);
        optionsPanel:SetSize(w - 40, h - 90);
    end
end

function optionsWindow:Closing()
    -- back to options host
    unpinButton:Click();
end

-----------------------------------------------------------
-- Plugin
-----------------------------------------------------------

-- Create the "options" tab in the plugin manager.
plugin.GetOptionsPanel = function()
    -- We return the host instead of the options panel
    -- so we can pin/unpin to floating window.
    -- Normally we would return the options panel here.
    optionsHost:SetSize(540, 580);
    return optionsHost;
end
