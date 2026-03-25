local get_lerp_weight,filter_text = get_lerp_weight,filter_text

local selections = {}

local button_names = {}
for i, button in ipairs(Usamune.buttons.indexed) do
   table.insert(button_names, button.name)
end
table.insert(button_names, "NONE")

-- update submenus/options and return them in a table
local function update_menu()
	local submenus = {
		{ name = "timer", selection = 1, description =
         "Timer features" },
		{ name = "misct", selection = 1, description =
         "Miscellaneous timing features" },
		{ name = "reset", selection = 1, description =
         "Resetting features" },
		{ name = "deflt", selection = 1, description =
         "Default values applied on level start" },
		{ name = "hud",   selection = 1, description =
         "Display a bunch of information on the HUD" },
		{ name = "input", selection = 1, description =
         "Input Display-specific features" },
		{ name = "data",  selection = 1, description =
         "Data" },
		{ name = "delux", selection = 1, description =
         "Mod-exclusive features that aren't present in regular Usamune" },
	}
	local options = {
		timer = {
			{ name = "stop",     values = {"NONE", "GRAB", "xCAM", "GRABx"}, description =
            "Stops the timer when touching a star, touching the ground after grabbing a star, or stop on grab and update on ground touch" },
			{ name = "display",  values = {"HIDE", "GRAB", "xCAM", "ALWAYS"}, description =
            "Shows the timer on screen when grabing a star, x, x or always" },
			{ name = "pssrace",  values = {"NORMAL", "RACE", "SKIP", "END", "STACK"}, description =
            "Sets how and/or when the race timer should be displayed on screen" },
			{ name = "tmrposi",  values = {"NORMAL", "LEFT"}, description =
            "Sets the position of the timer" },
		},
		misct = {
			{ name = "numdisp",  values = {"off", "on"}, description =
            "\"Screenshots\" the timer when you collect a red coin or find a secret" },
			{ name = "wk",       values = {"off", "on"}, description =
            "\"Screenshots\" the timer when you wall kick" },
		},
		reset = {
			{ name = "lbutton",  values = {"none", "lreset", "sslect"}, description =
            "Resets the current level when you press L" },
			{ name = "lxr",      values = {"none", "lreset", "sslect" }, description =
            "Resets the current level when you press L + R" },
			{ name = "randstg",  values = {"off", "on"}, description =
            "Puts you in a random level when restarting" },
		},
		deflt = {
			{ name = "defcoin",  values = {"off", "on"}, description =
            "Always start levels with the specified number of coins",
				input = { text = "$x%03d",       length = 3, min = 0, max = 999 } },
			{ name = "defmiss",  values = {"off", "on"}, description =
            "Always start levels on the specified act number",
				input = { text = "mission %d",   length = 1, min = 1, max = 6 } },
		},
		hud = {
			{ name = "life",     values = {"normal", "igmenu", "fspeed", "vspeed", "vellen"}, description =
            "Overrides the lives count with player info" },
			{ name = "star",     values = {"normal", "igmenu", "fspeed", "vspeed", "vellen"}, description =
            "Overrides the stars counter with player info" },
			{ name = "dust",     values = {"off", "on"}, description =
            "Shows a counter that increases when you miss a 1st frame roll-out" },
			{ name = "wkdisp",   values = {"off", "on"}, description =
            "Shows the wall kick frame on screen for a second when you wall kick" },
			{ name = "attempt",  values = {"off", "on", "alert", "grab"}, description =
            "Shows the number of attempts on the current level (increases on level reset)" },
		},
		input = {
			{ name = "stick",    values = {"off", "onval", "onvis", "oncomb"}, description =
            "Displays your stick input axis, appearance, or both",
				alt = { values = {"small", "large"} } },
			{ name = "stkaxis",  values = {"usamun", "cdelux"}, description =
            "Raw stick axis (max ~127) or Usamune-accurate axis (max ~64)",
				enable_if = (Config.input.stick.value == 2 or Config.input.stick.value == 4) },
			{ name = "stickbg",  values = {"square", "circle"}, description =
            "Stick base appearance (mildly affects stick axis display)",
				enable_if = (Config.input.stick.value > 2) },
			{ name = "buttons",  values = {"off", "asmall", "alarge", "bsmall", "blarge"}, description =
            "Displays your button inputs",
				alt = { values = {"usamune", "cdeluxe"} } },
		},
		data = {
			{ name = "sstates",  values = {"off", "on"}, description =
            "Replicates save/load state functions found in emulators",
				alt = { values = {"dup", "cx4"} } },
		},
		delux = {
			{ name = "menubtn",  values = button_names,  description =
            "Sets the default button for opening the Usamune menu %n You can also use the '/usamenu' chat command" },
			{ name = "hints",    values = {"off", "on"}, description =
            "Shows submenu/option descriptions, just like this %n Please refer to the official Usamune ROM Manual for more detailed info  " },
			{ name = "arwlerp",  values = {"off", "on"}, description =
            "Makes the selection arrow move more smoothly", value = 7,
				input = { text = "weight %d",    length = 1, min = 1, max = 9 } },
			--{ name = "framep",   values = {"off", "dpadl", "dpadr"}, description = "Toggles autoframe-pauses on a single button press %n (DO NOT USE IN ACTUAL SPEEDRUNS)" },
		},
	}

   -- load selections
   for i, submenu in ipairs(submenus) do
      submenu.selection = selections[i] or submenu.selection
   end

	-- load "default" value
	for k, submenu in pairs(options) do
		for i, option in ipairs(submenu) do
			local cfg = Config[k][option.name]

			option.value = cfg.value

			-- option has alt value
			if option.alt then
				option.alt.value = cfg.alt

			-- option has number input value
			elseif option.input then
				option.input.value = cfg.alt
			end

			-- option always enabled if 'enable_if' is null
			option.enable_if = (option.enable_if == nil) or option.enable_if
		end
	end

   return { submenus = submenus, options = options}
