local function on_warp(t, levelNum)
   local m = gMarioStates[0]

   -- DEFCOIN
   if Config.deflt.defcoin.value > 1 then
      if get_level_course_num(levelNum) > 0 then
         m.numCoins = Config.deflt.defcoin.alt
      end
   end
end
hook_event(HOOK_ON_WARP, on_warp)
