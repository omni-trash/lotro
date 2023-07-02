--[[
    Callback Events
]]

-- global shared events
events   = events   or {};
callback = callback or {};

-- target registrations
local scope = scope or {};

-- prevent recursion
local checker = {};

local function ensure_scope_and_checker(target)
    -- ensure target scope and checker entry
    scope[target]   = scope[target]   or {};
    checker[target] = checker[target] or {};
end

-- callback.add(target, "EventName", function(sender) end);
function callback.add(target, event, callback)
    ensure_scope_and_checker(target);

    -- create event registration for target scope
    scope[target][event] = scope[target][event] or {};

    -- add callback to target event
    table.insert(scope[target][event], callback);
end

-- callback.raise(target, "EventName")
function callback.raise(target, event)
    ensure_scope_and_checker(target);

    -- check event is in progress for that target
    if (checker[target][event]) then
        return;
    end

    -- reserve
    checker[target][event] = true;

    -- callbacks
    local handlers = scope[target][event] or {};

    for _, handler in ipairs(handlers) do
        handler(target);
    end

    -- release
    checker[target][event] = false;
end
