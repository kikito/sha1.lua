local bit = require "bit"

local ops = {}

local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

ops.uint32_lrot = bit.rol
ops.byte_xor = bit.bxor
ops.uint32_xor_3 = bit.bxor
ops.uint32_xor_4 = bit.bxor

function ops.uint32_ternary(a, b, c)
   return bor(band(a, b), band(bnot(a), c))
end

function ops.uint32_majority(a, b, c)
   -- One less bitwise operation than (a & b) | (a & c) | (b & c).
   return bor(band(a, bor(b, c)), band(b, c))
end


return ops
