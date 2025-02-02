local awful = require('awful')
local beautiful = require('beautiful')

require('awful.autofocus')

local hotkeys_popup = require('awful.hotkeys_popup').widget

local modkey = require('configuration.keys.mod').mod_key
local altkey = require('configuration.keys.mod').alt_key
local apps = require('configuration.apps')

-- Key bindings
local global_keys = awful.util.table.join(
	awful.key(
		{modkey},
		"s",
		hotkeys_popup.show_help,
		{
			description = "عرض المساعدة", group = "اوسم"
		}
	),
	awful.key(
		{modkey}, 
		"Escape", 
		awful.tag.history.restore, 
		{
			description = "التنقل بين اخر مكانين", group = "تاق"
		}
	),
	awful.key(
		{modkey},
		"Right",
		function()
			awful.client.focus.byidx(1)
		end,
		{description = "التركيز على السابق بالفهرس", group = "عميل"}
	),
	awful.key(
		{modkey},
		"Left",
		function()
			awful.client.focus.byidx(-1)
		end,
		{description = "التركيز على التالي بالفهرس", group = "عميل"}
	),
	awful.key(
		{modkey},
		"w",
		function()
			mymainmenu:show()
		end,
		{
			description = "عرض القائمة الرئيسية",
			group = "اوسم"
		}
	), 
	awful.key(
		{ },
		'Print',
		function ()
			awful.spawn.easy_async_with_shell(apps.utils.full_screenshot,function() end)
		end,
		{description = 'لقطة كاملة للشاشة', group = 'ادوات'}
	),
	awful.key(
		{modkey},
		't',
		function()
			awesome.emit_signal('widget::blue_light:toggle')
		end,
		{description = 'تغيير وضع القراءة', group = 'ادوات'}
	),
	awful.key(
		{modkey},
		'x',
		function()
			awesome.spawn('xcolor -s')
		end,
		{description = 'اخذ لون من الشاشة', group = 'ادوات'}
	),
	awful.key(
		{modkey},
		'l',
		function()
			awful.spawn(apps.default.lock, false)
		end,
		{description = 'اقفل الشاشة', group = 'ادوات'}
	),
	awful.key(
		{modkey},
		'e',
		function()
			local focused = awful.screen.focused()

			if focused.left_panel then
				focused.left_panel:hide_dashboard()
				focused.left_panel.opened = false
			end
			if focused.right_panel then
				focused.right_panel:hide_dashboard()
				focused.right_panel.opened = false
			end
			awful.spawn(apps.default.rofi_appmenu, false)
		end,
		{description = 'فتح درج التطبيقات', group = 'المشغل'}
	),
	-----------------------------------------------------
	-- ROFI MENUS
	-----------------------------------------------------
	-- Right menu
	awful.key(
		{modkey},
		'r',
		function()
			local focused = awful.screen.focused()
			
			if focused.right_panel and focused.right_panel.visible then
				focused.right_panel.visible = false
			end
			screen.primary.left_panel:toggle()
		end,
		{description = 'فتح الشريط الجانبي', group = 'المشغل'}
	),
	awful.key(
		{modkey, 'Shift'},
		'r',
		function()
			local focused = awful.screen.focused()
			
			if focused.right_panel and focused.right_panel.visible then
				focused.right_panel.visible = false
			end
			screen.primary.left_panel:toggle(true)
		end,
		{description = 'فتح البحث في الشريط الجانبي', group = 'المشغل'}
	),
	
	-- Notification menus
	awful.key(
		{modkey},
		'F2',
		function()
			local focused = awful.screen.focused()

			if focused.left_panel and focused.left_panel.opened then
				focused.left_panel:toggle()
			end

			if focused.right_panel then
				if _G.right_panel_mode == 'today_mode' or not focused.right_panel.visible then
					focused.right_panel:toggle()
					switch_rdb_pane('today_mode')
				else
					switch_rdb_pane('today_mode')
				end

				_G.right_panel_mode = 'today_mode'
			end
		end,
		{description = 'فتح اشعارات اليوم', group = 'المشغل'}
	),
	awful.key(
		{modkey},
		'F3',
		function()
			local focused = awful.screen.focused()

			if focused.left_panel and focused.left_panel.opened then
				focused.left_panel:toggle()
			end

			if focused.right_panel then
				if _G.right_panel_mode == 'notif_mode' or not focused.right_panel.visible then
					focused.right_panel:toggle()
					switch_rdb_pane('notif_mode')
				else
					switch_rdb_pane('notif_mode')
				end

				_G.right_panel_mode = 'notif_mode'
			end
		end,
		{description = 'فتح مركز الاشعارات', group = 'المشغل'}
	),

	-- Applicatopn menu
	awful.key(
		{modkey},
		"e",
		function()
			awful.util.spawn("rofi -show drun")
		end,
		{description = "فتح قائمة روفي", group = "روفي"}
	),
	-- Power menu
	awful.key(
		{modkey, 'Shift'},
		"l",
		function()
			awful.util.spawn("rofi -show p -modi p:~/.config/rofi/rofi-power-menu -theme power-menu-theme")
		end,
		{description = "فتح قائمة الطاقة", group = "روفي"}
	), 
	
	-----------------------------------------------------
	-- Layout manipulation
	-----------------------------------------------------
	awful.key(
		{modkey, "Shift"},
		"Right",
		function()
			awful.client.swap.byidx(1)
		end,
		{description = "غير ترتيب النافذة مكان النافذة لليمين", group = "عميل"}
	),
	awful.key(
		{modkey, "Shift"},
		"Left",
		function()
			awful.client.swap.byidx(-1)
		end,
		{description = "غير ترتيب النافذة مكان النافذة لليسار", group = "عميل"}
	),
	awful.key(
		{modkey, "Control"},
		"Right",
		function()
			awful.screen.focus_relative(1)
		end,
		{description = "ركز على الشاشة التالية", group = "الشاشة"}
	),
	awful.key(
		{modkey, "Control"},
		"Left",
		function()
			awful.screen.focus_relative(-1)
		end,
		{description = "ركز على الشاشة السابقة", group = "الشاشة"}
	),
	awful.key(
		{modkey},
		"u",
		awful.client.urgent.jumpto,
		{
			description = "الانتقال الى العميل الطارئ",
			group = "عميل"
		}
	),
	awful.key(
		{modkey},
		"Tab",
		function()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = "عد للخلف", group = "عميل"}
	), 
	awful.key(
		{modkey, "Control"}, 
		"r", 
		awesome.restart, 
		{
			description = "اعد تشغيل اوسم", group = "اوسم"
		}
	),
	awful.key(
		{modkey, "Shift"},
		"q",
		awesome.quit,
		{
			description = "اخرج من اوسم",
			group = "اوسم"
		}
	),
	awful.key(
		{modkey, altkey},
		"Right",
		function()
			awful.tag.incmwfact(0.05)
		end,
		{description = "زيادة عامل العرض الرئيسي", group = "التخطيط"}
	),
	awful.key(
		{modkey, altkey},
		"Left",
		function()
			awful.tag.incmwfact(-0.05)
		end,
		{description = "تقليل عامل العرض الرئيسي", group = "التخطيط"}
	),
	-- awful.key(
	-- 	{modkey, altkey},
	-- 	"Left",
	-- 	function()
	-- 		awful.tag.incnmaster(1, nil, true)
	-- 	end,
	-- 	{description = "زيادة عدد الصفوف في اليسار", group = "التخطيط"}
	-- ),
	-- awful.key(
	-- 	{modkey, altkey},
	-- 	"Right",
	-- 	function()
	-- 		awful.tag.incnmaster(-1, nil, true)
	-- 	end,
	-- 	{description = "زيادة عدد الصفوف في اليمين", group = "التخطيط"}
	-- ),
	-- awful.key(
	-- 	{modkey, altkey},
	-- 	"Up",
	-- 	function()
	-- 		awful.tag.incncol(1, nil, true)
	-- 	end,
	-- 	{description = "زيادة عدد الاعمدة", group = "التخطيط"}
	-- ),
	-- awful.key(
	-- 	{modkey, altkey},
	-- 	"Down",
	-- 	function()
	-- 		awful.tag.incncol(-1, nil, true)
	-- 	end,
	-- 	{description = "تقليل عدد الاعمدة", group = "التخطيط"}
	-- ), 
	-- awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
	--           {description = "select next", group = "التخطيط"}),
	-- awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
	--           {description = "select previous", group = "التخطيط"}),
	awful.key(
		{modkey, "Control"},
		"n",
		function()
			local c = awful.client.restore()
			-- Focus restored client
			if c then
				c:emit_signal("request::activate", "key.unminimize", {raise = true})
			end
		end,
		{description = "استعادة المصغر", group = "عميل"}
	), 
	-- Prompt
	-- awful.key(
	-- 	{modkey},
	-- 	"x",
	-- 	function()
	-- 		awful.prompt.run {
	-- 			prompt = "Run Lua code: ",
	-- 			textbox = awful.screen.focused().mypromptbox.widget,
	-- 			exe_callback = awful.util.eval,
	-- 			history_path = awful.util.get_cache_dir() .. "/history_eval"
	-- 		}
	-- 	end,
	-- 	{description = "تنفيذ كود لوا", group = "اوسم"}
	-- ), 
	-- Media Control
	awful.key(
		{},
		"XF86AudioRaiseVolume",
		function()
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
			awesome.emit_signal('widget::volume')
			awesome.emit_signal('module::volume_osd:show', true)
		end,
		{description = "رفع مستوى الصوت 10", group = "اوسم"}
	), 
	awful.key(
		{},
		"XF86AudioLowerVolume",
		function()
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
			awesome.emit_signal('widget::volume')
			awesome.emit_signal('module::volume_osd:show', true)
		end,
		{description = "خفظ مستوى الصوت 10", group = "اوسم"}
	), 
	awful.key(
		{},
		'XF86AudioMute',
		function()
			awful.spawn('amixer -D pulse set Master 1+ toggle', false)
		end,
		{description = 'التبديل بين الوضع الصامت', group = 'النظام'}
	),
	awful.key(
		{},
		'XF86AudioMicMute',
		function()
			awful.spawn('amixer set Capture toggle', false)
		end,
		{description = 'التبديل بين الوضع الصامت للمكرفون', group = 'النظام'}
	),
	-- الاضاءة
	awful.key(
		{},
		'XF86MonBrightnessUp',
		function()
			awful.spawn('brightnessctl set 5%+', false)
			awesome.emit_signal('widget::brightness')
			awesome.emit_signal('module::brightness_osd:show', true)
		end,
		{description = 'رفع مستوى اضاءة الشاشة', group = 'النظام'}
	),
	awful.key(
		{},
		'XF86MonBrightnessDown',
		function()
			awful.spawn('brightnessctl set 5%-', false)
			awesome.emit_signal('widget::brightness')
			awesome.emit_signal('module::brightness_osd:show', true)
		end,
		{description = 'خفض مستوى اضاءة الشاشة', group = 'النظام'}
	),
	-- البرامج الاخرى
	awful.key(
		{modkey},
		"Return",
		function()
			awful.spawn(apps.default.terminal)
		end,
		{description = "افتح الطرفية", group = "تطبيقات"}
	),
	awful.key(
		{modkey, "Shift"},
		"e",
		function()
			awful.spawn(apps.default.file_manager)
		end,
		{
			description = "افتح متصفح الملفات (دولفين)",
			group = "تطبيقات"
		}
	),
	awful.key(
		{modkey, "Shift"},
		"f",
		function()
			awful.spawn(apps.default.web_browser)
		end,
		{
			description = "افتح فايرفوكس",
			group = "تطبيقات"
		}
	),
	awful.key(
		{modkey, "Shift"},
		"a",
		function()
			awful.spawn(apps.default.development)
		end,
		{
			description = "افتح اندرويد استوديو",
			group = "تطبيقات"
		}
	),
	awful.key(
		{modkey, "Shift"},
		"p",
		function()
			awful.spawn("prime-run pycharm")
		end,
		{description = "افتح PyCahrm", group = "تطبيقات"}
	),
	awful.key(
		{modkey, "Shift"},
		"t",
		function()
			awful.spawn("telegram-desktop")
		end,
		{description = "افتح تلقرام", group = "تطبيقات"}
	),
	awful.key(
		{modkey},
		"c",
		function()
			awful.spawn(apps.default.multimedia)
		end,
		{description = "افتح مشغل الموسيقى", group = "تطبيقات"}
	),
	awful.key(
		{modkey},
		"v",
		function()
			awful.spawn("easyeffects")
		end,
		{description = "افتح easyeffects", group = "تطبيقات"}
	),
	awful.key(
		{modkey, 'Shift'},
		"c",
		function()
			awful.spawn(apps.default.text_editor)
		end,
		{description = "افتح VS Code", group = "تطبيقات"}
	)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = {description = 'عرض سطح المكتب #', group = 'سطح المكتب'}
		descr_toggle = {description = 'تبديل سطح المكتب #', group = 'سطح المكتب'}
		descr_move = {description = 'تحريك تطبيق الى سطح المكتب #', group = 'سطح المكتب'}
		descr_toggle_focus = {description = 'تبديل تطبيق الى سطح المكتب#', group = 'سطح المكتب'}
	end
	global_keys =
		awful.util.table.join(
		global_keys,
		-- View tag only.
		awful.key(
			{modkey},
			'#' .. i + 9,
			function()
				local focused = awful.screen.focused()
				local tag = focused.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			descr_view
		),
		-- Toggle tag display.
		awful.key(
			{modkey, 'Control'},
			'#' .. i + 9,
			function()
				local focused = awful.screen.focused()
				local tag = focused.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			descr_toggle
		),
		-- Move client to tag.
		awful.key(
			{modkey, 'Shift'},
			'#' .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
			descr_move
		),
		-- Toggle tag on focused client.
		awful.key(
			{modkey, 'Control', 'Shift'},
			'#' .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end,
			descr_toggle_focus
		)
	)
end

return global_keys
