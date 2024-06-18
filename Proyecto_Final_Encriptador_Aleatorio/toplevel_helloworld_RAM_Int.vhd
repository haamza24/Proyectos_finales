library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity toplevel is
    Port (      port_id : out std_logic_vector(7 downto 0);	--solo para depurar
           write_strobe : out std_logic;	 						--solo para depurar
            read_strobe : out std_logic;							--solo para depurar
               out_port : out std_logic_vector(7 downto 0);	--solo para depurar
                in_port : out std_logic_vector(7 downto 0);	--solo para depurar
						reset : in std_logic;
						  clk : in std_logic;
						   rx : in std_logic;
				         tx : out std_logic;
		     		      LED : out std_logic);	 --led de comprobacion y reset
end toplevel ;

architecture behavioral of toplevel is
----------------------------------------------------------------
-- declaracion del picoblaze
----------------------------------------------------------------
  component picoblaze
    Port (      address : out std_logic_vector(7 downto 0);
            instruction : in std_logic_vector(15 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
                  reset : in std_logic; 
						  clk : in std_logic);
    end component;


----------------------------------------------------------------
-- declaracion del CODIFICADOR
----------------------------------------------------------------

	component encriptador
	
	port(	data_in:	in std_logic_vector(7 downto 0);
			port_id: in std_logic_vector(7 downto 0);
			write_strobe: in std_logic;
			clk: in std_logic;
			reset: in std_logic;
			data_out: out std_logic_vector(7 downto 0));
			
	end component;

-- se�al de salida del periferico--
	signal data_out_encriptador: std_logic_vector(7 downto 0);
	

-----------------------------------------------------------------------------


component generadorAleatorio
	
	generic (
		init_z1	    : std_logic_vector(15 downto 0) := x"EF70";
		init_z2	    : std_logic_vector(15 downto 0) := x"BB56";
		init_z3	    : std_logic_vector(15 downto 0) := x"A780"
    );
	
	
	port(	
		clk : in std_logic;
		rst : in std_logic;
		data_out_generador_1 : out std_logic_vector(7 downto 0);
		data_out_generador_2 : out std_logic_vector(7 downto 0);
		port_id: in std_logic_vector(7 downto 0); 
		write_strobe: in std_logic;
		data_in:	in std_logic_vector(7 downto 0));
		
	end component;
----------------------
--se�ales salida del periferico
signal data_out_aleatorio_1: std_logic_vector(7 downto 0);
signal data_out_aleatorio_2: std_logic_vector(7 downto 0);
-----------------------------------------------------------------
-- declaraci�n de la ROM de programa
-----------------------------------------------------------------
  component programa_helloworld_int_FLIP
    Port (      address : in std_logic_vector(7 downto 0);
            		   dout : out std_logic_vector(15 downto 0);
                    clk : in std_logic);
    end component;

-----------------------------------------------------------------
-- Signals usadas para conectar el picoblaze y la ROM de programa
-----------------------------------------------------------------
signal     address : std_logic_vector(7 downto 0);
signal instruction : std_logic_vector(15 downto 0);
		
-----------------------------------------------------------------
-- Signals para debugging 
-----------------------------------------------------------------
signal readstrobe: std_logic;
signal writestrobe: std_logic;
signal portid: std_logic_vector(7 downto 0);
signal inport: std_logic_vector(7 downto 0);
signal outport: std_logic_vector(7 downto 0);
signal picoint: std_logic;

type ram_type is array (0 to 63) of std_logic_vector (7 downto 0);
signal RAM : ram_type := (
x"0A", x"0D", x"2A", x"20", x"48", x"45", x"4C", x"4C",
x"4F", x"20", x"49", x"27", x"4D", x"20", x"41", x"4C",
x"49", x"56", x"45", x"21", x"20", x"3A", x"2D", x"44",
x"20", x"2A", x"0A", x"0D", x"2A", x"20", x"50", x"52",
x"45", x"53", x"53", x"20", x"41", x"4E", x"59", x"20",
x"4B", x"45", x"59", x"20", x"54", x"4F", x"20", x"43",
x"4F", x"4E", x"54", x"49", x"4E", x"55", x"45", x"20",
x"2A", x"0A", x"0D", x"00", x"00", x"00", x"00", x"00" );

signal rxbuff_out,RAM_out: std_logic_vector(7 downto 0);

begin

	LED <= reset; 	-- para comprobar la programacion encendemos
						--	un led cada vez que reseteamos

	read_strobe <= readstrobe;
	write_strobe <= writestrobe;
	port_id <= portid;
	in_port <= inport;
	out_port <= outport;
	picoint <= NOT rx;
 	
  processor: picoblaze
    port map(      address => address,
               instruction => instruction,
                   port_id => portid,
              write_strobe => writestrobe,
                  out_port => outport,
               read_strobe => readstrobe,
                   in_port => inport,
                 interrupt => picoint,
                     reset => reset,
                       clk => clk);

  program: programa_helloworld_int_FLIP
    port map(     address => address,
               	     dout => instruction,
                      clk => clk);
							 
							 
							 
	--2 instancia y mapeo del componente
		
		encriptador1:encriptador
		port map(
			data_in => outport,
			port_id => portid,
			write_strobe => writestrobe,
			clk => clk,
			reset => reset,
			data_out => data_out_encriptador);
		
		
		
		
		
		generadorAleatorio1:generadorAleatorio
		port map(
			data_in => outport,
			port_id => portid,
			write_strobe => writestrobe,
			clk => clk,
			rst => reset,
			data_out_generador_1 => data_out_aleatorio_1,
			data_out_generador_2 => data_out_aleatorio_2);
				

	--registra el bit tx del puerto de salida, por si �ste cambia
	txbuff:process(reset, clk)
	begin
		if (reset='1') then
			tx <= '1';
		elsif rising_edge(clk) then
			if (writestrobe = '1' and portid=x"FF") then
				tx <= outport(0);	
			end if;
		end if;
	end process;
	
	--a�ade 7ceros a rx para meterlos al puerto de entrada cuando se lea
	rxbuff:process(reset, clk)
	begin
		if (reset='1') then
			rxbuff_out <= (others=>'1');
		elsif rising_edge(clk) then
			if (readstrobe = '1' and portid =x"FF") then
				rxbuff_out <= rx & "0000000";	
			end if;		 
		end if;
	end process;
	
	-- Memoria RAM (escritura sincrona / lectura asincrona)
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (writestrobe = '1' and portid<x"40") then
				RAM(to_integer(unsigned(portid))) <= outport;
			end if;
		end if;
	end process;
	RAM_out <= RAM(to_integer(unsigned(portid)));
	
-- Multiplexor inport
inport <= RAM_out when (readstrobe = '1' and portid<x"40") else
			 rxbuff_out when (readstrobe = '1' and portid=x"FF") else
			 data_out_encriptador when(readstrobe='1' and portid=x"50") else
			 data_out_aleatorio_1 when(readstrobe='1' and portid=x"61")else
			 data_out_aleatorio_2 when(readstrobe='1' and portid=x"62")else
			 x"00";

end behavioral;