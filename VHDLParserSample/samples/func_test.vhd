library ieee;
use ieee.std_logic_1164.all;

entity top is
end entity;

architecture top of top is

function foo(a1: bit; a2: string) return bit
is begin
    return a1;
end;

function foo(b1: std_logic; b2: std_logic_vector) return bit
is begin
    return '1';
end;

function foo(c1: bit; c2: std_logic) return bit is
begin
	return c1;
end;

procedure foo(d1: bit; d2: bit) is
begin
end;

    signal st: bit_vector(1 downto 0) := (others => '0');
    signal st1 : bit := '1';

begin
	process is
	variable a1, a2: bit;
	variable s: bit;
	begin
--		s := foo(a1, a2);
--      s := foo('1', st1);
		s := foo('1', "000");
--		s := foo(foo('0', '1'), foo(a1, a2));
--        foo('0', st1);
		wait;
	end process;
end architecture;