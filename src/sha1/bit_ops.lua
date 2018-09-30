local bit = require "bit"

local ops = {}

local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

ops.uint32_lrot = bit.rol
ops.byte_xor = bit.bxor
ops.uint32_xor_3 = bit.bxor
ops.uint32_xor_4 = bit.bxor

-- (B AND C) OR ((NOT B) AND D)
function ops.loop_op_1(B, C, D)
   return bor(band(B, C), band(bnot(B), D))
end

-- (B AND C) OR (B AND D) OR (C AND D) = (B AND (C OR D)) OR (C AND D)
function ops.loop_op_3(B, C, D)
   return bor(band(B, bor(C, D)), band(C, D))
end


return ops
