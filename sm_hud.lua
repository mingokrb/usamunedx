-- features from the HUD submenu --

local display_values = {}

-- [DUST]
local dust_timer = 0
local dusted = false
local dust_pos = {x = -64, y = -35} -- more like offset but whatever
-- [WKDISP]
local wkdisp = {
   frame_text = {
      [0] = '1st',[4] = '2nd',[3] = '3rd',
      [2] = '4th',[1] = '5th'
   },
   last_frame = 0,
   text_timer = 0,
   text_screentime = 30, -- in frames

   combo = 0,
   comboshake_strength = 0,
}
-- [BPSDISP]
local button_presses = 0
local bps = 0

local function mario_update(m)
   if m.playerIndex ~= 0 then return end

   -- [IGMENU]-[FSPEED]-[VSPEED]
   display_values = {
      0, -- should not be displayed
      Usamune.hud.igmenu,
      m.forwardVel,
      m.vel.y,
      vec3f_length(m.vel),
   }
   if (m.action & ACT_GROUP_CUTSCENE) ~= 0 then
      Usamune.hud.igmenu = Usamune.hud.igmenu + 1
   end

   -- [DUST]
   -- mario can't rollout on slopes so it wouldn't make sense for it to increase the counter anyway
   if (m.action == ACT_DIVE_SLIDE and m.floor.type & SURFACE_CLASS_SLIPPERY <= 4) or m.action == ACT_SLIDE_KICK_SLIDE then
      dust_timer = dust_timer + 1
   else
      dust_timer = 0
   end

   -- [WKDISP]
   if wkdisp.text_timer > 0 then
      wkdisp.text_timer = wkdisp.text_timer - 1
      if wkdisp.text_timer <= 0 then
         wkdisp.combo = 0
      end
   end
   if wkdisp.comboshake_strength > math.floor((wkdisp.combo-1) / 3) then
      wkdisp.comboshake_strength = wkdisp.comboshake_strength - 1
   end

   -- [BPSDISP]
   if buttonPressed() then
      button_presses = button_presses + 1
   end
   if (get_global_timer() % 30) == 0 then
      bps = button_presses
      button_presses = 0
   end
end
hook_event(HOOK_MARIO_UPDATE, mario_update)

local function hud_render_behind()
   if Usamune.in_menu or hud_is_hidden() then return end
   djui_hud_set_resolution(RESOLUTION_N64)
   djui_hud_set_font(FONT_HUD)

   -- [LIFE]
   if Config.hud.life.value > 1 then
      hud_set_value(HUD_DISPLAY_LIVES, display_values[Config.hud.life.value] or 0)
   end
   -- [STAR]
   if Config.hud.star.value > 1 then
      hud_set_value(HUD_DISPLAY_STARS, display_values[Config.hud.star.value] or 0)
   end

   -- [DUST]
   if Config.hud.dust.value > 1 then
      if Usamune.hud.dust_count == 67 then
         -- i just had to do this i'm sorry
         local sine = math.sin(get_global_timer() * 0.25) * 0.2

         local pos_y = screen.height + dust_pos.y
         djui_hud_print_text_rtl("6", screen.width + dust_pos.x - 12, pos_y + sine, 1)
         djui_hud_print_text_rtl("7", screen.width + dust_pos.x, pos_y - sine, 1)
      else
         djui_hud_print_text_rtl(tostring(Usamune.hud.dust_count), screen.width + dust_pos.x, screen.height + dust_pos.y, 1)
      end
   end
   -- [WKDISP]
   if Config.hud.wkdisp.value > 1 then
      if wkdisp.text_timer > 0 then
         djui_hud_print_text(wkdisp.frame_text[wkdisp.last_frame] or '6th', 24, 40, 1) -- evil secret 6th frame as fallback
      end

      if Config.hud.wkdisp.alt > 1 and wkdisp.combo > 1 then
         local shakeA, shakeB = {x=0,y=0}, {x=0,y=0}
         if not is_game_paused() then
            shakeA = {x = math.random(-wkdisp.comboshake_strength, wkdisp.comboshake_strength), y = math.random(-wkdisp.comboshake_strength, wkdisp.comboshake_strength)}
            shakeB = {x = math.random(-wkdisp.comboshake_strength, wkdisp.comboshake_strength), y = math.random(-wkdisp.comboshake_strength, wkdisp.comboshake_strength)}
         end
         local combostr = tostring(wkdisp.combo)
         djui_hud_set_color(220,220,220, 255)
         djui_hud_print_text(combostr, 20 + shakeA.x, 60 + shakeA.y, 0.9)
         djui_hud_print_text(string.format("%".. #combostr .."s", "`"), 30 + shakeB.x, 60 + shakeB.y, 0.9)
         djui_hud_reset_color()
      end
   end

   -- [BPSDISP]
   if Config.hud.bpsdisp.value > 1 then
      djui_hud_print_text_rtl(string.format("%d BPS", bps), screen.width - 24, screen.height - 56, 1)
   end
end
hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)

local function before_mario_action(m, nextAct)
   if m.playerIndex ~= 0 then return end

   -- [DUST]
   if nextAct == ACT_FORWARD_ROLLOUT then
      if dust_timer > 1 then
         Usamune.hud.dust_count = Usamune.hud.dust_count + 1
      end
      -- reset timer
      dust_timer = 0
   end
   -- [WKDISP]
   if (m.wall or m.prevAction == ACT_AIR_HIT_WALL) and nextAct == ACT_WALL_KICK_AIR then
      -- wall kicked
      wkdisp.last_frame = m.wallKickTimer
      wkdisp.text_timer = wkdisp.text_screentime
      -- firsties combo
      if wkdisp.last_frame == 0 then
         wkdisp.combo = wkdisp.combo + 1
         wkdisp.comboshake_strength = 5 + (math.floor((wkdisp.combo-1) / 3) * 2)
      else
         wkdisp.combo = 0
      end

      if Config.misct.wk.value > 1 then
         Usatimer.screenshot()
      end
   end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_mario_action)
