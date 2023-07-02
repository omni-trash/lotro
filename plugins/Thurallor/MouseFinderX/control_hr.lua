--[[ 
    Control UI Factory - HR

    requires: 
    - control.lua
]]

-- create HR
function control.hr()
    local hr = control.control();
    hr.type  = "HR";

    hr:SetHeight(1);
    hr:SetBackColor(Turbine.UI.Color(41/255, 48/255, 72/255));

    return hr;
end
