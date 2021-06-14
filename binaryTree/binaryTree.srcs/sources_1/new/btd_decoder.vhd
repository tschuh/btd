library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg.all;


entity btd_decoder is
port (
  clk: in std_logic;
  decoder_din: in t_binaryTree;
  decoder_dout: out t_hitMap
);
end;


architecture rtl of btd_decoder is


-- step 5

signal dout: t_hitMap := nulll;


begin


-- step 5
decoder_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 5

  dout.reset <= decoder_din.reset;
  dout.valid <= decoder_din.valid;
  dout.data <= ( others => '0' );
  if decoder_din.valid = '1' then
    dout.data <= f_decode( decoder_din.data );
  end if;

end if;
end process;


end;