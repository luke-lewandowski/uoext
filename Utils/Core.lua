UOExt = UOExt or {}
UOExt.Core = UOExt.Core or {}

-- This methods makes sure that value is 0 if nil.
-- TODO: This needs to be replaced with constructor
UOExt.Core.ConvertToInt = function(val)
    return tonumber(val) or 0
end