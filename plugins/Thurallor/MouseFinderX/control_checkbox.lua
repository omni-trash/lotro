--[[ 
    Control UI Factory - CheckBox

    requires: 
    - control.lua
]]

-- create checkbox
function control.checkbox(text, changed)
    local checkbox = Turbine.UI.Lotro.CheckBox();
    checkbox.type  = "CHECKBOX";

    checkbox:SetFont(control.Default.Font);
    checkbox:SetForeColor(control.Default.ForeColor);
    checkbox:SetCheckAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    checkbox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    checkbox:SetText(text);

    checkbox.CheckedChanged = changed;    
    return checkbox;
end
