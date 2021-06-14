library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.pkg.all;
use work.tb_pkg.all;


entity tb is
end;


architecture trl of tb is

constant numHitMaps: natural := 9;
constant hitMaps: t_hms( 0 to numHitMaps - 1 ) := (
  ( ( "________" ),
    ( "______x_" )
  ),
  ( ( "__xx____" ),
    ( "___xx___" )
  ),
  ( ( "________" ),
    ( "_______x" )
  ),
  ( ( "xxxxxxxx" ),
    ( "xxxxxxxx" )
  ),
  ( ( "________" ),
    ( "______x_" )
  ),
  ( ( "__xx____" ),
    ( "___xx___" )
  ),
  ( ( "________" ),
    ( "______x_" )
  ),
  ( ( "__xx____" ),
    ( "___xx___" )
  ),
  ( ( "________" ),
    ( "______x_" )
  ),
--  ( ( "__xx____" ),
--    ( "___xx___" )
--  ),
--  ( ( "________" ),
--    ( "______x_" )
--  ),
--  ( ( "__xx____" ),
--    ( "___xx___" )
--  ),
--  ( ( "________" ),
--    ( "______x_" )
--  ),
--  ( ( "__xx____" ),
--    ( "___xx___" )
--  ),
--  ( ( "________" ),
--    ( "______x_" )
--  ),
--  ( ( "__xx____" ),
--    ( "___xx___" )
--  ),
--  ( ( "________" ),
--    ( "______x_" )
--  ),
--  ( ( "__xx____" ),
--    ( "___xx___" )
--  ),
  others => nulll
);

constant bts: t_bts( hitMaps'range ) := f_bts( hitMaps );
constant size: natural := f_size( bts );
constant numDatas: natural := integer( ceil( real( size ) / real( widthData ) ) );
type t_datas is array ( 0 to numDatas - 1 ) of std_logic_vector( widthData - 1 downto 0 );

function f_init return t_datas is
  variable std: std_logic_vector( numDatas * widthData - 1 downto 0 ) := ( others => '0' );
  variable bt: t_bt;
  variable pos: natural := numDatas * widthData;
  variable datas: t_datas := ( others => ( others => '0' ) );
begin
  for k in bts'range loop
    bt := bts( k );
    std( pos - 1 downto pos - bt.size ) := bt.word( bt.size - 1 downto 0 );
    pos := pos - bt.size;
  end loop;
  for k in datas'range loop
    datas( k ) := std( ( numDatas - k ) * widthData - 1 downto ( numDatas - k - 1 ) * widthData );
  end loop;
  return datas;
end function;

constant datas: t_datas := f_init;

constant latency: natural := 5;
signal k: natural := 0;
signal j: integer := -latency;
signal hitMap, test: t_hm := nulll;
signal hm: std_logic_vector( numPixel - 1 downto 0 ) := ( others => '0' );
signal bt: t_bt := nulll;

signal clk: std_logic := '0';
signal btd_din: t_data := nulll;
signal btd_dout: t_hitMap := nulll;
component btd_top
port (
  clk: in std_logic;
  btd_din: in t_data;
  btd_dout: out t_hitMap
);
end component;


begin


clk <= not clk after 0.5 ns;


process ( clk ) is
begin
if rising_edge( clk ) then

  btd_din <= nulll;
  k <= k + 1;
  if k = numHitMaps then
    k <= 0;
  end if;
  if k = 0 then
    btd_din.reset <= '1';
  elsif k < numDatas + 1 then
    btd_din.valid <= '1';
    btd_din.data <= datas( k - 1 );
  elsif k < numHitMaps + 1 then
    btd_din.valid <= '1';
  end if;
  hitMap <= nulll;
  bt <= nulll;
  hm <= ( others => '0' );
  j <= j + 1;
  if j = numHitMaps then
    j <= 0;
  end if;
  if j > 0 then
    hitMap <= hitMaps( j - 1 );
    bt <= bts( j - 1 );
    hm <= f_conv( hitMaps( j - 1 ) );
  end if;

end if;
end process;

c: btd_top port map ( clk, btd_din, btd_dout );

end;