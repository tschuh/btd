library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg.all;


entity btd_aligner is
port (
  clk: in std_logic;
  aligner_din: in t_data;
  aligner_dout: out t_binaryTree
);
end;


architecture rtl of btd_aligner is


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

signal binaryTree: std_logic_vector( widthData - 1 downto 0 ) := ( others => '0' );

-- step 5

signal pos: std_logic_vector( widthPosition - 1 downto 0 ) := ( others => '0' );
signal size: t_size := powPixel;
signal stack, data: std_logic_vector( 2 * widthData - 1 downto 0 ) := ( others => '0' );


begin


-- step 4
aligner_dout <= ( reset( 4 ), valid( 4 ), binaryTree( widthData - 1 downto widthData - widthBinaryTree ) );

-- step 5
size <= f_size( binaryTree );
stack <= slu( reg & read, uint( pos ) );
data <= slu( binaryTree & stack( 2 * widthData - 1 downto widthData ), size );


process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  reset <= reset( reset'high - 1 downto reset'low ) & aligner_din.reset;
  valid <= valid( valid'high - 1 downto valid'low ) & aligner_din.valid;
  ram( uint( waddr ) ) <= aligner_din.data;
  if aligner_din.valid = '1' then
    waddr <= incr( waddr );
  end if;

  if aligner_din.reset = '1' then
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

  binaryTree <= reg;

  -- step 5

  if valid( 4 ) = '1' then
    pos <= stdu( uint( pos ) + size, widthPosition );
    binaryTree <= data( 2 * widthData - 1 downto widthData );
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