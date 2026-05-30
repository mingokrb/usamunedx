# Usamune Deluxe
## usamunedx
A faithful recreation of the **[Usamune Practice ROM](https://sites.google.com/view/supermario64/usamunepj/usamunerom)** in **[sm64coopdx](https://github.com/coop-deluxe/sm64coopdx)** as a Lua mod, with a few extra features.

You can also easily add new menus if you got basic Lua knowledge.

> [!IMPORTANT]
> **Please check the [official Usamune ROM Manual](https://goo.gl/NTR61H) before using this mod** if you're not familiar with how the Usamune Practice ROM works.

---
---
---

## ⚒️ **TODO LIST** ⚒️
* **config,menus.main**: Finish adding submenus and options
* **menus**: Prevent pausing while Usamenu is open (somehow, as `HOOK_BEFORE_MARIO_UPDATE` won't work here)
* **menus.levels**: Add sound to "**Custom**" editing
* **menus.levels**: Warp to the level's act select instead of defaulting to act 1 (couldn't figure this out but I hope it's possible with Lua)
* **menus.levels**: Test/fix romhack support with custom scripted levels (for decomp romhacks)
* **menus.main**: Add category settings reset by holding Z for 30 frames (1.0s)
* **general**: Optimize code
---
* **repo**: Finish this README
* **repo**: List new features (in this repo's Wiki or in a separate README)
* **repo**: Document custom menus with examples (in this repo's Wiki)

<br>

### ❓ **TOpossiblyDO LIST**
These are features I've thought about adding but ain't sure if they would be worth the time / have enough potential
* **api**: Add an API for adding new menus with extension mods rather than having to edit the base mod's code
