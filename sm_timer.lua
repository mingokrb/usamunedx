local djui_hud_set_resolution,djui_hud_set_font,djui_hud_set_color,djui_hud_print_text_rtl,is_game_paused,get_id_from_behavior = djui_hud_set_resolution,djui_hud_set_font,djui_hud_set_color,djui_hud_print_text_rtl,is_game_paused,get_id_from_behavior

local in_act_select = false

local function int(bool)
   return bool and 1 or 0
end

-- timer format is entirely based on subtimer which is pure elapsed frames
local subtimer = 0
Usatimer = {
   time = {
      mins = 0,
      secs = 0,
      ms = 0,
   },
   racetmr_screentime = 0,

   render_layer = "behind",
   is_paused = false, -- paused by opening the menu
   is_running = true,
   is_hidden = true,
   shot = {
      time = {
         mins = 0,
         secs = 0,
         ms = 0,
      },
      max_lifespan = 30, -- in frames
      remaining = 0,
   },
}

local interactions = {
   -- [INTERACTION_TYPE] = interactionValue
   stop = {
      [INTERACT_WARP_DOOR] = true,
      [INTERACT_BBH_ENTRANCE] = true,
   },
   screenshot = {
      [INTERACT_WARP] = true,
      [INTERACT_HOOT] = true,
      [INTERACT_DOOR] = true,
      [INTERACT_CAP] = true,
      [INTERACT_POLE] = true,
      [INTERACT_BREAKABLE] = true,
      [INTERACT_WATER_RING] = true,
      [INTERACT_KOOPA_SHELL] = true,
      [INTERACT_TEXT] = true,
   }
}

local timer_pos = {
   x = 0,
   y = 20,
   separation = 20,
}

local function render_timers()
   if Usamune.in_menu or is_game_paused() then
      Usatimer.render_layer = "front"
   else
      Usatimer.render_layer = "behind"
   end
   djui_hud_set_resolution(RESOLUTION_N64)
   djui_hud_set_font(FONT_CUSTOM_HUD)

   Usatimer.is_hidden = in_act_select or (Config.timer.display.value ~= 4)
   Usatimer.is_hidden = Usatimer.is_hidden or (Config.timer.pssrace.value == 2 and Usatimer.racetmr_screentime > 0)

   local right_stack = 0
   if not Usamune.in_menu then
      right_stack = right_stack
      -- main timer on screen
         + int(not Usatimer.is_hidden)

      -- race/slide timer on screen
      if Config.timer.pssrace.value == 5 then
         right_stack = right_stack + min(hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAGS_TIMER, 1)
      end
   end

   timer_pos.x = screen.width - (Config.timer.tmrposi.value == 1 and 18 or 24)
   local timer_y = timer_pos.y + (right_stack * timer_pos.separation)

   djui_hud_set_color(255, 255, 255, 255)
   -- main timer
   if Usamune.in_menu or not Usatimer.is_hidden then
      local timerstr = string.format("%d'%02d\"%02d", Usatimer.time.mins, Usatimer.time.secs, Usatimer.time.ms)
      djui_hud_print_text_rtl(timerstr, timer_pos.x, timer_y, 1)
   end
   -- screenshot timer
   if Usatimer.shot.remaining > 0 then
      local t = Usatimer.shot.time
      local timerstr = string.format("%d'%02d\"%02d", t.mins, t.secs, t.ms)
      djui_hud_print_text_rtl(timerstr, timer_pos.x, timer_y + timer_pos.separation, 1)
   end
end

local function on_hud_render_behind()
   if Usatimer.render_layer == "behind" then
      render_timers()
   end
end
local function on_hud_render()
   if Usatimer.render_layer == "front" then
      render_timers()
   end
end
hook_event(HOOK_ON_HUD_RENDER_BEHIND, on_hud_render_behind)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

local function update()
   if not Usatimer.is_running or Usamune.in_menu then return end

   -- update timer
   subtimer = subtimer + 1
   Usatimer.time.ms = math.floor((subtimer / 30) * 100) % 100
   Usatimer.time.secs = math.floor(subtimer / 30) % 60
   Usatimer.time.mins = math.floor(subtimer / (30 * 60))

   -- update screenshot
   if Usatimer.shot.remaining > 0 then
      Usatimer.shot.remaining = Usatimer.shot.remaining - 1
   end


   -- PSSRACE
   if Config.timer.pssrace.value == 1 then
      Usatimer.racetmr_screentime = 0

   elseif Config.timer.pssrace.value == 2 or Config.timer.pssrace.value == 4 then
      if level_control_timer_running() > 0 then
         Usatimer.racetmr_screentime = 30
      end
   
      if Usatimer.racetmr_screentime > 0 then
         Usatimer.racetmr_screentime = Usatimer.racetmr_screentime - 1
      end
   end

   if Usatimer.racetmr_screentime <= 0 then
      hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) & ~HUD_DISPLAY_FLAGS_TIMER)
   end
end
hook_event(HOOK_UPDATE, update)

local should_restart_timer = true
hook_event(HOOK_BEFORE_WARP, function(destLevel, destArea)
   should_restart_timer = gNetworkPlayers[0].currLevelNum ~= destLevel
end)

local function on_warp()
   if should_restart_timer then
      subtimer = 0
   end
   Usatimer.is_running = true
   Usatimer.shot.remaining = 0
   in_act_select = false
end
hook_event(HOOK_ON_WARP, on_warp)

-- timer functions --
function Usatimer.stop(hideTimer)
   Usatimer.is_running = false

   if hideTimer then
   end
end
function Usatimer.screenshot(hideTimer)
   Usatimer.shot.time = {
      mins = Usatimer.time.mins,
      secs = Usatimer.time.secs,
      ms = Usatimer.time.ms,
   }
   Usatimer.shot.remaining = Usatimer.shot.max_lifespan

   if hideTimer then
   end
end



local function on_interact(m, obj, intType, val)
   if m.playerIndex ~= 0 then return end

   -- red coins
   if intType == INTERACT_COIN then
      if get_id_from_behavior(obj.behavior) == id_bhvRedCoin then
         Usatimer.screenshot()
         return
      end
   end

   -- stop timer
   for i, value in pairs(interactions.stop) do
      if i == intType and value == val then
         Usatimer.stop()
         return
      end
   end
   -- screenshot timer
   for i, value in pairs(interactions.screenshot) do
      if i == intType and value == val then
         Usatimer.screenshot()
      end
   end
end
hook_event(HOOK_ON_INTERACT, on_interact)


-- basically serves as a HOOK_ON_ACT_SELECT
local function on_obj_load(obj)
   if get_id_from_behavior(obj.behavior) == id_bhvActSelector then
      in_act_select = true
   end
end

hook_event(HOOK_ON_OBJECT_LOAD, on_obj_load)
