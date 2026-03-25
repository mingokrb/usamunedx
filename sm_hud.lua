-- features from the HUD submenu --

local display_values = {}
local igmenu = 0

-- DUST
local dust_timer = 0
local dusted = false
local dust_pos = { x = -64, y = -35 } -- more like offset but whatever
-- WKDISP
local wkdisp = {
   frame_text = {
      [0] = '1st',[4] = '2nd',[3] = '3rd',
      [2] = '4th',[1] = '5th'
   },
   last_frame = 0,
   text_timer = 0,
   text_screentime = 30, -- in frames
}

local function mario_update(m)
	if m.playerIndex ~= 0 then return end

	-- IGMENU - FSPEED - VSPEED --
	display_values = {
		0, -- should not be displayed
		igmenu,
		m.forwardVel,
		m.vel.y,
      vec3f_length(m.vel)
	}

	-- DUST --
	if (m.action == ACT_DIVE_SLIDE and m.floor.type & SURFACE_CLASS_SLIPPERY <= 4) or m.action == ACT_SLIDE_KICK_SLIDE then
		-- mario can't rollout on slopes so it wouldn't make sense for it to increase the counter anyway
		dust_timer = dust_timer + 1
	end
	-- WKDISP --
   if wkdisp.text_timer > 0 then
      wkdisp.text_timer = wkdisp.text_timer - 1
   end
end
hook_event(HOOK_MARIO_UPDATE, mario_update)

local function hud_render_behind()
	if Usamune.in_menu then return end
	djui_hud_set_resolution(RESOLUTION_N64)
	djui_hud_set_font(FONT_HUD)

	-- LIFE
	if Config.hud.life.value > 1 then
		hud_set_value(HUD_DISPLAY_LIVES, display_values[Config.hud.life.value])
	end
	-- STAR
	if Config.hud.star.value > 1 then
		hud_set_value(HUD_DISPLAY_STARS, display_values[Config.hud.star.value])
	end

	-- DUST --
	if Config.hud.dust.value > 1 then
      if Usamune.dust_count == 67 then
         -- i just had to do this i'm sorry
         local sine = math.sin(get_global_timer() * 0.2) * 0.2
         local pos_y = screen_h + dust_pos.y
         djui_hud_print_text_rtl("6", screen_w + dust_pos.x - 12, pos_y + sine, 1)
         djui_hud_print_text_rtl("7", screen_w + dust_pos.x, pos_y - sine, 1)
      else
         djui_hud_print_text_rtl(tostring(Usamune.dust_count), screen_w + dust_pos.x, screen_h + dust_pos.y, 1)
      end
	end
   -- WKDISP --
   if Config.hud.wkdisp.value > 1 then
      if wkdisp.text_timer > 0 then
         djui_hud_print_text(wkdisp.frame_text[wkdisp.last_frame] or '6th', 24, 40, 1)
      end
   end
end
hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)

local function before_mario_action(m, nextAct)
	if m.playerIndex ~= 0 then return end

	-- DUST --
	if nextAct == ACT_FORWARD_ROLLOUT then
		if dust_timer > 1 then
			Usamune.dust_count = Usamune.dust_count + 1
		end
		-- reset timer
		dust_timer = 0
	end
   -- WKDISP --
   if (m.wall or m.prevAction == ACT_AIR_HIT_WALL) and nextAct == ACT_WALL_KICK_AIR then
      wkdisp.last_frame = m.wallKickTimer
      wkdisp.text_timer = wkdisp.text_screentime
      if Config.misct.wk.value > 1 then
         timer.screenshot()
      end
   end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_mario_action)