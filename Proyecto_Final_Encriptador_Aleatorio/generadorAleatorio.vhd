----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:23:40 11/22/2023 
-- Design Name: 
-- Module Name:    n - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generadorAleatorio is
	generic (
		init_z1	    : std_logic_vector(15 downto 0) := x"EF70";
		init_z2	    : std_logic_vector(15 downto 0) := x"BB56";
		init_z3	    : std_logic_vector(15 downto 0) := x"A780"
    );
    port (
		clk : in std_logic;
		rst : in std_logic;
		data_out_generador_1 : out std_logic_vector(7 downto 0);
		data_out_generador_2 : out std_logic_vector(7 downto 0);
		port_id: in std_logic_vector(7 downto 0); 
		write_strobe: in std_logic;
		data_in:	in std_logic_vector(7 downto 0)
		
     				
    );
end generadorAleatorio;

architecture Behavioral of generadorAleatorio is

signal z1_next : std_logic_vector(15 downto 0);
	signal z2_next : std_logic_vector(15 downto 0);
	signal z3_next : std_logic_vector(15 downto 0);
	signal z1 : std_logic_vector( 15 downto 0);
	signal z2 : std_logic_vector( 15 downto 0);
	signal z3 : std_logic_vector( 15 downto 0); 
	signal data : std_logic_vector( 15 downto 0); 
	signal data_1 : std_logic_vector( 7 downto 0); 
	signal data_2 : std_logic_vector( 7 downto 0); 
	
	signal enable,reset: std_logic;
	signal R0 : std_logic_vector ( 7 downto 0);
	
	 
	type mis_estados is (inicio, fin);
	signal actual,siguiente: mis_estados;

begin

	z1_next <= z1(9 downto 1) & (z1(15 downto 9) xor z1(8 downto 2));
		z2_next <= z2(15 downto 7) & (z2(12 downto 6) xor z2(7 downto 1));
		z3_next <= z3(8 downto 0) & (z3(6 downto 0) xor z3(14 downto 8));
		
	
	data_1<=data(7 downto 0);
	data_2<= data(15 downto 8);
	
	
	process(clk,rst) begin
		if(rst='1') then
			actual<= inicio;
		elsif rising_edge(clk) then
			actual<= siguiente;
		end if;
	end process;
	
	process(R0,actual) begin
			
			reset  <='0';
			enable <='0';
		
		
		case actual is 
							
				when inicio => if(R0 =x"72") then -- si recibimos una r
										
										siguiente <= fin;
									
									else	
										
										siguiente <= inicio;
									end if;
				
				when fin =>  enable <= '1';
									reset <= '1';	
								siguiente <= inicio;
				end case;
		end process;
	
		
	process(clk,rst) begin
		if(rst ='1') then 
			
			z1 <= init_z1; --inicialmente le damos los valores por defecto
			z2 <= init_z2;
			z3 <= init_z3;
		elsif rising_edge(clk) then
			data <= z1_next xor z2_next xor z3_next;
			z1 <= z1_next ; -- actualizamos 
			z2 <= z2_next ;
			z3 <= z3_next ;
		end if;
	end process;	
	
	
	process(clk,rst) begin
		if(rst='1' ) then
		data_out_generador_1<= (others =>'0');
		data_out_generador_2<= (others =>'0');
		elsif (rising_edge(clk) and enable='1') then
				
					data_out_generador_1 <= data_1;
				
				
					data_out_generador_2 <= data_2;
			
			
		end if;
	end process;
	
	
	
	
		
		---PROCESO R0  x47 
	process(clk, reset,rst) begin
		if(reset ='1' or rst ='1') then
			R0 <=(others =>'0');
			elsif rising_edge(clk) then
				if (port_id = x"47" and write_strobe = '1') then
						R0 <=  data_in;
					end if;
			end if;
end process;
		



end Behavioral;