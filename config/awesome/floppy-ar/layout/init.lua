local awful = require("awful")
local left_panel = require("layout.left-panel")
local top_panel = require("layout.top-panel")
local right_panel = require("layout.right-panel")

-- Create a wibox panel for each screen and add it
screen.connect_signal(
	"request::desktop_decoration",
	function(s)
		-- awful.spawn(string.format("notify-send %s", tostring()))
		if s.index == 1 then
			s.left_panel = left_panel(s)
			s.top_panel = top_panel(s, true)
		else
			s.top_panel = top_panel(s, false)
		end
		s.right_panel = right_panel(s)
		s.right_panel_show_again = false
	end
)

function check_panal(s)
	if s.left_panel == nil then
		s.left_panel = left_panel(s)
	end
	if s.top_panel == nil then
		s.top_panel = top_panel(s, true)
	end

	if s.right_panel == nil then
		s.right_panel = right_panel(s)
	end

	if s.right_panel_show_again == nil then
		s.right_panel_show_again = false
	end
end

-- Hide bars when app go fullscreen
function update_bars_visibility()
	for s in screen do
		if s.selected_tag then
			
			check_panal(s)

			local fullscreen = s.selected_tag.fullscreen_mode
			-- Order matter here for shadow
			s.top_panel.visible = not fullscreen
			if s.left_panel then
				s.left_panel.visible = true
			end
			
			if s.right_panel then
				if fullscreen and s.right_panel.visible then
					s.right_panel:toggle()
					s.right_panel_show_again = true
				elseif not fullscreen and not s.right_panel.visible and s.right_panel_show_again then
					s.right_panel:toggle()
					s.right_panel_show_again = false
				end
			end

			s.left_panel.visible = not fullscreen
		end
	end
end

tag.connect_signal(
	"property::selected",
	function(t)
		update_bars_visibility()
	end
)

client.connect_signal(
	"property::fullscreen",
	function(c)
		if c.first_tag then
			c.first_tag.fullscreen_mode = c.fullscreen
		end
		update_bars_visibility()
	end
)

client.connect_signal(
	"unmanage",
	function(c)
		if c.fullscreen then
			c.screen.selected_tag.fullscreen_mode = false
			update_bars_visibility()
		end
	end
)
