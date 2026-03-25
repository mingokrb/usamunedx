-- split string by separator
function string:split(separator)
   local pattern = "([^".. separator .."]+)"
   local arr = {}

   for part in self:gmatch(pattern) do
      table.insert(arr, part)
   end
   return arr
end

-- concatenate array values into a string
function table.join(arr, separator)
	local str = ""

	for i, item in ipairs(arr) do
		str = str ..(separator or " ").. tostring(item)
	end

	return str
end

-- pick random item from array
function table.pickRandom(arr, startIndex, endIndex)
   return arr[math.random(startIndex or 1, endIndex or #arr)]
end