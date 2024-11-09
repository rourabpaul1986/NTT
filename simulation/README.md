# Run ctbf_fault.py
This file tarnsforms a coeffcient form of N-1 degree polynomial into pointwise representation using ntt.forward(A, f, l, w, detect, fault_mode, check_node, verbose= verbose_mode) where A is the N-1 degree polynomial, f is the number of fault you want inject, l is the number of bits in each elements of polynomial coefficient and q, w is the number of bits you want compute at a time

## Steps
To run ctbf_fault.py you need to pass 4 input arguments where -f specifies the number of random fault bit you want to inject in multiplier A and B. -s specifies sample size you want to run. -m specifes 3 conditions:
if -m=A it means fault will be injected in A only
if -m=B it means fault will be injected in B only
if -m=AB it means fault will be injected in AB only

### 1. open
```python3 ctbf_fault.py -f 3 -s 100 -m B -c Ut```



