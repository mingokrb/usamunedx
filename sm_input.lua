local hud_is_hidden = hud_is_hidden
local djui_hud_is_pause_menu_created,djui_hud_set_resolution,djui_hud_set_font,djui_hud_print_text_rtl = djui_hud_is_pause_menu_created,djui_hud_set_resolution,djui_hud_set_font,djui_hud_print_text_rtl

-- textures
local TEX_STICK   = get_texture_info('sticks')
local TEX_BUTTONS = get_texture_info('buttons')

-- button-specific
local buttons = {
   arr = {
   -- buttons in order
   -- dx: coopdx-exclusive (toggleable)
      { id = A_BUTTON,     text = 'A' },
      { id = B_BUTTON,     text = 'B' },
      { id = X_BUTTON,     text = 'X',  dx=true },
      { id = Y_BUTTON,     text = 'Y',  dx=true },
      { id = START_BUTTON, text = 'S' },
      { id = Z_TRIG,       text = 'Z' },
      { id = L_TRIG,       text = 'L',  dx=true },
      { id = R_TRIG,       text = 'R' },

      { id = U_CBUTTONS,   text = 'CU' },
      { id = D_CBUTTONS,   text = 'CD' },
      { id = L_CBUTTONS,   text = 'CL' },
      { id = R_CBUTTONS,   text = 'CR' },
      { id = U_JPAD,       text = 'DU', dx=true },
      { id = D_JPAD,       text = 'DD', dx=true },
      { id = L_JPAD,       text = 'DL', dx=true },
      { id = R_JPAD,       text = 'DR', dx=true },
   },
   spacing = 10,
   tex_size = 8,
   scale = 1,
}
-- stick-specific
local stick = {
   notch_pos = { x=0, y=0 },
   base_pos  = { x=24, y=0 },
   tex_size = 32,
   scale = 1,
}

-- general input
local INPUT_POS = { x=40, y=0 }

local function hud_render_behind()
   if Usamune.in_menu or hud_is_hidden() then return end

   djui_hud_set_resolution(RESOLUTION_N64)
   djui_hud_set_font(FONT_HUD)
   local w,h = djui_hud_get_screen_width(),djui_hud_get_screen_height()

   local m = gMarioStates[0]
   local c = m.controller
   local input = Config.input

   -- stick onval / oncomb
   if input.stick.value == 2 or input.stick.value == 4 then
      local direction = { x=" ", y=" " }

      -- up/down
      if c.rawStickY ~= 0 then
         direction.y = (c.rawStickY > 0) and "U" or "D"
      end
      -- left/right
      if c.rawStickX ~= 0 then
         direction.x = (c.rawStickX > 0) and "R" or "L"
      end

      -- print stick coords
      local shrink_axis_max = (input.stkaxis.value / 2)
      djui_hud_print_text(direction.y..math.floor(math.abs(c.rawStickY)*shrink_axis_max), stick.base_pos.x-4, h-50, 1)
      djui_hud_print_text(direction.x..math.floor(math.abs(c.rawStickX)*shrink_axis_max), stick.base_pos.x-4, h-30, 1)
   end

   -- stick onvis / oncomb
   if input.stick.value > 2 then
      -- check stick texture
      if input.stkbase.value == 1 then
         -- square
         stick.pos = {
            x =  c.rawStickX*0.118,
            y = -c.rawStickY*0.118
         }
      else
         -- circle
         stick.pos = {
            x =  c.stickX*0.237,
            y = -c.stickY*0.237
         }
      end
      -- render stick base and stick
      djui_hud_render_texture_tile(TEX_STICK, stick.base_pos.x,h-48, stick.scale,stick.scale, (input.stkbase.value-1)*stick.tex_size,0, stick.tex_size,stick.tex_size)
      djui_hud_render_texture_tile(TEX_STICK, stick.base_pos.x+stick.pos.x,(h-48)+stick.pos.y, stick.scale,stick.scale, (input.stick.alt-1)*stick.tex_size,stick.tex_size, stick.tex_size,stick.tex_size)
   end

   local input_initial_x = INPUT_POS.x*math.min(input.stick.value, 2)
   local input_y = h-24

   -- if buttons enabled
   if input.buttons.value == 0 or djui_hud_is_pause_menu_created() then return end

   local large_buttons = (input.buttons.value == 3 or input.buttons.value == 5)
   local cdeluxe = (input.buttons.alt == 2)

   buttons.scale = large_buttons and 1.5 or 1

   local button_x = input_initial_x
   -- invert spacing if RtL alignment
   local spacing = buttons.spacing*(buttons.scale*0.5)

   -- render button inputs
   for i,button in ipairs(buttons.arr) do
      -- if cdeluxe button and cdeluxe enabled
      if not button.dx or (button.dx and cdeluxe) then
         if (c.buttonDown & button.id) ~= 0 then
            -- texture (small)
            if (input.buttons.value == 2 or input.buttons.value == 3) then
               djui_hud_render_texture_tile(TEX_BUTTONS, button_x+4, input_y+buttons.tex_size-(buttons.tex_size*buttons.scale), buttons.scale,buttons.scale, ((i-1)%4)*buttons.tex_size, math.floor((i-1)/4)*buttons.tex_size, buttons.tex_size,buttons.tex_size)
               button_x = button_x+(spacing*2)

            -- text (large)
            elseif (input.buttons.value == 4 or input.buttons.value == 5) then
               djui_hud_print_text(button.text, button_x, input_y-(16*buttons.scale)+8, buttons.scale)
               button_x = button_x+(spacing*(djui_hud_measure_text(button.text)*0.27))
            end
         else
            button_x = button_x
         end
      end
   end
end
hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)
