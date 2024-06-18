-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:28:58 11/09/2023 
-- Design Name: 
-- Module Name:    Encrypter - Behavioral 
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

entity encriptador is
Port(		data_in:	in std_logic_vector(7 downto 0); 
					port_id: in std_logic_vector(7 downto 0); 
					write_strobe: in std_logic; 
					clk: in std_logic; 
					data_out: out std_logic_vector(7 downto 0); 
					reset: in std_logic); 


end encriptador;

architecture Behavioral of encriptador is

		type estados is (inicio,clave, control ,encripter,desencripter,final,enc_plus,denc_plus);
		signal estado_actual , estado_siguiente : estados;

		signal R0,R1, R2,R3,R7: std_logic_vector(7 downto 0);
		signal clave_out, data_encripted ,data_desencripted: std_logic_vector(7 downto 0);
		signal encripter_ok:std_logic;
		signal enable_enc,enable_denc,desencripter_ok,rst,enable_error:std_logic;
		signal enable_dencp,enable_encp : std_logic;

begin
		
		
		
		
		---PROCESO R0  x41 C1
	process(clk, reset,rst) begin
		if(reset ='1' or rst ='1') then
			R0 <=(others =>'0');
			elsif rising_edge(clk) then
				if (port_id = x"41" and write_strobe = '1') then
						R0 <=  data_in;
					end if;
			end if;
end process;
		


	---PROCESO R1  x42  C2
	process(clk, reset,rst) begin
		if(reset ='1' or rst ='1') then
			R1 <=(others =>'0');
			elsif rising_edge(clk) then
				if (port_id = x"42" and write_strobe = '1') then
						R1 <=  data_in;
					end if;
			end if;
end process;			
			
	--PROCESO R2		x43 D1
process(clk, reset,rst) begin
		if(reset ='1' or rst ='1') then
			R2 <=(others =>'0');
			elsif rising_edge(clk) then
				if (port_id = x"43" and write_strobe = '1') then
						R2 <=  data_in;
					end if;
			end if;
end process;	



	--PROCESO R3 x44		R3 Puede ser :#,-,+  si es # eso nos peermite pasar de clave a control
			process(clk, reset,rst) begin
				if(reset ='1' or rst ='1') then
					R3<=(others =>'0');
					elsif rising_edge(clk) then
						if (port_id = x"44" and write_strobe = '1') then
						R3 <=  data_in;
					end if;
			end if;
end process;	


	--PROCESO R7 x47	 puerta logica para entrar al periferico	
			process(clk, reset,rst) begin
				if(reset ='1' or rst ='1') then
					R7<=(others =>'0');
					elsif rising_edge(clk) then
						if (port_id = x"47" and write_strobe = '1') then
						R7 <=  data_in;
					end if;
			end if;
end process;

				--SALIDA DE NUESTRA CLAVE CREADA siempre la tengo operativa 
					clave_out<=R0 XOR R1;


				--fsm:
				
			process(reset,clk) 
			begin 
				if(reset='1')then 
						estado_actual<=clave; 
					elsif (rising_edge(clk)) then 
						estado_actual<=estado_siguiente;       
			end if; 
	end process; 
	
	
	
			
			
			process(estado_actual,enable_enc,enable_denc,R3,R7)
							begin
									  rst<='0';enable_enc<='0'; enable_denc<='0'; encripter_ok<='0';	desencripter_ok<='0';	enable_error<='0';
						
							case estado_actual is
							
							when 	inicio => 			if(R7 =x"42") then	
															
																estado_siguiente<=clave;
															else
																estado_siguiente<=inicio;
															end if;
													
							
							when clave=>								--CONMUTO A CONTROL SI EN R3 HAY UN #
													if(R3=X"23") then	
														
														estado_siguiente<=control;
												else
														estado_siguiente<=clave;
									end if;
										
										
							when control=> if(R3=x"2b")then -- R3=+
													enable_enc<='1';
													estado_siguiente<=encripter;	
													
												elsif(R3=x"2d")then -- R3=-
														enable_denc<='1';
													estado_siguiente<=desencripter;
												elsif(R3=x"31")then -- R3=1
														enable_encp<='1';
													estado_siguiente<=enc_plus;
												elsif(R3=x"32")then -- R3=2
														enable_dencp<='1';
													estado_siguiente<=denc_plus;
													
												else
													enable_error<='1';
													estado_siguiente <= control;
										end if;
										
										
				
							when encripter=> 		
													enable_enc<='1';
													encripter_ok<='1';
													estado_siguiente<=final;
									
									
							when desencripter=>		
											
														enable_denc<='1';
														desencripter_ok<='1';
														estado_siguiente<=final;
														
							when enc_plus => 
													enable_encp<='1';
													desencripter_ok<='1';
													estado_siguiente<=final;
													
							
										
									
							
							when denc_plus => 
													enable_encp<='1';
													desencripter_ok<='1';
													estado_siguiente<=final;
													
													
	
		
									
							when final=>			rst <= '1';
														estado_siguiente <=clave;
														
														
									
													
								when others => estado_siguiente <= clave;		
									
					end case;
		end process;
				

	process(clk,reset) begin
		if(reset='1') then
			data_encripted<=(others=>'0');
		elsif rising_edge(clk) then
			if(enable_enc ='1')then
				
			data_encripted<=(R2(7 downto 0) xor clave_out(7 downto 0));
			elsif( enable_encp ='1') then
				data_encripted <= R2 ;
			end if;
		end if;
	end process;
	
	process(clk,reset) begin
		if(reset='1') then
			data_desencripted<=(others=>'0');
		elsif rising_edge(clk) then
			if(enable_denc ='1')then
				data_desencripted<=(R2(7 downto 0) xor clave_out(7 downto 0));
			elsif( enable_dencp ='1') then
				data_desencripted<= R2;
				
			end if;
		end if;
	end process;
		
	
	
	
	
	process(clk,reset) begin
		if(reset='1') then
			data_out <=(others =>'0');
		elsif rising_edge(clk) then
			if(encripter_ok ='1') then
				data_out<=data_encripted;
			
			elsif(desencripter_ok ='1') then
				data_out<= data_desencripted;
			
			elsif(enable_error ='1')then
				data_out <=x"3F";
			end if;
		end if;
	end process;

	
	
				
	
	
				
	
	
end Behavioral;