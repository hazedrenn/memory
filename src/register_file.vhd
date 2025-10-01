library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------------------
-- ENTITY: register_file
--
-- Description: This module allows for the creation, storage, and 
--              access of register-based memory a.k.a. register file. 
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
--              3) Add data to memory by populating [write_data], setting
--                 [write_enable], setting the [write_address], and pulsing a 
--                 [write_clock] cycle. 
--              4) Read from memory by setting the [read_address], setting
--                 [read_enable], and pulsing a [read_clock] cycle. The output 
--                 will come from [read_data].
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

entity register_file is
  generic( 
    G_LENGTH      : natural := 8;
    G_DEPTH       : natural := 4);
  port(
    reset         : in  std_logic;
    enable        : in  std_logic;

    -- Read Interface
    read_clock    : in  std_logic;
    read_data     : out std_logic_vector(G_LENGTH-1 downto 0);
    read_address  : in  std_logic_vector(G_DEPTH-1 downto 0);
    read_enable   : in  std_logic;
    
    -- Write Interface
    write_clock   : in  std_logic;
    write_data    : in  std_logic_vector(G_LENGTH-1 downto 0);
    write_address : in  std_logic_vector(G_DEPTH-1 downto 0);
    write_enable  : in  std_logic);
end entity register_file;

architecture behavior of register_file is
  subtype depth_range     is natural range 0          to     2**G_DEPTH-1;
  subtype length_range    is natural range G_LENGTH-1 downto 0;
  subtype t_register      is std_logic_vector(length_range);
  type    t_register_file is array (depth_range) of t_register;
  signal  s_register_file : t_register_file;
begin
  --------------------------
  -- PROCESS: write proc
  --
  -- Writes [write_data] into memory @ [write_address].
  --------------------------
  write_proc: process(write_clock)
    variable v_write_address : natural;
  begin
    if rising_edge(write_clock) then
      if write_enable and enable then
        v_write_address := to_integer(unsigned(write_address));
        s_register_file(v_write_address) <= write_data;  
      end if;
    end if;
  end process write_proc;

  --------------------------
  -- PROCESS: read proc
  --
  -- Reads [read_data] from memory @ [read_address].
  --------------------------
  read_proc: process(read_clock)
    variable v_read_address : natural;
  begin
    if rising_edge(read_clock) then
      if read_enable and enable then
        v_read_address := to_integer(unsigned(read_address));
        read_data <= s_register_file(v_read_address);
      end if;
    end if;
  end process read_proc;
end architecture behavior;
