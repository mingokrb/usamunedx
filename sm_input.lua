local djui_hud_set_resolution,djui_hud_set_font,djui_hud_print_text_rtl = djui_hud_set_resolution,djui_hud_set_font,djui_hud_print_text_rtl

-- textures
local tex_sticks = get_texture_info('sticks')
local tex_buttons = get_texture_info('buttons')

-- button-specific
local buttons = {
   arr = {
   -- buttons in order
   -- deluxe: includes unused and coop-exclusive buttons (X, Y, L and dpad)
      { id = A_BUTTON,     text = 'A' },
      { id = B_BUTTON,     text = 'B' },
      { id = X_BUTTON,     text = 'X',  deluxe = true },
      { id = Y_BUTTON,     text = 'Y',  deluxe = true },
      { id = START_BUTTON, text = 'S' },
      { id = Z_TRIG,       text = 'Z' },
      { id = L_TRIG,       text = 'L',  deluxe = true },
      { id = R_TRIG,       text = 'R' },

      { id = U_CBUTTONS,   text = 'CU' },
      { id = D_CBUTTONS,   text = 'CD' },
      { id = L_CBUTTONS,   text = 'CL' },
      { id = R_CBUTTONS,   text = 'CR' },
      { id = U_JPAD,       text = 'DU', deluxe = true },
      { id = D_JPAD,       text = 'DD', deluxe = true },
      { id = L_JPAD,       text = 'DL', deluxe = true },
      { id = R_JPAD,       text = 'DR', deluxe = true },
   },
   spacing = 10,
   tex_size = 8,
   scale = 1,
}
-- stick-specific
local stick = {
   pos = { x = 0, y = 0 },
   base_pos = { x = 24, y = 0 },
   tex_size = 32,
   scale = 1,
}

-- general input
local input = {
   pos = { x = 40, y = 0 },
}

local function hud_render_behind()
   if Usamune.in_menu then return end

   djui_hud_set_resolution(RESOLUTION_N64)
   djui_hud_set_font(FONT_HUD)
   local m = gMarioStates[0]
   local c = m.controller

   -- stick onval / oncomb
   if Config.input.stick.value == 2 or Config.input.stick.value == 4 then
      local direction = { x = " ", y = " " }

      -- up - down
      if c.rawStickY > 0 then
         direction.y = "U"
      elseif c.rawStickY < 0 then
         direction.y = "D"
      end

      -- left - right
      if c.rawStickX > 0 then
         direction.x = "R"
      elseif c.rawStickX < 0 then
         direction.x = "L"
      end

      local shrink_axis_max = (Config.input.stkaxis.value / 2)

      djui_hud_print_text(string.format('%s%d', direction.y, math.floor(math.abs(c.rawStickY) * shrink_axis_max)), stick.base_pos.x - 4, screen.height - 50, 1)
      djui_hud_print_text(string.format('%s%d', direction.x, math.floor(math.abs(c.rawStickX) * shrink_axis_max)), stick.base_pos.x - 4, screen.height - 30, 1)
   end

   -- stick onvis / oncomb
   if Config.input.stick.value > 2 then
      -- move stick texture
      if Config.input.stkbase.value == 1 then
         -- square
         stick.pos = {
            x = c.rawStickX * 0.118,
            y = -c.rawStickY * 0.118
         }
      elseif Config.input.stkbase.value == 2 then
         -- circle
         stick.pos = {
            x = c.stickX * 0.237,
            y = -c.stickY * 0.237
         }
      end
      -- render stick base and stick
      djui_hud_render_texture_tile(tex_sticks, stick.base_pos.x, screen.height - 48, stick.scale, stick.scale, (Config.input.stkbase.value - 1) * stick.tex_size, 0, stick.tex_size, stick.tex_size)
      djui_hud_render_texture_tile(tex_sticks, stick.base_pos.x + stick.pos.x, (screen.height - 48) + stick.pos.y, stick.scale, stick.scale, (Config.input.stick.alt - 1) * stick.tex_size, stick.tex_size, stick.tex_size, stick.tex_size)
   end

   input.initial_x = input.pos.x * math.min(Config.input.stick.value, 2)
   input.y = screen.height - 24

   -- if buttons enabled
   if Config.input.buttons.value == 1 then return end

   local large_buttons = (Config.input.buttons.value == 3 or Config.input.buttons.value == 5)
   local cdeluxe = (Config.input.buttons.alt == 2)

   buttons.scale = large_buttons and 1.5 or 1

   local button_x = input.initial_x
   -- invert spacing if RtL alignment
   local spacing = buttons.spacing * (buttons.scale * 0.5)

   -- render and reposition button inputs
   for i, button in ipairs(buttons.arr) do
      -- if cdeluxe button and cdeluxe enabled
      if not button.deluxe or (button.deluxe and cdeluxe) then
         if (c.buttonDown & button.id) ~= 0 then
            -- texture (small)
            if Config.input.buttons.value == 2 or Config.input.buttons.value == 3 then
               djui_hud_render_texture_tile(tex_buttons, button_x + 4, input.y + buttons.tex_size - (buttons.tex_size * buttons.scale), buttons.scale, buttons.scale, ((i - 1) % 4) * buttons.tex_size, math.floor((i - 1) / 4) * buttons.tex_size, buttons.tex_size, buttons.tex_size)
               button_x = button_x + (spacing * 2)

            -- text (large)
            elseif Config.input.buttons.value == 4 or Config.input.buttons.value == 5 then
               djui_hud_print_text(button.text, button_x, input.y + 8 - (16 * buttons.scale), buttons.scale)
               button_x = button_x + (spacing * (djui_hud_measure_text(button.text) * 0.27))
            end
         else
            button_x = button_x
         end
      end
   end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)