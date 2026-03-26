local buttonPressed = buttonPressed

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
            level = { id = i, name = get_level_name_ascii(courseNum, i, 1, 0), courseNum = courseNum }
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

local messages_durations = {
   COPIED_SUCCESSFULLY = 75,
   INVALID_DESTINATION = 45,
   CAN_NOT_WARP_HERE = 45,
}
local copy_hold_time_max = 18
local copy_hold_time_elapsed = 0

local menu = {
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
		local pos = from_screen_center(0, 0)
		djui_hud_set_color(255, 255, 255, Usamenu.opacity + math.sin(get_global_timer() * 0.3) * 2)
		djui_hud_print_text_centered("NO LEVELS", pos.x, pos.y, 1)
		return
	end

   -- duplicate levels array
   local levels = {}
   for i, level in ipairs(menu.levels.arr) do
      levels[i] = level
   end

	menu.levels.levels_per_line = math.floor(screen_w / menu.levels.separation.x)
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

   -- iterate through each level
	for k = visible_lines.min, visible_lines.max do
	for i = 1, menu.levels.levels_per_line do
      i = i - menu.levels.levels_per_line + (k * menu.levels.levels_per_line)
      local level = levels[i]
      if not level then break end

      local target = menu.levels.pos.y - (menu.levels.separation.y * visible_lines.min)

		local level_pos = {
			x = menu.levels.pos.x + (((i-1) % menu.levels.levels_per_line) * menu.levels.separation.x),
			y = target + (math.floor((i-1) / menu.levels.levels_per_line) * menu.levels.separation.y)
		}

		-- render level names
		djui_hud_print_text(filter_text(level.name), level_pos.x, level_pos.y, 1)

		local selected_level = levels[menu.levels.selection]

      -- selected level is current iteration
		if i == menu.levels.selection then
		   -- render arrow next to selection
			arrowlerp(level_pos.x - 10, level_pos.y + 4)
			djui_hud_render_texture(Usamenu.tex_arrow, arrow_pos[1].x, arrow_pos[1].y, 1, 1)

         -- custom level at the very end
         if selected_level.is_custom then
            local x = level_pos.x + (menu.levels.separation.x * 1.45)
            djui_hud_print_text_rtl(string.format('%02x %02x %02x', selected_level.id, selected_level.area, selected_level.node),
               x, level_pos.y, 1)

            local indexed_level_info = { selected_level.node, selected_level.area, selected_level.id }

            -- handle input
            local input = gMarioStates[0].controller.buttonPressed & (L_CBUTTONS | R_CBUTTONS | U_CBUTTONS | D_CBUTTONS)

            if input ~= 0 then
               local selected_info = math.floor((menu.levels.custom_selected_char - 1) / 2) + 1
               local selected_info_char = (menu.levels.custom_selected_char - 1) % 2
               local steps = math.floor(16 * math.pow(10, selected_info_char - 1))

               if input == L_CBUTTONS then
                  menu.levels.custom_selected_char = menu.levels.custom_selected_char % 6 + 1
               elseif input == R_CBUTTONS then
                  menu.levels.custom_selected_char = (menu.levels.custom_selected_char - 2) % 6 + 1

               elseif input == U_CBUTTONS then
                  indexed_level_info[selected_info] = indexed_level_info[selected_info] + steps
               elseif input == D_CBUTTONS then
                  indexed_level_info[selected_info] = indexed_level_info[selected_info] - steps
               end

               selected_level.id = math.clamp(indexed_level_info[3], 0, 255)
               selected_level.area = math.clamp(indexed_level_info[2], 0, 255)
               selected_level.node = math.clamp(indexed_level_info[1], 0, 255)
            end

            -- render arrow
			   arrowlerp(x + 4 - (menu.levels.custom_selected_char * 12) - (math.floor((menu.levels.custom_selected_char - 1) / 2) * 12), level_pos.y + 16, 2)
			   djui_hud_render_texture(gTextures.arrow_up, arrow_pos[2].x, arrow_pos[2].y, 1, 1)
         end

   		-- enter level
   		if buttonPressed(A_BUTTON) and selected_level.id then
   			menu.levels.selected = true
   			local warped = warp_to_warpnode(selected_level.id, selected_level.area or 1, 1, selected_level.node or 10)

            -- warp failed
            if not warped and menu.levels.selected then
               Usamenu.bottom_message({'INVALID DESTINATION'}, messages_durations.INVALID_DESTINATION)
               sound_play('buzz')
            end

   			menu.levels.selected = false
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
   --printc(menu.levels.current_line)
	local levels_limit = menu.levels.levels_per_line + ((menu.levels.current_line - 1) * menu.levels.levels_per_line)

	-- handle other inputs --
   local input = gMarioStates[0].controller.buttonPressed & (L_JPAD | R_JPAD | U_JPAD | D_JPAD)

   if input ~= 0 then
      if input == L_JPAD then
		   menu.levels.selection = (menu.levels.selection - 2) % #levels + 1
         if levels[menu.levels.selection] and levels[menu.levels.selection].name == '' then
            menu.levels.selection = #menu.levels.arr
         end
   	elseif input == R_JPAD then
   		menu.levels.selection = menu.levels.selection % #levels + 1
         if levels[menu.levels.selection] and levels[menu.levels.selection].name == '' then
            menu.levels.selection = #levels
         end
   	elseif input == U_JPAD then
         menu.levels.selection = menu.levels.selection - 1
         menu.levels.selection = (menu.levels.selection - menu.levels.levels_per_line) % (#levels + 2) + 1
   	elseif input == D_JPAD then
         menu.levels.selection = (menu.levels.selection + menu.levels.levels_per_line) % (#levels + 2)
         if levels[menu.levels.selection] and levels[menu.levels.selection].name == '' then
            menu.levels.selection = #menu.levels.arr
         end
      end
      menu.levels.selection = math.clamp(menu.levels.selection, 1, #levels)
		sound_play('change')
   end
end


return menu