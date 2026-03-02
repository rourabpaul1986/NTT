library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package variant_pkg is

constant l  : integer := 32;
--constant q : integer := 3329; --kyber --constant q : integer := 8380417;--Dilithium --
--constant q : integer := 12289;--falcon, ntru
--constant q_u : unsigned(l-1 downto 0) := x"100400001230002D";
--constant q_u : unsigned(l-1 downto 0) := x"D01";  --kyber
--constant q_u : unsigned(l-1 downto 0) := x"3001"; --12289;--falcon, ntru
--constant q_u : unsigned(l-1 downto 0) := x"3FFFD001";
constant q_u : unsigned(l-1 downto 0) := x"6C000001"; --CKSS
constant q : integer := to_integer(q_u);

constant logq : positive := l;
constant w : positive := 8;
constant k : integer := 2*logq; --32 for w=4
--constant mu : integer := (2**(2*logq)) / q; --2^k//n
constant mu_vec : unsigned(k-1 downto 0) := to_unsigned((2**(2*logq)) / q, k);
end variant_pkg;
