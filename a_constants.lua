local djui_hud_set_resolution,djui_hud_get_screen_width,djui_hud_get_screen_height = djui_hud_set_resolution,djui_hud_get_screen_width,djui_hud_get_screen_height

_G.USAMUNE_VERSION = "1.0.0"

-- main table
Usamune = {
   time = 0,
   -- if usamune menu enabled
   in_menu = false,
   -- for warps/resets
   level_is_restarting = false,
   last_warpnode_id = 0,
   last_health = gMarioStates[0].health,
   hud_display_flags = hud_get_value(HUD_DISPLAY_FLAGS),

   buttons = {
      indexed = {
         { id = A_BUTTON,     name = "A" },
         { id = B_BUTTON,     name = "B" },
         { id = X_BUTTON,     name = "X" },
         { id = Y_BUTTON,     name = "Y" },
         { id = L_TRIG,       name = "LTRIG" },
         { id = R_TRIG,       name = "RTRIG" },
         { id = Z_TRIG,       name = "ZTRIG" },
         { id = START_BUTTON, name = "START" },
         { id = U_JPAD,       name = "D-UP" },
         { id = L_JPAD,       name = "DLEFT" },
         { id = R_JPAD,       name = "DRIGHT" },
         { id = D_JPAD,       name = "DDOWN" },
         { id = U_CBUTTONS,   name = "C-UP" },
         { id = L_CBUTTONS,   name = "CLEFT" },
         { id = R_CBUTTONS,   name = "CRIGHT" },
         { id = D_CBUTTONS,   name = "CDOWN" },
      },
      id = {},
   },
}
for i, button in ipairs(Usamune.buttons.indexed) do
   Usamune.buttons.id[button.id] = { id = i, name = button.name }
end

-- screen resolution
screen = {
   width = 0,
   height = 0,
}

local function hud_render()
   djui_hud_set_resolution(RESOLUTION_N64)
   screen.width = djui_hud_get_screen_width()
   screen.height = djui_hud_get_screen_height()
end
hook_event(HOOK_ON_HUD_RENDER, hud_render)


-- gameplay stats
Usamune.hud = {
   -- resets on warp
   igmenu = 0,
   dust_count = 0,
   attempts = 0,
}
