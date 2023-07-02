--[[ 
    Control UI Factory - Label

    requires: 
    - control.lua
]]

-- create label
function control.label(text)
    local label = Turbine.UI.Label();
    label.type  = "LABEL";
   
    label:SetFont(control.Default.Font);
    label:SetForeColor(control.Default.ForeColor);
    label:SetText(text);

    return label;
end
