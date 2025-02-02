-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local awful = require('awful')
local naughty = require('naughty')
local apps = require('configuration.apps')
local config = require('configuration.config')
-- local debug_mode = config.module.auto_start.debug_mode or false
local debug_mode = true

local run_once = function(cmd)
    local findme = cmd
    local firstspace = cmd:find(' ')
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end
    awful.spawn.easy_async_with_shell(
        string.format('pgrep -u $USER -x %s > /dev/null || (%s)', findme, cmd),
        function(stdout, stderr)
            -- Debugger 
            if not stderr or stderr == '' or not debug_mode then
                return 
            end
            naughty.notification({
                app_name = 'بدء تشغيل البرامج',
                title = '<b>عذرا! حدث خطأ اثناء بدء تشغيل البرنامج!</b>',
                message = stderr:gsub('%\n', ''),
                timeout = 20,
                icon = require('beautiful').awesome_icon
            })
        end
    )
end

for _, app in ipairs(apps.run_on_start_up) do
    run_once(app)
end
