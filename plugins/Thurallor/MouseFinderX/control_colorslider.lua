--[[ 
    Control UI Factory - ColorSlider

    requires: 
    - control.lua
]]

-- create color slider
function control.colorslider(pic)
    local slider = control.control();
    slider.type  = "COLORSLIDER";
    slider.value = 0;

    local image = control.image(pic);
    image:SetParent(slider);
    image:SetHeight(10);

    local thumb = control.control();
    thumb:SetParent(slider);
    thumb:SetBackColor(Turbine.UI.Color(0.6, 0.6, 0.6));
    thumb:SetPosition(0, 0);
    thumb:SetSize(10, 15);

    function thumb:MouseDown()
        -- redirect
        image:MouseDown();
    end

    function thumb:MouseUp()
        -- redirect
        image:MouseUp();
    end

    function thumb:MouseMove()
        -- redirect
        image:MouseMove();
    end

    function image:MouseDown()
        self.mouseDown = true;
        -- update thumb position
        self:MouseMove();
    end

    function image:MouseUp()
        self.mouseDown = false;
    end

    function image:MouseMove()
        if (not self.mouseDown) then
            return;
        end

        local mouseX, mouseY = self:PointToClient(
            Turbine.UI.Display.GetMouseX(),
            Turbine.UI.Display.GetMouseY()
        );

        local width = self:GetWidth();

        if (width < 1) then
            return;
        end

        local value = mouseX / width;
        slider:SetValue(value);
    end

    function slider:GetValue()
        return slider.value;
    end

    function slider:SetValue(value)
        local value = math.min(1, math.max(0, value));

        if (slider.value ~= value) then
            slider.value = value;
            callback.raise(slider, "ValueChanged");
        end
    end

    callback.add(slider, "ValueChanged", function(sender)
        local width = image:GetWidth();
        local xpos  = slider.value * width;
        local half  = thumb:GetWidth() / 2;
        local left  = xpos - half;

        if (left < 0) then
            left = 0;
        end

        if (left > width - thumb:GetWidth()) then
            left = width - thumb:GetWidth();
        end

        thumb:SetLeft(left);
    end);

    slider.image = image;
    slider.thumb = thumb;

    return slider;
end
