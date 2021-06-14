library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.pkg.all;


package tb_pkg is


type t_bit is ( '_', 'x' );
type t_col is array ( 0 to numCols - 1 ) of t_bit;
type t_hm is array ( numRows - 1 downto 0 ) of t_col;
type t_hms is array ( natural range <> ) of t_hm;

type t_bt is
record
  size: natural;
  word: std_logic_vector( widthBinaryTree - 1 downto 0 );
end record;
type t_bts is array ( natural range <> ) of t_bt;

function nulll return t_col;
function nulll return t_hm;
function nulll return t_bt;

function f_conv ( hitMap: t_hm ) return std_logic_vector;
function f_conv ( std: std_logic_vector ) return t_hm;

function f_bin ( din: std_logic_vector ) return std_logic_vector;

function f_decode ( hitMap: t_hm ) return t_bt;

function f_bts( hitMaps: t_hms ) return t_bts;

function f_size( bts: t_bts ) return natural;


end;



package body tb_pkg is


function nulll return t_col is begin return ( others => '_' ); end function;
function nulll return t_hm is begin return ( others => nulll ); end function;
function nulll return t_bt is begin return ( 0, ( others => '0' ) ); end function;

function f_conv ( hitMap: t_hm ) return std_logic_vector is
  variable std: std_logic_vector( numPixel - 1 downto 0 ) := ( others => '0' );
begin
  for row in numRows - 1 downto 0 loop
    for col in 0 to numCols - 1 loop
      if hitMap( row )( col ) = 'x' then
        -- mapping l/r, t/b, l/r, l/r
        -- col  |  0  1  2  3  4  5  6  7
        ---------------------------------
        -- row1 | 15 14 13 12  7  6  5  4
        -- row0 | 11 10  9  8  3  2  1  0
        std( 4 * ( 2 * ( 1 - col / 4 ) + row + 1 ) - ( col mod 4 ) - 1 ) := '1';
      end if;
    end loop;
  end loop;
  return std;
end function;

function f_conv ( std: std_logic_vector ) return t_hm is
  variable hm: t_hm := nulll;
begin
  for k in 16 - 1 downto 16 - 4 loop
    if std( k ) = '1' then
      hm( 1 )( k - 8 ) := 'x';
    end if;
  end loop;
  for k in 16 - 4 - 1 downto 16 - 4 - 4 loop
    if std( k ) = '1' then
      hm( 0 )( k - 4 ) := 'x';
    end if;
  end loop;
  for k in 16 - 4 - 4 - 1 downto 16 - 4 - 4 - 4 loop
    if std( k ) = '1' then
      hm( 1 )( k - 4 ) := 'x';
    end if;
  end loop;
  for k in 16 - 4 - 4 - 4 - 1 downto 16 - 4 - 4 - 4 - 4 loop
    if std( k ) = '1' then
      hm( 0 )( k ) := 'x';
    end if;
  end loop;
  return hm;
end function;

function f_bin ( din: std_logic_vector ) return std_logic_vector is
  variable dout: std_logic_vector( din'high / 2 downto 0 ) := ( others => '0' );
begin
  for k in din'range loop
    if din( k ) = '1' then
      dout( k / 2 ) := '1';
    end if;
  end loop;
  if dout'length = 2 then
    return dout & din;
  end if;
  return f_bin( dout ) & din;
end function;

function f_decode ( hitMap: t_hm ) return t_bt is
  variable unsubstituted: std_logic_vector( widthBinaryTree - 1 downto 0 ) := f_bin( f_conv( hitMap ) );
  variable p: std_logic_vector( 1 downto 0 );
  variable bt: t_bt := nulll;
begin
  for k in 0 to widthBinaryTree / 2 - 1 loop
    p := unsubstituted( 2 * ( k + 1 ) - 1 downto 2 * k );
    if p( 1 ) = '1' then
      bt.word( bt.size + 1 downto bt.size ) := p;
      bt.size := bt.size + 2;
    elsif p( 0 ) = '1' then
      bt.word( bt.size ) := '0';
      bt.size := bt.size + 1;
    end if;
  end loop;
  return bt;
end function;

function f_bts( hitMaps: t_hms ) return t_bts is
  variable bts: t_bts( hitMaps'range );
begin
  for k in hitMaps'range loop
    bts( k ) := f_decode( hitMaps( k ) );
  end loop;
  return bts;
end function;

function f_size( bts: t_bts ) return natural is
  variable size: natural := 0;
begin
  for k in bts'range loop
    size := size + bts( k ).size;
  end loop;
  return size;
end function;


end;