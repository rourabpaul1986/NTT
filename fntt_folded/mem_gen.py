import math
import random
import numpy as np
import ast
import argparse
import subprocess
import os


def generate_variant_pkg(n, q, filename="./src/variant_pkg.vhd"):
    with open(filename, "w") as f:
        f.write(f"""library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

package variant_pkg is

constant n  : integer := {n};
constant q  : integer := {q};
constant logn : positive := positive(ceil(log2(real(n))));
constant lognby2 : positive := positive(ceil(log2(real(n/2))));
constant logq : positive := positive(ceil(log2(real(q))));

end variant_pkg;
""")





def generate_poly_mem_vhd(A, filename="./src/poly_mem.vhd"):
    with open(filename, "w") as f:
        f.write("""----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: {date}
-- Design Name: 
-- Module Name: poly_mem - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.variant_pkg.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity poly_mem is
    port(   clk : in std_logic; --clock
            wr_en : in std_logic;   --write enable for port 0
            data_in0 : in std_logic_vector(logq-1 downto 0);   --Input data to port 0.
            data_in1 : in std_logic_vector(logq-1 downto 0);   --Input data to port 1.
            addr_in_0 : in std_logic_vector(logn-1 downto 0);    --address for port 0
            addr_in_1 : in std_logic_vector(logn-1 downto 0);    --address for port 1
            ce : in std_logic;   --enable port 0.
            rd_en : in std_logic;   --enable port 1.
            data_out_0 : out std_logic_vector(logq-1 downto 0);  --output data from port 0.
            data_out_1 : out std_logic_vector(logq-1 downto 0)   --output data from port 1.
        );
end poly_mem;

architecture Behavioral of poly_mem is

    type ram_type is array(0 to {max_index}) of std_logic_vector(logq-1 downto 0);
    signal ram : ram_type := (
""".format(date="04/08/2025", max_index=len(A)-1))

        for i, val in enumerate(A):
            comma = ',' if i < len(A) - 1 else ''
            f.write(f"        {i:>2} => std_logic_vector(to_unsigned({val}, logq)){comma}\n")

        f.write("""    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if ce = '1' then
                if wr_en = '1' then
                    ram(conv_integer(addr_in_0)) <= data_in0;
                    ram(conv_integer(addr_in_1)) <= data_in1;
                end if;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if ce = '1' then
                if rd_en = '1' then
                    data_out_0 <= ram(conv_integer(addr_in_0));
                    data_out_1 <= ram(conv_integer(addr_in_1));
                end if;
            end if;
        end if;
    end process;

end Behavioral;
""")





def generate_random_numbers(n, a, b):
    return [random.randint(a, b) for _ in range(n)]
    
    
def generate_twidle(N, q, alpha=None):
    Nlen = int(np.log2(N))
    Ninv = findinv(N, q)
    if alpha is not None and not is_primitive(alpha, N, q):
        raise ValueError('Given alpha is not primitive')
    alpha = alpha or find_primitive(N, q)
    if alpha == 0:
        raise ValueError('No primitive root exists')
    print(f"initial omega: {alpha}")
    w = [modpow(alpha, i, q) for i in range(N+1)]
    return w
    
    
def findinv(alpha, M):
    for i in range(M):
        if modmult(alpha, i, M) == 1:
            return i
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
parser = argparse.ArgumentParser(description="Process fault tolerance level and verbose mode.")
parser.add_argument("-n", "--degree", type=int, required=True, help="Fault tolerance level (integer value)")
parser.add_argument("-q", "--modulus", type=int, required=True, help="Sample Size (integer value)")
args = parser.parse_args()

# Accessing the arguments
n = args.degree

q = args.modulus


# Generate polynomials
A = generate_random_numbers(n, 0, q)
#A = [2121, 1613, 2930, 3245, 33, 812, 3142, 1735, 2264, 1857, 1339, 2566, 1549, 1783, 1794, 777]
#B = [2121, 1613, 2930, 3245, 33, 812, 3142, 1735, 2264, 1857, 1339, 2566, 1549, 1783, 1794, 777]
w = generate_twidle(n, q)
generate_poly_mem_vhd(A)
generate_variant_pkg(n, q)
# Print polynomials
print(f"Input Polynomial A of degree {len(A)-1}: {A}")
#print(f"Input Polynomial B of degree {len(B)-1}: {B}")
print(f"Twiddle factor (w) : {w}")
A_str = ",".join(map(str, A))  # Serialize list
subprocess.run([
    "python3", "fntt.py",
    "-n", str(n),
    "-q", str(q),
    "--array", A_str
])
# Write to COE file
with open("w_mem.coe", "w") as f:
    #f.write("#Xilinx COE file for polynomials B\n")
    f.write("memory_initialization_radix=10;\n")
    f.write("memory_initialization_vector=\n")
    
    # Write w coefficients
    #f.write("# Polynomial B coefficients\n")
    f.write(", ".join(map(str, w)) + ";\n")

print("COE file 'w_mem.coe' generated successfully.")
