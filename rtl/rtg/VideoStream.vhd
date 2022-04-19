-- A minimalist FIFO-based video buffer
--
-- Copyright 2020 by Alastair M. Robinson
--
-- 512 words of 16 bit each to fill one M9K
-- On vblank, reset inpointer and start filling.
-- Thereafter, compare inptr with outptr and fill any time they differ.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity VideoStream is
port
(
	clk : in std_logic;
	reset_n : in std_logic;
	enable : in std_logic;
	-- RAM interface
	baseaddr : in std_logic_vector(25 downto 0);
	a : out std_logic_vector(25 downto 0);
	req : out std_logic;
	d : in std_logic_vector(15 downto 0);
	fill : in std_logic;
	-- Display interface
	rdreq : in std_logic;
	q : out std_logic_vector(15 downto 0)
);
end entity;

architecture rtl of VideoStream is

type samplebuffer is array(0 to 511) of std_logic_vector(15 downto 0);
signal samplebuf : samplebuffer;
signal inptr : unsigned(8 downto 0);
signal outptr : unsigned(8 downto 0);
signal watermark : unsigned(5 downto 0);
signal address : unsigned(25 downto 0);
signal address_high : unsigned(25 downto 4);
signal address_low : unsigned(2 downto 0);
signal full : std_logic;

begin

-- The req signal should be high any time the output process
-- is in the same half of the buffer as the fill process.

req<=reset_n and enable and not full;

-- Fill from RAM
a<=std_logic_vector(address_high) & std_logic_vector(address_low) & '0';
inptr<=unsigned(address_high(9 downto 4)&address_low);


process(clk)
begin
	if rising_edge(clk) then
		
		-- Need to drop the req signal a few cycles early when the buffer fills up.
		if watermark(watermark'high downto 1)=inptr(8 downto 4) then
			full <= '1';
		else
			full <= '0';
		end if;

		if reset_n='0' then
			address_high<=unsigned(baseaddr(25 downto 4));
			address_low<="000";
			samplebuf(to_integer(inptr))<=(others=>'0');
		elsif fill='1' then
			samplebuf(to_integer(inptr))<=d;
			address_low<=address_low+1;
			if address_low="111" then -- carry to addr_high
				address_high<=address_high+1;
			end if;
		end if;
	end if;
end process;


-- Output to video

process(clk)
begin
	if rising_edge(clk) then
		if rdreq='1' then
			outptr<=outptr+1;
		end if;
		if reset_n='0' then
			outptr<=unsigned(baseaddr(9 downto 1));
		end if;
		watermark<=outptr(outptr'high downto 3)-2;
		q<=samplebuf(to_integer(outptr));
	end if;
end process;


end architecture;
