#!/usr/bin/env wpexec

--[[
  This script monitors changes in WirePlumber to the default source and sink.
  This allows us to detect whenever the volume is updated or when a sink/source
  is muted/umuted without polling. Whenever a change is detected, we output a
  JSON object which represents the current state.
--]]

-- This function is just a very rudimentary conversion from lua tables to a
-- JSON object.
local function jsonify(t)
    local output = {};
    for key, val in pairs(t) do
        if type(val) == "table" then
            table.insert(output, string.format('"%s": %s', key, jsonify(val)));
        elseif type(val) == "number" then
            table.insert(output, string.format('"%s": %s', key, val));
        else
            table.insert(output, string.format('"%s": "%s"', key, val));
        end
    end
    return '{' .. table.concat(output, ',') .. '}'
end

-- This function is just a helper for extracting the information we want fro m
-- the get-volume call.
local function extract_volume(vol)
    return {
            muted  = vol.mute,
            volume = vol.volume,
    }
end

Core.require_api('default-nodes', 'mixer', function (...)
    local default_nodes, mixer = ...;
    mixer.scale = 'cubic'

    -- Output the initial value. We only look for the default source and sink
    -- nodes.
    local snk_id = default_nodes:call('get-default-node', 'Audio/Sink');
    local src_id = default_nodes:call('get-default-node', 'Audio/Source');
    local info = {
        sink = extract_volume(mixer:call('get-volume', snk_id)),
        source = extract_volume(mixer:call('get-volume', src_id)),
    }

    print(jsonify(info));

    -- Watch for changes to the default nodes
    mixer:connect('changed', function (proxy, id)
        -- This seems somewhat silly as we already have the ids.
        -- But maybe they change? Just fetc them again.
        snk_id = default_nodes:call('get-default-node', 'Audio/Sink');
        src_id = default_nodes:call('get-default-node', 'Audio/Source');
        if snk_id == id or src_id == id then
            -- Fetch any new values which might have changes.
            --
            -- TODO: If the source changed we don't need to update the sink
            --       and vice-versa.
            info.sink = extract_volume(proxy:call('get-volume', snk_id));
            info.source = extract_volume(proxy:call('get-volume', src_id));
            print(jsonify(info))
        end
    end)
end)
