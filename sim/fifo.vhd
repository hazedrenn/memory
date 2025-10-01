library ieee;
use ieee.std_logic_1164.all;
use ieee.std_unsigned.all;

entity fifo is
  generic( 
    DATA_LENGTH : integer := 8;
    DEPTH : integer := 4);
  port(
    data_in : in std_logic_vector(DATA_LENGTH-1 downto 0);
    clock : in std_logic;
    wr_enable: in std_logic; -- write on '1', read on '0'
    enable : in std_logic; -- enable memory access
    data_out : out std_logic_vector(DATA_LENGTH-1 downto 0));
end entity fifo;

architecture behavior of fifo is
  component ram is
    generic( 
      DATA_LENGTH : integer := DATA_LENGTH;
      DEPTH : integer := DEPTH);
    port(
      data_in : in std_logic_vector(DATA_LENGTH-1 downto 0);
      clock : in std_logic;
      wr_enable: in std_logic; -- write on '1', read on '0'
      enable : in std_logic; -- enable memory access
      address : in std_logic_vector(2**DEPTH-1 downto 0);
      data_out : out std_logic_vector(DATA_LENGTH-1 downto 0));
  end component ram;

  signal read_ptr : std_logic_vector(2**DEPTH-1 downto 0);
  signal write_ptr : std_logic_vector(2**DEPTH-1 downto 0);
begin
  t_ram: ram generic map (
    DATA_LENGTH => DATA_LENGTH,
    DEPTH => DEPTH
  ) port map (
    data_in => data_in,
    clock => clock,
    wr_enable => wr_enable,
    address => address,
    data_out => data_out);

  process(clock)
  begin
    if rising_edge(clock) then
      read_ptr <= read_ptr + 1;
    end if;
  end process;
end architecture behavior;
