dofile('base64.lua')

assert(Base64Decode('') == '')
assert(Base64Decode('Zg==') == 'f')
assert(Base64Decode('Zm8=') == 'fo')
assert(Base64Decode('Zm9v') == 'foo')
assert(Base64Decode('Zm9vYg==') == 'foob')
assert(Base64Decode('Zm9vYmE=') == 'fooba')
assert(Base64Decode('Zm9vYmFy') == 'foobar')
assert(Base64Decode('Zm9v\r\nYmFy') == 'foobar')
assert(Base64Decode('Zm9vYmE') == 'fooba')

assert(Base64Decode('AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w==')
    == (function() local t = {} for i = 0, 255 do t[#t + 1] = string.char(i) end return table.concat(t) end)())

assert(Base64Decode('Zm9v!') == nil)
assert(Base64Decode('Z') == nil)

print('base64 ok')
