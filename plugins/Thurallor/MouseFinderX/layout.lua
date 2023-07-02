--[[
    Simple Grid Layout Engine
]]
layout = layout or {};

-- ensure values
local function layout_fillout(layout)
    layout.min_w  = layout.min_w  or 0;
    layout.max_w  = layout.max_w  or 1000;
    layout.min_h  = layout.min_h  or 0;
    layout.max_h  = layout.max_h  or 1000;
    layout.grid   = layout.grid   or {};
    layout.coldef = layout.coldef or {};
    layout.rowdef = layout.rowdef or {};
    layout.style  = layout.style  or {};
end

-- needed only for padding and sub-panels (for now)
local function layout_compile_style(style)
    local compiled = {};

    compiled.padding_left   = style["padding-left"]   or 0;
    compiled.padding_top    = style["padding-top"]    or 0;
    compiled.padding_right  = style["padding-right"]  or 0;
    compiled.padding_bottom = style["padding-bottom"] or 0;
    compiled.padding_width  = compiled.padding_left + compiled.padding_right;
    compiled.padding_height = compiled.padding_top  + compiled.padding_bottom;

    return compiled;
end

--[[
       1 2 3 4 5 6
     +------------ x
    1| h h h h h h
    2| m m c c c c
    3| m m c c c c
    4| m m c c c c
    5| f f f f f f
     y

    the position of area "m" in the grid is:

    top left
    x1 = 1, y1 = 2

    bottom right
    x2 = 2, y2 = 4
]]

