import math
import random
import numpy as np
import ast
import random
#########################library to open nayuki website##############################
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import Select
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from datetime import datetime
from selenium.common.exceptions import TimeoutException
import time
import os
from datetime import datetime
import webdriver_manager
import selenium
import sys
import argparse
import threading
##################################################################################
chrome_options = Options()
chrome_options.add_argument("--headless")  # Enable headless mode
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
chrome_options.add_argument("--window-size=1920x1080") 
# Optionally, you can use ChromeDriverManager for automatic management of the driver
driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()), options=chrome_options)
#driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
link="https://www.nayuki.io/page/number-theoretic-transform-integer-dft"
driver.get(link)
# Locate the input element by its ID and set the value
input_element0 = WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.ID, "circular-convolution-input-vector-0"))
)

input_element1 = WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.ID, "circular-convolution-input-vector-1"))
)
input_element0.clear()  # Clear any existing value
input_element1.clear()  # Clear any existing value

input_elementm = WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.ID, "circular-convolution-minimum-working-modulus"))
)
input_elementm.clear()  # Clear any existing value

input_elementw = WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.ID, "circular-convolution-nth-root-of-unity"))
)
input_elementw.clear()  # Clear any existing value
###########################################################################################
def flip_random_bits(binary_str, n):
    # Convert binary string to a list of characters for mutability
    binary_list = list(binary_str)
    
    # Get the length of the binary number
    length = len(binary_list)
    
    # Select n random positions in the binary string to flip
    positions = random.sample(range(length), n)
    
    # Flip the bits at the chosen positions
    for pos in positions:
        # Flip the bit: if it's '0', change to '1', and vice versa
        binary_list[pos] = '1' if binary_list[pos] == '0' else '0'
    
    # Convert the list back to a string and return it
    return ''.join(binary_list)
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

def word_wise_montgomery_multiplication(A, B, N, N_prime, l, w, b, R, f):
    T=0
    m=l//w
    fault=[0]*m
    ####################################
    unfault_A=A
    fault_A = flip_random_bits(A, f)
    #fault_A = A
    ####################################
    #xor_result = int(A,2) ^ int(fault_A,2)
    #result_str = bin(xor_result)[2:].zfill(len(A))
    #print(f"A: {A}, fault_A: {fault_A} no. of fault: {result_str} ")
    
    for i in range(m):
       T0=T%b
       B0=B[-w:]
       #########################################
       Aw=fault_A[-w:] 
       At=unfault_A[-w:] 
       k=random.randint(0, 10)
       Awf=(int(At,2)+(k*N))%N
       #########################################       
       #print(f"Aw is {Aw} & B0 is {B0}")
       u=((T0+int(Aw,2)*int(B0,2))*N_prime) % b
       u_f=((T0+Awf*int(B0,2))*N_prime) % b
       if(u!=u_f):
        fault[i]=1
       print(f"Aw: {int(Aw,2)%N}, Awf: {Awf}, B0:{B0}; N_prime:{N_prime}; T0: {T0}; u: {u} & u_f: {u_f} ")
       
       T=(T  +  (int(Aw,2)*int(B,2)) + (u*N)) // b
       fault_A = fault_A[:-w] 
       unfault_A = unfault_A[:-w] 
    # Step 4: Check if T >= N and perform final subtraction if necessary
    if T >= N:
     T = T-N
    T=T*R % N
    print(f"fault:{fault}")
    return T


def generate_random_numbers(n, a, b):
    random_numbers = [random.randint(a, b) for _ in range(n)]
    return random_numbers


def mont_mult_top(l, w, A, B, N, f):

    b=2**w 
    N_prime=pow(-N,-1, b)
    R=2**l

    A_bin = l_binary(A, l)
    B_bin = l_binary(B, l)
    N_bin = l_binary(N, l)
    #print(f"N_prime {N_prime}")
    result= word_wise_montgomery_multiplication(A_bin, B_bin, N, N_prime, l, w, b, R, f)
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

