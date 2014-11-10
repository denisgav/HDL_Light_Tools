package utils is
	procedure add(a: integer; b: integer; c: out integer);
end package;

package body utils is
	procedure add(a: integer; b: integer; c: out integer) is
	begin
		c := a + b;
	end procedure;
end package body;

library work;
use work.utils.add;

entity testbench is
end entity;

architecture tb of testbench is
	signal a, b, c : integer := 2;
begin
	process begin
		add(a, b, c);
		wait;
	end process;
end architecture;