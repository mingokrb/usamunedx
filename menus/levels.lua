local from_screen_center,buttonPressed,buttonDown = from_screen_center,buttonPressed,buttonDown

local vanilla_levels = {
   { name = "BOB",     id = LEVEL_BOB },
   { name = "WF",      id = LEVEL_WF },
   { name = "JRB",     id = LEVEL_JRB },
   { name = "CCM",     id = LEVEL_CCM},
   { name = "BBH",     id = LEVEL_BBH },
   { name = "HMC",     id = LEVEL_HMC },
   { name = "LLL",     id = LEVEL_LLL },
   { name = "SSL",     id = LEVEL_SSL },
   { name = "DDD",     id = LEVEL_DDD },
   { name = "SL",      id = LEVEL_SL },
   { name = "WDW",     id = LEVEL_WDW },
   { name = "TTM",     id = LEVEL_TTM },
   { name = "THIT",    id = LEVEL_THI,    area = 1 },
   { name = "THIH",    id = LEVEL_THI,    area = 2 },
   { name = "TTC",     id = LEVEL_TTC },
   { name = "RR",      id = LEVEL_RR },
   { name = "TOTWC",   id = LEVEL_TOTWC },
   { name = "VCUTM",   id = LEVEL_VCUTM },
   { name = "COTMC",   id = LEVEL_COTMC },
   { name = "PSS",     id = LEVEL_PSS },
   { name = "AQUA",    id = LEVEL_SA },
   { name = "WMOTR",   id = LEVEL_WMOTR },
   { name = "BITDW",   id = LEVEL_BITDW },
   { name = "BOW1",    id = LEVEL_BOWSER_1 },
   { name = "BITFS",   id = LEVEL_BITFS },
   { name = "BOW2",    id = LEVEL_BOWSER_2 },
   { name = "BITS",    id = LEVEL_BITS },
   { name = "BOW3",    id = LEVEL_BOWSER_3 },
   { name = "BASE",    id = LEVEL_CASTLE, area = 3, node = 0 },
   { name = "UPSTR",   id = LEVEL_CASTLE, area = 2, node = 1 },
}
for i, level in ipairs(vanilla_levels) do
   local courseNum = get_level_course_num(level.id)
   level.fullName = get_level_name_ascii(courseNum, level.id, 0, 1)
end

-- update levels and return them
local function update_levels()
   -- vanilla
   local all_vanilla = true
   for i = 1, LEVEL_COUNT - 1 do
      if not level_is_vanilla_level(i) then
         all_vanilla = false
         break
      end
   end
   if all_vanilla then
      return vanilla_levels
   end

   local levels = {}
   for i = 1, LEVEL_COUNT - 1 do
      local courseNum = get_level_course_num(i)
      if courseNum > 0 then
         -- get level info
         local level = smlua_level_util_get_info(i)
         if not level then
            printc("level util got no info")
            local lname = get_level_name_ascii(courseNum, i, 0, 1)
            level = { id = i, name = lname, fullName = lname, courseNum = courseNum }
         else
            printc("level util got info")
            print(level)
         end

         -- abbreviate level names
         local words = level.name:gsub("-", " "):split(" ")
         level.name = ""
         for _, word in ipairs(words) do
            level.name = level.name .. word:sub(1, 1)
         end

         table.insert(levels, level)
      end
   end

   -- sort by courseNum ascending
   table.sort(levels, function(a, b)
      return a.courseNum < b.courseNum
   end)

   -- remove duplicates
   local duplicates, filtered = {}, {}
   for l, level in ipairs(levels) do
      if not duplicates[level.name] then
         duplicates[level.name] = true
         table.insert(filtered, level)
      end
   end
   levels = filtered

   return levels
end
local custom_entry = { name = "CUSTOM", id = 0, area = 0, node = 0, is_custom = true }

-- for arrow lerp
local arrow_pos = {
   { x = 0, y = 0 },
   { x = 0, y = 0 },
}
local get_lerp_weight = get_lerp_weight
local function arrowlerp(x, y, i)
   if not i then i = 1 end
   local weight = get_lerp_weight()

   arrow_pos[i].x = math.lerp(arrow_pos[i].x, x, weight)
   arrow_pos[i].y = math.lerp(arrow_pos[i].y, y, weight)
end

local scroll_time = 0
local scroll_max_time = 10

local messages_durations = {
   COPIED_SUCCESSFULLY = 75,
   INVALID_DESTINATION = 45,
   CAN_NOT_WARP_HERE = 45,
}
local copy_hold_time_max = 18
local copy_hold_time_elapsed = 0

local menu = {
   name = "level_select",
   title = "",
   title_update = HOOK_ON_WARP,

   levels = {
      arr = update_levels(),

      selection = 1,
      selected = false,
      levels_per_line = 2,
      current_line = 1,
      custom_selected_char = 1, -- from right to left

      pos = { x = 60, y = 76 },
      separation = { x = 132, y = 22 },
   }
}


