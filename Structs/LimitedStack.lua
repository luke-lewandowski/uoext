--- Simple stack structure. It however has a limit. Once reached old items get overriden!
-- @module UOExt.Structs.LimitedStack

UOExt = UOExt or {}
UOExt.Structs = UOExt.Structs or {}
UOExt.Structs.LimitedStack = UOExt.Structs.LimitedStack or {}

--- Create new limited stack of specific size
-- @param maxSize size of the stack
function UOExt.Structs.LimitedStack:Create(maxSize)
  local t = {}

  t.p_arr = {}
  t.p_currentIndex = 0

  --- Push an item onto the stack
  -- @param value
  -- @return value or nil if not added
  function t:push(value)
    if(t.p_currentIndex == maxSize) then
      print("Reached maximum amount of items. Starting over.")
      t.p_currentIndex = 0
    end

    if(value ~= nil) then
      t.p_currentIndex = t.p_currentIndex + 1
      t.p_arr[t.p_currentIndex] = value
      
      return value
    end

    return nil
  end

  --- Pop an item from the stack. 
  -- @return item last added item to the stack
  function t:pop()
    if(t.p_arr[t.p_currentIndex]) then
      local currentValue = t.p_arr[t.p_currentIndex]
      t.p_arr[t.p_currentIndex] = nil
      t.p_currentIndex = t.p_currentIndex - 1
      return currentValue
    end
  end

  --- Gets all items from the stack (without actually removing them)
  -- @return array of items
  function t:getAll()
    return t.p_arr
  end

  --- Checks if specific value exists on the stack
  -- @param value to check for
  -- @return true if value found on the stack, false otherwise.
  function t:valueExists(value)
    if(t.p_currentIndex > 0) then
      for k,v in pairs(t.p_arr) do
        if(v == value) then
        return true;
        end
      end
    end

    return false
  end

  return t
end