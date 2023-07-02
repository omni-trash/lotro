--[[ 
    Control UI Factory - Slider

    requires: 
    - control.lua
]]

-- create slider
function control.slider(min, max, changed)
    local slider = Turbine.UI.Lotro.ScrollBar();
    slider.type  = "SLIDER";

    slider:SetMinimum(min);
    slider:SetMaximum(max);
    slider:SetOrientation(Turbine.UI.Orientation.Horizontal);
    slider:SetBackColor(control.Default.BarColor);

    slider.ValueChanged = changed;
    return slider
end
