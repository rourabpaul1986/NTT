import math
import random
import numpy as np
def rule_check(l, w, N):
    if(l%w!=0):
     print(f"Error: l={l} must be divisible by w={w}")
     sys.exit(1)  # Exit with a non-zero status code indicating an error.
    
    n=math.ceil(math.log2(N))
    #print(f"n={n} l={l}")
    if(l<=n):
     print(f"Error: l={l} must be grater than the number of binary bit required by N={N}")
     sys.exit(1)  # Exit with a non-zero status code indicating an error.


def l_binary(decimal, l):
 binary = bin(decimal)[2:]
 binary = binary.zfill(l) 
 #print(f"{l} bit Binary representation of {decimal} is {binary}")
 return binary

def word_wise_montgomery_multiplication(A, B, N, N_prime, l, w, b, R):
    T=0
    m=l//w
    for i in range(m):
       Aw=A[-w:]
       B0=B[-w:]
       #print(f"Aw is {Aw} & B0 is {B0}")
       u=((T+int(Aw,2)*int(B0,2))*N_prime) % b
       
       #print(f"u{i} is {u}")
       T=(T  +  (int(Aw,2)*int(B,2)) + (u*N)) // b
       #print(f"T{i} is {T}")
       A = A[:-w] 
    # Step 4: Check if T >= N and perform final subtraction if necessary
    if T >= N:
     T = T-N
    T=T*R % N
    return T


def generate_random_numbers(n, a, b):
    random_numbers = [random.randint(a, b) for _ in range(n)]
    return random_numbers


def mont_mult_top(l, w, A, B, N):

    b=2**w 
    N_prime=pow(-N,-1, b)
    R=2**l

    A_bin = l_binary(A, l)
    B_bin = l_binary(B, l)
    N_bin = l_binary(N, l)
    #print(f"N_prime {N_prime}")
    result = word_wise_montgomery_multiplication(A_bin, B_bin, N, N_prime, l, w, b, R)
    #print(f"The result of Montgomery multiplication is: {result}")
    return result

def modmult(a, b, M):
    return (a * b) % M

def modpow(alpha, n, M):
    if n == 0:
        return 1
    p = 1
    bn = bin(n)
    for b in bn[2:]:
        p = modmult(p, p, M)
        if b == '1':
            p = modmult(p, alpha, M)
    return p

def is_primitive(alpha, N, M):
    for i in range(1, N):
        if modpow(alpha, i, M) == 1:
            return False
    return modpow(alpha, N, M) == 1

def find_primitive(N, M):
    for alpha in range(2, M):
        if is_primitive(alpha, N, M):
            return alpha
    return 0

def findinv(alpha, M):
    for i in range(M):
        if modmult(alpha, i, M) == 1:
            return i

def bit_reverse(x, n):
    if type(x) == int:
        b = '{:0{width}b}'.format(x, width=n)
        return int(b[::-1], 2)
    else:
        x_out = np.zeros(len(x), dtype=int)
        for i in range(len(x)):
            x_out[i] = x[bit_reverse(i, n)]
        return x_out

def CT_Butterfly(x_out, A, twiddle_factor, M, length):
    l=16
    w=4
    if length <= 1:
        x_out[0] = A[0]
        return x_out
    halflen = length >> 1
    for i in range(halflen):
        u = A[i]
        #v = modmult(A[i + halflen], twiddle_factor, M)
        #print(f"Ai:{A[i + halflen]}")
        #print(f"omega:{twiddle_factor}")
        v=mont_mult_top(l, w, A[i + halflen], twiddle_factor, M)
        x_out[i] = (u + v) % M
        x_out[i + halflen] = (u - v) % M
    return x_out

class fNTT:
    def __init__(self, N, M, alpha=None):
        self.N = N
        self.M = M
        self.Nlen = int(np.log2(N))
        self.Ninv = findinv(self.N, self.M)
        if alpha is not None and not is_primitive(alpha, N, M):
            raise ValueError('Given alpha is not primitive')
        self.alpha = alpha or find_primitive(N, M)
        if self.alpha == 0:
            raise ValueError('No primitive root exists')

        self.alpha_modpow_table = [modpow(self.alpha, i, M) for i in range(N+1)]
        self.bit_reverse_table = [bit_reverse(i, self.Nlen - 1) for i in range(N // 2)]

    def forward(self, x_in):
        if len(x_in) != self.N:
            raise ValueError(f'Input should be sized {self.N}')
        x = np.copy(x_in)
        for i in range(self.Nlen):
            n = 1 << i
            seqlen = self.N // n
            for j in range(n):
                twiddle_factor = self.alpha_modpow_table[self.bit_reverse_table[j]]
                CT_Butterfly(x[seqlen * j: seqlen * (j + 1)], x[seqlen * j: seqlen * (j + 1)], twiddle_factor, self.M, seqlen)
        return bit_reverse([i % self.M for i in x], self.Nlen)

    def inverse(self, x_in):
        if len(x_in) != self.N:
            raise ValueError(f'Input should be sized {self.N}')
        x = np.copy(x_in)
        for i in range(self.Nlen):
            n = 1 << i
            seqlen = self.N // n
            for j in range(n):
                twiddle_factor = self.alpha_modpow_table[self.N - self.bit_reverse_table[j]]
                CT_Butterfly(x[seqlen * j: seqlen * (j + 1)], x[seqlen * j: seqlen * (j + 1)], twiddle_factor, self.M, seqlen)
        x = [modmult(i, self.Ninv, self.M) for i in x]
        return bit_reverse(x, self.Nlen)
def check_arrays(array1, array2):
    if len(array1) != len(array2):
        print("Wrong: Arrays have different lengths.")
        return False
    for i in range(len(array1)):
        if array1[i] != array2[i]:
            print(f"Wrong: Elements at index {i} are different ({array1[i]} != {array2[i]}).")
            return False
    print("Correct: All elements match.")
    return True
if __name__ == "__main__":
    N = 16  # Size of the input sequence, must be a power of 2
    M = 7681  # A prime number for modulus
    ntt = fNTT(N, M)
    l = 16 #lenth of binary bits
    w = 4  # how many binary bits will be processed
    #A = 5792      # Example operand A 
    #B = 1229      # Example operand B i
    #N = 72639     # Modulus
    #N = 7681     # Modulus
    #omega=3383
    
    A = generate_random_numbers(N, 0, M)
    print(f"Original input sequence: {A}")
    ntt_A = ntt.forward(A)
    print(f"NTT Result: {ntt_A}")
    ntt_mult = [0] * N  # Creates a list with 5 elements, all initialized to 0
    for i in range(N):
    	ntt_mult[i]=mont_mult_top(l, w, ntt_A[i], ntt_A[i], M)
    print(f"ntt_mult: {ntt_mult}")
    inv_ntt_mult = ntt.inverse(ntt_mult)
    print(f"Inverse NTT Mult: {inv_ntt_mult}")
    #inv_ntt_A = ntt.inverse(ntt_A)
    #print(f"Inverse NTT Result (should match original): {inv_ntt_A}")
    #check_arrays(A, inv_ntt_A)
