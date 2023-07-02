--[[ 
    Control UI Factory - Button

    requires: 
    - control.lua
]]

-- create button
function control.button(text, click)
    local button = Turbine.UI.Lotro.Button();
    button.type  = "BUTTON";

    button:SetFont(control.Default.Font);
    button:SetForeColor(control.Default.ForeColor);
    button:SetText(text);

    button.Click = click;
    return button;
end
