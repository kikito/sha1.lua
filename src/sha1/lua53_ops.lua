local ops = {}

function ops.uint32_lrot(a, bits)
   return ((a << bits) & 0xFFFFFFFF) | (a >> (32 - bits))
end

function ops.byte_xor(a, b)
   return a ~ b
end

function ops.uint32_xor_3(a, b, c)
   return a ~ b ~ c
end

function ops.uint32_xor_4(a, b, c, d)
   return a ~ b ~ c ~ d
end

function ops.uint32_ternary(a, b, c)
   return (a & b) | (~a & c)
end

function ops.uint32_majority(a, b, c)
   -- One less bitwise operation than (a & b) | (a & c) | (b & c).
   return (a & (b | c)) | (b & c)
end

return ops
