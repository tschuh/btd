library ieee;
use ieee.std_logic_1164.all;
use work.pkg.all;


entity top is
port (
  clk: in std_logic;
  din: in t_data;
  dout: out t_hitMap
);
end;


architecture rtl of top is


signal btd_din: t_data := nulll;
signal btd_dout: t_hitMap := nulll;
component btd_top
port (
  clk: in std_logic;
  btd_din: in t_data;
  btd_dout: out t_hitMap
);
end component;

-- step 0

signal reg: t_data := nulll;


begin


btd_din <= reg;

dout <= btd_dout;


c: btd_top port map ( clk, btd_din, btd_dout );


process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 0

  reg <= din;

end if;
end process;


end;