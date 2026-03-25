-- textures
local tex_sticks = get_texture_info('sticks')
local tex_buttons = get_texture_info('buttons')

-- buttons in order
local buttons = {
	{ id = A_BUTTON,     text = 'A' },
	{ id = B_BUTTON,     text = 'B' },
	{ id = X_BUTTON,     text = '`',  deluxe = true },
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
}
-- cdeluxe: includes unused buttons and exclusive ex-coop/coopdx ones such as X and Y

local sticks_tex_size = 32
local stick_scale = 1
local stick_pos = { x = 0, y = 0 }
local stick_main_x = 24

local buttons_spacing = 10
local buttons_tex_size = 8
local button_scale = 1

local function hud_render_behind()
	if Usamune.in_menu then return end
	
	djui_hud_set_resolution(RESOLUTION_N64)
	djui_hud_set_font(FONT_HUD)
	local m = gMarioStates[0]
	
	-- stick onval / oncomb
	if Config.input.stick.value == 2 or Config.input.stick.value == 4 then
      local direction = { x = '', y = '' }
		
		if m.controller.rawStickY > 0 then
			direction.y = "U" -- UP
		elseif m.controller.rawStickY < 0 then
			direction.y = "D" -- DOWN
		else direction.y = " " end
		
		if m.controller.rawStickX > 0 then
			direction.x = "R" -- RIGHT
		elseif m.controller.rawStickX < 0 then
			direction.x = "L" -- LEFT
		else direction.x = " " end
		
		local shrink_axis_max = (Config.input.stkaxis.value) / 2
      
		djui_hud_print_text(string.format('%s%d', direction.y, math.floor(math.abs(m.controller.rawStickY) * shrink_axis_max)), stick_main_x - 4, screen_h - 50, 1)
		djui_hud_print_text(string.format('%s%d', direction.x, math.floor(math.abs(m.controller.rawStickX) * shrink_axis_max)), stick_main_x - 4, screen_h - 30, 1)
	end
	
	-- stick onvis / oncomb
	if Config.input.stick.value > 2 then
		-- move stick texture
		if Config.input.stickbg.value == 1 then
			-- square
			stick_pos = {
				x = m.controller.rawStickX * 0.118,
				y = -m.controller.rawStickY * 0.118
			}
		elseif Config.input.stickbg.value == 2 then
			-- circle
			stick_pos = {
				x = m.controller.stickX * 0.237,
				y = -m.controller.stickY * 0.237
			}
		end
		-- render stick base and stick
		djui_hud_render_texture_tile(tex_sticks, stick_main_x, screen_h - 48, stick_scale, stick_scale, (Config.input.stickbg.value - 1) * sticks_tex_size, 0, sticks_tex_size, sticks_tex_size)
		djui_hud_render_texture_tile(tex_sticks, stick_main_x + stick_pos.x, (screen_h - 48) + stick_pos.y, stick_scale, stick_scale, (Config.input.stick.alt - 1) * sticks_tex_size, sticks_tex_size, sticks_tex_size, sticks_tex_size)
	end
	
	local input_default_x = 24
	
	local input_initial_x = input_default_x
	local inputs_y = (screen_h - 24)
	
	-- move buttons if stick enabled
	if Config.input.stick.value > 1 then
		input_initial_x = input_default_x + 40
	end
	
	-- if buttons enabled
	if Config.input.buttons.value == 1 then return end
	
	local large_buttons = Config.input.buttons.value == 3 or Config.input.buttons.value == 5
	local cdeluxe = Config.input.buttons.alt == 2
	
	--djui_chat_message_create(tostring(large_buttons))

   button_scale = large_buttons and 2 or 1
	
	local button_x = input_initial_x
	-- invert spacing if RtL alignment
	local spacing = buttons_spacing * (button_scale * 0.5)
	
	-- render and reposition button inputs
	for i, button in ipairs(buttons) do
		-- if cdeluxe button and cdeluxe enabled
		-- using 'break' was literally breaking it so yeah
		if not button.deluxe or (button.deluxe and cdeluxe) then
			
			if (m.controller.buttonDown & button.id) ~= 0 then
				button_x = button_x + (spacing * 2)
				
				if Config.input.buttons.value == 2 or Config.input.buttons.value == 3 then
					-- texture
					djui_hud_render_texture_tile(tex_buttons, button_x + 4, inputs_y, button_scale, button_scale, ((i - 1) % 4) * buttons_tex_size, math.floor((i - 1) / 4) * buttons_tex_size, buttons_tex_size, buttons_tex_size)
				elseif Config.input.buttons.value == 4 or Config.input.buttons.value == 5 then
					-- text
					djui_hud_print_text(button.text, button_x, inputs_y - 8, button_scale)
				end
			else
				button_x = button_x
			end
		end
	end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)