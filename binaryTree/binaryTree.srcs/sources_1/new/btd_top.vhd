library ieee;
use ieee.std_logic_1164.all;
use work.pkg.all;


entity btd_top is
port (
  clk: in std_logic;
  btd_din: in t_data;
  btd_dout: out t_hitMap
);
end;


architecture rtl of btd_top is


signal aligner_din: t_data := nulll;
signal aligner_dout: t_binaryTree := nulll;
component btd_aligner
port (
  clk: in std_logic;
  aligner_din: in t_data;
  aligner_dout: out t_binaryTree
);
end component;

signal decoder_din: t_binaryTree := nulll;
signal decoder_dout: t_hitMap := nulll;
component btd_decoder
port (
  clk: in std_logic;
  decoder_din: in t_binaryTree;
  decoder_dout: out t_hitMap
);
end component;


begin


aligner_din <= btd_din;

decoder_din <= aligner_dout;

btd_dout <= decoder_dout;

aligner: btd_aligner port map ( clk, aligner_din, aligner_dout );

decoder: btd_decoder port map ( clk, decoder_din, decoder_dout );


end;