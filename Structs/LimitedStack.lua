UOExt = UOExt or {}
UOExt.Structs = UOExt.Structs or {}
UOExt.Structs.LimitedStack = UOExt.Structs.LimitedStack or {}

function UOExt.Structs.LimitedStack:Create(maxSize)
  local t = {}

  t.p_arr = {}
  t.p_currentIndex = 0

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

  function t:pop()
    if(t.p_arr[t.p_currentIndex]) then
      local currentValue = t.p_arr[t.p_currentIndex]
      t.p_arr[t.p_currentIndex] = nil
      t.p_currentIndex = t.p_currentIndex - 1
      return currentValue
    end
  end

  function t:getAll()
    return t.p_arr
  end

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