-- determine areas in grid and they position.
-- calc fixed static space and dynamic space
-- to use for each area in grid.
local function layout_compile(layout)
    local grid     = layout.grid;
    local width    = 0;
    local height   = 0;
    local areas    = {};
    local compiled = {};

    --------------------------------------------------
    -- Get the position for each area in grid
    --------------------------------------------------

    -- recommended access order for positioning
    local sorted_keys = {};

    -- note: lua libs starts at index 1
    for i, line in ipairs(grid) do
        local x = 1;
        local y = i;

        -- grid size
        width  = math.max(width, #line);
        height = height + 1;

        -- for each char in line
        for c in string.gmatch(line, ".") do
            local area = areas[c];

            -- new entry
            if (not area) then
                table.insert(sorted_keys, c);

                area = {
                    x1 = x, x2 = x,
                    y1 = y, y2 = y
                };

                areas[c] = area;
            end

            -- shrink or grow
            area.x1 = math.min(area.x1, x);
            area.x2 = math.max(area.x2, x);
            area.y2 = math.max(area.y2, y);

            x = x + 1;
        end 
    end

    --------------------------------------------------
    -- Calculate fixed static space and dynamic space
    -- for each row and col
    --------------------------------------------------

    -- sum of fixed static space
    local x_offset = {};
    local y_offset = {};

    -- no offset at 1/1
    x_offset[1] = 0;
    y_offset[1] = 0;

    -- count of dynamic space
    local x_factor = {};
    local y_factor = {};

    -- no dynamic space at 1/1
    x_factor[1] = 0;
    y_factor[1] = 0;

    -- sum of static space
    local xo = 0;
    local yo = 0;

    -- num of fixed rows and cols
    local fixcols = 0;
    local fixrows = 0;

    -- calc over cols
    local coldef = layout.coldef;

    for x=1,width do
        -- width of col
        coldef[x] = coldef[x] or -1;

        -- is fixed width
        if (coldef[x] > 0) then
            xo = xo + coldef[x];
            fixcols = fixcols + 1;
        end

        -- for next col
        x_offset[x + 1] = xo;
        x_factor[x + 1] = x - fixcols;
    end

    -- calc over rows
    local rowdef = layout.rowdef;

    for y=1,height do
        -- height of row
        rowdef[y] = rowdef[y] or -1;

        -- is fixed height
        if (rowdef[y] > 0) then
            yo = yo + rowdef[y];
            fixrows = fixrows + 1;
        end

        -- for next row
        y_offset[y + 1] = yo;
        y_factor[y + 1] = y - fixrows;
    end

    -- fixed static parts
    compiled.y_offset = y_offset;
    compiled.x_offset = x_offset;

    -- dynamic parts
    compiled.x_factor = x_factor;
    compiled.y_factor = y_factor;

    -- at last index we should have the sum of all
    compiled.w_reserved = x_offset[#x_offset] or 0;
    compiled.h_reserved = y_offset[#y_offset] or 0;

    --------------------------------------------------
    -- Calculate fixed static space and dynamic space
    -- for each area we have.
    --
    -- Save them in the box prop, so we can use that
    -- values for positioning.
    --------------------------------------------------

    -- available dynamic space
    local dyn_w = width  - fixcols;
    local dyn_h = height - fixrows;

    -- dynamic space per cell
    local fx = (dyn_w > 0) and (1 / dyn_w) or 0;
    local fy = (dyn_h > 0) and (1 / dyn_h) or 0;

    -- calc offset and factor for each area box
    -- we can use for positioning.
    for name, area in pairs(areas) do
        area.box = {
            x1 = {
                offset = x_offset[area.x1],
                factor = x_factor[area.x1] * fx,
            },
            x2 = {
                offset = x_offset[area.x2 + 1],
                factor = x_factor[area.x2 + 1] * fx,
            },
            y1 = {
                offset = y_offset[area.y1],
                factor = y_factor[area.y1] * fy,
            },
            y2 = {
                offset = y_offset[area.y2 + 1],
                factor = y_factor[area.y2 + 1] * fy,
            },
        };
    end

    compiled.areas    = areas;
    compiled.keyorder = sorted_keys;
    compiled.style    = layout_compile_style(layout.style);
    layout.compiled   = compiled;
end

-- mouse wheel event bubble
local function mouse_wheel_bubble(self, args)
    local parent = self:GetParent();

    if (parent and parent.MouseWheel) then
        parent:MouseWheel(args);
    end
end

-- set the position and size for all controls in panel.layout.areas,
-- use the panel.layout.compiled.areas[area].box prop for that.
local function layout_apply(panel)
    local compiled = panel.layout.compiled;
    local content  = panel.content;

    -- available space
    local width, height = panel:GetSize();

    -- min max
    width  = math.min(panel.layout.max_w, math.max(panel.layout.min_w, width));
    height = math.min(panel.layout.max_h, math.max(panel.layout.min_h, height));

    -----------------------------------------------------------------
    -- ScrollBars
    -----------------------------------------------------------------

    -- parking to prevent interference
    local w_con = width;
    local h_con = height;

    local w_vscroll = panel.vscroll:GetWidth();
    local h_hscroll = panel.hscroll:GetHeight();

    panel.hscroll:SetVisible(false);
    panel.vscroll:SetVisible(false);

    -- need vscroll
    if (panel:GetHeight() < height) then
        panel.vscroll:SetVisible(true);

        if (w_con + w_vscroll >= panel:GetWidth()) then
            w_con = math.max(panel.layout.min_w, panel:GetWidth() - w_vscroll);
        end
    end

    -- need hscroll
    if (panel:GetWidth() < width) then
        panel.hscroll:SetVisible(true);

        if (h_con + h_hscroll >= panel:GetHeight()) then
            h_con = math.max(panel.layout.min_h, panel:GetHeight() - h_hscroll);
        end
    end

    -- parking to prevent interference
    local hscroll_visible = panel.hscroll:IsVisible();
    local vscroll_visible = panel.vscroll:IsVisible();

    -- need vscroll
    if (hscroll_visible) then
        if (h_con > panel:GetHeight() - h_hscroll) then
            panel.vscroll:SetVisible(true);
        end
    end

    -- need hscroll
    if (vscroll_visible) then
        if (w_con > panel:GetWidth() - w_vscroll) then
            panel.hscroll:SetVisible(true);
        end
    end

    width  = w_con;
    height = h_con;
    -----------------------------------------------------------------

    -- apply to content (not panel himself) to force min/max size
    content:SetSize(width, height);

    -- when in listbox (see options.lua)
    --panel:SetSize(width, height);

    -- mouse wheel support
    content.MouseWheel = content.MouseWheel or mouse_wheel_bubble;

    -- fix
    local dyn_w = width;
    local dyn_h = height;

    dyn_w = dyn_w - compiled.style.padding_width;
    dyn_h = dyn_h - compiled.style.padding_width;

    dyn_w = dyn_w - compiled.w_reserved;
    dyn_h = dyn_h - compiled.h_reserved;

    dyn_w = math.max(0, dyn_w);
    dyn_h = math.max(0, dyn_h);

    -- draw order (got that hint from ChatGPT)
    for _, k in ipairs(compiled.keyorder) do
        local ctls = panel.layout.areas[k];
        local area = compiled.areas[k];

        if (ctls and area) then
            -- array expected, but it is a single control
            if (ctls.SetParent) then
                ctls = {ctls};
            end

            for _, ctl in ipairs(ctls) do
                -- ensure parent
                ctl:SetParent(content);

                -- mouse wheel support
                ctl.MouseWheel = ctl.MouseWheel or mouse_wheel_bubble;

                local x1 = area.box.x1.offset + area.box.x1.factor * dyn_w;
                local x2 = area.box.x2.offset + area.box.x2.factor * dyn_w;
                local y1 = area.box.y1.offset + area.box.y1.factor * dyn_h;
                local y2 = area.box.y2.offset + area.box.y2.factor * dyn_h;

                local x = x1;
                local y = y1;
                local w = x2 - x1;
                local h = y2 - y1;

                ctl:SetPosition(
                    compiled.style.padding_left + x,
                    compiled.style.padding_top  + y
                );

                if (ctl.type == "SLIDER") then
                    -- dont set both dimensions on scrollbar
                    if (ctl:GetOrientation() == Turbine.UI.Orientation.Horizontal) then
                        ctl:SetSize(w, 10);
                    else
                        ctl:SetSize(10, h);
                    end
                elseif (ctl.type == "HR") then
                    -- dont set height on horizontal rule
                    ctl:SetWidth(w);
                    ctl:SetPosition(
                        compiled.style.padding_left + x,
                        compiled.style.padding_top  + y + (h - ctl:GetHeight()) / 2
                    );
                else
                    -- set dimension
                    ctl:SetSize(w, h);
                end
            end
        end
    end
end

-- set panel controls position and size, defined in grid layout.
function layout.update(panel, layout, w, h)
    if (panel.type ~= "PANEL") then
        terminal.write("must be a panel");
        return;
    end

    if (not panel.layout) then
        terminal.write("panel has no layout");
        return;
    end

    if (not panel.layout.compiled) then
        layout_fillout(panel.layout);
        layout_compile(panel.layout);
    end

    layout_apply(panel);
end
