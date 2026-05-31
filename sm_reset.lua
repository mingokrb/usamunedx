-- features from the RESET submenu --

local function restart_level()
   Usamune.level_is_restarting = true
   local g = gNetworkPlayers[0]
   warp_to_warpnode(g.currLevelNum, g.currAreaIndex, g.currActNum, Usamune.last_warpnode_id)
   --warp_to_level(warp_info.levelNum, warp_info.areaIdx, warp_info.actNum)

   gMarioStates[0].health = Usamune.last_health
   Usamune.hud.attempts = Usamune.hud.attempts + 1
   hud_set_value(HUD_DISPLAY_FLAGS, Usamune.hud_display_flags)
end

local function mario_update(m)
   if m.playerIndex ~= 0 then return end

   -- LBUTTON
   if Config.reset.lbutton.value > 1 then
      if buttonPressed(L_TRIG) then
         restart_level()
      end
   end
   -- LXR
   if Config.reset.lxr.value > 1 then
      if buttonPressed(L_TRIG) and buttonPressed(R_TRIG) then
         restart_level()
      end
   end
end
hook_event(HOOK_MARIO_UPDATE, mario_update)
