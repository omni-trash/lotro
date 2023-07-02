--[[ 
    Control UI Factory - Control

    requires: 
    - control.lua
]]

-- create control
function control.control()
    local ctl = Turbine.UI.Control();
    ctl.type  = "CONTROL";

    function ctl:MouseWheel(args)
        local parent = ctl:GetParent();

        if (parent and parent.MouseWheel) then
            parent:MouseWheel(args);
        end
    end

    return ctl;
end
