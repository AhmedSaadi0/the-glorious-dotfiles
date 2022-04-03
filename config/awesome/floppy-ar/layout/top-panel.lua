local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local icons = require("theme.icons")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("widget.clickable-container")
local task_list = require("widget.task-list")

local top_panel = function(s, offset)
	local offsetx = 0
	if offset == true then
		offsetx = dpi(45)
	end

	local panel =
		wibox {
		ontop = true,
		screen = s,
		type = "dock",
		height = dpi(30),
		width = s.geometry.width - offsetx,
		x = s.geometry.x,
		y = s.geometry.y,
		stretch = false,
		bg = beautiful.background,
		fg = beautiful.fg_normal
	}

	panel:struts {
		top = dpi(28)
	}

	panel:connect_signal(
		"mouse::enter",
		function()
			local w = mouse.current_wibox
			if w then
				w.cursor = "left_ptr"
			end
		end
	)

	s.systray =
		wibox.widget {
		visible = true,
		base_size = dpi(20),
		horizontal = true,
		screen = "primary",
		widget = wibox.widget.systray
	}

	local clock = require("widget.clock")(s)
	local layout_box = require("widget.layoutbox")(s)
	local add_button = require("widget.open-default-app")(s)
	s.tray_toggler = require("widget.tray-toggle")
	s.info_center_toggle = require("widget.info-center-toggle")()
	s.cpu = require("widget.cpu")({
		width = 70,
		step_width = 2,
		step_spacing = 0,
		color = '#434c5e'
	})
	s.ns = require("widget.net-speed-widget")()
	s.ram = require("widget.ram-widget")()
	s.mpd = require("widget.mpd")()
	s.volume_cr = require("widget.volumearc-widget")()
	s.volume_bar = require("widget.volumebar-widget")()
	s.brightness_cr = require("widget.brightness-widget")()
	s.temp = require("widget.temp")()
	s.bat = require("widget.battery")()

	panel:setup {
		{
			s.info_center_toggle,
			layout_box,
			
			{
				s.systray,
				margins = dpi(5),
				widget = wibox.container.margin
			},
			
			layout = wibox.layout.fixed.horizontal,
			s.bat,
			s.ram,
			s.cpu,
			s.ns,
			
			-- s.brightness_cr,
			-- s.volume_cr,
			
		},
		clock,

		{
			layout = wibox.layout.fixed.horizontal,
			task_list(s),
			add_button
		},

		expand = "none",
		layout = wibox.layout.align.horizontal

	}

	return panel
end

return top_panel
