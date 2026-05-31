-- load each config --

-- all default; 1 is usually false or disabled

-- option = { value = 1, alt = 1 }
--   option: name of menu option
--   value: main value
--   alt (optional): additional value that depends on the main value

-- key pattern to be used with mod_storage_save_number and mod_storage_load_number
-- 1. submenu; 2. option; 3. 'value' or 'alt'
local config_key_pattern = "usamune.%s.%s.%s"

Config = {
   timer = {
      stop = { value = 1 },
      display = { value = 1 },
      pssrace = { value = 1 },
      tmrposi = { value = 1 },
   },
   misct = {
      misctmr = { value = 1 },
      numdisp = { value = 1 },
      xcam = { value = 1 },
      bswitch = { value = 1 },
      pswitch = { value = 1 },
      ride = { value = 1 },
      chest = { value = 1 },
      crystal = { value = 1 },
      enemy = { value = 1 },
      exclbox = { value = 1 },
      corkbox = { value = 1 },
      objgrab = { value = 1 },
      ldgegrb = { value = 1 },
      polegrb = { value = 1 },
      wk = { value = 1 },
      wallhit = { value = 1 },
      clip = { value = 1 },
      surface = { value = 1 },
      flip = { value = 1 },
      rollout = { value = 1 },
      dive = { value = 1 },
      ljsldk = { value = 1 },
      tj = { value = 1 },
      spdkick = { value = 1 },
      load = { value = 1 },
      bowser = { value = 1 },
      coin = { value = 1 },
      oneup = { value = 1 },
   },
   reset = {
      lbutton = { value = 1 },
      lxr = { value = 1 },
      randstg = { value = 1 },
   },
   deflt = {
      -- these are number input values
      defcoin = { value = 1, alt = 0 },
      defmiss = { value = 1, alt = 1 },
   },
   hud = {
      life = { value = 1 },
      star = { value = 1 },
      dust = { value = 1 },
      wkdisp = { value = 1 },
      attempt = { value = 1 },
      bpsdisp = { value = 1 },
   },
   input = {
      stick = { value = 1, alt = 1 },
      stkbase = { value = 1 },
      stkaxis = { value = 1 },
      buttons = { value = 1, alt = 1 },
   },
   data = {
      sstates = { value = 1, alt = 1 },
   },
   misc = {
      music = { value = 1 },
   },
   delux = {
      menubtn = { value = 12 }, -- D_JPAD as default
      hints = { value = 1 },
      arwlerp = { value = 1, alt = 7 },
      framep = { value = 1, alt = 1 },
   },
}

-- return config value from mod storage
local function load_config(key)
   local value = mod_storage_load_number(key)
   return value
end

-- refresh Config table
function refresh_config()
   for k, menu in pairs(Config) do
      for i, option in pairs(menu) do
         local save = load_config(string.format(config_key_pattern, k, i, 'value'))
         -- Config.submenu.option
         option.value = (save < 1) and option.value or save
         if option.alt then
            save = load_config(string.format(config_key_pattern, k, i, 'alt'))
            option.alt = (save < 1) and option.alt or save
         end
      end
   end
end

refresh_config()

-- save to mod storage
function save_config(submenu, option, value, isAlt)
   local str = string.format(config_key_pattern, submenu, option, (isAlt and 'alt' or 'value'))
   mod_storage_save_number(str, value)
   --Config[submenu][option][isAlt and 'alt' or 'value'] = value
   refresh_config()
   console_log("config", "Saved key /g2/".. str .."/reset/ as /y/".. math.floor(mod_storage_load_number(str)))
   return str
end

-- final mod storage strings:
--   'usamune.submenu.option.value' (main value)
--   'usamune.submenu.option.alt'   (variant value if any)