def CT_Butterfly(x_out, A, twiddle_factor, M, length, f):
    l=16
    w=4
    #print(f"tomega: {twiddle_factor}")
    if length <= 1:
        x_out[0] = A[0]
        return x_out
    halflen = length >> 1
    for i in range(halflen):
        u = A[i]
        #v = modmult(A[i + halflen], twiddle_factor, M) # this line should be on for school book multiplication
        #print(f"Ai:{A[i + halflen]}")
        #print(f"omega:{twiddle_factor}")
        
        v=mont_mult_top(l, w, A[i + halflen], twiddle_factor, M, f)
       
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
        print(f"unitial omega: {self.alpha}")
        self.alpha_modpow_table = [modpow(self.alpha, i, M) for i in range(N+1)]
        self.bit_reverse_table = [bit_reverse(i, self.Nlen - 1) for i in range(N // 2)]

    def forward(self, x_in, f):
        if len(x_in) != self.N:
            raise ValueError(f'Input should be sized {self.N}')
        x = np.copy(x_in)
        for i in range(self.Nlen):
            n = 1 << i
            seqlen = self.N // n
            for j in range(n):
                twiddle_factor = self.alpha_modpow_table[self.bit_reverse_table[j]]
                CT_Butterfly(x[seqlen * j: seqlen * (j + 1)], x[seqlen * j: seqlen * (j + 1)], twiddle_factor, self.M, seqlen, f)
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
                CT_Butterfly(x[seqlen * j: seqlen * (j + 1)], x[seqlen * j: seqlen * (j + 1)], twiddle_factor, self.M, seqlen, f)
        x = [modmult(i, self.Ninv, self.M) for i in x]
        return bit_reverse(x, self.Nlen)
def check_arrays(array1, array2):
    if len(array1) != len(array2):
        print(f"Wrong: Arrays have different lengths. {len(array1)} {len(array2)}")
        return False
    for i in range(len(array1)):
        if array1[i] != array2[i]:
            print(f"Wrong: Elements at index {i} are different ({array1[i]} != {array2[i]}).")
            return False
    print("Bingo !!  All elements match.")
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
    f=0 # number of fault bit
    A = generate_random_numbers(N, 0, M)
    B = generate_random_numbers(N, 0, M)
    print(f"Input Polynomial A of degree {len(A)-1}: {A}")
    print(f"Input Polynomial B of degree {len(B)-1}: {B}")
    ntt_A = ntt.forward(A, f)
    ntt_B = ntt.forward(B, f)
    print(f"Forward NTT of A: {ntt_A}")
    print(f"Forward NTT of B: {ntt_B}")
    A_str = str(A)
    input_element0.send_keys(A_str)
    B_str = str(B)
    input_element1.send_keys(B_str)
    input_elementm.send_keys(M)
    button = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.ID, "circular-convolution-calculate")))
    button.click()
    
    output_element = WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.ID, "circular-convolution-output-vector")))
    output_nayuki = output_element.text
    

    ntt_mult = [0] * N  # Creates a list with 5 elements, all initialized to 0
    for i in range(N):
    	ntt_mult[i]=mont_mult_top(l, w, ntt_A[i], ntt_B[i], M, f)
    print(f"ntt_mult: {ntt_mult}")
    inv_ntt_mult = ntt.inverse(ntt_mult)
    print(f"\033[31m Final NTT mult Result (after Inverse NTT): {inv_ntt_mult} \033[0m")
    print(f"\033[31m Output vector from [https://www.nayuki.io/] is: {output_nayuki} \033[0m")
    #inv_ntt_A = ntt.inverse(ntt_A)
    #print(f"Inverse NTT Result (should match original): {inv_ntt_A}")
    check_arrays(inv_ntt_mult, ast.literal_eval(output_nayuki))
