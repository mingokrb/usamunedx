-- name: Usamune Deluxe
-- description: accurate (and more awesome) usamune

-- reset gameplay stats
local function on_warp(_, __, ___, nodeId)
	Usamune.toggle_menu(false)

   Usamune.hud.igmenu = 0
   Usamune.hud.dust_count = 0

   Usamune.last_warpnode_id = nodeId
   -- if NOT level restart (L button pressed)
   if not Usamune.level_is_restarting then
      Usamune.last_health = gMarioStates[0].health
      Usamune.hud.attempts = 0
      Usamune.hud_display_flags = hud_get_value(HUD_DISPLAY_FLAGS)
   end
   Usamune.level_is_restarting = false



   if Usamune.DEAD26 then hud_hide() end
end
hook_event(HOOK_ON_WARP, on_warp)
