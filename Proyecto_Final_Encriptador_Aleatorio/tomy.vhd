----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:22:02 11/29/2023 
-- Design Name: 
-- Module Name:    tomy - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity tomy is
	Port (operand : in std_logic_vector(7 downto 0);
          Y : out std_logic_vector(7 downto 0);
          clk : in std_logic);
	
	
end tomy;

architecture Behavioral of tomy is

signal contador : integer := 0;

begin
	
process(clk)
    begin
        if rising_edge(clk) then
            -- Contar el número de unos en el operando
            contador <= to_integer(unsigned(operand));

            -- Sumar 1 al resultado si el número de unos es impar
            if (contador mod 2 = 1) then
                Y <= operand + "00000001";
            else
                Y <= operand;
            end if;
        end if;
    end process;

end Behavioral;

