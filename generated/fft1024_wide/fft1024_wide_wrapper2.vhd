
library ieee;
library work;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.fft_types.all;
use work.fft1024_wide;
use work.fft1024_wide_oreorderer2;

use work.fft1024_wide_ireorderer2;

-- 2 interleaved channels, natural order
-- phase should be 0,1,2,3,4,5,6,...
-- din should be ch0d0, ch1d0, ch2d0, ch3d0, ch0d1, ch1d1, ... (if 4 channels)
-- delay is 5323
entity fft1024_wide_wrapper2 is
	generic(dataBits: integer := 24; twBits: integer := 12);
	port(clk: in std_logic;
		din: in complex;
		phase: in unsigned(11-1 downto 0);
		dout: out complex
		);
end entity;
architecture ar of fft1024_wide_wrapper2 is
	signal core_din, core_dout: complex;
	signal core_phase: unsigned(11-1 downto 0);
	signal oreorderer_phase: unsigned(11-1 downto 0);
begin

	ireorder: entity fft1024_wide_ireorderer2 generic map(dataBits=>dataBits)
		port map(clk=>clk, phase=>phase, din=>din, dout=>core_din);

	core_phase <= phase - 2048 + 1 when rising_edge(clk);

	core: entity fft1024_wide generic map(dataBits=>dataBits, twBits=>twBits)
		port map(clk=>clk, phase=>core_phase(10-1 downto 0), din=>core_din, dout=>core_dout);
	
	oreorderer_phase <= core_phase - 1227 + 1 when rising_edge(clk);
	
	oreorderer: entity fft1024_wide_oreorderer2 generic map(dataBits=>dataBits)
		port map(clk=>clk, phase=>oreorderer_phase, din=>core_dout, dout=>dout);
end ar;
