-- name: The Definitive Usamune Mod
-- description: accurate (and more awesome) usamune

local function on_warp(_, __, ___, nodeId)
	Usamune.toggle_menu(false)

   Usamune.dust_count = 0
   Usamune.last_warpnode_id = nodeId
end
hook_event(HOOK_ON_WARP, on_warp)
