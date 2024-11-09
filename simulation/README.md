# Run ctbf_fault.py
This file tarnsforms a coeffcient form of N-1 degree polynomial into pointwise representation using ntt.forward(A, f, l, w, detect, fault_mode, check_node, verbose= verbose_mode) where A is the N-1 degree polynomial, f is the number of fault you want inject, l is the number of bits in each elements of polynomial coefficient and q, w is the number of bits you want compute at a time
This file can inject fault in A and 

## Steps
The below steps need follow sequentially:

### 1. open
```python3 ctbf_fault.py -f 3 -s 100 -m B -c Ut```



