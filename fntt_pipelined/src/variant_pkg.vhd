library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

package variant_pkg is

constant n  : integer := 32;
constant q  : integer := 3329;
constant logn : positive := positive(ceil(log2(real(n))));
constant lognby2 : positive := positive(ceil(log2(real(n/2))));
constant logq : positive := positive(ceil(log2(real(q))));
constant max_loop : positive := logn*n/2;
end variant_pkg;
