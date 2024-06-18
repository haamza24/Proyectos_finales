library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mi_programa is
	port( address : in std_logic_vector(7 downto 0);
		clk : in std_logic;
		dout : out std_logic_vector(15 downto 0));
	end;

architecture v1 of mi_programa is

	constant ROM_WIDTH: INTEGER:= 16;
	constant ROM_LENGTH: INTEGER:= 256;

	subtype rom_word is std_logic_vector(ROM_WIDTH-1 downto 0);
	type rom_table is array (0 to ROM_LENGTH-1) of rom_word;

constant rom: rom_table := rom_table'(
	"1111000000000000",
	"1101100000010100",
	"1000101001000001",
	"1000000101000001",
	"1101100000100001",
	"1000000101000010",
	"1101100000100001",
	"1101000000000001",
	"1100000111100000",
	"0010000100000000",
	"1101010000001110",
	"1101100000100001",
	"0010011100000001",
	"1101000000001000",
	"1111000000000001",
	"0000011000001001",
	"0011011000000001",
	"1101010100010000",
	"0000011000001001",
	"1101000000010000",
	"1000001011111111",
	"0000101010000000",
	"1101010100010100",
	"1101100000110101",
	"0000001100001001",
	"1101100000101110",
	"1010001000001110",
	"1000000011111111",
	"0000100010000000",
	"0101001000000000",
	"0011001100000001",
	"1101010100011001",
	"1001000000000000",
	"0000000000000000",
	"1000100011111111",
	"1101100000101110",
	"0000001100001000",
	"1000100111111111",
	"1101100000101110",
	"1010000100001110",
	"0011001100000001",
	"1101010100100101",
	"0000000011111111",
	"1000100011111111",
	"1101100000101110",
	"1001000000000000",
	"0000010000000011",
	"0000010100100010",
	"0011010100000001",
	"1101010100110000",
	"0011010000000001",
	"1101010100101111",
	"1001000000000000",
	"0000010000000011",
	"0000010100010000",
	"0011010100000001",
	"1101010100110111",
	"0011010000000001",
	"1101010100110110",
	"1001000000000000",
	"1111000000000000",
	"1101100000010100",
	"1111101000000000",
	"0100000101000000",
	"1101100000100001",
	"0010011000110000",
	"0100000111000000",
	"1101100000100001",
	"1011000000000001",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"1101000000111100");

begin

process (clk)
begin
	if clk'event and clk = '1' then
		dout <= rom(conv_integer(address));
	end if;
end process;
end v1;
