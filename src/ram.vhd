library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.numeric_std.all;
---------------------------------------------------------
-- ENTITY: ram
--
-- This module allows for the storage and access of data.
-- Set DATA_LENGTH for the length of each data cell. Set
-- DEPTH for the depth of the memory.
---------------------------------------------------------
entity ram is
  generic( 
    DATA_LENGTH : integer := 8;
    DEPTH : integer := 4);
  port(
    data_in : in std_logic_vector(DATA_LENGTH-1 downto 0);
    clock : in std_logic;
    wr_enable: in std_logic; -- write on '1', read on '0'
    enable : in std_logic; -- enable memory access
    address : in std_logic_vector(2**DEPTH-1 downto 0);
    data_out : out std_logic_vector(DATA_LENGTH-1 downto 0));
end entity ram;

architecture behavior of ram is 
  subtype data is std_logic_vector(DATA_LENGTH-1 downto 0);
  type t_memory is array (0 to 2**address'length-1) of data;
  signal memory : t_memory;
begin
  --------------------------
  -- PROCESS: write proc
  --------------------------
  write_proc: process(clock)
  begin
    if rising_edge(clock) then
      if wr_enable and enable then
        memory(to_integer(unsigned(address))) <= data_in;  
      end if;
    end if;
  end process write_proc;

  --------------------------
  -- PROCESS: read proc
  --------------------------
  read_proc: process(clock)
  begin
    if rising_edge(clock) then
      if not wr_enable and enable then
        data_out <= memory(to_integer(unsigned(address)));  
      end if;
    end if;
  end process read_proc;

end architecture behavior;
