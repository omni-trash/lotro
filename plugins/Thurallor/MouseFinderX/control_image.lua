--[[ 
    Control UI Factory - Image

    requires: 
    - control.lua
]]

-- create image
function control.image(backgroundImagePathOrId)
    local image = control.control();
    image.type  = "IMAGE";

    image:SetBackground(backgroundImagePathOrId);
    -- auto fit to image size
    image:SetSize(0, 0);
	image:SetStretchMode(2);
	image:SetStretchMode(0);
    image:SetBlendMode(Turbine.UI.BlendMode.Overlay);
    image:SetBackColorBlendMode(Turbine.UI.BlendMode.Multiply);
    image:SetBackColor(Turbine.UI.Color.White);

    return image;
end
