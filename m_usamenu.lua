local djui_hud_set_resolution,djui_hud_set_font,get_screen_size,djui_hud_set_color_array,djui_hud_render_rect,djui_hud_set_color,djui_hud_print_text,is_game_paused,buttonPressed =
      djui_hud_set_resolution,djui_hud_set_font,get_screen_size,djui_hud_set_color_array,djui_hud_render_rect,djui_hud_set_color,djui_hud_print_text,is_game_paused,buttonPressed

local RANDOM_MSG_CHANCE = 0.1
local RANDOM_MSG_DEFAULT_TIME = 2*30 -- 2 mins

Usamenu = {
   -- selection arrow
   TEX_ARROW = get_texture_info('arrow_right'),

   -- global base menu stuff
   opacity = 0,
   bgcolor = { 0,0,0, 112 },

   ------------------------------
   -- IMPORT CUSTOM MENUS HERE --
   menus = {
      require('menus/main'),
      require('menus/levels'),
      --require('menus/test'),
   },
   ------------------------------

   -- default selected menu
   selected_menu = 1,
   -- if menu open button being pressed (used to avoid scrolling down instantly after opening the menu)
   open_button_pressed = false,
}

-- messages that appear at the bottom after opening the menu
local menu_bottom_msg = {
   visible = false,
   current = "",
   opacity = 0,
   time_left = 0, -- frames left until complete fade out
   timer_max = 0, -- frames to wait (fades out on last 15 frames)
}

