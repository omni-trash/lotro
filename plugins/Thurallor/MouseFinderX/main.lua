--[[ 
    Main Window
    Shows the mouse finder on screen
]]

-- "Thurallor.MouseFinderX.main"
local file     = getfenv(1)._.Name;
-- "Thurallor.MouseFinderX"
local path     = string.gsub(file, "%.[^%.]+$", "");
-- "Thurallor/MouseFinderX"
local assets   = string.gsub(path, "%.", "/");
-- "Thurallor/MouseFinderX/assets/mouse_finder.tga"
local mousepic = assets.."/assets/mouse_finder.tga";

terminal.write("<rgb=#DAA520>{Name} v{Version} by {Author}</rgb>", {
    Name    = plugin:GetName(),
    Author  = plugin:GetAuthor(), 
    Version = plugin:GetVersion()
});

player = Turbine.Gameplay.LocalPlayer:GetInstance();
win    = Turbine.UI.Window();

--win:SetSize(480, 480);
win:SetVisible(true);
win:SetBackground(mousepic);
-- Color is faster but we can't set V value (HSV)
--win:SetBackColorBlendMode(Turbine.UI.BlendMode.Color);
win:SetBackColorBlendMode(Turbine.UI.BlendMode.Multiply);
win:SetMouseVisible(false);
win:SetZOrder(2147483647);
-- works for .tga files only
win:SetStretchMode(2);
win:SetWantsUpdates(true);
win:SetVisible(false);

win.nativeWidth, win.nativeHeight = win:GetSize();
win.x, win.y    = Turbine.UI.Display:GetMousePosition();
win.w, win.h    = win:GetSize();
win.rotateAngle = 0;
win.hueAngle    = 0;
win.fadeOutEnd  = 0;
win.backColor   = Turbine.UI.Color.White;

-- half screen size
local halfScreenW = Turbine.UI.Display:GetWidth()  / 2;
local halfScreenH = Turbine.UI.Display:GetHeight() / 2;

-- FPS (experimental, no performance benefit)
local fps  = 1 / 30;
local draw = 0;

callback.add(events, "SettingsChanged", function()
    -- scale size
    win.w = settings.scale * win.nativeWidth;
    win.h = settings.scale * win.nativeHeight;

    -- half size
    win.halfW = win.w / 2;
    win.halfH = win.h / 2;

    win:SetSize(win.w, win.h);

    if (not settings.cycleColors) then
        win:SetBackColor(Turbine.UI.Color(
            settings.color.R,
            settings.color.G,
            settings.color.B
        ));
    end

    win:SetOpacity(settings.opacity);

    fps = 1 / math.max(1, settings.fpsLimit);
end);

function win:Update(args)
    local timestamp = Turbine.Engine.GetGameTime();
    local x, y      = Turbine.UI.Display:GetMousePosition();
    local moved     = ((self.x ~= x) or (self.y ~= y));
    local dx        = math.abs((self.x or 0) - x);
    local dy        = math.abs((self.y or 0) - y);
    self.x, self.y  = x, y;

    -- Sometimes GetMousePosition is wrong
    -- and the mouse finder jumps to center of screen
    -- and then next update jumps back to current position.
    -- To reduce that "jumps" we do check:
    --    * is new mouse position near center (cx, cy)
    --    * is mouse move long distance (dx, dy)
    --
    -- Most time when right mouse button is released and 
    -- Lotro is loading some resources like sound or NPC's.
    local cx = math.abs(halfScreenW - x);
    local cy = math.abs(halfScreenH - y);

    -- mouse move near center
    if (moved and cx < 20 and cy < 20) then
        -- mouse move long distance
        if (dx > 50 or dy > 50) then
            -- skip that frame
            return;
        end
    end

    if (player:IsInCombat()) then
        self.fadeOutEnd = timestamp + settings.persistTime;
    elseif (moved and not settings.showOnlyInCombat) then
        self.fadeOutEnd = timestamp + settings.persistTime;
    end

    local visible = self.fadeOutEnd > timestamp;

    self:SetPosition(self.x - self.halfW, self.y - self.halfH);
    self:SetVisible(visible);

    if (visible) then
        -- FPS Limit, so we have constant rotation and cycle colors,
        -- otherwise we have the system FPS for each draw cycle.
        if (draw > timestamp) then
            return;
        else
            draw = draw + fps;
        end

        -- rotation
        if (settings.speed > 0) then
            self.rotateAngle = (self.rotateAngle + settings.speed) % 360;
            self:SetRotation({x = 0; y = 0; z = self.rotateAngle});
        end

        -- color
        if (settings.cycleColors) then
            self.hueAngle = (self.hueAngle + settings.colorCycleSpeed) % 360;
            local R, G, B = color.hsv2rgb(self.hueAngle / 360, settings.hsv.S, settings.hsv.V);

            self.backColor.R = R;
            self.backColor.G = G;
            self.backColor.B = B;

            self:SetBackColor(self.backColor);
        end
    else
        draw = timestamp;
    end
end
