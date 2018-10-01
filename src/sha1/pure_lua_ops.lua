local common = require "sha1.common"

local ops = {}

local bytes_to_uint32 = common.bytes_to_uint32
local uint32_to_bytes = common.uint32_to_bytes

-- shift the bits of a 32 bit word. Don't use negative values for "bits"
function ops.uint32_lrot(a, bits)
   local power = 2 ^ bits
   local inv_power = 0x100000000 / power
   local lower_bits = a % inv_power
   return (lower_bits * power) + ((a - lower_bits) / inv_power)
end

local function make_byte_op_cache(bit_op)
   local prev_cache = {[0] = bit_op(0, 0), bit_op(0, 1), bit_op(1, 0), bit_op(1, 1)}
   local prev_power = 2

   for _ = 1, 3 do
      local cache = {}
      local power = prev_power * prev_power

      for a1 = 0, prev_power - 1 do
         local a1_prev_power = a1 * prev_power

         for a2 = 0, prev_power - 1 do
            local a2_power = a2 * prev_power
            local a_power = (a1_prev_power + a2) * power

            for b1 = 0, prev_power - 1 do
               local a_power_plus_b1_prev_power = a_power + b1 * prev_power
               local r1_prev_power = prev_cache[a1_prev_power + b1] * prev_power

               for b2 = 0, prev_power - 1 do
                  cache[a_power_plus_b1_prev_power + b2] = r1_prev_power + prev_cache[a2_power + b2]
               end
            end
         end
      end

      prev_cache = cache
      prev_power = power
   end

   return prev_cache
end

local byte_and_cache = make_byte_op_cache(function(a, b) return a * b end)
local byte_or_cache = make_byte_op_cache(function(a, b) return a + b - a * b end)
local byte_xor_cache = make_byte_op_cache(function(a, b) return a == b and 0 or 1 end)

function ops.byte_xor(a, b)
   return byte_xor_cache[a * 256 + b]
end

function ops.uint32_xor_3(a, b, c)
   local a1, a2, a3, a4 = uint32_to_bytes(a)
   local b1, b2, b3, b4 = uint32_to_bytes(b)
   local c1, c2, c3, c4 = uint32_to_bytes(c)

   return bytes_to_uint32(
      byte_xor_cache[a1 * 256 + byte_xor_cache[b1 * 256 + c1]],
      byte_xor_cache[a2 * 256 + byte_xor_cache[b2 * 256 + c2]],
      byte_xor_cache[a3 * 256 + byte_xor_cache[b3 * 256 + c3]],
      byte_xor_cache[a4 * 256 + byte_xor_cache[b4 * 256 + c4]]
   )
end

function ops.uint32_xor_4(a, b, c, d)
   local a1, a2, a3, a4 = uint32_to_bytes(a)
   local b1, b2, b3, b4 = uint32_to_bytes(b)
   local c1, c2, c3, c4 = uint32_to_bytes(c)
   local d1, d2, d3, d4 = uint32_to_bytes(d)

   return bytes_to_uint32(
      byte_xor_cache[a1 * 256 + byte_xor_cache[b1 * 256 + byte_xor_cache[c1 * 256 + d1]]],
      byte_xor_cache[a2 * 256 + byte_xor_cache[b2 * 256 + byte_xor_cache[c2 * 256 + d2]]],
      byte_xor_cache[a3 * 256 + byte_xor_cache[b3 * 256 + byte_xor_cache[c3 * 256 + d3]]],
      byte_xor_cache[a4 * 256 + byte_xor_cache[b4 * 256 + byte_xor_cache[c4 * 256 + d4]]]
   )
end

function ops.uint32_ternary(a, b, c)
   local B1, B2, B3, B4 = uint32_to_bytes(a)
   local C1, C2, C3, C4 = uint32_to_bytes(b)
   local D1, D2, D3, D4 = uint32_to_bytes(c)

   return bytes_to_uint32(
      byte_or_cache[byte_and_cache[C1 * 256 + B1] * 256 + byte_and_cache[D1 * 256 + 255 - B1]],
      byte_or_cache[byte_and_cache[C2 * 256 + B2] * 256 + byte_and_cache[D2 * 256 + 255 - B2]],
      byte_or_cache[byte_and_cache[C3 * 256 + B3] * 256 + byte_and_cache[D3 * 256 + 255 - B3]],
      byte_or_cache[byte_and_cache[C4 * 256 + B4] * 256 + byte_and_cache[D4 * 256 + 255 - B4]]
   )
end

function ops.uint32_majority(a, b, c)
   local B1, B2, B3, B4 = uint32_to_bytes(a)
   local C1, C2, C3, C4 = uint32_to_bytes(b)
   local D1, D2, D3, D4 = uint32_to_bytes(c)

   return bytes_to_uint32(
      byte_or_cache[byte_and_cache[B1 * 256 + byte_or_cache[C1 * 256 + D1]] * 256 + byte_and_cache[C1 * 256 + D1]],
      byte_or_cache[byte_and_cache[B2 * 256 + byte_or_cache[C2 * 256 + D2]] * 256 + byte_and_cache[C2 * 256 + D2]],
      byte_or_cache[byte_and_cache[B3 * 256 + byte_or_cache[C3 * 256 + D3]] * 256 + byte_and_cache[C3 * 256 + D3]],
      byte_or_cache[byte_and_cache[B4 * 256 + byte_or_cache[C4 * 256 + D4]] * 256 + byte_and_cache[C4 * 256 + D4]]
   )
end

return ops
