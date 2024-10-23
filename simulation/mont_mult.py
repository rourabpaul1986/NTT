
def word_wise_montgomery_multiplication(A, B, N, N_prime, l, w,b,R):
    T=0
    m=l//w
    for i in range(m):
       Aw=A[-4:]
       B0=B[-4:]
       print(f"Aw is {Aw} & B0 is {B0}")
       u=((T+int(Aw,2)*int(B0,2))*N_prime) % b
       
       print(f"u{i} is {u}")
       T=(T  +  (int(Aw,2)*int(B,2)) + (u*N)) // b
       print(f"T{i} is {T}")
       A = A[:-4] 
    # Step 4: Check if T >= N and perform final subtraction if necessary
    if T >= N:
     T = T-N
    T=T*R % N
    return T


l = 20 #lenth of binary bits
w = 4  # how many binary bits will be processed
b=2**4 

A = 5792      # Example operand A 
B = 1229       # Example operand B i
N = 72639     # Modulus
N_prime=pow(-N,-1, b)
R=2**l
A_bin = bin(A)[2:]
A_bin = A_bin.zfill(l)
print(f"Binary representation of {A} is {A_bin}")
B_bin = bin(B)[2:]
B_bin = B_bin.zfill(l)
print(f"Binary representation of {B} is {B_bin}")
N_bin = bin(N)[2:]
N_bin = N_bin.zfill(l)
print(f"Binary representation of {N} is {N_bin}")
print(f"N_prime {N_prime}")
result = word_wise_montgomery_multiplication(A_bin, B_bin, N, N_prime, l, w,b,R)
print(f"The result of Montgomery multiplication is: {result}")
