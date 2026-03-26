local djui_hud_print_text,djui_hud_set_color_array = djui_hud_print_text,djui_hud_set_color_array
local filter_text = filter_text

Usamenu = {
   -- selection arrow
   tex_arrow = get_texture_info('arrow_right'),

   -- global base menu stuff
   opacity = 0,
   bg_color = { 0, 0, 0, 112 },

   -- INCLUDE YOUR CUSTOM MENUS HERE --
   menus = {
	   require('menus/main'),
	   require('menus/levels'),
	   --require('menus/debug'),
   },
   -- default selected menu
   selected_menu = 1,
}


local menu_info = {
   -- random messages that appear when opening the menu
   random_messages = {
      arr = {},
      on_screen = false,
      selected_message = "",
      opacity = 0,
      -- time in frames until message fades out
      timer = 0,
      -- 2 seconds; message starts fading out at 1.5
      timer_max = 60,
   },
}

-- this is done so messages like "total playtime" work properly by calling this function each time you open the menu
local function update_messages()
	menu_info.random_messages.arr = {
		-- usamune (these are all i could find)
		"TY for using Usamune",
		"Usamune Hello Work",
		"Developed by Usampas",
		"Time is money",
		"Easy Come Easy Go",
		"Stay hungry",
		"Good luck",
		"Do your best",
		"You can do it",
		"Whats up?",
		"I like Chopin",
		"Play time ".. math.floor((get_global_timer() % 30) / 60) .."min",

		-- custom
		"yo waddup",
		((get_os_name():lower() == 'android' or get_os_name():lower() == 'ios') and "tap" or "click") .." here for B3313", -- gotta think about everything
		"come to brazil",
		"Pingas",
		"HOW GET BASEROM PLS",
		"69420th dust be like", -- spoilers! oops! sorry!
	}
end

-- show bottom message and start timer
function Usamenu.bottom_message(msgArray, timerMax)
   if not msgArray then
      update_messages()
      msgArray = menu_info.random_messages.arr
   end
	menu_info.random_messages.selected_message = table.pickRandom(msgArray)
	menu_info.random_messages.timer_max = timerMax or 60

	menu_info.random_messages.timer = menu_info.random_messages.timer_max
	menu_info.random_messages.opacity = 255
	menu_info.random_messages.on_screen = true
end

-- mainly for random messages
local current_selection_has_alt_values = false

-- enable or disable menu
function Usamune.toggle_menu(toggle)
	Usamune.in_menu = toggle
	set_audio_muted(toggle)
	if toggle then
		-- on
		Usamenu.opacity = 5
		
		-- chance of showing random message
		if not current_selection_has_alt_values and math.random(5) == 1 then
			Usamenu.bottom_message()
		end

		if network_player_connected_count() == 1 then
			camera_freeze()
			enable_time_stop_including_mario()
		end
		hud_hide()
	else
		-- off
		menu_info.random_messages.on_screen = false

		camera_unfreeze()
		disable_time_stop_including_mario()
		hud_show()
	end

   on_menu_toggled(toggle)
end

local current_menu = Usamenu.menus[Usamenu.selected_menu]

-- render menus
local function hud_render()
	if is_game_paused() or not Usamune.in_menu then return end
	djui_hud_set_resolution(RESOLUTION_N64)
	djui_hud_set_font(FONT_HUD)

	-- fade menu items in
	if Usamenu.opacity < 255 then
		Usamenu.opacity = Usamenu.opacity + 25
	end
	-- render background
	djui_hud_set_color_array(current_menu.bg_color or Usamenu.bg_color, Usamenu.bg_color[4])
	djui_hud_render_rect(0, 0, screen_w + 4, screen_h + 4)

	-- render selected menu
   if current_menu.render then
	   djui_hud_set_color(255, 255, 255, Usamenu.opacity)
	   current_menu.render()
      djui_hud_set_font(FONT_HUD)
   end

	-- render menu title
	djui_hud_set_color(255, 255, 255, Usamenu.opacity)
	djui_hud_print_text(filter_text("* ".. current_menu.title .." *"), 24, 16, 1)

	-- render random message
	if menu_info.random_messages.on_screen then
		djui_hud_set_color(255,255,255, math.min(Usamenu.opacity, menu_info.random_messages.opacity))
		djui_hud_print_text(filter_text(menu_info.random_messages.selected_message), 32, screen_h - 32, 1)
	end
end
hook_event(HOOK_ON_HUD_RENDER, hud_render)

-- if menu switched or opened
function on_menu_switched(oldIndex, newIndex)
   local menu = Usamenu.menus[Usamenu.selected_menu]
   if menu.update_once then
      menu.update_once()
   end

   current_menu = Usamenu.menus[newIndex]

   if oldIndex ~= newIndex then
      sound_play('switchMenu')
   end
end

-- if menu toggled on/off
function on_menu_toggled()
end

local function toggle_as_button(toggle)
   if toggle == nil or type(toggle) ~= 'boolean' then
      toggle = not Usamenu.in_menu
   end
	Usamune.toggle_menu(toggle)
   on_menu_switched(Usamenu.selected_menu, Usamenu.selected_menu)
   on_menu_toggled()
	sound_play('pause')

   return true
end

local button_names = Usamune.buttons
local hold_times = {
   soft_reset = {
      max = 15,
      elapsed = 0,
   },
   category_reset = {
      max = 20,
      elapsed = 0,
   },
}

local function update()
	if is_game_paused() then return end

	-- menu is closed
	if not Usamune.in_menu then
		-- open menu
		if Config.delux.menubtn.value ~= #button_names.indexed + 1 and buttonPressed(button_names.indexed[Config.delux.menubtn.value].id) then
         toggle_as_button(true)
		end

	-- menu is open
	else
      -- soft reset
      if (gMarioStates[0].controller.buttonDown & START_BUTTON) ~= 0 then
         local sr = hold_times.soft_reset
         sr.elapsed = sr.elapsed + 1
         if sr.elapsed == sr.max then
            sr.elapsed = 0
            warp_to_level(gLevelValues.entryLevel, 1, 1)
            console_log("Usamenu", "Executed soft reset")
         end
      else
         hold_times.soft_reset.elapsed = 0
      end

		-- close menu
		if buttonPressed(B_BUTTON) then
         toggle_as_button(false)

		-- go to previous menu
		elseif buttonPressed(L_TRIG) then
         local previndex = Usamenu.selected_menu
			Usamenu.selected_menu = (Usamenu.selected_menu - 2) % #Usamenu.menus + 1
         on_menu_switched(previndex, Usamenu.selected_menu)

		-- go to next menu
		elseif buttonPressed(R_TRIG) then
         local previndex = Usamenu.selected_menu
			Usamenu.selected_menu = Usamenu.selected_menu % #Usamenu.menus + 1
         on_menu_switched(previndex, Usamenu.selected_menu)
		end

		-- random message timer activated
		if menu_info.random_messages.on_screen then
			local msg = menu_info.random_messages
			-- increase timer
         if msg.timer > 0 then
			   msg.timer = msg.timer - 1
         end

			-- fade out before time out
			if msg.timer <= 15 then
				msg.opacity = msg.opacity - 17
			end
			-- hide timer when fully timed out
			if msg.timer <= 0 then
				msg.on_screen = false
			end
		end
	end
end
hook_event(HOOK_UPDATE, update)

hook_chat_command("usamenu", "- Toggle the Usamune menu on/off", toggle_as_button)