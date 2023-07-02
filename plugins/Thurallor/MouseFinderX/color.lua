--[[
    Color Utils
    see Thurallor/Utils/ Color_1.lua
]]
color = color or {};

-- convert from RGB to HSV
function color.rgb2hsv(R, G, B)
    local H, S, V = 0, 0, 0;

    local rgb_min = math.min(R, G, B);
    local rgb_max = math.max(R, G, B);

    V = rgb_max;

    if (V == 0) then
        return H, S, V;
    end
    
    R = R / V;
    G = G / V;
    B = B / V;

    rgb_min = math.min(R, G, B);
    rgb_max = math.max(R, G, B);

    S = rgb_max - rgb_min;

    if (S == 0) then
        return H, S, V;
    end

    R = (R - rgb_min) / S;
    G = (G - rgb_min) / S;
    B = (B - rgb_min) / S;

    rgb_min = math.min(R, G, B);
    rgb_max = math.max(R, G, B);

    if (rgb_max == R) then
        H = 0.0 + 60 * (G - B);

        if (H < 0) then
            H = H + 360;
        end
    elseif (rgb_max == G) then
        H = 120 + 60 * (B - R);
    else -- rgb_max == B
        H = 240 + 60 * (R - G);
    end
    
    return H / 360, S, V;
end

-- convert from HSV to RGB
function color.hsv2rgb(H, S, V)
    local i, f, p, q, t;

	if (S == 0) then
		return V, V, V;
	end

    H = H % 1;
    H = H * 360 / 60;
    i = math.floor(H);
    f = H - i;
    p = V * (1 - S);
    q = V * (1 - S * f);
    t = V * (1 - S * (1 - f));

    if (i == 0) then
        return V, t, p;
    elseif (i == 1) then
        return q, V, p;
    elseif (i == 2) then
        return p, V, t;
    elseif (i == 3) then
        return  p, q, V;
    elseif (i == 4) then
        return t, p, V;
    else -- (i == 5)
        return V, p, q;
    end    
end