local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local naughty = require('naughty')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widget/email/icons/'

local config = require('configuration.config')
local secrets = {
	email_address = config.widget.email.address,
	app_password = config.widget.email.app_password,
	imap_server = config.widget.email.imap_server,
	port = config.widget.email.port
}

local unread_email_count = 0
local startup_show = true

local scroll_container = function(widget)
	return wibox.widget {
		widget,
		id = 'scroll_container',
		max_size = 345,
		speed = 75,
		expand = true,
		direction = 'h',
		step_function = wibox.container.scroll
						.step_functions.waiting_nonlinear_back_and_forth,
		fps = 30,
		layout = wibox.container.scroll.horizontal,
	}
end

local email_icon_widget = wibox.widget {
	{
		id = 'icon',
		image = widget_icon_dir .. 'email.svg',
		resize = true,
		forced_height = dpi(45),
		forced_width = dpi(45),
		widget = wibox.widget.imagebox,
	},
	layout = wibox.layout.fixed.horizontal
}

local email_from_text = wibox.widget {
	font = 'JF Flat 10',
	markup = 'من:',
	align = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local email_recent_from = wibox.widget {
	font = 'JF Flat 10',
	markup = 'loading@stdout.sh',
	align = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local email_subject_text = wibox.widget {
	font = 'JF Flat 10',
	markup = 'العنوان',
	align = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local email_recent_subject = wibox.widget {
	font = 'JF Flat 10',
	markup = 'Loading data',
	align = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local email_date_text = wibox.widget {
	font = 'JF Flat 10',
	markup = 'التوقيت المحلي:',
	align = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local email_recent_date = wibox.widget {
	font = 'JF Flat 10',
	markup = 'جلب البيانات...',
	align = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local email_report = wibox.widget{
	{
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(10),
			{
				layout = wibox.layout.align.vertical,
				expand = 'none',
				nil,
				email_icon_widget,
				nil
			},
			{
				layout = wibox.layout.align.vertical,
				expand = 'none',
				nil,
				{
					layout = wibox.layout.fixed.vertical,
					{
						email_from_text,
						scroll_container(email_recent_from),
						spacing = dpi(5),
						layout = wibox.layout.fixed.horizontal
					},
					{
						email_subject_text,
						scroll_container(email_recent_subject),
						spacing = dpi(5),
						layout = wibox.layout.fixed.horizontal
					},
					{
						email_date_text,
						scroll_container(email_recent_date),
						spacing = dpi(5),
						layout = wibox.layout.fixed.horizontal
					}
				},
				nil
			}
		},
		margins = dpi(10),
		widget = wibox.container.margin
	},
	forced_height = dpi(92),
	bg = beautiful.groups_bg,
	shape = function(cr, width, height)
	gears.shape.partially_rounded_rect(cr, width, height, true, true, true, true, beautiful.groups_radius)
end,
widget = wibox.container.background
}

local email_details_tooltip = awful.tooltip
{
	text = 'جاري التحميل...',
	objects = {email_icon_widget},
	mode = 'outside',
	align = 'right',
	preferred_positions = {'left', 'right', 'top', 'bottom'},
	margin_leftright = dpi(8),
	margin_topbottom = dpi(8)
}

local fetch_email_command = [[
python3 - <<END
import imaplib
import email
import datetime
import re
import sys
from email.policy import default

def process_mailbox(M):
	rv, data = M.search(None, "(UNSEEN)")
	if rv != 'OK':
		print ("لا يوجد اي رسالة!")
		return

	for num in reversed(data[0].split()):
		rv, data = M.fetch(num, '(BODY.PEEK[])')
		if rv != 'OK':
			print ("حدث خطأ اثناء جلب الرسائل", num)
			return

		msg = email.message_from_bytes(data[0][1], policy=default)
		print ('من:', msg['From'])
		print ('العنوان %s' % (msg['Subject']))
		date_tuple = email.utils.parsedate_tz(msg['Date'])
		if date_tuple:
			local_date = datetime.datetime.fromtimestamp(email.utils.mktime_tz(date_tuple))
			print ("التوقيت المحلي:", local_date.strftime("%a, %H:%M:%S %b %d, %Y") + "\n")
			# with code below you can process text of email
			# if msg.is_multipart():
			#     for payload in msg.get_payload():
			#         if payload.get_content_maintype() == 'text':
			#             print  payload.get_payload()
			#         else:
			#             print msg.get_payload()


try:
	M=imaplib.IMAP4_SSL("]] .. secrets.imap_server .. [[", ]] .. secrets.port .. [[)
	M.login("]] .. secrets.email_address .. [[","]] .. secrets.app_password .. [[")

	status, counts = M.status("INBOX","(MESSAGES UNSEEN)")

	rv, data = M.select("INBOX")
	if rv == 'OK':
		unread = re.search(r'UNSEEN\s(\d+)', counts[0].decode('utf-8')).group(1)
		print ("عدد الرسائل:" + unread)
		process_mailbox(M)

	M.close()
	M.logout()

except Exception as e:
	if e:
		print (e)

END
]]

local notify_all_unread_email = function(email_data)
	
	local unread_counter = email_data:match('عدد الرسائل:(.-)من:'):sub(1, -2)

	local email_data = email_data:match('(من:.*)'):sub(1, -2)

	local title = nil

	if tonumber(unread_email_count) > 1 then
		title = 'لديك ' .. unread_counter .. ' رسالة غير مقروءة!'
	else
		title = 'لديك ' .. unread_counter .. ' رسالة غير مقروءة!'
	end
	
	naughty.notification ({
		app_name = 'Email',
		title = title,
		message = email_data,
		timeout = 30,
		icon = widget_icon_dir .. 'email-unread.svg'
	})
end

local notify_new_email = function(count, from, subject)
	if not startup_show and (tonumber(count) > tonumber(unread_email_count)) then
		unread_email_count = tonumber(count)

		local message = "من: " .. from ..
		"\nSubject: " .. subject
		
		naughty.notification ({
			app_name = 'Email',
			title = 'لديك ايميل جديد!',
			message = message,
			timeout = 10,
			icon = widget_icon_dir .. 'email-unread.svg'
		})
	else
		unread_email_count = tonumber(count)
	end

end

local set_email_data_tooltip = function(email_data)
	local email_data = email_data:match('(من:.*)')
	local counter = "<span font='JF Flat 10'>عدد الرسائل: </span>" .. unread_email_count
	email_details_tooltip:set_markup(counter .. '\n\n' .. email_data)
end

local set_widget_markup = function(from, subject, date, tooltip)

	email_recent_from:set_markup(from:gsub('%\n', ''))
	email_recent_subject:set_markup(subject:gsub('%\n', ''))
	email_recent_date:set_markup(date:gsub('%\n', ''))

	if tooltip then
		email_details_tooltip:set_markup(tooltip)
	end
end

local set_no_connection_msg = function()
	set_widget_markup(
		'message@stderr.sh',
		'تاكد من اتصالك بالانترنت!',
		os.date('%d-%m-%Y %H:%M:%S'),
		'لا يوجد اتصال بالانترنت!'		
	)
end

local set_invalid_credentials_msg = function()
	set_widget_markup(
		'message@stderr.sh',
		'خطأ في التوثيق!',
		os.date('%d-%m-%Y %H:%M:%S'),
		'بياناتك التوثيق غير صحيحة!'
	)
end

local set_latest_email_data = function(email_data)

	local unread_count = email_data:match('عدد الرسائل:(.-)من:'):sub(1, -2)
	local recent_from = email_data:match('من: (.-)العنوان'):sub(1, -2)
	local recent_subject = email_data:match('العنوان (.-)التوقيت المحلي:'):sub(1, -2)
	local recent_date = email_data:match('التوقيت المحلي: (.-)\n')

	recent_from = recent_from:match('<(.*)>') or recent_from:match('&lt;(.*)&gt;') or recent_from

	local count = tonumber(unread_count)
	if count > 0 and count <= 9 then
		email_icon_widget.icon:set_image(widget_icon_dir .. 'email-'.. tostring(count) .. '.svg')
	elseif count > 9 then
		email_icon_widget.icon:set_image(widget_icon_dir .. 'email-9+.svg')
	end
	
	set_widget_markup(
		recent_from,
		recent_subject,
		recent_date
	)

	notify_new_email(unread_count, recent_from, recent_subject)
end

local set_empty_inbox_msg = function()
	set_widget_markup(
		'empty@stdout.sh',
		'Empty inbox',
		os.date('%d-%m-%Y %H:%M:%S'),
		'Empty inbox.'
	)
end

local fetch_email_data = function()
	awful.spawn.easy_async_with_shell(
		fetch_email_command,
		function(stdout)
			stdout = gears.string.xml_escape(stdout:sub(1, -2))

			if stdout:match('Temporary failure in name resolution') then
				set_no_connection_msg()
				return
			elseif stdout:match('Invalid credentials') then
				set_invalid_credentials_msg()
				return
			elseif stdout:match('عدد الرسائل:0') then
				email_icon_widget.icon:set_image(widget_icon_dir .. 'email.svg')
				set_empty_inbox_msg()
				return
			elseif not stdout:match('عدد الرسائل:(.-)من:') then
				return
			elseif not stdout or stdout == '' then
				return
			end

			set_latest_email_data(stdout)
			set_email_data_tooltip(stdout)

			if startup_show then
				notify_all_unread_email(stdout)
				startup_show = false
			end
		end
	)
end

local set_missing_secrets_msg = function()
	set_widget_markup(
		'message@stderr.sh',
		'Credentials are missing!',
		os.date('%d-%m-%Y %H:%M:%S'),
		'Missing credentials!'
	)
end

local check_secrets = function()
	if secrets.email_address == '' or secrets.app_password == '' or secrets.imap_server == '' or secrets.port == '' then
		set_missing_secrets_msg()
		return
	else
		fetch_email_data()
	end
end

check_secrets()

local update_widget_timer = gears.timer {
	timeout = 30,
	autostart = true,
	call_now = true,
	callback  = function()
		check_secrets() 
	end
}

email_report:connect_signal(
	'mouse::enter',
	function()
		check_secrets()
	end
)

awesome.connect_signal(
	'system::network_connected',
	function()
		gears.timer.start_new(
			5,
			function() 
				check_secrets()
			end
		)
	end
)

return email_report