end

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

local menu = {
   title = "MENU",

   main = {
      submenus = {
         arr = {},
         selection = 1,
         selected = false,
         pos = { x = 34, y = 44 },
         separation = 30,
         max_visible = 5,
      },
      options = {
         arr = {},
         offset_x = -42,
         separation = 22,

         input = {
            edit_mode = false,
            selected_char = 1,
         },
      },
   },
}

local function main_menu_update()
   for i, submenu in ipairs(menu.main.submenus.arr) do
      selections[i] = submenu.selection
   end

   local info = update_menu()
   menu.main.submenus.arr = info.submenus
   menu.main.options.arr = info.options
end


function menu.update_once()
   main_menu_update()
   menu.main.options.input.edit_mode = false
end

function menu.render()
	local visible_submenus = {}
	-- submenus
	visible_submenus.min = math.min(math.max(1, menu.main.submenus.selection - 2), menu.main.submenus.selection, #menu.main.submenus.arr - 4)
	visible_submenus.max = visible_submenus.min + 4
	
	for i = visible_submenus.min, visible_submenus.max do
		local submenu = menu.main.submenus.arr[i]
      if not submenu then break end
		
		local target = menu.main.submenus.pos.y - (menu.main.submenus.separation * visible_submenus.min)
		local submenu_y = (target + (i * menu.main.submenus.separation))
		
		-- darken other submenus if submenu selected
		local submenu_color = (menu.main.submenus.selected and i ~= menu.main.submenus.selection) and 170 or 255
		djui_hud_set_color(submenu_color, submenu_color, submenu_color, Usamenu.opacity)
		
		-- render submenu name
		djui_hud_print_text(filter_text(submenu.name), menu.main.submenus.pos.x, submenu_y, 1)
		-- render arrow next to selection
		if not menu.main.submenus.selected and i == menu.main.submenus.selection then
			arrowlerp(menu.main.submenus.pos.x - 10, submenu_y + 5)
			djui_hud_render_texture(Usamenu.tex_arrow, arrow_pos[1].x, arrow_pos[1].y, 1, 1)
		end
	end
	-- options
	for i = 0, 5 do
		local oindex = (i + 1)
		local option = menu.main.options.arr[menu.main.submenus.arr[menu.main.submenus.selection].name][oindex]
		if not option then break end
		
		local selection = menu.main.submenus.arr[menu.main.submenus.selection].selection
		local offset = from_screen_center(menu.main.options.offset_x, 0)
		local option_y = 58 + (i * menu.main.options.separation)
		
		-- change color if disabled
		local option_color = (option.enable_if) and 255 or 170
		
		-- render option names
		djui_hud_set_color(option_color, option_color, option_color, Usamenu.opacity)
		djui_hud_print_text(filter_text(option.name), offset.x, option_y, 1)
		-- render arrow next to selection
		if menu.main.submenus.selected and oindex == selection then
			arrowlerp(offset.x - 10, option_y + 5)
			djui_hud_render_texture(Usamenu.tex_arrow, arrow_pos[1].x, arrow_pos[1].y, 1, 1)
		end
		
		local values_x = (screen_w - menu.main.submenus.pos.x)
		
		if menu.main.submenus.selected and oindex == selection and option.value > 1 then
			-- alt values
			if option.alt then
				current_selection_has_alt_values = true
				
				for k, alt in ipairs(option.alt.values) do
					local alt_y = (screen_h - (#option.alt.values * 18) - 16) + ((k - 1) * 18)
					-- render arrow
					if k == option.alt.value then
						arrowlerp(values_x - djui_hud_measure_text(alt) - 10, alt_y + 5, 2)
						djui_hud_render_texture(Usamenu.tex_arrow, arrow_pos[2].x, arrow_pos[2].y, 1, 1)
						djui_hud_set_color(255, 255, 255, Usamenu.opacity)
					else
						djui_hud_set_color(170, 170, 170, Usamenu.opacity)
					end
					-- render text
					djui_hud_print_text_rtl(filter_text(alt), values_x, alt_y, 1)
					djui_hud_set_color(255, 255, 255, Usamenu.opacity)
				end
				
				-- input
				if buttonPressed(U_CBUTTONS) then
					option.alt.value = (option.alt.value - 2) % #option.alt.values + 1
					save_config(menu.main.submenus.arr[menu.main.submenus.selection].name, option.name, option.alt.value, true)
					main_menu_update()
					sound_play('change')
				-- c-right
				elseif buttonPressed(D_CBUTTONS) then
					option.alt.value = option.alt.value % #option.alt.values + 1
					save_config(menu.main.submenus.arr[menu.main.submenus.selection].name, option.name, option.alt.value, true)
					main_menu_update()
					sound_play('change')
				end
			
			-- input values
			elseif option.input then
				current_selection_has_alt_values = true
            local inputs = menu.main.options.input
				local input_y = (screen_h - 40)

				-- render text
            --local hue = inputs.edit_mode and 255 or 170
				--djui_hud_set_color(hue, hue, hue, Usamenu.opacity)
				djui_hud_set_color(255, 255, 255, Usamenu.opacity)
				djui_hud_print_text_rtl(filter_text(string.format(option.input.text, option.input.value)), values_x + 12, input_y - 18, 1)

            -- switch edit mode
            if buttonPressed(A_BUTTON) then
               inputs.edit_mode = not inputs.edit_mode
               sound_play('switchMenu')
            end

            if not inputs.edit_mode then
               djui_hud_print_text_rtl("PRESSA TO EDIT", values_x + 12, input_y, 1)
            else
   				for k = 1, option.input.length do
   					-- render arrow
   					if k == inputs.selected_char then
   						arrowlerp(values_x - (k * 12) + 16, input_y, 2)
   						djui_hud_render_texture(gTextures.arrow_up, arrow_pos[2].x, arrow_pos[2].y, 1, 1)
   					end
   				end

   				-- handle input
               local input = gMarioStates[0].controller.buttonPressed & (L_CBUTTONS | R_CBUTTONS | U_CBUTTONS | D_CBUTTONS)
               if input ~= 0 then
                  local steps = math.pow(10, inputs.selected_char - 1)
   
                  -- left - right
                  if option.input.length > 1 then
                     if input == L_CBUTTONS then
                        inputs.selected_char = inputs.selected_char % option.input.length + 1
                     elseif input == R_CBUTTONS then
                        inputs.selected_char = (inputs.selected_char - 2) % option.input.length + 1
                     end
                  end
                  -- up - down
                  if input == U_CBUTTONS then
                     option.input.value = option.input.value + steps
                  elseif input == D_CBUTTONS then
                     option.input.value = option.input.value - steps
                  end

                  option.input.value = (option.input.value - 1) % option.input.max + 1
                  option.input.value = math.clamp(option.input.value, option.input.min, option.input.max)

   					save_config(menu.main.submenus.arr[menu.main.submenus.selection].name, option.name, option.input.value, true)
   					main_menu_update()
   					sound_play('change')
               end
            end
				--	option.input.value = option.input.value % option.input.max + 1
				-- option.input.value = (option.input.value - 2) % option.input.max + 1
			else
				current_selection_has_alt_values = false
			end
		end

		-- value
		--djui_chat_message_create(tostring(option.enable_if))
		djui_hud_print_text_rtl(filter_text(option.values[option.value]), values_x, option_y, 1)
	end

	-- handle other inputs --
	-- submenus
	if not menu.main.submenus.selected then
		-- allow scroll if more than 1
		if #menu.main.submenus.arr > 1 then
			-- up
			if buttonPressed(U_JPAD) then
				menu.main.submenus.selection = (menu.main.submenus.selection - 2) % #menu.main.submenus.arr + 1
				sound_play('change')
			-- down
			elseif buttonPressed(D_JPAD) then
				menu.main.submenus.selection = menu.main.submenus.selection % #menu.main.submenus.arr + 1
				sound_play('change')
			end
		end
		-- right
		if buttonPressed(R_JPAD) then
			-- select submenu
			menu.main.submenus.selected = true
			sound_play('change')
		end
	end

	-- options
	if menu.main.submenus.selected and not menu.main.options.input.edit_mode then
		local submenu = menu.main.submenus.arr[menu.main.submenus.selection]
		local options = menu.main.options.arr[submenu.name]
		-- allow scroll if more than 1
		if #options > 1 then
			-- up
			if buttonPressed(U_JPAD) then
				local prev = submenu.selection
				while submenu.selection == prev or not options[submenu.selection].enable_if do
					submenu.selection = (submenu.selection - 2) % #options + 1
				end
				sound_play('change')
			-- down
			elseif buttonPressed(D_JPAD) then
				local prev = submenu.selection
				while submenu.selection == prev or not options[submenu.selection].enable_if do
					submenu.selection = submenu.selection % #options + 1
				end
				sound_play('change')
			end
		end
		
		-- unselect submenu
		if buttonPressed(L_JPAD) then
			menu.main.submenus.selected = false
			sound_play('change')
		end
		
		-- allow value scroll if more than 1 value
		if #options[submenu.selection].values > 1 then
			local option = options[submenu.selection]
			-- c-left
			if buttonPressed(L_CBUTTONS) then
				option.value = (option.value - 2) % #option.values + 1
				save_config(submenu.name, option.name, option.value)
				main_menu_update()
				sound_play('change')
			-- c-right
			elseif buttonPressed(R_CBUTTONS) then
				option.value = option.value % #option.values + 1
				save_config(submenu.name, option.name, option.value)
				main_menu_update()
				sound_play('change')
			end
		end
	end
	
	
	-- hints/descriptions --
	-- credits to the roblox bubble messages mod creator for some of this code!!!
	if Config.delux.hints.value > 1 then
		-- get submenu/option description if any
		local hint_text
		if menu.main.submenus.selected then
         -- fucking mess ik, sorry
			hint_text = menu.main.options.arr[menu.main.submenus.arr[menu.main.submenus.selection].name][menu.main.submenus.arr[menu.main.submenus.selection].selection].description
		else
			hint_text = menu.main.submenus.arr[menu.main.submenus.selection].description
		end
		
		-- text
		local text = {
			text = hint_text or "No description",
			pos = from_screen_center(0, 0),
			scale = 0.5,
			font_size = 14,
			
			lines = { "" },
			current_line = 1,
			line_width_max = screen_w + 20,
		}
		
		-- split words
		text.words = string.split(text.text, " ")
		
		-- description text lines
		for i, word in next, text.words do
			local wline = text.lines[text.current_line]
			-- add space before word if not the first
			wline = wline .. (i > 1 and " " or "") .. word
			
			local word_width = djui_hud_measure_text(word) * text.scale
			-- if word is line break (default '%n')
			local is_line_break = false
			
			-- if word width greater than limit or line break
			if word_width >= text.line_width_max or word == "%n" then
				-- line break or not
				if word == "%n" then
					is_line_break = true
					word = ""
				else
					is_line_break = false
				end
				
				-- add space before word if not the first nor a line break
				wline = text.lines[text.current_line] .. ((i > 1 and not is_line_break) and " " or "")
				
				-- for each character in word 
				for c = 1, #word do
					local character = string.sub(word, c, c)
					-- add character to line
					wline = wline .. character
					
					local line_width = djui_hud_measure_text(wline) * text.scale
					if line_width > text.line_width_max or is_line_break then
						text.current_line = text.current_line + 1
						wline = character
					end
					text.lines[text.current_line] = wline
				end
			end
			
			local line_width = djui_hud_measure_text(wline) * text.scale
			if line_width > text.line_width_max or is_line_break then
				text.current_line = text.current_line + 1
				wline = is_line_break and "" or word
			end
			text.lines[text.current_line] = wline
		end
		
		-- render bg
		djui_hud_set_color(0, 0, 0, Usamenu.opacity * 0.5)
		djui_hud_render_rect(0, screen_h - 32 - ((#text.lines - 1) * text.font_size), screen_w + 4, 32 + ((#text.lines - 1) * text.font_size))
		
		-- render text
		djui_hud_set_font(FONT_NORMAL)
		
		for i, line in next, text.lines do
			local text_y = (screen_h - 25) + ((i - 1) * text.font_size) - ((#text.lines - 1) * text.font_size)
			djui_hud_set_color(0, 0, 0, Usamenu.opacity)
			djui_hud_print_text_centered(line, text.pos.x + 1, text_y + 1, 0.5)
			djui_hud_set_color(255, 255, 255, Usamenu.opacity)
			djui_hud_print_text_centered(line, text.pos.x, text_y, 0.5)
		end
		
		djui_hud_set_font(FONT_HUD)
	end
end

return menu