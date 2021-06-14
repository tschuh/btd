library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


package pkg is

constant widthAddr: natural := 9;  -- power of 2 of fifo depth
constant widthData: natural := 32; -- width of input data stream

constant powRows: natural := 1; -- hitMap power of 2 of number of rows
constant powCols: natural := 3; -- hitMap power of 2 of number of columns

constant powPixel: natural := powRows + powCols; --  4 
constant numRows : natural := 2 ** powRows;      --  2
constant numCols : natural := 2 ** powCols;      --  8
constant numPixel: natural := 2 ** powPixel;     -- 16

constant widthBinaryTree: natural := 2 ** ( powPixel + 1 ) - 2 ** 1;               -- 30
constant widthPosition  : natural := integer( ceil( log2( real( widthData ) ) ) ); --  5

subtype t_size  is natural range powPixel to 2 ** ( powPixel + 1 ) - 2; -- 4 to 30

type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthData - 1 downto 0 );

type t_data is
record
  reset: std_logic;
  valid: std_logic;
  data : std_logic_vector( widthData - 1 downto 0 );
end record;
function nulll return t_data;

type t_binaryTree is
record
  reset: std_logic;
  valid: std_logic;
  data: std_logic_vector( widthBinaryTree - 1 downto 0 );
end record;
function nulll return t_binaryTree;

type t_hitMap is
record
  reset: std_logic;
  valid: std_logic;
  data : std_logic_vector( numPixel - 1 downto 0 );
end record;
function nulll return t_hitMap;

function uint( std: std_logic_vector ) return natural;
function stdu( val, width: natural ) return std_logic_vector;
function incr( std: std_logic_vector ) return std_logic_vector;
function slu( std: std_logic_vector; n: natural ) return std_logic_vector;

function f_s3( std: std_logic_vector; iter, pos: natural ) return t_size;
function f_s2( std: std_logic_vector; nodes, iter, pos: natural ) return t_size;
function f_s1( std: std_logic_vector; nodes, iter, pos: natural ) return t_size;
function f_s0( std: std_logic_vector; nodes, iter, pos: natural ) return t_size;
function f_size( std: std_logic_vector ) return t_size;

function f_d ( sub, unsub: std_logic_vector ) return std_logic_vector;
function f_decode ( substituted: std_logic_vector ) return std_logic_vector;


end;



package body pkg is


function nulll return t_data is begin return ( '0', '0', ( others => '0' ) ); end function;
function nulll return t_binaryTree is begin return ( '0', '0', ( others => '0' ) ); end function;
function nulll return t_hitMap is begin return ( '0', '0', ( others => '0' ) ); end function;

function uint( std: std_logic_vector ) return natural is
begin
  return to_integer( unsigned( std ) );
end function;

function stdu( val, width: natural ) return std_logic_vector is
begin
  return std_logic_vector( to_unsigned( val, width ) );
end function;

function incr( std: std_logic_vector ) return std_logic_vector is
begin
  return std_logic_vector( unsigned( std ) + 1 );
end function;

function slu( std: std_logic_vector; n: natural ) return std_logic_vector is
begin
  return std_logic_vector( shift_left( unsigned( std ), n ) );
end function;

function f_s3( std: std_logic_vector; iter, pos: natural ) return t_size is
begin
  if iter = 0 then
    return widthData - pos;
  end if;
  if std( pos - 1 ) = '0' then
    return f_s3( std, iter - 1, pos - 1 );
  end if;
  return f_s3( std, iter - 1, pos - 2 );
end function;

function f_s2( std: std_logic_vector; nodes, iter, pos: natural ) return t_size is
begin
  if iter = 0 then
    return f_s3( std, nodes, pos );
  end if;
  if std( pos - 1 ) = '0' then
    return f_s2( std, nodes + 1, iter - 1, pos - 1 );
  end if;
  if std( pos - 2 ) = '0' then
    return f_s2( std, nodes + 1, iter - 1, pos - 2 );
  end if;
  return f_s2( std, nodes + 2, iter - 1, pos - 2 );
end function;

function f_s1( std: std_logic_vector; nodes, iter, pos: natural ) return t_size is
begin
  if iter = 0 then
    return f_s2( std, 0, nodes, pos );
  end if;
  if std( pos - 1 ) = '0' then
    return f_s1( std, nodes + 1, iter - 1, pos - 1 );
  end if;
  if std( pos - 2 ) = '0' then
    return f_s1( std, nodes + 1, iter - 1, pos - 2 );
  end if;
  return f_s1( std, nodes + 2, iter - 1, pos - 2 );
end function;

function f_s0( std: std_logic_vector; nodes, iter, pos: natural ) return t_size is
begin
  if iter = 0 then
    return f_s1( std, 0, nodes, pos );
  end if;
  if std( pos - 1 ) = '0' then
    return f_s0( std, nodes + 1, iter - 1, pos - 1 );
  end if;
  if std( pos - 2 ) = '0' then
    return f_s0( std, nodes + 1, iter - 1, pos - 2 );
  end if;
  return f_s0( std, nodes + 2, iter - 1, pos - 2 );
end function;

function f_size( std: std_logic_vector ) return t_size is
begin
  return f_s0( std, 0, 1, widthData );
end function;

function f_d ( sub, unsub: std_logic_vector ) return std_logic_vector is
begin
  if unsub'length = widthBinaryTree + 1 then
    return unsub( widthBinaryTree + 1 - numPixel to widthBinaryTree );
  end if;
  if unsub( unsub'length / 2 ) = '0' then
    return f_d ( sub, unsub & "00" );
  end if;
  if sub( sub'high ) = '0' then
    return f_d ( sub( sub'high - 1 downto 0 ), unsub & "01" );
  end if;
  if sub( sub'high - 1 ) = '0' then
    return f_d ( sub( sub'high - 2 downto 0 ), unsub & "10" );
  end if;
  return f_d ( sub( sub'high - 2 downto 0 ), unsub & "11" );
end function;

function f_decode ( substituted: std_logic_vector ) return std_logic_vector is
begin
  return f_d( substituted, "1" );
end function;


end;