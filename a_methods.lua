-- split string by separator
function string:split(separator)
   local pattern = "([^".. (separator or " ") .."]+)"
   local arr = {}

   for part in self:gmatch(pattern) do
      table.insert(arr, part)
   end
   return arr
end

-- replace element in string with another
function string.replace(this, what, with)
   local str, _ = this:gsub(what, with)
   return str
end


-- concatenate array values into a string
function table.join(arr, concatenator)
   local str = ""
   for i, item in ipairs(arr) do
      str = str .. (concatenator or " ") .. tostring(item)
   end
   return str
end

----------------------
-----------
-- table --
-----------

-- pick random item from array
function pickRandom(arr, starts, ends)
   return arr[math.random(starts or 1, ends or #arr)]
end
