local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utilities/"

return {
	-- The default applications that we will use in keybindings and widgets
	default = {
		-- Default terminal emulator
		terminal = "konsole",
		-- Default web browser
		web_browser = "firefox",
		-- Default text editor
		text_editor = "code",
		-- Default file manager
		file_manager = "dolphin",
		-- Default media player
		multimedia = "clementine",
		-- Default game, can be a launcher like steam
		game = "supertuxkart",
		-- Default graphics editor
		graphics = "gimp-2.10",
		-- Default sandbox
		social = "telegram-desktop",
		-- Default IDE
		development = "prime-run studio",
		-- Default network manager
		network_manager = "konsole -e nmtui-connect",
		-- Default bluetooth manager
		bluetooth_manager = "blueman-manager",
		-- Default power manager
		power_manager = "xfce4-power-manager",
		-- Default GUI package manager
		package_manager = "pacman",
		-- Default locker
		lock = 'awesome-client "awesome.emit_signal(\'module::lockscreen_show\')"',
		-- Default quake terminal
		quake = "konsole --name QuakeTerminal",
		-- Default rofi global menu
		rofi_global = "rofi -dpi " ..
			screen.primary.dpi ..
				' -show "Global Search" -modi "Global Search":' ..
					config_dir ..
						"/configuration/rofi/global/rofi-spotlight.sh" ..
							" -theme " .. config_dir .. "/configuration/rofi/global/rofi.rasi",
		-- Default app menu
		rofi_appmenu = "rofi -dpi " ..
			screen.primary.dpi .. " -show drun -theme " .. config_dir .. "/configuration/rofi/appmenu/rofi.rasi"

		-- You can add more default applications here
	},
	-- List of apps to start once on start-up
	run_on_start_up = {
		"nm-applet -sm-disable",
		"blueman-applet",
		"xrandr --output eDP-1",
		"xfce4-power-manager",
		[[
		xidlehook --not-when-fullscreen --not-when-audio --timer 600 \
		"awesome-client 'awesome.emit_signal(\"module::lockscreen_show\")'" ""
		]],
		'setxkbmap -layout "us,ar" -option "grp:win_space_toggle"',
		"/usr/lib/polkit-kde-authentication-agent-1",
		"xrandr --output HDMI-1-0 --mode 1440x900 --rate 61 --noprimary --left-of eDP-1",
		"picom -b --experimental-backends --dbus --config " .. config_dir .. "/configuration/picom.conf"
	},
	-- List of binaries/shell scripts that will execute for a certain task
	utils = {
		-- Fullscreen screenshot
		full_screenshot = utils_dir .. "snap full",
		-- Area screenshot
		area_screenshot = utils_dir .. "snap area",
		-- Update profile picture
		update_profile = utils_dir .. "profile-image"
	}
}
