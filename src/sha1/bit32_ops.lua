local bit32 = require "bit32"

local ops = {}

local band = bit32.band
local bor = bit32.bor
local bnot = bit32.bnot

ops.uint32_lrot = bit32.lrotate
ops.byte_xor = bit32.bxor
ops.uint32_xor_3 = bit32.bxor
ops.uint32_xor_4 = bit32.bxor

function ops.uint32_ternary(B, C, D)
   return bor(band(B, C), band(bnot(B), D))
end

function ops.uint32_majority(B, C, D)
   -- One less bitwise operation than (a & b) | (a & c) | (b & c).
   return bor(band(B, bor(C, D)), band(C, D))
end

return ops
