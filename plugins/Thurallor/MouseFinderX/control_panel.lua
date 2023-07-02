--[[ 
    Control UI Factory - Panel

    The panel control can be used with layout and have builtin scrollbars.
    The panel holds a content control, which will be layouted (see layout.lua).
    The scrollbars are showing when the content size is larger the panel size.

    requires: 
    - control.lua
    - scrollbar.lua
]]

-- create panel
function control.panel()
    -- use listbox to have mouse wheel events
    local panel = Turbine.UI.ListBox();
    panel.type  = "PANEL";

    -- layout container
    local content = control.control();
    content:SetParent(panel);

    local hscroll = control.scrollbar();
    hscroll:SetParent(panel);
    hscroll:SetOrientation(Turbine.UI.Orientation.Horizontal);

    local vscroll = control.scrollbar();
    vscroll:SetParent(panel);
    vscroll:SetOrientation(Turbine.UI.Orientation.Vertical);

    -- set scrollbar position and size
    -- (see layout.update)
    local function update_scrollbars()
        local w_pan, h_pan = panel:GetSize();
        local w_con, h_con = content:GetSize();

        local w_diff = w_con - w_pan + (vscroll:IsVisible() and vscroll:GetWidth()  or 0);
        local h_diff = h_con - h_pan + (hscroll:IsVisible() and hscroll:GetHeight() or 0);

        if (hscroll:IsVisible()) then
            hscroll:SetMaximum(w_diff);
            hscroll:SetPosition(0, h_pan - hscroll:GetHeight());
            hscroll:SetWidth(w_pan - (vscroll:IsVisible() and vscroll:GetWidth() or 0));
        else
            hscroll:SetValue(0);
        end

        if (vscroll:IsVisible()) then
            vscroll:SetMaximum(h_diff);
            vscroll:SetPosition(w_pan - vscroll:GetWidth(), 0);
            vscroll:SetHeight(h_pan);
        else
            vscroll:SetValue(0);
        end
    end

    -- update panel layout
    -- (see layout.update)
    function panel:SizeChanged()
        layout.update(panel);
        update_scrollbars();
    end

    function panel:MouseWheel(args)
        if (vscroll:IsVisible()) then
            -- redirect
            vscroll:MouseWheel(args);
            return;
        end

        if (hscroll:IsVisible()) then
            -- redirect
            hscroll:MouseWheel(args);
            return;
        end

        -- redirect to parent
        local parent = panel:GetParent();

        if (parent and parent.MouseWheel) then
            parent:MouseWheel(args);
        end
    end

    callback.add(hscroll, "ValueChanged", function(sender)
        content:SetLeft(0 - sender.value);
    end);

    callback.add(vscroll, "ValueChanged", function(sender)
        content:SetTop(0 - sender.value);
    end);

    -- used in layout_apply
    panel.content = content;
    panel.vscroll = vscroll;
    panel.hscroll = hscroll;

    return panel;
end
