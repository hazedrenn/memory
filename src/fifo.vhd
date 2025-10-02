library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.register_file_package.all;

entity fifo is
  generic( 
    G_LENGTH      : integer := 8;
    G_DEPTH       : integer := 4);
  port(
    reset         : in std_logic;
    data_in       : in std_logic_vector(G_LENGTH-1 downto 0);
    clock         : in std_logic;
    write_enable  : in std_logic;
    read_enable   : in std_logic;
    enable        : in std_logic;
    data_out      : out std_logic_vector(G_LENGTH-1 downto 0);
    full          : out std_logic;
    empty         : out std_logic);
end entity fifo;

architecture behavior of fifo is
  -------------------------------------
  -- COMPONENTS
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

  -------------------------------------
  -- SIGNALS
  -------------------------------------
  signal read_pointer  : std_logic_vector(G_DEPTH-1 downto 0);
  signal write_pointer : std_logic_vector(G_DEPTH-1 downto 0);
  signal count         : integer;
begin
  -------------------------------------
  -- COMPONENT Instantiation: inst_register_file
  -------------------------------------
  inst_register_file : register_file port map(
    reset    => reset,
    enable   => enable,
    read     => (clock, read_enable, read_pointer),
    write    => (clock, write_enable, write_pointer),
    data_in  => data_in,
    data_out => data_out);

  -------------------------------------
  -- PROCESS: read pointer process
  -------------------------------------
  read_ptr_proc: process(clock, reset)
  begin
    if reset then
      read_pointer <= (others => '0');
    elsif rising_edge(clock) then
      if read_enable and enable and empty then
        read_pointer <= read_pointer + 1;
      end if;
    end if;
  end process;

  -------------------------------------
  -- PROCESS: write pointer process
  -------------------------------------
  write_ptr_proc: process(clock, reset)
  begin
    if reset then
      write_pointer <= (others => '0');
    elsif rising_edge(clock) then
      if write_enable and enable and full then
        write_pointer <= write_pointer + 1;
      end if;
    end if;
  end process;

  -------------------------------------
  -- PROCESS: count process
  -------------------------------------
  count_proc: process(clock, reset)
  begin
    if reset then
      count <= 0;
    elsif rising_edge(clock) then
      if enable then
        if not read_enable and write_enable and not full then
          count <= count + 1;
        elsif read_enable and not write_enable and not empty then
          count <= count - 1;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------
  -- FIFO flags
  -------------------------------------
  empty <= '1' when count = 0          else '0';
  full  <= '1' when count = 2**G_DEPTH else '0';
end architecture behavior;
