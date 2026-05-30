---------------
-- rendering --
---------------

-- render text from right to left
function djui_hud_print_text_rtl(text, x, y, scale)
	x = x - djui_hud_measure_text(text)
	return djui_hud_print_text(text, x, y, scale)
end
-- render centered text
function djui_hud_print_text_centered(text, x, y, scale)
	x = x - ((djui_hud_measure_text(text) * scale) / 2)
	return djui_hud_print_text(text, x, y, scale)
end
-- render text with shadow (ltr only)
function djui_hud_print_text_shadowed(text, x, y, scale, color, distx, disty)
   if color then
      local col = djui_hud_get_color()
      djui_hud_set_color(color[1] or 0, color[2] or 0, color[3] or 0, color[4] or 127)
      djui_hud_print_text(text, x + distx, y + disty, scale)
      djui_hud_set_color(col.r, col.g, col.b, col.a)
   end
   djui_hud_print_text(text, x, y, scale)
end

-- render centered texture with/out disabling x or y centering
function djui_hud_render_texture_centered(tex, x, y, scale, centering)
	if not centering or centering == 'x' then
		x = x - (tex.width * scale) / 2
	end
	if not centering or centering == 'y' then
		y = y - (tex.height * scale) / 2
	end
	return djui_hud_render_texture(tex, x, y, scale, scale)
end

-- calculate position relative to screen center
function from_screen_center(x, y)
	x = (screen.width / 2) + (x or 0)
	y = (screen.height / 2) + (y or 0)
	return { x = x, y = y }
end

-----------
-- utils --
-----------

-- play sound as a string
function sound_play(sound)
	local pos = gMarioStates[0].pos

	if sound == 'buzz' or not sound then
		play_sound(SOUND_MENU_CAMERA_BUZZ, pos)
	elseif sound == 'change' then
		play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, pos)
	elseif sound == 'switchMenu' then
		play_sound(SOUND_MENU_CLICK_CHANGE_VIEW, pos)
	elseif sound == 'pause' then
		play_sound(SOUND_MENU_PAUSE_2, pos)
	elseif sound == 'copy' then
		play_sound(SOUND_MENU_MARIO_CASTLE_WARP, pos)
	end
end

-- faster than having to type that entire check every single time
function buttonPressed(button)
	return (gMarioStates[0].controller.buttonPressed & (button or gMarioStates[0].controller.buttonPressed)) ~= 0
end
function buttonDown(button)
	return (gMarioStates[0].controller.buttonDown & (button or gMarioStates[0].controller.buttonDown)) ~= 0
end

-- supports color indexes in order (1, 2, 3, 4) and RGBA keys in any order (r = 1, g = 2, b = 3, a = 4)
function djui_hud_set_color_array(array, alpha)
	djui_hud_set_color(array[1] or array.r or 255, array[2] or array.g or 255, array[3] or array.b or 255, array[4] or array.a or alpha or 255)
end
function djui_hud_get_color_array()
   local color = djui_hud_get_color()
   return { color.r, color.g, color.b, color.a }
end

-- replace all lowercase 'x' with '`' to use the original x character texture
function filter_text(text)
	return text:gsub("x", "`")
end

-- return saved lerp value or 1 if lerping disabled
function get_lerp_weight()
	return (Config.delux.arwlerp.value > 1) and (Config.delux.arwlerp.alt * 0.1) or 1
end

local button_names = Usamune.buttons
function get_button(buttonID)
   return button_names.id[buttonID]
end



-----------
-- DEBUG --
-----------

