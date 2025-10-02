library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.numeric_std.all;

library work;
use work.register_file_package.all;
------------------------------------------------------------------------
-- ENTITY: ram
--
-- Description: This module allows for the creation, storage, and 
--              access of register-based memory a.k.a register file. 
--             
--              generic: G_LENGTH sets length of register.
--              generic: G_DEPTH sets depth of the register file.
--              
--              To use this module:
--              1) Instantiate the module and set the G_LENGTH 
--                 and G_DEPTH generics to determine the size of the 
--                 memory.
--              2) Set [enable] to enable access and storage of
--                 memory.
--              3) Add data to memory by populating [data_in], setting
--                 [wr_enable], setting the [address], and pulsing a 
--                 [clock] cycle. 
--              4) Read from memory by setting the [address], clearing
--                 [wr_enable], and pulsing a [clock] cycle. The output 
--                 will come from [data_out].
--              
--             
--              Here's a visual representation of a register file with
--              G_DEPTH=3 and G_LENGTH=6 and a write of 001001 @ 
--              address 4:
--             
--                          register length
--                            5 4 3 2 1 0
--                          +-------------+
--               a   d    0 |             | 
--               d   e    1 |             |
--               d   p    2 |             |
--               r   t    3 |             |
--               e   h    4 | 0 0 1 0 0 1 |  
--               s        5 |             |
--               s        6 |             |
--                        7 |             |
--                          +-------------+
--             
------------------------------------------------------------------------
entity ram is
  generic( 
    G_LENGTH      : integer := 8;
    G_DEPTH       : integer := 4);
  port(
    reset         : in  std_logic;
    data_in       : in  std_logic_vector(G_LENGTH-1 downto 0);
    clock         : in  std_logic;
    wr_enable     : in  std_logic;                                 -- write on '1', read on '0' or other
    enable        : in  std_logic;                                 -- enable memory access
    address       : in  std_logic_vector(G_DEPTH-1 downto 0);
    data_out      : out std_logic_vector(G_LENGTH-1 downto 0));
end entity ram;

architecture behavior of ram is 
  -------------------------------------
  -- COMPONENT: register_file
  -------------------------------------
  component register_file is
    generic( 
      G_LENGTH : natural := G_LENGTH;
      G_DEPTH  : natural := G_DEPTH);
    port(
      reset    : in  std_logic;
      enable   : in  std_logic;
      read     : in  t_read_write_interface(address(G_DEPTH-1 downto 0));
      write    : in  t_read_write_interface(address(G_DEPTH-1 downto 0));
      data_in  : in  std_logic_vector(G_LENGTH-1 downto 0);
      data_out : out std_logic_vector(G_LENGTH-1 downto 0));
  end component register_file;

  signal s_read  : t_read_write_interface(address(G_DEPTH-1 downto 0));
  signal s_write : t_read_write_interface(address(G_DEPTH-1 downto 0));
begin

  s_read  <= (clock, not wr_enable, address);
  s_write <= (clock, wr_enable, address);

  -------------------------------------
  -- COMPONENT Instantiation: inst_register_file
  -------------------------------------
  inst_register_file : register_file port map(
    reset    => reset   ,
    enable   => enable  ,
    read     => s_read  ,
    write    => s_write ,
    data_in  => data_in ,
    data_out => data_out);

end architecture behavior;
