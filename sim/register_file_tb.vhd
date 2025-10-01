library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.my_package.all;

entity register_file_tb is
  generic(
    G_LENGTH : integer := 8;
    G_DEPTH  : integer := 4);
end entity register_file_tb;

architecture behavior of register_file_tb is
  -------------------------------------
  -- PROCEDURE: print_result
  --
  -- Displays address
  -- If write enabled, displays data_in
  -- If read enabled, displays data_out
  -------------------------------------
  procedure print_result(
    read_data     : in std_logic_vector(G_LENGTH-1 downto 0);
    read_enable   : in std_logic;
    read_address  : in std_logic_vector(G_DEPTH-1 downto 0);
    write_data    : in std_logic_vector(G_LENGTH-1 downto 0);
    write_enable  : in std_logic;
    write_address : in std_logic_vector(G_DEPTH-1 downto 0) ) is
  begin
    if write_enable then
      print("WRITE data: 0x" & to_hstring(write_data) &
            " @ address: 0x" & to_hstring(write_address) );
    end if;
    if read_enable then
      print("READ  data: 0x" & to_hstring(read_data) &
            " @ address: 0x" & to_hstring(read_address) );
    end if;
  end procedure print_result;

  -------------------------------------
  -- COMPONENT: register_file
  -------------------------------------
  component register_file is
    generic( 
      G_LENGTH      : natural := G_LENGTH;
      G_DEPTH       : natural := G_DEPTH);
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
  end component register_file;

  -------------------------------------
  -- CONSTANTS
  -------------------------------------
  constant PERIOD        : time := 1 ns;

  -------------------------------------
  -- SIGNALS
  -------------------------------------
  signal s_reset         : std_logic;
  signal s_enable        : std_logic;
  
  -- Read Interface
  signal s_read_clock    : std_logic;
  signal s_read_data     : std_logic_vector(G_LENGTH-1 downto 0);
  signal s_read_address  : std_logic_vector(G_DEPTH-1 downto 0);
  signal s_read_enable   : std_logic;
  
  -- Write Interface
  signal s_write_clock   : std_logic;
  signal s_write_data    : std_logic_vector(G_LENGTH-1 downto 0);
  signal s_write_address : std_logic_vector(G_DEPTH-1 downto 0);
  signal s_write_enable  : std_logic;
begin
  -------------------------------------
  -- COMPONENT Instantiation: inst_register_file
  -------------------------------------
  inst_register_file : register_file port map(
    reset         => s_reset         ,
    enable        => s_enable        ,
    read_clock    => s_read_clock    ,
    read_data     => s_read_data     ,
    read_address  => s_read_address  ,
    read_enable   => s_read_enable   ,
    write_clock   => s_write_clock   ,
    write_data    => s_write_data    ,
    write_address => s_write_address ,
    write_enable  => s_write_enable  );

  -------------------------------------
  -- PROCESS: Clock generator
  -------------------------------------
  clock_generator: process
  begin
    s_read_clock <= '1';
    s_write_clock <= '1';
    wait for PERIOD/2;
    s_read_clock <= '0';
    s_write_clock <= '0';
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
      data_in         : in std_logic_vector(G_LENGTH-1 downto 0);
      address         : in std_logic_vector(G_DEPTH-1 downto 0) ) is
    begin
      s_write_data    <= data_in;
      s_write_address <= address;
      s_write_enable  <= '1';
      s_read_enable   <= '0';
      s_enable        <= '1';
      wait for PERIOD;
    
      print_result(
        read_data     => s_read_data    ,
        read_enable   => s_read_enable  ,
        read_address  => s_read_address ,
        write_data    => s_write_data   ,
        write_enable  => s_write_enable ,
        write_address => s_write_address);
    end procedure write_to_memory;

    -------------------------------------
    -- PROCEDURE: Read from memory
    -------------------------------------
    procedure read_from_memory(
      address         : in std_logic_vector(G_DEPTH-1 downto 0) ) is
    begin
      s_read_address  <= address;
      s_read_enable   <= '1';
      s_write_enable  <= '0';
      s_enable        <= '1';
      wait for PERIOD;

      print_result(
        read_data     => s_read_data    ,
        read_enable   => s_read_enable  ,
        read_address  => s_read_address ,
        write_data    => s_write_data   ,
        write_enable  => s_write_enable ,
        write_address => s_write_address);
    end procedure read_from_memory;

    -------------------------------------
    -- VARIABLES
    -------------------------------------
    variable v_read_data      : std_logic_vector(G_LENGTH-1 downto 0);
    variable v_read_address   : std_logic_vector(G_DEPTH-1 downto 0);
    variable v_write_data     : std_logic_vector(G_LENGTH-1 downto 0);
    variable v_write_address  : std_logic_vector(G_DEPTH-1 downto 0);

  begin
    -------------------------------------
    -- BEGIN TESTING
    -------------------------------------
    s_reset <= '0';
    wait for PERIOD;
    print("*****************************************");
    print("** Testing ram...");
    print("*****************************************");

    -------------------------------------
    -- Fill memory
    -------------------------------------
    print("Writing to memory..."&lf);
    for i in 0 to 2**G_DEPTH-1 loop
      v_write_data    := std_logic_vector(to_unsigned(i, s_write_data'length));
      v_write_address := std_logic_vector(to_unsigned(i, s_write_address'length));

      write_to_memory(data_in => v_write_data, address => v_write_address);
    end loop;

    -------------------------------------
    -- Read memory
    -------------------------------------
    print("Reading from memory..."&lf);
    for i in 0 to 2**G_DEPTH-1 loop
      v_write_data    := std_logic_vector(to_unsigned(i, s_write_data'length));
      v_read_address  := std_logic_vector(to_unsigned(i, s_read_address'length));

      read_from_memory(address => v_read_address);
      assert v_write_data = s_read_data report "Data mismatch" severity FAILURE;
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