-- easier logging
function console_log(...)
   local str = select(1, ...) or ""

	-- presets --
	if str == "config" then
		str = "> /g1/UsamuneConfig:/reset/"
	elseif str == "savestate" then
		str = "> /g1/UsamuneStates:/reset/"
	end

   if #{...} > 1 then
	   str = str .." ".. table.concat({...}, " ", 2, #{...})
   end

	-- colors --
	-- red
	str = str:gsub("/r/", "\\#b34343\\")
	-- green
	str = str:gsub("/g/", "\\#53c253\\")
	-- blue
	str = str:gsub("/b/", "\\#71abca\\")
	-- yellow
	str = str:gsub("/y/", "\\#c8c85f\\")

	-- orange
	str = str:gsub("/o/", "\\#e59b7f\\")
	-- purple
	str = str:gsub("/purple/", "\\#c187df\\")

	-- gray 1
	str = str:gsub("/g1/", "\\#999999\\")
	-- gray 2
	str = str:gsub("/g2/", "\\#acacac\\")

	-- reset
	str = str:gsub("/reset/", "\\#dcdcdc\\")

	log_to_console(str)
	return str
end

local function printtable(tbl, tblName, inline, deepPrint, indent)
   if not tblName or tblName == '' then tblName = 'LuaTable' end
   if not inline then
      log_to_console(string.format('/g/%s/reset/ {'), tblName)
   end
   if not indent then indent = '  ' end

   local keys = {}

   for i, item in pairs(tbl) do
      local color = ''
      if type(item) == 'string' then
         if string.find(item, ' ') then
            item = string.format('"%s"', item)
         else
            item = string.format("'%s'", item)
         end
         color = '/o/'
      elseif type(item) == 'table' then
         color = '/g/'
      elseif type(item) == 'number' then
         color = '/y/'
      elseif type(item) == 'boolean' then
         color = '/purple/'
      end

      local item_length = 0

      if type(item) == 'table' then
         if deepPrint then
            for _, __ in pairs(item) do
               item_length = item_length + 1
            end
         else
            item = string.format('%s/reset/[/y/%d/reset/]', tblName, #item)
         end
      end

      if type(i) == 'number' then
         if type(item) == 'table' and deepPrint then
            if item_length > 0 then
               console_log(string.format('%s[/y/%d/reset/] = /g/LuaTable/reset/ {', indent, i))
               printtable(item, '', true, false, '    ')
               console_log(string.format('%s},', indent))
            else
               console_log(string.format('%s[/y/%d/reset/] = /g/LuaTable/reset/ {},', indent, i))
            end
         else
            -- print indexed items
            console_log(string.format('%s[/y/%d/reset/] = %s%s/reset/,', indent, i, color, tostring(item)))
         end
      else
         if type(item) == 'table' and deepPrint then
            if item_length > 0 then
               console_log(string.format('%s/b/%s/reset/ = /g/LuaTable/reset/ {', indent, i))
               printtable(item, '', true, false, '    ')
               console_log(string.format('%s},', indent))
            else
               console_log(string.format('%s/b/%s/reset/ = /g/LuaTable/reset/ {},', indent, i))
            end
         else
            -- store keys and values
            table.insert(keys, { key = i, value = color .. tostring(item) })
         end
      end
   end

   -- sort keys alphabetically
   table.sort(keys, function(a, b)
      return a.key < b.key
   end)

   -- print keys and values
   for i, item in ipairs(keys) do
      console_log(string.format('%s/b/%s/reset/ = %s/reset/,', indent, item.key, item.value))
   end

   if not inline then
      log_to_console('}')
   end
end

-- ultra mega definitive print system
function print(...)
   local strs = ''

   for i, item in pairs({...}) do
      if type(item) == 'table' then
         console_log(strs.. '/g/LuaTable/reset/ {')
         printtable(item, '', true, true)
         strs = '} '
      else
         local color = ''
         if type(item) == 'number' then
            color = '/y/'
         elseif type(item) == 'boolean' then
            color = '/purple/'
         end
         strs = strs .. string.format('%s%s/reset/', color, tostring(item)).. ' '
      end
   end

   if strs ~= '' then
      console_log(strs)
   end
end

-- print to chat
function printc(...)
   local t = {}
   for i, item in ipairs({...}) do
      t[i] = tostring(item)
   end
   djui_chat_message_create(table.concat(t, " "))
end