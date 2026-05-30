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
         "Timer functions" },
		{ name = "misct", selection = 1, description =
         "Miscellaneous timing functions" },
		{ name = "reset", selection = 1, description =
         "Resetting functions" },
		{ name = "deflt", selection = 1, description =
         "Default values applied on level start" },
		{ name = "hud",   selection = 1, description =
         "Additional information to display on the HUD" },
		{ name = "input", selection = 1, description =
         "Input Display-specific functions" },
		{ name = "data",  selection = 1, description =
         "Game data functions" },
		{ name = "misc",  selection = 1, description =
         "Miscellaneous functions" },
		{ name = "delux", selection = 1, description =
         "Mod-exclusive functions that aren't present in regular Usamune" },
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
			{ name = "misctmr",  values = {"off", "on"}, description =
            "Highlights the current time when a condition is met\nThe following options are all the available conditions" },
			{ name = "numdisp",  values = {"off", "on"}, description =
            "When you collect a red coin or find a secret" },
			{ name = "xcam",     values = {"off", "on"}, description =
            "When you touch the ground after getting a star" },
			{ name = "bswitch",  values = {"off", "on"}, description =
            "When you press a \\#cc4040\\cap \\#2070cc\\swi\\#40cc40\\tch" },
			{ name = "pswitch",  values = {"off", "on"}, description =
            "When you press a \\#aa70cc\\purple switch" },
			{ name = "ride",     values = {"off", "on"}, description =
            "When you start riding a Koopa shell" },
			{ name = "chest",    values = {"off", "on"}, description =
            "When you open a chest" },
			{ name = "crystal",  values = {"off", "on"}, description =
            "When you ........ a crystal" },
			{ name = "enemy",    values = {"off", "on"}, description =
            "When you defeat an enemy" },
			{ name = "exclbox",  values = {"off", "on"}, description =
            "When you break an [!] box" },
			{ name = "corkbox",  values = {"off", "on"}, description =
            "When you grab a cork box" },
			{ name = "objgrab",   values = {"off", "on"}, description =
            "When you grab an object" },
			{ name = "ldgegrb",  values = {"off", "on"}, description =
            "When you perform a ledge-grab" },
			{ name = "polegrb",  values = {"off", "on"}, description =
            "When you perform a pole-grab" },
			{ name = "wk",       values = {"off", "on"}, description =
            "When you perform a wall-kick" },
			{ name = "wallhit",  values = {"off", "on"}, description =
            "When you hit a wall" },
			{ name = "clip",     values = {"off", "on"}, description =
            "When you clip out-of-bounds" },
			{ name = "surface",  values = {"off", "on"}, description =
            "When you reach the surface" },
			{ name = "flip",     values = {"off", "on"}, description =
            "When you perform a flip" },
			{ name = "rollout",  values = {"off", "on"}, description =
            "When you perform a roll-out" },
			{ name = "dive",     values = {"off", "on"}, description =
            "When you perform a dive" },
			{ name = "ljsldk",   values = {"off", "on"}, description =
            "When you perform a lj-sldk idk" },
			{ name = "tj",       values = {"off", "on"}, description =
            "When you perform a tj" },
			{ name = "load",     values = {"off", "on"}, description =
            "When the Load" },
			{ name = "bowser",   values = {"off", "on"}, description =
            "When you grab Bowser's tail" },
			{ name = "coin",     values = {"off", "on"}, description =
            "When you collect a coin" },
			{ name = "oneup",     values = {"off", "on"}, description =
            "When you collect an extra life" },
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
            "Overrides the life counter with player info" },
			{ name = "star",     values = {"normal", "igmenu", "fspeed", "vspeed", "vellen"}, description =
            "Overrides the star counter with player info" },
			{ name = "dust",     values = {"off", "on"}, description =
            "Shows a counter that increases when you miss a 1st frame roll-out" },
			{ name = "wkdisp",   values = {"off", "on"}, description =
            "Shows the wall kick frame on screen for a second when you wall kick" },
			{ name = "attempt",  values = {"off", "on", "alert", "grab"}, description =
            "Shows the number of attempts on the current level (increases on level reset)" },
			{ name = "bpsdisp",  values = {"off", "on"}, description =
            "Shows the number of buttons pressed per second" },
		},
		input = {
			{ name = "stick",    values = {"off", "onval", "onvis", "oncomb"}, description =
            "Displays your stick input axis, appearance, or both",
				alt = { values = {"small", "large"} } },
			{ name = "stkbase",  values = {"square", "circle"}, description =
            "Stick base appearance (mildly affects stick axis display)",
				enable_if = (Config.input.stick.value > 2) },
			{ name = "stkaxis",  values = {"usamun", "cdelux"}, description =
            "Raw stick axis (max ~127) or Usamune-accurate axis (max ~64)",
				enable_if = (Config.input.stick.value == 2 or Config.input.stick.value == 4) },
			{ name = "buttons",  values = {"off", "asmall", "alarge", "bsmall", "blarge"}, description =
            "Displays your button inputs",
				alt = { values = {"usamune", "cdeluxe"} } },
		},
		data = {
			{ name = "sstates",  values = {"off", "on"}, description =
            "Replicates save/load state functions found in emulators",
				alt = { values = {"dup", "cx4"} } },
		},
		misc = {
			{ name = "music",    values = {"on", "off"}, description =
            "Toggles sequence loading\nDoes not apply to streamed music from mods" },
      },
		delux = {
			{ name = "menubtn",  values = button_names,  description =
            "Sets the default button for opening the Usamune menu\nYou can also use the \\#aaaaaa\\/usamenu\\#ffffff\\ chat command" },
			{ name = "hints",    values = {"off", "on"}, description =
            "Shows submenu/option descriptions, just like this\nPlease refer to the \\#dddd60\\official Usamune ROM Manual\\#ffffff\\ for more detailed info  " },
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

local scroll_time = 0
local scroll_max_time = 10

local menu = {
   name = "main",
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
	-- submenus
	local visible_submenus = {}
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
	local visible_options = {}
	local submenu = menu.main.submenus.arr[menu.main.submenus.selection]
	visible_options.min = math.min(math.max(1, submenu.selection - 2), submenu.selection, math.max(1, #menu.main.options.arr[submenu.name] - 4))
	visible_options.max = visible_options.min + 4

	for i = visible_options.min, visible_options.max do
		local option = menu.main.options.arr[submenu.name][i]
		if not option then break end

		local offset = from_screen_center(menu.main.options.offset_x, 0)
		local target = 58 - (menu.main.options.separation * visible_options.min)
		local option_y = target + (i * menu.main.options.separation)

		-- change color if disabled
		local option_color = (option.enable_if) and 255 or 170
		local values_x = (screen.width - menu.main.submenus.pos.x)

		-- render option names
		djui_hud_set_color(option_color, option_color, option_color, Usamenu.opacity)
		djui_hud_print_text(filter_text(option.name), offset.x, option_y, 1)

		if menu.main.submenus.selected and i == submenu.selection then
		   -- render arrow next to selection
			arrowlerp(offset.x - 10, option_y + 5)
			djui_hud_render_texture(Usamenu.tex_arrow, arrow_pos[1].x, arrow_pos[1].y, 1, 1)

      	if option.value > 1 then
      		-- alt values
      		if option.alt then
      			current_selection_has_alt_values = true

      			for k, alt in ipairs(option.alt.values) do
      				local alt_y = (screen.height - (#option.alt.values * 18) - 16) + ((k - 1) * 18)
      				-- render arrow
      				if k == option.alt.value then
      					arrowlerp(values_x - djui_hud_measure_text(alt) - 10, alt_y + 5, 2)
      					djui_hud_render_texture(Usamenu.tex_arrow, arrow_pos[2].x, arrow_pos[2].y, 1, 1)
      					djui_hud_set_color(255,255,255, Usamenu.opacity)
      				else
      					djui_hud_set_color(170,170,170, Usamenu.opacity)
      				end
      				-- render text
      				djui_hud_print_text_rtl(filter_text(alt), values_x, alt_y, 1)
      				djui_hud_set_color(255,255,255, Usamenu.opacity)
      			end

      			-- input
      			if buttonPressed(U_CBUTTONS) then
      				option.alt.value = (option.alt.value - 2) % #option.alt.values + 1
      				save_config(submenu.name, option.name, option.alt.value, true)
      				main_menu_update()
      				sound_play('change')
      			-- c-right
      			elseif buttonPressed(D_CBUTTONS) then
      				option.alt.value = option.alt.value % #option.alt.values + 1
      				save_config(submenu.name, option.name, option.alt.value, true)
      				main_menu_update()
      				sound_play('change')
      			end

      		-- input values
      		elseif option.input then
      			current_selection_has_alt_values = true
               local inputs = menu.main.options.input
      			local input_y = (screen.height - 40)

   				-- render text
               --local hue = inputs.edit_mode and 255 or 170
   				--djui_hud_set_color(hue, hue, hue, Usamenu.opacity)
   				djui_hud_set_color(255,255,255, Usamenu.opacity)
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

      					save_config(submenu.name, option.name, option.input.value, true)
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
      end
		-- value
		djui_hud_print_text_rtl(filter_text(option.values[option.value]), values_x, option_y, 1)
	end

   local submenus = menu.main.submenus
   local options = menu.main.options

	-- handle other inputs --
	-- submenus
	if not submenus.selected then
		-- allow scroll if more than 1
		if #submenus.arr > 1 then
         local input = gMarioStates[0].controller.buttonDown & (U_JPAD | D_JPAD)
         if input ~= 0 and not Usamenu.opening_button_pressed then
            scroll_time = scroll_time + 1

            if scroll_time == 1 or scroll_time >= scroll_max_time then
               if scroll_time > 1 then
                  scroll_time = scroll_max_time - 3
               end
			      -- up - down
   			   if input == U_JPAD then
                  submenus.selection = Usamenu.move_selection(submenus.selection, 1, #submenus.arr, -1)
               elseif input == D_JPAD then
                  submenus.selection = Usamenu.move_selection(submenus.selection, 1, #submenus.arr, 1)
               end
            end
         else
            scroll_time = 0
         end
		end
		-- right
		if buttonPressed(R_JPAD) then
			-- select submenu
			submenus.selected = true
			sound_play('change')
		end
	end

	-- options
	if submenus.selected and not options.input.edit_mode then
		local submenu = submenus.arr[submenus.selection]
		local options = options.arr[submenu.name]
		-- allow scroll if more than 1
      local input = gMarioStates[0].controller.buttonDown & (U_JPAD | D_JPAD)
		if input ~= 0 and #options > 1 and not Usamenu.opening_button_pressed then
         scroll_time = scroll_time + 1
         if scroll_time == 1 or scroll_time >= scroll_max_time then
            if scroll_time > 1 then
               scroll_time = scroll_max_time - 3
            end

   			local prev = submenu.selection
   			-- up - down
   			if input == U_JPAD then
   				while submenu.selection == prev or not options[submenu.selection].enable_if do
                  submenu.selection = Usamenu.move_selection(submenu.selection, 1, #options, -1, '')
   				end
   			elseif input == D_JPAD then
   				while submenu.selection == prev or not options[submenu.selection].enable_if do
                  submenu.selection = Usamenu.move_selection(submenu.selection, 1, #options, 1, '')
   				end
   			end
            sound_play('change')
         end
      else
         scroll_time = 0
		end
		
		-- unselect submenu
		if buttonPressed(L_JPAD) then
			submenus.selected = false
			sound_play('change')
		end
		
		-- allow value scroll if more than 1 value
		if #options[submenu.selection].values > 1 then
			local option = options[submenu.selection]
			-- c-left
			if buttonPressed(L_CBUTTONS) then
            option.value = Usamenu.move_selection(option.value, 1, #option.values, -1)
				save_config(submenu.name, option.name, option.value)
				main_menu_update()
			-- c-right
			elseif buttonPressed(R_CBUTTONS) then
            option.value = Usamenu.move_selection(option.value, 1, #option.values, 1)
				save_config(submenu.name, option.name, option.value)
				main_menu_update()
			end
		end
	end
end

return menu