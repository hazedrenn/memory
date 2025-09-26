library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.numeric_std.all;

entity rom is
  generic( 
    DATA_LENGTH : integer := 8;
    ADDRESS_LENGTH : integer := 4);
  port(
    data_in : in std_logic_vector(DATA_LENGTH-1 downto 0);
    clock : in std_logic;
    write_enable : in std_logic;
    read_enable : in std_logic;
    address : in std_logic_vector(2**ADDRESS_LENGTH-1 downto 0);
    data_out : out std_logic_vector(DATA_LENGTH-1 downto 0));
end entity rom;

architecture behavior of rom is 
  type t_memory is array (0 to 2**address'length-1) of std_logic_vector(DATA_LENGTH-1 downto 0);
  signal memory : t_memory;
begin
  write_proc: process(clock)
  begin
    if rising_edge(clock) then
      if write_enable then
        memory(to_integer(unsigned(address))) <= data_in;  
      end if;
    end if;
  end process write_proc;

  read_proc: process(clock)
  begin
    if rising_edge(clock) then
      if read_enable then
        data_out <= memory(to_integer(unsigned(address)));  
      end if;
    end if;
  end process read_proc;

end architecture behavior;
