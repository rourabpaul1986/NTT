# Folded Architecture of Forward NTT
If vivado and python environment are properly installed then just write
```
./run
```
The ./run file will generate all the required vhdl files of forward ntt.
The run file has two variables n and q where n is the degree of the polynomial and q is the modulous. You can change the value of n and q in 'src/variant_pkg.vhd. as per your requirement. 
To verify your output please follow the print in red color in the terminal

![ntt forward](./ntt_test.png)


![test bench of forward ntt](./tb.png)

It is to be noted that final output of the forward NTT (as shown in terminal) will  not be actual content of the RAM (in Vivado testbench). It will be the bit reverse value of RAM. That means the address of the ram should be reversed fliped. For an example if you need 5th polynomial co-efficnet, you need to reverse 5 ('0101') to 10 ('1010'). Instead of 5th content of the ram you need to take 10th content of the ram. Therfore 10th content of the ram is 0x89e which comes at the 5th position (2206 in decimal) of Forward NTT of A. you need to take 4 bits because the number of coefficnets are 16 which need log16=4 bits.
For verification you need to match the value of X with ram contents.

| Feature            | SampleNTT (Kyber) | Proposed SampleNTT |
|--------------------|-------------------|---------------------|
| Energy (nJ)        | 3000              | 2000                |
| Latency (%)        | Base              | 25% lower           |
| Slices (%)         | Base              | 0.25% fewer         |
| SHAKE128 Bytes     | 504               | 336                 |
