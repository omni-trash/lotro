--[[ 
    Control UI Factory - ScrollBar
    
    requires: 
    - control.lua

    I was trying to use Turbine.UI.Lotro.ScrollBar, but no success.
]]

--[[
    range = scrollbar - thumb

    | offset      |  thumb   |
    [-------------############----------------------------]
    | scrollbar                                           |

       ^
       |
    translate
       |
       v

    range = content - panel

    | offset           | panel                   |
    [------------------|-------------------------|-------------------------------]
    | content                                                                    |


    ******************************************************************************
    We have to translate between scrollbar values and content values.
    From panel and content we only knows the scrollable range.
    That will be set with scrollbar:SetMaximum(range);

    ******************************************************************************
    How to calculate the thumb size:

    For exact ratio we have to know panel and content size, but we dont have them.
    So we think that the scrollbar size is the panel size (about, not exactly).
    Scrollbar is for the panel on right or bottom, so it should be same.

    Then the sum of "panel" and the "range" (SetMaximum) must be the "content" size.
    Ok, the ration is panel / content.

    panel     thumb
    ------- = ----------
    content   scrollbar

    thumb = panel * scrollbar / content;
    thumb = scrollbar * scrollbar / (scrollbar + max); <- YES

    Ok, we have the thumb size.

    Note: thumb size can also be fix size, that is ok.

    ******************************************************************************
    How to translate scrollbar offset to content offset:
    The ratio is offset / range.

    scrolblar_offset    content_offset
    ----------------- = ------------------
    scrolblar_range     content_range

    content_offset = scrollbar_offset * content_range / scrollbar_range
    content_offset = scrollbar_offset * max / (scrollbar - thumb) <- YES

    Ok, we have the content offset.

    Note: scrollbar.value is the content offset to use and which is 
          triggered with "ValueChanged" event.

    ******************************************************************************
    How to translate content offset to scrollbar offset:

    scrollbar_offset = content_offset * scrollbar_range / content_range
    scrollbar_offset = value * (scrollbar - thumb) / max <- YES

    Ok, we have the scrollbar offset.
]]

-- create scrollbar
function control.scrollbar()
    local scrollbar = control.control();
    scrollbar.type  = "SCROLLBAR";

    scrollbar:SetSize(6, 6);
    scrollbar:SetBackColorBlendMode(Turbine.UI.BlendMode.AlphaBlend);

    -- with alpha
    scrollbar.backcolor = Turbine.UI.Color(
        0.5,
        control.Default.BarColor.R,
        control.Default.BarColor.G,
        control.Default.BarColor.B
    );

    scrollbar:SetBackColor(scrollbar.backcolor);

    -- defaults
    scrollbar.value       = 0;  -- content offset
    scrollbar.max         = 0;  -- content range (scrollable)
    scrollbar.largeChange = 50; -- mouse wheel
    scrollbar.orientation = Turbine.UI.Orientation.Vertical;

    -- Turbine.UI.Orientation.Horizontal: 0
    -- Turbine.UI.Orientation.Vertical  : 1

    local thumb = control.control();
    thumb:SetParent(scrollbar)
    thumb:SetSize(6, 6);
    thumb:SetBackColorBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    thumb:SetPosition(0, 0);

    -- with alpha
    thumb.backcolor = Turbine.UI.Color(
        0.5,
        control.Default.ThumbColor.R,
        control.Default.ThumbColor.G,
        control.Default.ThumbColor.B
    );

    thumb:SetBackColor(thumb.backcolor);

    --------------------------------------------------------------
    -- Thumb
    --------------------------------------------------------------

    -- true if is vertical scrollbar
    local function is_vert()
        return scrollbar.orientation == Turbine.UI.Orientation.Vertical;
    end

    -- calc and set thumb size
    local function update_thumb_size()
        if (is_vert()) then
            local size = scrollbar:GetHeight() * scrollbar:GetHeight() / (scrollbar:GetHeight() + scrollbar.max);
            size = math.max(10, size);
            thumb:SetSize(scrollbar:GetWidth(), size);
        else
            local size = scrollbar:GetWidth() * scrollbar:GetWidth() / (scrollbar:GetWidth() + scrollbar.max);
            size = math.max(10, size);
            thumb:SetSize(size, scrollbar:GetHeight());
        end
    end

    -- remember mouse pos
    function thumb:MouseDown()
        local mouseX, mouseY = thumb:PointToClient(
            Turbine.UI.Display.GetMouseX(),
            Turbine.UI.Display.GetMouseY()
        );

        thumb.mouseX    = mouseX;
        thumb.mouseY    = mouseY;
        thumb.mouseDown = true;
        thumb:MouseEnter();
    end

    function thumb:MouseUp()
        thumb.mouseDown = false;
        thumb:MouseLeave();
    end

    -- scroll with thumb while mouse button is pressed
    function thumb:MouseMove()
        if (not thumb.mouseDown) then
            return;
        end

        local mouseX, mouseY = scrollbar:PointToClient(
            Turbine.UI.Display.GetMouseX(),
            Turbine.UI.Display.GetMouseY()
        );

        local range  = 0;
        local offset = 0;

        if (is_vert()) then
            range  = scrollbar:GetHeight() - thumb:GetHeight();
            offset = mouseY - thumb.mouseY;
        else
            range  = scrollbar:GetWidth()  - thumb:GetWidth();
            offset = mouseX - thumb.mouseX;
        end

        if (not (range > 0)) then
            scrollbar:SetValue(0);
            return;
        end

        local value  = offset * scrollbar.max / range;
        scrollbar:SetValue(value);
    end

    function thumb:MouseWheel(args)
        -- redirect
        scrollbar:MouseWheel(args);
    end

    -- hover effect
    function thumb:MouseEnter()
        if (thumb.hover) then
            return;
        end

        thumb.hover = true;
        thumb.backcolor.A = thumb.backcolor.A + 0.2;
        thumb:SetBackColor(thumb.backcolor);
    end

    -- hover effect
    function thumb:MouseLeave()
        if (thumb.mouseDown) then
            return;
        end

        if (not thumb.hover) then
            return;
        end

        thumb.hover = false;
        thumb.backcolor.A = thumb.backcolor.A - 0.2;
        thumb:SetBackColor(thumb.backcolor);
    end

    --------------------------------------------------------------
    -- Scrollbar
    --------------------------------------------------------------

    -- max is same as outer scroll range
    function scrollbar:SetMaximum(value)
        -- Note: we have no min value (unsupported)
        scrollbar.max = math.max(0, value);
        update_thumb_size();
    end

    function scrollbar:SetOrientation(value)
        if (value == Turbine.UI.Orientation.Horizontal) then
            scrollbar.orientation = Turbine.UI.Orientation.Horizontal;
        else
            scrollbar.orientation = Turbine.UI.Orientation.Vertical;
        end
    end

    function scrollbar:SizeChanged()
        update_thumb_size();
        scrollbar:SetValue(scrollbar.value);
    end

    -- Note: param value is floating point
    function scrollbar:SetValue(value)
        local max = scrollbar.max;

        value = math.max(0,   value);
        value = math.min(max, value);

        local offset = 0;

        if (max > 0) then
            local range = 0;

            if (is_vert()) then
                range = scrollbar:GetHeight() - thumb:GetHeight();
            else
                range = scrollbar:GetWidth()  - thumb:GetWidth();
            end

            offset = value * range / max;
        end

        if (is_vert()) then
            thumb:SetTop(offset);
        else
            thumb:SetLeft(offset);
        end

        -- to integer
        value = math.round(value);

        if (scrollbar.value ~= value) then
            scrollbar.value = value;
            callback.raise(scrollbar, "ValueChanged");
        end
    end

    -- scroll with wheel
    function scrollbar:MouseWheel(args)
        if (not args) then
            return;
        end

        -- Direction
        --  down: -1
        --  up  :  1
        --
        -- TODO: virtual units?
        scrollbar:SetValue(scrollbar.value - (args.Direction * scrollbar.largeChange));
    end

    -- jump to mouse
    function scrollbar:MouseDown()
        local mouseX, mouseY = scrollbar:PointToClient(
            Turbine.UI.Display.GetMouseX(),
            Turbine.UI.Display.GetMouseY()
        );

        local range  = 0;
        local offset = 0;

        if (is_vert()) then
            range  = scrollbar:GetHeight() - thumb:GetHeight();
            offset = mouseY - thumb:GetHeight() / 2;
        else
            range  = scrollbar:GetWidth()  - thumb:GetWidth();
            offset = mouseX - thumb:GetWidth() / 2;
        end

        if (not (range > 0)) then
            scrollbar:SetValue(0);
            return;
        end

        local value = offset * scrollbar.max / range;
        scrollbar:SetValue(value);
    end

    -- hover effect
    function scrollbar:MouseEnter()
        -- redirect
        thumb:MouseEnter();
    end

    -- hover effect
    function scrollbar:MouseLeave()
        -- redirect
        thumb:MouseLeave();
    end

    return scrollbar;
end
