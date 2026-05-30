local hints = {
   render = {},
}

local hint = {
   scale = 0.5,
   font_size = 14,

   text = "",
}

local prevtext = ""

function hints.render_text(text)
   hint.max_width = screen.width * 2

   -- setup
   if prevtext ~= text then
      text = text or "No description"
      -- split words
      hint.words = string.split(text, " ")
      hint.text = ""

      for w, word in ipairs(hint.words) do
         local textw = djui_hud_measure_text(hint.text .. " " .. word)
         local separator = (textw < hint.max_width) and " " or "\n"
         hint.text = hint.text .. separator .. word
      end
      hint.text = string.sub(hint.text, 2)
      prevtext = text
   end
end

function hints.render_main()
   local textw, texth = djui_hud_measure_text(hint.text)
   local text_y = (screen.height - 10)
   hint.pos = from_screen_center()
   djui_hud_set_text_alignment(0.5, 1)

   -- render bg
   djui_hud_set_color(0,0,0, Usamenu.opacity * 0.5)
   djui_hud_render_rect(0, text_y - (texth * 0.6) - 10, screen.width + 4, 30 + ((texth - 1) * hint.font_size))

   -- render text
   djui_hud_set_font(FONT_NORMAL)
   djui_hud_set_color(0,0,0, Usamenu.opacity)
   djui_hud_print_text(hint.text, hint.pos.x + 1, text_y + 1, 0.5)
   djui_hud_set_color(255,255,255, Usamenu.opacity)
   djui_hud_print_text(hint.text, hint.pos.x, text_y, 0.5)

   djui_hud_set_font(FONT_HUD)
   djui_hud_set_text_alignment(0, 0)
end

-- custom
function hints.render.main(menu)
   local submenus = menu.main.submenus
   local options = menu.main.options

   local hint_text
   local curr_submenu = submenus.arr[submenus.selection]
   if submenus.selected then
      hint_text = options.arr[curr_submenu.name][curr_submenu.selection].description
   else
      hint_text = curr_submenu.description
   end
   hints.render_text(hint_text)
end

function hints.render.level_select(menu)
   local level
   if menu.levels.selection <= #menu.levels.arr then
      level = menu.levels.arr[menu.levels.selection]
   end

   local hint_text = ""
   if not level then
      hint_text = "Custom \\#eeee40\\levelId\\#ffffff\\, \\#eeee40\\areaIndex\\#ffffff\\ and \\#eeee40\\warpNode\\#ffffff\\"
   else
      hint_text = string.format("%s\n\\#cbcbcb\\Level ID: %02X - Area Index: %02X - Warp Node: %02X", level.fullName, level.id, level.area or 1, level.node or 10)
   end

   hints.render_text(hint_text)
end


return hints