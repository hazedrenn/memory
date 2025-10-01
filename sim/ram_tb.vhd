library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.my_package.all;

entity ram_tb is
  generic(
    G_LENGTH : integer := 8;
    G_DEPTH  : integer := 4);
end entity ram_tb;

architecture behavior of ram_tb is
  -------------------------------------
  -- PROCEDURE: print_result
  --
  -- Displays address
  -- If write enabled, displays data_in
  -- If read enabled, displays data_out
  -------------------------------------
  procedure print_result(
    data_in   : in std_logic_vector(G_LENGTH-1 downto 0);
    wr_enable : in std_logic;
    address   : in std_logic_vector(G_DEPTH-1 downto 0);
    data_out  : in std_logic_vector(G_LENGTH-1 downto 0) ) is
  begin
    if wr_enable then
      print("WRITE data_in: 0x" & to_hstring(data_in) &
            " @ address: 0x" & to_hstring(address) );
    else
      print("READ data_out: 0x" & to_hstring(data_out) &
            " @ address: 0x" & to_hstring(address) );
    end if;
  end procedure print_result;

  -------------------------------------
  -- COMPONENT: ram
  -------------------------------------
  component ram is
    generic( 
      G_LENGTH    : integer := G_LENGTH;
      G_DEPTH     : integer := G_DEPTH);
    port(
      data_in     : in  std_logic_vector(G_LENGTH-1 downto 0);
      clock       : in  std_logic;
      wr_enable   : in  std_logic; -- write on '1', read on '0'
      enable      : in  std_logic;
      address     : in  std_logic_vector(G_DEPTH-1 downto 0);
      data_out    : out std_logic_vector(G_LENGTH-1 downto 0));
  end component ram;

  -------------------------------------
  -- CONSTANTS
  -------------------------------------
  constant PERIOD     : time := 1 ns;

  -------------------------------------
  -- SIGNALS
  -------------------------------------
  signal s_data_in    : std_logic_vector(G_LENGTH-1 downto 0);
  signal s_clock      : std_logic;
  signal s_wr_enable  : std_logic;
  signal s_enable     : std_logic;
  signal s_address    : std_logic_vector(G_DEPTH-1 downto 0);
  signal s_data_out   : std_logic_vector(G_LENGTH-1 downto 0);
begin
  -------------------------------------
  -- COMPONENT Instantiation: t_ram
  -------------------------------------
  t_ram : ram port map(
    data_in   => s_data_in,
    clock     => s_clock,
    wr_enable => s_wr_enable,
    enable    => s_enable,
    address   => s_address,
    data_out  => s_data_out);

  -------------------------------------
  -- PROCESS: Clock generator
  -------------------------------------
  clock_generator: process
  begin
    s_clock <= '1';
    wait for PERIOD/2;
    s_clock <= '0';
    wait for PERIOD/2;
  end process;

  -------------------------------------
  -- PROCESS: Main test process
  -------------------------------------
  main_test_proc: process
    -------------------------------------
    -- PROCEDURE: Write to memory
    -------------------------------------
    procedure write_to_memory(
      data_in     : in std_logic_vector(G_LENGTH-1 downto 0);
      address     : in std_logic_vector(G_DEPTH-1 downto 0) ) is
    begin
      s_data_in   <= data_in;
      s_address   <= address;
      s_wr_enable <= '1';
      s_enable    <= '1';
      wait for PERIOD;
      --print_result(s_data_in, s_wr_enable, s_address, s_data_out);
    end procedure write_to_memory;

    -------------------------------------
    -- PROCEDURE: Read from memory
    -------------------------------------
    procedure read_from_memory(
      address     : in std_logic_vector(G_DEPTH-1 downto 0) ) is
    begin
      s_data_in   <= (others => '0');
      s_address   <= address;
      s_wr_enable <= '0';
      s_enable    <= '1';
      wait for PERIOD;
      --print_result(s_data_in, s_wr_enable, s_address, s_data_out);
    end procedure read_from_memory;

    -------------------------------------
    -- VARIABLES
    -------------------------------------
    variable v_data_in : std_logic_vector(G_LENGTH-1 downto 0);
    variable v_address : std_logic_vector(G_DEPTH-1 downto 0);

  begin
    -------------------------------------
    -- BEGIN TESTING
    -------------------------------------
    wait for PERIOD;
    print("*****************************************");
    print("** Testing ram...");
    print("*****************************************");

    -------------------------------------
    -- Fill memory
    -------------------------------------
    print("Writing to memory..."&lf);
    for i in 0 to 2**G_DEPTH-1 loop
      v_data_in := std_logic_vector(to_unsigned(i, s_data_in'length));
      v_address := std_logic_vector(to_unsigned(i, s_address'length));

      write_to_memory(data_in => v_data_in, address => v_address);
    end loop;

    -------------------------------------
    -- Read memory
    -------------------------------------
    print("Reading from memory..."&lf);
    for i in 0 to 2**G_DEPTH-1 loop
      v_data_in := std_logic_vector(to_unsigned(i, s_data_in'length));
      v_address := std_logic_vector(to_unsigned(i, s_address'length));

      read_from_memory(address => v_address);
      assert v_data_in = s_data_out report "Data mismatch" severity FAILURE;
    end loop;
    
    print("*****************************************");
    print("** FINISHED ram test...");
    print("*****************************************");
    finish;
    -------------------------------------
    -- END TESTING
    -------------------------------------
  end process main_test_proc;

end architecture behavior;
