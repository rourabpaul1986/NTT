# Folded Architecture of Forward NTT
If vivado and python environment are properly installed then just write
```
./run
```
The ./run file will generate all the required vhdl files of forward ntt.
The run file has two variables n and q where n is the degree of the polynomial and q is the modulous. You can change the value of n and q as per your requirement. 
To verify your output please follow the print in red color in the terminal

![ntt forward](./ntt_test.png)


![test bench of forward ntt](./tb.png)

It is to be noted that final output of the forward NTT will not be actual content of the RAM. It will be the bit reverse value of RAM. That means the address of the ram should be reversed fliped.
