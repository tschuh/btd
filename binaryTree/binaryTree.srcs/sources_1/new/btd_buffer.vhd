library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg.all;


entity btd_alginer is
port (
  clk: in std_logic;
  alginer_din: in t_data;
  alginer_dout: out t_data
);
end;


architecture rtl of btd_alginer is


attribute ram_style: string;

-- step 1

signal reset, valid: std_logic_vector( 4 downto 1 ) := ( others => '0' );
signal waddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal ram: t_ram := ( others => ( others => '0' ) );
attribute ram_style of ram: signal is "block";

-- step 2

signal read: std_logic_vector( widthData - 1 downto 0 ) := ( others => '0' );
signal raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );

-- step 3

signal reg: std_logic_vector( widthData - 1 downto 0 ) := ( others => '0' );

-- step 4

signal dout: std_logic_vector( widthData - 1 downto 0 ) := ( others => '0' );

-- step 5

signal pos: std_logic_vector( widthPosition - 1 downto 0 ) := ( others => '0' );
signal size: t_size := powPixel;
signal stack, data: std_logic_vector( 2 * widthData - 1 downto 0 ) := ( others => '0' );


begin


-- step 4
alginer_dout <= ( reset( 4 ), valid( 4 ), dout );

-- step 5
size <= f_size( dout );
stack <= std_logic_vector( shift_left( unsigned( reg ) & unsigned( read ), uint( pos ) ) );
data <= std_logic_vector( shift_left( unsigned( dout ) & unsigned( stack( 2 * widthData - 1 downto widthData ) ), size ) );


process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  reset <= reset( reset'high - 1 downto reset'low ) & alginer_din.reset;
  valid <= valid( valid'high - 1 downto valid'low ) & alginer_din.valid;
  ram( uint( waddr ) ) <= alginer_din.data;
  if alginer_din.valid = '1' then
    waddr <= incr( waddr );
  end if;

  if alginer_din.reset = '1' then
    waddr <= ( others => '0' );
  end if;

  -- step 2

  read <= ram( uint( raddr ) );
  if valid( 1 ) = '1' then
    raddr <= incr( raddr );
  end if;

  -- step 3

  reg <= read;

  -- step 4

  dout <= reg;

  -- step 5

  if valid( 4 ) = '1' then
    pos <= stdu( uint( pos ) + size, widthPosition );
    dout <= data( 2 * widthData - 1 downto widthData );
    if uint( pos ) + size < widthData then
      reg <= reg;
      raddr <= raddr;
    end if;
  end if;

  if reset( 4 ) = '1' then
    pos <= ( others => '0' );
    raddr <= raddr;
  end if;
  if reset( 3 ) = '1' or reset( 2 ) = '1' then
    reg <= read;
    raddr <= incr( raddr );
  end if;
  if reset( 1 ) = '1' then
    raddr <= ( others => '0' );
  end if;

end if;
end process;


end;