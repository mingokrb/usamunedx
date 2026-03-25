local djui_hud_set_resolution,djui_hud_set_font,djui_hud_print_text_rtl = djui_hud_set_resolution,djui_hud_set_font,djui_hud_print_text_rtl

local in_act_select = false

local function int(bool)
   return bool and 1 or 0
end

-- timer format is entirely based on subtimer which is pure elapsed frames
local subtimer = 0
timer = {
   time = {
      mins = 0,
      secs = 0,
      ms = 0,
   },
   racetmr_screentime = 0,

   is_paused = false, -- paused by opening the menu
   is_running = true,
   is_hidden = true,
   shot = {
      time = {
         mins = 0,
         secs = 0,
         ms = 0,
      },
      max_lifespan = 60, -- in frames
      remaining = 0,
   },
}

local interactions = {
   -- [INTERACTION_TYPE] = interactionValue
   stop = {
      [INTERACT_WARP_DOOR] = true,
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
      [INTERACT_BBH_ENTRANCE] = true,
   }
}

local timer_pos = {
   x = screen_w - 24,
   y = 20,
   separation = 20,
}

local function hud_render_behind()
   djui_hud_set_resolution(RESOLUTION_N64)
   djui_hud_set_font(FONT_CUSTOM_HUD)

   timer.is_hidden = in_act_select or (Config.timer.display.value ~= 4)

   local right_stack = 0
   if not Usamune.in_menu then
      right_stack = right_stack
      -- main timer on screen
         + int(not timer.is_hidden)

      -- race/slide timer on screen
      if Config.timer.pssrace.value == 5 then
         right_stack = right_stack + min(hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAGS_TIMER, 1)
      end
   end

   timer_pos.x = screen_w - (Config.timer.tmrposi.value == 1 and 18 or 24)
   local timer_y = timer_pos.y + (right_stack * timer_pos.separation)

   djui_hud_set_color(255, 255, 255, 255)
   -- main timer
   if not timer.is_hidden then
      local timerstr = string.format("%d'%02d\"%02d", timer.time.mins, timer.time.secs, timer.time.ms)
      djui_hud_print_text_rtl(timerstr, timer_pos.x, timer_y, 1)
   end
   -- screenshot timer
   if timer.shot.remaining > 0 then
      local t = timer.shot.time
      local timerstr = string.format("%d'%02d\"%02d", t.mins, t.secs, t.ms)
      djui_hud_print_text_rtl(timerstr, timer_pos.x, timer_y + timer_pos.separation, 1)
   end
end
hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)

local function update()
   if not timer.is_running or Usamune.in_menu then return end

   -- update timer
   subtimer = subtimer + 1
   timer.time.ms = math.floor((subtimer / 30) * 100) % 100
   timer.time.secs = math.floor(subtimer / 30) % 60
   timer.time.mins = math.floor(subtimer / (30 * 60))

   -- update screenshot
   if timer.shot.remaining > 0 then
      timer.shot.remaining = timer.shot.remaining - 1
   end


   -- PSSRACE
   if Config.timer.pssrace.value == 1 then
      hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) & ~HUD_DISPLAY_FLAGS_TIMER)

   elseif Config.timer.pssrace.value == 2 or Config.timer.pssrace.value == 4 then
      if level_control_timer_running() > 0 then
         timer.racetmr_screentime = 30
      end
   
      if timer.racetmr_screentime > 0 then
         timer.racetmr_screentime = timer.racetmr_screentime - 1
      end
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
   timer.is_running = true

   --if obj_get_first_with_behavior_id(id_bhvActSelector) then
   --   printc('TEM')
   --end
end
hook_event(HOOK_ON_WARP, on_warp)

local function on_seq_load(p, seqId)
   in_act_select = seqId == SEQ_MENU_STAR_SELECT
end
hook_event(HOOK_ON_SEQ_LOAD, on_seq_load)

-- timer functions --
function timer.stop(hideTimer)
   timer.is_running = false

   if hideTimer then
   end
end
function timer.screenshot(hideTimer)
   timer.shot.time = {
      mins = timer.time.mins,
      secs = timer.time.secs,
      ms = timer.time.ms,
   }
   timer.shot.remaining = timer.shot.max_lifespan

   if hideTimer then
   end
end



local function on_interact(m, obj, intType, val)
   if m.playerIndex ~= 0 then return end

   -- red coins
   if intType == INTERACT_COIN then
      if get_id_from_behavior(obj.behavior) == id_bhvRedCoin then
         timer.screenshot()
         return
      end
   end

   -- stop timer
   for i, value in pairs(interactions.stop) do
      if i == intType and value == val then
         timer.stop()
         return
      end
   end
   -- screenshot timer
   for i, value in pairs(interactions.screenshot) do
      if i == intType and value == val then
         timer.screenshot()
      end
   end
end
hook_event(HOOK_ON_INTERACT, on_interact)