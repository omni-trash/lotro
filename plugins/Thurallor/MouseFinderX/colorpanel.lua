--[[
    Plugin Color Panel
]]

-- "Thurallor.MouseFinderX.colorpanel"
local file   = getfenv(1)._.Name;
-- "Thurallor.MouseFinderX"
local path   = string.gsub(file, "%.[^%.]+$", "");
-- "Thurallor/MouseFinderX"
local assets = string.gsub(path, "%.", "/");
-- "Thurallor/MouseFinderX/assets/pic1.jpg"
local hsv_h_pic = assets.."/assets/hsv_h.jpg";
local hsv_s_pic = assets.."/assets/hsv_s.jpg";
local hsv_v_pic = assets.."/assets/hsv_v.jpg";

-----------------------------------------------------------
-- Panel & Controls
-----------------------------------------------------------

local colorPreview = control.control();

-- HSV - hue
local h_slider = control.colorslider(hsv_h_pic);
h_slider.image:SetBackColorBlendMode(Turbine.UI.BlendMode.Overlay);

callback.add(h_slider, "ValueChanged", function(sender)
    settings.hsv.H = sender.value;
    callback.raise(events, "SettingsChanged");
end);

-- HSV - saturation
local s_slider = control.colorslider(hsv_s_pic);
s_slider.image:SetBackColorBlendMode(Turbine.UI.BlendMode.Screen);

callback.add(s_slider, "ValueChanged", function(sender)
    settings.hsv.S = sender.value;
    callback.raise(events, "SettingsChanged");
end);

-- HSV - value
local v_slider = control.colorslider(hsv_v_pic);

callback.add(v_slider, "ValueChanged", function(sender)
    settings.hsv.V = sender.value;
    callback.raise(events, "SettingsChanged");
end);

-- R G B H
local text = control.label("");

-- add callback to global event hub
callback.add(events, "SettingsChanged", function()
    -- convert from HSV to RGB
    local R, G, B = color.hsv2rgb(
        settings.hsv.H, 
        settings.hsv.S,
        settings.hsv.V
    );

    settings.color.R = R;
    settings.color.G = G;
    settings.color.B = B;

    h_slider:SetValue(settings.hsv.H);
    s_slider:SetValue(settings.hsv.S);
    v_slider:SetValue(settings.hsv.V);

    -- Set visual feedback now, not perfect but ok.
    --
    -- We are playing with background image,
    -- SetBackColorBlendMode, background color 
    -- and transparency.
    --
    -- All these will give us for the given slider
    -- picture good visual feedback, to reflect the
    -- settings we did.

    --[[
           S
        1-----0 white
         \    |
          \   |
         V \  |
            \ |
             \|
              0 black
    ]]

    -- visual feedback
    h_slider.image:SetBackColor(Turbine.UI.Color(
        1 - settings.hsv.S * settings.hsv.V,
        settings.hsv.V,
        settings.hsv.V,
        settings.hsv.V
    ));

    -- visual feedback
    s_slider.image:SetBackColor(Turbine.UI.Color(
        color.hsv2rgb(settings.hsv.H, 1, settings.hsv.V)));

    -- visual feedback
    v_slider.image:SetBackColor(Turbine.UI.Color(
        color.hsv2rgb(settings.hsv.H, settings.hsv.S, 1)));

    colorPreview:SetBackColor(Turbine.UI.Color(
        settings.color.R,
        settings.color.G,
        settings.color.B
    ));

    local r = math.floor(R * 255);
    local g = math.floor(G * 255);
    local b = math.floor(B * 255);

    text:SetText(string.render("R {R} G {G} B {B} #{H}", {
        R = r,
        G = g,
        B = b,
        H = string.format("%02X%02X%02X", r, g, b)
    }));
end);

-- panel layout
local layout = {
    min_w = 330,
    min_h = 95,
    grid  = {
        "P h H",
        "P s S",
        "P v V",
        "    T",
    },
    coldef = {30, 10 ,15, 10, -1},
    rowdef = {25, 25, 25, 20},
    areas  = {
        -- note: u can use more than one control on an area        
        ["H"] = h_slider,
        ["S"] = s_slider,
        ["V"] = v_slider,
        ["P"] = colorPreview,
        ["h"] = control.label("H"),
        ["s"] = control.label("S"),
        ["v"] = control.label("V"),
        ["T"] = text,
        
    }
};

colorPanel = control.panel();
colorPanel.layout = layout;
