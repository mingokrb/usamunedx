local djui_hud_set_color_array,djui_hud_get_color_array,djui_hud_print_text_shadowed = djui_hud_set_color_array,djui_hud_get_color_array,djui_hud_print_text_shadowed

local menu = {
   title = "EVIL MENU",
   bg_color = {0,0,0, 160 },
}

function menu.render()
   djui_hud_print_text_shadowed("this is a trial version", 24, 80, 1, {0,0,0,127}, 0,0)
   djui_hud_set_font(FONT_NORMAL)
   djui_hud_print_text_shadowed("To unlock all Usamune features, please purchase the full version of this mod", 24, 110, 0.5, {0,0,0,80}, 2,2)
   djui_hud_set_color(255,255,255, 80)
   djui_hud_print_text_shadowed("jk", 24, 160, 0.5, { 0, 0, 0, 40 }, 2, 2)
   --for i, letter in ipairs({"s", "u", "p"}) do
   --   djui_hud_print_text(letter, 100 + (i * 12), 100 + (math.sin((get_global_timer() + (i * 10)) * 0.1) * 2.0), 1)
   --end
end

return menu