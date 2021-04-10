-- Bridge to interface 32-bit CPU to 16-bit host CPU  bus

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity EightThirtyTwo_Bridge is
   generic (
      debug : boolean := false
   );
   port(
      clk             : in std_logic;
      nReset            : in std_logic;         --low active
      addr              : out std_logic_vector(31 downto 2);
      q                 : out std_logic_vector(31 downto 0);
      sel               : out std_logic_vector(3 downto 0);
      wr                : out std_logic;

      ram_req           : out std_logic;
      ram_ack           : in std_logic;
      ram_d             : in std_logic_vector(15 downto 0);

      hw_req            : out std_logic;
      hw_ack            : in std_logic;
      hw_d              : in std_logic_vector(15 downto 0);
      interrupt         : in std_logic
   );
end EightThirtyTwo_Bridge;

architecture rtl of EightThirtyTwo_Bridge is

-- attribute MARK_DEBUG : string;
-- attribute MARK_DEBUG of addr : signal is "TRUE";
-- attribute MARK_DEBUG of q : signal is "TRUE";
-- attribute MARK_DEBUG of sel : signal is "TRUE";
-- attribute MARK_DEBUG of wr : signal is "TRUE";
-- attribute MARK_DEBUG of ram_req : signal is "TRUE";
-- attribute MARK_DEBUG of ram_ack : signal is "TRUE";
-- attribute MARK_DEBUG of ram_d : signal is "TRUE";
-- attribute MARK_DEBUG of hw_req : signal is "TRUE";
-- attribute MARK_DEBUG of hw_ack : signal is "TRUE";
-- attribute MARK_DEBUG of interrupt : signal is "TRUE";

type bridgestates is (waiting,ram,hw,rom);
signal state : bridgestates;

signal cpu_req : std_logic;
signal cpu_ack : std_logic;
signal cpu_d   : std_logic_vector(31 downto 0);
signal cpu_q   : std_logic_vector(31 downto 0);
signal cpu_addr   : std_logic_vector(31 downto 2);
signal cpu_wr  : std_logic; 
signal cpu_sel : std_logic_vector(3 downto 0);

signal cache_req : std_logic;
signal cache_ack : std_logic;
signal cache_q : std_logic_vector(31 downto 0);

signal debug_d : std_logic_vector(31 downto 0);
signal debug_q : std_logic_vector(31 downto 0);
signal debug_req : std_logic;
signal debug_ack : std_logic;
signal debug_wr : std_logic;

signal rom_d : std_logic_vector(31 downto 0);
signal rom_wr : std_logic;
signal rom_select : std_logic;
signal hw_select : std_logic;

attribute MARK_DEBUG : string;
attribute MARK_DEBUG of cpu_addr : signal is "TRUE";
attribute MARK_DEBUG of cpu_q : signal is "TRUE";
attribute MARK_DEBUG of cpu_sel : signal is "TRUE";
attribute MARK_DEBUG of cpu_req : signal is "TRUE";
attribute MARK_DEBUG of rom_select : signal is "TRUE";
attribute MARK_DEBUG of hw_select : signal is "TRUE";
attribute MARK_DEBUG of hw_ack : signal is "TRUE";
attribute MARK_DEBUG of ram_ack : signal is "TRUE";

component hostcache
port
(
   sysclk : in std_logic;
   reset_n : in std_logic;
   a : in std_logic_vector(24 downto 2);
   q : out std_logic_vector(31 downto 0);
   req : in std_logic;
   wr : in std_logic;
   ack : out std_logic;
   sdram_d : in std_logic_vector(15 downto 0);
   sdram_req : out std_logic;
   sdram_ack : in std_logic
);
end component;

begin


my832 : entity work.eightthirtytwo_cpu
generic map (
   littleendian => false,
   interrupts => true,
   dualthread => false,
   forwarding => false,
   prefetch => false,
   debug => debug
)
port map(
   clk => clk, 
   reset_n => nReset,
   addr => cpu_addr,
   d => cpu_d,
   q => cpu_q,
   wr => cpu_wr,
   req => cpu_req,
   ack => cpu_ack,
   bytesel => cpu_sel,
   interrupt => interrupt,
   debug_d => debug_d,
   debug_q => debug_q,
   debug_req => debug_req,
   debug_ack => debug_ack,
   debug_wr => debug_wr
);

gendebugbridge:
if debug=true generate
debugbridge : entity work.debug_bridge_jtag
port map(
   clk => clk,
   reset_n => nReset,
   d => debug_q,
   q => debug_d,
   req => debug_req,
   ack => debug_ack,
   wr => debug_wr
);
end generate;

bootrom: entity work.OSDBoot_832_ROM
   generic map
   (
      ADDR_WIDTH => 12
   )
   PORT MAP 
   (
      addr => cpu_addr(12 downto 2),
      clk   => clk,
      d  => cpu_q,
      we => rom_wr,
      bytesel => cpu_sel,
      q     => rom_d
   );

rom_select <= '1' when cpu_addr(23 downto 13)=X"00"&"000" ELSE '0';

hw_select <= cpu_addr(23);

process(clk,nReset)
begin

   if nReset='0' then
      state<=waiting;
      hw_req<='0';
      wr<='0';
   elsif rising_edge(clk) then

      cpu_ack<='0';
      rom_wr<='0';

      addr<=cpu_addr;
      q<=cpu_q;
      sel<=cpu_sel;
      wr<=cpu_wr;

      case state is
         when waiting =>
            if cpu_ack='0' and cpu_req='1' then
               if rom_select='1' then
                  rom_wr<=cpu_wr;
                  state<=rom;
               elsif hw_select='1' then
                  hw_req<='1';
                  state<=hw;
               else
                  cache_req<='1';
                  state<=ram;
               end if;
            end if;

         when rom =>
            cpu_d<=rom_d;
            wr<='0';
            rom_wr<='0';
            cpu_ack<='1';
            state<=waiting;
            
         when ram =>
            if cache_ack='1' then
               cache_req<='0';
               cpu_d<=cache_q;
               wr<='0';
               cpu_ack<='1';
               state<=waiting;
            end if;

         when hw =>
            if hw_ack='1' then
               cpu_d(31 downto 16)<=(others=>'0');
               cpu_d(15 downto 0)<=hw_d;
               wr<='0';
               hw_req<='0';
               cpu_ack<='1';
               state<=waiting;
            end if;

         when others =>
            null;
      end case;
   end if;
end process;

hostcache_inst : component hostcache
port map
(
   sysclk => clk,
   reset_n => nReset,
   a => cpu_addr(24 downto 2),
   q => cache_q,
   req => cache_req,
   wr => cpu_wr,
   ack => cache_ack,
   sdram_d => ram_d,
   sdram_req => ram_req,
   sdram_ack => ram_ack
);

end architecture;
