local hud_is_hidden,djui_hud_set_resolution,djui_hud_set_font,get_screen_size,djui_hud_print_text,djui_hud_render_texture_tile,djui_hud_is_pause_menu_created,djui_hud_measure_text =
      hud_is_hidden,djui_hud_set_resolution,djui_hud_set_font,get_screen_size,djui_hud_print_text,djui_hud_render_texture_tile,djui_hud_is_pause_menu_created,djui_hud_measure_text

local function trunc(x)
   return (x >= 0) and math.floor(x) or math.ceil(x)
end

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
   stick_pos = { x=0,  y=0 },
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
   local w,h = get_screen_size()
   INPUT_POS.y = h-24

   local m = gMarioStates[0]
   local c = m.controller
   local input = Config.input

   -- stick onval / oncomb
   if input.stick.value == 2 or input.stick.value == 4 then
      local direction = { x=" ", y=" " }
      local axis = (input.stkbase.value == 2) and
         { x = c.stickX,    y = c.stickY }
      or
         { x = c.rawStickX, y = c.rawStickY }

      -- up/down
      if axis.y ~= 0 then
         direction.y = (axis.y > 0) and "U" or "D"
      end
      -- left/right
      if axis.x ~= 0 then
         direction.x = (axis.x > 0) and "R" or "L"
      end

      -- print stick coords
      local shrink_axis_max = ((input.stkaxis.value*input.stkbase.value) / 2) -- ~128 or ~64
      djui_hud_print_text(direction.y..math.floor(math.abs(axis.y)*shrink_axis_max), stick.base_pos.x-4, h-50, 1)
      djui_hud_print_text(direction.x..math.floor(math.abs(axis.x)*shrink_axis_max), stick.base_pos.x-4, h-30, 1)
   end

   -- stick onvis / oncomb
   if input.stick.value > 2 then
      -- check stick texture
      if input.stkbase.value == 1 then
         -- square
         stick.stick_pos = {
            x =  c.rawStickX*0.118,
            y = -c.rawStickY*0.118
         }
      else
         -- circle
         stick.stick_pos = {
            x =  c.stickX*0.237,
            y = -c.stickY*0.237
         }
      end
      -- render stick base
      djui_hud_render_texture_tile(TEX_STICK, stick.base_pos.x, h-48, stick.scale,stick.scale,
         (input.stkbase.value-1)*stick.tex_size, 0, stick.tex_size,stick.tex_size)
      -- render stick
      djui_hud_render_texture_tile(TEX_STICK, stick.base_pos.x + stick.stick_pos.x, (h-48) + stick.stick_pos.y, stick.scale,stick.scale,
         (input.stick.alt-1)*stick.tex_size, stick.tex_size, stick.tex_size,stick.tex_size)
   end

   local vertical = (input.buttdir.alt == 2)
   local rtl = (input.buttdir.value == 2)

   local inputpos,inputoffset
   -- horizontal
   if not vertical then
      inputpos = {
         x = rtl and (w-64) or (INPUT_POS.x * math.min(input.stick.value,2)),
         y = h-24
      }
      inputoffset = {
         x = rtl and -4 or 4,
         y = 0
      }
   -- vertical
   else
      inputpos = {
         x = 24,
         y = rtl and ((h+24) - (45 * math.min(input.stick.value,2))) or 40
      }
      inputoffset = {
         x = 0,
         y = rtl and -4 or 4
      }
   end

   -- if buttons enabled
   if input.buttons.value == 0 or djui_hud_is_pause_menu_created() then return end

   local large_buttons = (input.buttons.value == 3 or input.buttons.value == 5)
   local cdeluxe = (input.buttons.alt == 2)

   buttons.scale = large_buttons and 1.5 or 1

   local spacing = buttons.spacing*(buttons.scale*0.5)
   if input.buttdir.value == 2 then
      spacing = -spacing
   end

   -- render button inputs
   for i,button in ipairs(buttons.arr) do
      -- if cdeluxe button and cdeluxe enabled
      if (not button.dx or (button.dx and cdeluxe)) and (c.buttonDown & button.id) ~= 0 then
         -- texture (small)
         if (input.buttons.value == 2 or input.buttons.value == 3) then
            djui_hud_render_texture_tile(TEX_BUTTONS, inputpos.x + inputoffset.x, inputpos.y + buttons.tex_size - (buttons.tex_size*buttons.scale) + inputoffset.y, buttons.scale,buttons.scale,
            ((i-1) % 4) * buttons.tex_size, ((i-1) // 4) * buttons.tex_size, buttons.tex_size,buttons.tex_size)

            if vertical then
               inputpos.y = inputpos.y + (spacing*2)
            else
               inputpos.x = inputpos.x + (spacing*2)
            end

            -- text (large)
         elseif (input.buttons.value == 4 or input.buttons.value == 5) then
            local textW,textH = djui_hud_measure_text(button.text)
            if not vertical and rtl then
               inputpos.x = inputpos.x + spacing*(textW*0.26)
            end

            -- draw button text
            djui_hud_print_text(button.text, inputpos.x, (vertical and not rtl) and inputpos.y or inputpos.y - (16*buttons.scale) + 8, buttons.scale)

            if vertical then
               inputpos.y = inputpos.y + (spacing*(textH*0.24))
            elseif not rtl then
               inputpos.x = inputpos.x + (spacing*(textW*0.26))
            end
         end
      end
   end
end
hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)
