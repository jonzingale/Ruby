require 'byebug'
# AN ATTEMPT TO BUILD BlowFish.

def rand_uint32 ; 2**(rand 32) ; end

# uint32_t P[18];
# uint32_t S[4][256];
PP = (0...18).map{ rand_uint32 }
SS = (0...4).map{ (1..256).map{ rand_uint32 } }

# uint32_t f (uint32_t x) {
#    uint32_t h = S[0][x >> 24] + S[1][x >> 16 & 0xff];
#    return ( h ^ S[2][x >> 8 & 0xff] ) + S[3][x & 0xff];
# }
def ff x
  h = SS[0][x >> 24] + SS[1][x >> 16 & 0xff]
  h | SS[2][x >> 8 & 0xff] + SS[3][x & 0xff]
end

# break up message into length 16 L and R messages
def encode msg
  code = msg.split('').inject(''){|str,n|str += n.ord.to_s}
  code.scan(/.{4}/).map(&:to_i) # likely good for
end

# void encrypt (uint32_t & L, uint32_t & R) {
#    for (int i=0 ; i<16 ; i += 2) {
#       L ^= P[i];
#       R ^= f(L);
#       R ^= P[i+1];
#       L ^= f(R);
#    }
#    L ^= P[16];
#    R ^= P[17];
#    swap (L, R);
# }
def encrypt(l_32, r_32)
  i=0
  while i < 16 ; i+=2
    l_32 |= PP[i]
    r_32 |= ff(l_32)
    r_32 |= PP[i+1]
    l_32 |= ff(r_32)
  end
  l_32 |= PP[16]
  r_32 |= PP[17]
  [r_32, l_32]
end

# void decrypt (uint32_t & L, uint32_t & R) {
#    for (int i=16 ; i > 0 ; i -= 2) {
#       L ^= P[i+1];
#       R ^= f(L);
#       R ^= P[i];
#       L ^= f(R);
#    }
#    L ^= P[1];
#    R ^= P[0];
#    swap (L, R);
# }
def decrypt(l_32, r_32)
  i=16
  while i > 0 ; i -= 1
    l_32 |= PP[i+1]
    r_32 |= ff(l_32)
    r_32 |= PP[i]
    l_32 |= ff(r_32)
  end
  l_32 |= PP[1]
  r_32 |= PP[0]
  [r_32, l_32]
end

# {
#    // ...
#    // initializing the P-array and S-boxes with values
#    // derived from pi; omitted in the example
#    // ...
#    for (int i=0 ; i<18 ; ++i)
#       P[i] ^= key[i % keylen];
#    uint32_t L = 0, R = 0;
#    for (int i=0 ; i<18 ; i+=2) {
#       encrypt (L, R);
#       P[i] = L; P[i+1] = R;
#    }
#    for (int i=0 ; i<4 ; ++i)
#       for (int j=0 ; j<256; j+=2) {
#          encrypt (L, R);
#          S[i][j] = L; S[i][j+1] = R;
#       }
# }

msg = encode('Damn')
ee = encrypt(*msg)
dd = decrypt(*ee)

byebug ; 4