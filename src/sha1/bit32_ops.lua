local bit32 = require "bit32"

local ops = {}

local band = bit32.band
local bor = bit32.bor
local bnot = bit32.bnot

ops.uint32_lrot = bit32.lrotate
ops.byte_xor = bit32.bxor
ops.uint32_xor_3 = bit32.bxor
ops.uint32_xor_4 = bit32.bxor

-- (B AND C) OR ((NOT B) AND D)
function ops.loop_op_1(B, C, D)
   return bor(band(B, C), band(bnot(B), D))
end

-- (B AND C) OR (B AND D) OR (C AND D) = (B AND (C OR D)) OR (C AND D)
function ops.loop_op_3(B, C, D)
   return bor(band(B, bor(C, D)), band(C, D))
end

return ops