-- get updated random messages so some of them (e.g. 'Play time') work properly
local function get_random_messages()
   return {
      -- usamune (these are all i could get)
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
      string.format("Play time %dmin", (get_global_timer() % 30) // 60),
      "v".. _G.USAMUNE_VERSION,

      -- custom
      "yo waddup",
      string.format("%s HERE FOR B3313", is_mobile() and "TAP" or "CLICK"),
      "come to brazil",
      "Pingas",
      "HOW GET BASEROM PLS",
      "69420th dust be like", -- spoilers! oops! sorry!
      "Doop Celuxe",

      "DE AD 26",
   }
end

-- show bottom message and start timer
function Usamenu.bottom_message(arr, frames)
   if not arr then return end
   menu_bottom_msg.current = pickRandom(arr)
   menu_bottom_msg.opacity = 255

   frames = frames or RANDOM_MSG_DEFAULT_TIME
   menu_bottom_msg.timer_max = frames
   menu_bottom_msg.time_left = frames
   menu_bottom_msg.visible = true
end

-- mainly for random messages
local current_selection_has_alt_values = false

-- open/close menu
function Usamune.toggle_menu(toggle)
   Usamune.in_menu = toggle
   set_audio_muted(toggle)
   -- open
   if toggle then
      Usamenu.opacity = 5

      -- chance of showing random message
      if not current_selection_has_alt_values and math.random() <= RANDOM_MSG_CHANCE then
         Usamenu.bottom_message(get_random_messages())
      end

      -- if single player
      if network_player_connected_count() == 1 then
         camera_freeze()
         enable_time_stop_including_mario()
      end
      hud_hide()

   -- close
   else
      menu_bottom_msg.visible = false

      camera_unfreeze()
      disable_time_stop_including_mario()

      if not Usamune.DEAD26 then hud_show() end
   end

   on_menu_toggled(toggle)
end

function Usamune.soft_reset()
   warp_to_start_level()
   Usamune.toggle_menu(false)
   log("Usamenu", "Executed soft reset")
end

---------------------------------

local hints = require('m_hints')
local current_menu = Usamenu.menus[Usamenu.selected_menu]

-- render menus
local function hud_render()
   if not Usamune.in_menu then return end
   djui_hud_set_resolution(RESOLUTION_N64)
   djui_hud_set_font(FONT_HUD)
   local w,h = get_screen_size()

   -- fade menu items in
   if Usamenu.opacity < 255 then
      local fade_in_by = 25
      Usamenu.opacity = math.clamp(Usamenu.opacity + fade_in_by, 0, 255)
   end
   -- render background
   djui_hud_set_color_array(current_menu.bgcolor or Usamenu.bgcolor, Usamenu.bgcolor[4])
   djui_hud_render_rect(0,0, w+4,h+4)

   -- render selected menu
   if current_menu.render then
      djui_hud_set_color(255,255,255, Usamenu.opacity)
      current_menu.render()
   end

   -- render hints
   if Config.delux.hints.value > 1 then
      if hints.render[current_menu.name] then
         hints.render_main()
         hints.render[current_menu.name](current_menu)
      end
   end

   -- render menu title
   djui_hud_set_font(FONT_HUD)
   djui_hud_set_color(255,255,255, Usamenu.opacity)
   djui_hud_print_text(string.format("* %s *", current_menu.title), 24, 16, 1) -- '*' == star icon

   -- render random message
   if menu_bottom_msg.visible then
      djui_hud_set_color(255,255,255, math.min(Usamenu.opacity, menu_bottom_msg.opacity))
      djui_hud_print_text(menu_bottom_msg.current, 32, h-32, 1)
   end
end
hook_event(HOOK_ON_HUD_RENDER, hud_render)

-- if menu switched or opened
function on_menu_switched(oldIndex, newIndex)
   current_menu = Usamenu.menus[newIndex]

   -- update next menu if needed
   if current_menu.update_once then current_menu.update_once() end

   -- play sound if next menu is different (in case there's only one menu)
   if oldIndex ~= newIndex then
      sound_play('switchMenu')
   end
end

-- if menu toggled on/off
function on_menu_toggled(toggle)
end

local button_names = Usamune.buttons
-- on open menu button pressed
local function toggle_as_button(toggle)
   if type(toggle) ~= 'boolean' then
      toggle = not Usamenu.in_menu
   end
   Usamune.toggle_menu(toggle)
   on_menu_switched(Usamenu.selected_menu, Usamenu.selected_menu)
   on_menu_toggled(toggle)
   sound_play('pause')
   if Config.delux.menubtn.value <= #button_names.indexed then
      Usamenu.open_button_pressed = true
   end

   return true
end

local HOLD_TIME = {
   soft_reset = {
      max = 15,
      elapsed = 0
   },
}

local function update()
   if is_game_paused() then return end

   if Usamenu.open_button_pressed then
      Usamenu.open_button_pressed = buttonDown(button_names.indexed[Config.delux.menubtn.value].id)
   end

   -- menu is closed
   if not Usamune.in_menu then
      -- open menu
      if Config.delux.menubtn.value <= #button_names.indexed
      and buttonPressed(button_names.indexed[Config.delux.menubtn.value].id) then
         toggle_as_button(true)
      end

   -- menu is open
   else
      -- soft reset timer
      if (gMarioStates[0].controller.buttonDown & START_BUTTON) ~= 0 then
         local sr = HOLD_TIME.soft_reset
         if sr.elapsed < sr.max then
            sr.elapsed = sr.elapsed + 1
            if sr.elapsed == sr.max then
               Usamune.soft_reset()
               --Usamenu.bottom_message({"SOFT RESET FAILED"})
            end
         end
      else
         HOLD_TIME.soft_reset.elapsed = 0
      end

      -- close menu
      if buttonPressed(B_BUTTON) then
         toggle_as_button(false)

      -- switch to previous menu
      elseif buttonPressed(L_TRIG) then
         local previndex = Usamenu.selected_menu
         Usamenu.selected_menu = wraplua(Usamenu.selected_menu - 1, 1, #Usamenu.menus)
         on_menu_switched(previndex, Usamenu.selected_menu)

      -- switch to next menu
      elseif buttonPressed(R_TRIG) then
         local previndex = Usamenu.selected_menu
         Usamenu.selected_menu = wraplua(Usamenu.selected_menu + 1, 1, #Usamenu.menus)
         on_menu_switched(previndex, Usamenu.selected_menu)
      end

      -- if bottom message active
      if menu_bottom_msg.visible then
         local msg = menu_bottom_msg
         -- decrease time left
         if msg.time_left > 0 then
            msg.time_left = msg.time_left - 1
         end

         -- fade out before timeout
         if msg.time_left <= 15 then
            local fade_out_by = 17
            msg.opacity = math.clamp(msg.opacity - fade_out_by, 0, 255)
         end
         -- hide message if timeout or fully transparent
         if msg.time_left <= 0 or msg.opacity <= 0 then
            msg.visible = false
         end
      end
   end
end
hook_event(HOOK_UPDATE, update)

-- wrap selection and play sound
function Usamenu.move_selection(nextIndex, min, max, sound)
   local selection = wraplua(nextIndex, min, max)

   -- only play sound if selection actually changed
   if selection ~= nextIndex and sound ~= '' then
      sound_play(sound or 'change')
   end
   return selection
end

-- prevent pause when menu is open
local function before_play_mode_upd(mode)
   local m = gMarioStates[0]
   if Usamune.in_menu and buttonPressed(START_BUTTON) then
      m.controller.buttonPressed = m.controller.buttonPressed &~ START_BUTTON
   end

   -- fix pausing and opening usamenu at the same time
   if Usamune.in_menu and is_game_paused() then
      game_unpause()
   end
end
hook_event(HOOK_BEFORE_PLAY_MODE_UPDATE, before_play_mode_upd)

-- menu chat command
hook_chat_command("usamenu", "- Toggle the Usamune menu on/off", toggle_as_button)