function menu.update_once()
   local g = gNetworkPlayers[0]
   menu.title = string.format("cur %02x %02x %02x", g.currLevelNum, g.currAreaIndex, Usamune.last_warpnode_id)
   --menu.levels.arr = update_levels()
end

function menu.render()
   if not menu.levels.arr[1] then
      -- 'no levels' text
      local pos = from_screen_center()
      djui_hud_set_color(255, 255, 255, Usamenu.opacity + math.sin(get_global_timer() * 0.3) * 2)
      djui_hud_print_text_centered("NO LEVELS", pos.x, pos.y, 1)
      return
   end

   -- duplicate levels array
   local levels = {}
   for i, level in ipairs(menu.levels.arr) do
      levels[i] = level
   end

   menu.levels.levels_per_line = math.floor(screen.width / menu.levels.separation.x)
   -- compensate lack of enough levels
   menu.levels.levels_per_line = menu.levels.levels_per_line - ((#levels < menu.levels.levels_per_line) and (menu.levels.levels_per_line - #levels) or 0)
   local lines = math.floor((#levels - 1) / menu.levels.levels_per_line) + 1

   -- "custom" level index
   local last_line_length = (#menu.levels.arr - 1) % menu.levels.levels_per_line + 1
   local custom_index = menu.levels.levels_per_line - last_line_length + 1
   
   for i = #menu.levels.arr + 1, #menu.levels.arr + custom_index do
      levels[i] = { name = '' }
   end
   levels[#levels] = custom_entry

   local visible_lines = {}
   visible_lines.min = math.min(math.max(1, menu.levels.current_line - 2), menu.levels.current_line, lines - 4)
   visible_lines.max = visible_lines.min + 5

   local level_pos = {}

   -- iterate through each level
   for k = visible_lines.min, visible_lines.max do
   for i = 1, menu.levels.levels_per_line do
      i = i - menu.levels.levels_per_line + (k * menu.levels.levels_per_line)
      local level = levels[i]
      if not level then break end

      local target = menu.levels.pos.y - (menu.levels.separation.y * visible_lines.min)

      level_pos = {
         x = menu.levels.pos.x + (((i-1) % menu.levels.levels_per_line) * menu.levels.separation.x),
         y = target + (math.floor((i-1) / menu.levels.levels_per_line) * menu.levels.separation.y)
      }

      -- render level names
      djui_hud_print_text(filter_text(level.name), level_pos.x, level_pos.y, 1)

      local selected_level = levels[menu.levels.selection]

      -- selected level is current iteration
      if i == menu.levels.selection then
         arrowlerp(level_pos.x - 10, level_pos.y + 4)
         local cl_text = ""

         -- if custom level
         if selected_level.is_custom then
            local x = level_pos.x + (menu.levels.separation.x * 1.45)
            cl_text = string.format("%02X %02X %02X", selected_level.id, selected_level.area, selected_level.node)
            djui_hud_print_text_rtl(cl_text, x, level_pos.y, 1)

            local indexed_level_info = { selected_level.node, selected_level.area, selected_level.id }

            -- handle input
            local input = gMarioStates[0].controller.buttonPressed & (L_CBUTTONS | R_CBUTTONS | U_CBUTTONS | D_CBUTTONS)

            if input ~= 0 then
               local selected_info = math.floor((menu.levels.custom_selected_char - 1) / 2) + 1
               local selected_info_char = (menu.levels.custom_selected_char - 1) % 2
               local steps = math.floor(16 * math.pow(10, selected_info_char - 1))

               -- left - right
               if input == L_CBUTTONS then
                  menu.levels.custom_selected_char = menu.levels.custom_selected_char % 6 + 1
               elseif input == R_CBUTTONS then
                  menu.levels.custom_selected_char = (menu.levels.custom_selected_char - 2) % 6 + 1
               -- up - down
               elseif input == U_CBUTTONS then
                  indexed_level_info[selected_info] = Usamenu.move_selection(indexed_level_info[selected_info], 0, 256, steps)
               elseif input == D_CBUTTONS then
                  indexed_level_info[selected_info] = Usamenu.move_selection(indexed_level_info[selected_info], 0, 256, -steps)
               end

               -- set custom IDs
               selected_level.id = math.clamp(indexed_level_info[3], 0, 255)
               selected_level.area = math.clamp(indexed_level_info[2], 0, 255)
               selected_level.node = math.clamp(indexed_level_info[1], 0, 255)
            end

            -- render arrow
            arrowlerp(x + 4 - (menu.levels.custom_selected_char * 12) - (math.floor((menu.levels.custom_selected_char - 1) / 2) * 12), level_pos.y + 16, 2)
            djui_hud_render_texture(gTextures.arrow_up, arrow_pos[2].x, arrow_pos[2].y, 1, 1)
         end

         -- warp to selected level
         if buttonPressed(A_BUTTON) and selected_level.id then
            if cl_text == "DE AD 26" then
                  if VERSION_NUMBER < 42 or Usamune.DEAD26 then
                     Usamenu.bottom_message({"..."}, 60)
                  else
                     Usamune.DEAD26 = true
                     Usamune.soft_reset()
                     hud_hide()
                     set_shader_flag_enabled(SHADER_FLAG_SATURATION, true)
                     set_shader_flag_enabled(SHADER_FLAG_BRIGHTNESS, true)
                     set_shader_flag_value(SHADER_FLAG_SATURATION, 0)
                     set_shader_flag_value(SHADER_FLAG_BRIGHTNESS, 0.7)
                  end
            else
               menu.levels.selected = true
               local warped = warp_to_warpnode(selected_level.id, selected_level.area or 1, 1, selected_level.node or 10)
               --local warped = warp_to_level(selected_level.id, selected_level.area or 1, 1)
   
               -- warp failed
               if not warped and menu.levels.selected then
                  Usamenu.bottom_message({'INVALID DESTINATION'}, messages_durations.INVALID_DESTINATION)
                  sound_play('buzz')
               end
   
               menu.levels.selected = false
            end
         end

         -- copy IDs
         if (gMarioStates[0].controller.buttonDown & Z_TRIG) ~= 0 then
            copy_hold_time_elapsed = copy_hold_time_elapsed + 1
            if copy_hold_time_elapsed == copy_hold_time_max then
               if selected_level.is_custom then
                  selected_level.id = gNetworkPlayers[0].currLevelNum
                  selected_level.area = gNetworkPlayers[0].currAreaIndex
                  selected_level.node = Usamune.last_warpnode_id
               else
                  local custom = levels[#levels]
                  custom.id = selected_level.id
                  custom.area = selected_level.area or 1
                  custom.node = selected_level.node or 10
                  menu.levels.selection = #levels
               end

               Usamenu.bottom_message({'COPIED SUCCESSFULLY'}, messages_durations.COPIED_SUCCESSFULLY)
               sound_play('copy')
            end
         else
            copy_hold_time_elapsed = 0
         end
      end
   end
   end

   menu.levels.current_line = math.ceil(menu.levels.selection / menu.levels.levels_per_line)
   local levels_limit = menu.levels.levels_per_line + ((menu.levels.current_line - 1) * menu.levels.levels_per_line)

   -- handle level selection input
   local input = gMarioStates[0].controller.buttonDown & (L_JPAD | R_JPAD | U_JPAD | D_JPAD)
   if input ~= 0 and #levels > 1 and not Usamenu.opening_button_pressed then
      scroll_time = scroll_time + 1

      if scroll_time == 1 or scroll_time >= scroll_max_time then
         if scroll_time > 1 then
            scroll_time = scroll_max_time - 3
         end

         local prevSelection = menu.levels.selection
         -- left - right
         if input == L_JPAD then
            while menu.levels.selection == prevSelection or (levels[menu.levels.selection] and levels[menu.levels.selection].name == '') do
               menu.levels.selection = Usamenu.move_selection(menu.levels.selection, 1, #levels, -1, '')
            end
         elseif input == R_JPAD then
            while menu.levels.selection == prevSelection or (levels[menu.levels.selection] and levels[menu.levels.selection].name == '') do
            menu.levels.selection = Usamenu.move_selection(menu.levels.selection, 1, #levels, 1, '')
            end
         -- up - down
         elseif input == U_JPAD then
            menu.levels.selection = Usamenu.move_selection(menu.levels.selection, 1, #levels + 2, -menu.levels.levels_per_line, '')
         elseif input == D_JPAD then
            if levels[menu.levels.selection + menu.levels.levels_per_line] and levels[menu.levels.selection + menu.levels.levels_per_line].name == '' then
               while menu.levels.selection == prevSelection or (levels[menu.levels.selection + 1] and levels[menu.levels.selection + 1].name ~= '') do
                  menu.levels.selection = Usamenu.move_selection(menu.levels.selection, 1, #levels + 2, 1, '')
               end
            else
               while menu.levels.selection == prevSelection or (levels[menu.levels.selection] and levels[menu.levels.selection].name == '') do
                  menu.levels.selection = Usamenu.move_selection(menu.levels.selection, 1, #levels + 2, menu.levels.levels_per_line, '')
               end
            end
         end

         menu.levels.selection = math.clamp(menu.levels.selection, 1, #levels)
         sound_play('change')
      end
   else
      scroll_time = 0
   end

   -- render arrow next to selection
   djui_hud_render_texture(Usamenu.tex_arrow, arrow_pos[1].x, arrow_pos[1].y, 1, 1)
end

hook_event(HOOK_ON_PLAY_SOUND, function()
   if Usamune.DEAD26 then return NO_SOUND end
end)
hook_event(HOOK_ON_SEQ_LOAD, function()
   if Usamune.DEAD26 then return 0 end
end)
hook_event(HOOK_USE_ACT_SELECT, function(levelNum)
   if get_level_course_num(levelNum) > 0 and Usamune.DEAD26 then return false end
end)

return menu
