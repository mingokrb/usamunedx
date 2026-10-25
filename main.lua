-- name: UsamuneDX
-- description: accurate (and more awesome) usamune

-- reset gameplay stats
local function on_warp(_, __, ___, nodeId)
	Usamune.toggle_menu(false)

   -- temporary info
   Usamune.hud.igmenu = 0
   Usamune.hud.dust_count = 0

   -- if NOT manual level restart, update last values
   if not Usamune.restart_info.level_is_restarting then
      local m = gMarioStates[0]
      Usamune.restart_info.warp_interact_timer = m.skipWarpInteractionsTimer
      Usamune.restart_info.hud_display_flags = hud_get_value(HUD_DISPLAY_FLAGS)
      Usamune.restart_info.last_health = m.health
      Usamune.restart_info.last_warpnode_id = nodeId

      Usamune.hud.attempts = 0
   end
   Usamune.restart_info.level_is_restarting = false



   if Usamune.DEAD26 then hud_hide() end
end
hook_event(HOOK_ON_WARP, on_warp)
