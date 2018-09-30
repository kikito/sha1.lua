local sha1 = {
  _VERSION     = "sha.lua 0.5.0",
  _URL         = "https://github.com/kikito/sha.lua",
  _DESCRIPTION = [[
   SHA-1 secure hash computation, and HMAC-SHA1 signature computation in Lua (5.1)
   Based on code originally by Jeffrey Friedl (http://regex.info/blog/lua/sha1)
   And modified by Eike Decker - (http://cube3d.de/uploads/Main/sha1.txt)
  ]],
  _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota + Eike Decker + Jeffrey Friedl

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local function choose_ops_module()
   if _VERSION:find("5%.3") then
      return "sha1.lua53_ops"
   elseif pcall(require, "bit") then
      return "sha1.bit_ops"
   elseif pcall(require, "bit32") then
      return "sha1.bit32_ops"
   else
      return "sha1.pure_lua_ops"
   end
end

local ops = require(choose_ops_module())
local uint32_lrot = ops.uint32_lrot
local byte_xor = ops.byte_xor
local uint32_xor_3 = ops.uint32_xor_3
local uint32_xor_4 = ops.uint32_xor_4
local loop_op_1 = ops.loop_op_1
local loop_op_3 = ops.loop_op_3

-- local storing of global functions (minor speedup)
local modf = math.modf
local char,format,rep = string.char,string.format,string.rep

local function bytes_to_uint32(a, b, c, d)
   return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
end

local function hex_to_binary(hex)
   return hex:gsub('..', function(hexval)
      return string.char(tonumber(hexval, 16))
   end)
end

-----------------------------------------------------------------------------

-- calculating the SHA1 for some text
function sha1.sha1(msg)
   local H0,H1,H2,H3,H4 = 0x67452301,0xEFCDAB89,0x98BADCFE,0x10325476,0xC3D2E1F0
   local msg_len_in_bits = #msg * 8

   local first_append = char(0x80) -- append a '1' bit plus seven '0' bits

   local non_zero_message_bytes = #msg +1 +8 -- the +1 is the appended bit 1, the +8 are for the final appended length
   local current_mod = non_zero_message_bytes % 64
   local second_append = current_mod>0 and rep(char(0), 64 - current_mod) or ""

   -- now to append the length as a 64-bit number.
   local B1, R1 = modf(msg_len_in_bits  / 0x01000000)
   local B2, R2 = modf( 0x01000000 * R1 / 0x00010000)
   local B3, R3 = modf( 0x00010000 * R2 / 0x00000100)
   local B4    = 0x00000100 * R3

   local L64 = char( 0) .. char( 0) .. char( 0) .. char( 0) -- high 32 bits
      .. char(B1) .. char(B2) .. char(B3) .. char(B4) --  low 32 bits

   msg = msg .. first_append .. second_append .. L64

   assert(#msg % 64 == 0)

   local W = {}

   for start = 1, #msg, 64 do
      --
      -- break chunk up into W[0] through W[15]
      --

      for t = 0, 15 do
         W[t] = bytes_to_uint32(msg:byte(start, start + 3))
         start = start + 4
      end

      --
      -- build W[16] through W[79]
      --
      for t = 16, 79 do
         -- For t = 16 to 79 let Wt = S1(Wt-3 XOR Wt-8 XOR Wt-14 XOR Wt-16).
         W[t] = uint32_lrot(uint32_xor_4(W[t-3], W[t-8], W[t-14], W[t-16]), 1)
      end

      local A, B, C, D, E = H0, H1, H2, H3, H4

      for t = 0, 79 do
         local f, K

         if t <= 19 then
            -- (B AND C) OR ((NOT B) AND D)
            f = loop_op_1(B, C, D)
            --f = uint32_or(uint32_and(B, C), uint32_and(uint32_not(B), D))
            K = 0x5A827999
         elseif t <= 39 then
            -- B XOR C XOR D
            f = uint32_xor_3(B, C, D)
            K = 0x6ED9EBA1
         elseif t <= 59 then
            -- (B AND C) OR (B AND D) OR (C AND D)
            f = loop_op_3(B, C, D)
            K = 0x8F1BBCDC
         else
            -- B XOR C XOR D
            f = uint32_xor_3(B, C, D)
            K = 0xCA62C1D6
         end

         -- TEMP = S5(A) + ft(B,C,D) + E + Wt + Kt;
         A,B,C,D,E = (uint32_lrot(A, 5) + f + E + W[t] + K) % 4294967296, A, uint32_lrot(B, 30), C, D
      end

      -- Let H0 = H0 + A, H1 = H1 + B, H2 = H2 + C, H3 = H3 + D, H4 = H4 + E.
      H0 = (H0 + A) % 4294967296
      H1 = (H1 + B) % 4294967296
      H2 = (H2 + C) % 4294967296
      H3 = (H3 + D) % 4294967296
      H4 = (H4 + E) % 4294967296
   end
   return format("%08x%08x%08x%08x%08x", H0, H1, H2, H3, H4)
end

function sha1.binary(msg)
   return hex_to_binary(sha1.sha1(msg))
end

-- building the lookuptables ahead of time (instead of littering the source code
-- with precalculated values)
local xor_with_0x5c = {}
local xor_with_0x36 = {}
for i=0,0xff do
   xor_with_0x5c[char(i)] = char(byte_xor(0x5c, i))
   xor_with_0x36[char(i)] = char(byte_xor(0x36, i))
end

local BLOCK_SIZE = 64 -- 512 bits

function sha1.hmac(key, text)
   assert(type(key)  == 'string', "key passed to sha1.hmac should be a string")
   assert(type(text) == 'string', "text passed to sha1.hmac should be a string")

   if #key > BLOCK_SIZE then
      key = sha1.binary(key)
   end

   local key_xord_with_0x36 = key:gsub('.', xor_with_0x36) .. string.rep(string.char(0x36), BLOCK_SIZE - #key)
   local key_xord_with_0x5c = key:gsub('.', xor_with_0x5c) .. string.rep(string.char(0x5c), BLOCK_SIZE - #key)

   return sha1.sha1(key_xord_with_0x5c .. sha1.binary(key_xord_with_0x36 .. text))
end

function sha1.hmac_binary(key, text)
   return hex_to_binary(sha1.hmac(key, text))
end

setmetatable(sha1, {__call = function(_,msg) return sha1.sha1(msg) end })

return sha1
