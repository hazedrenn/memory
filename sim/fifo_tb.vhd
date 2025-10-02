library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.my_package.all;
use work.register_file_package.all;

entity fifo_tb is
  generic(
    G_LENGTH : integer := 8;
    G_DEPTH  : integer := 4);
end entity fifo_tb;

architecture behavior of fifo_tb is
  -------------------------------------
  -- PROCEDURE: print_result
  --
  -- Displays data written/read
  -- Displays fifo flags
  -------------------------------------
  procedure print_result(
    data_out     : in std_logic_vector(G_LENGTH-1 downto 0);
    data_in      : in std_logic_vector(G_LENGTH-1 downto 0);
    read_enable  : in std_logic;
    write_enable : in std_logic;
    full         : in std_logic;
    empty        : in std_logic) is
  begin
    if write_enable then
      print("WRITE data: 0x" & to_hstring(data_in) );
    end if;
    if read_enable then
      print("READ  data: 0x" & to_hstring(data_out) );
    end if;
    if full then
      print("FIFO full!");
    elsif empty then
      print("FIFO empty!");
    end if;
  end procedure print_result;

  -------------------------------------
  -- COMPONENT: fifo
  -------------------------------------
  component fifo is
    generic( 
      G_LENGTH     : integer := 8;
      G_DEPTH      : integer := 4);
    port(
      reset        : in std_logic;
      data_in      : in std_logic_vector(G_LENGTH-1 downto 0);
      clock        : in std_logic;
      write_enable : in std_logic;
      read_enable  : in std_logic;
      enable       : in std_logic;
      data_out     : out std_logic_vector(G_LENGTH-1 downto 0);
      full         : out std_logic;
      empty        : out std_logic);
  end component fifo;

  -------------------------------------
  -- CONSTANTS
  -------------------------------------
  constant PERIOD       : time := 1 ns;

  -------------------------------------
  -- SIGNALS
  -------------------------------------
  signal s_reset        : std_logic;
  signal s_data_in      : std_logic_vector(G_LENGTH-1 downto 0);
  signal s_clock        : std_logic;
  signal s_write_enable : std_logic;
  signal s_read_enable  : std_logic;
  signal s_enable       : std_logic;
  signal s_data_out     : std_logic_vector(G_LENGTH-1 downto 0);
  signal s_full         : std_logic;
  signal s_empty        : std_logic;
begin
  -------------------------------------
  -- COMPONENT Instantiation: inst_fifo
  -------------------------------------
  inst_fifo: fifo port map(
    reset        => s_reset       ,
    clock        => s_clock       ,
    enable       => s_enable      ,
    data_in      => s_data_in     ,
    write_enable => s_write_enable,
    read_enable  => s_read_enable ,
    data_out     => s_data_out    ,
    full         => s_full        ,
    empty        => s_empty       );

  -------------------------------------
  -- PROCESS: clock generator
  -------------------------------------
  clock_generator: process
  begin
    s_clock <= '1';
    wait for PERIOD/2;
    s_clock <= '0';
    wait for PERIOD/2;
  end process;

  -------------------------------------
  -- PROCESS: stimulus
  -------------------------------------
  stimulus: process
    -------------------------------------
    -- PROCEDURE: Write to memory
    -------------------------------------
    procedure write_to_memory(
      data_in         : in std_logic_vector(G_LENGTH-1 downto 0) ) is
    begin
      s_data_in       <= data_in;
      s_write_enable  <= '1';
      s_read_enable   <= '0';
      s_enable        <= '1';
      wait for PERIOD;
    
      print_result(
        data_out     => s_data_out    ,
        data_in      => s_data_in     ,
        read_enable  => s_read_enable ,
        write_enable => s_write_enable,
        full         => s_full        ,
        empty        => s_empty       );
    end procedure write_to_memory;

    -------------------------------------
    -- PROCEDURE: Read from memory
    -------------------------------------
    procedure read_from_memory is
    begin
      s_read_enable   <= '1';
      s_write_enable  <= '0';
      s_enable        <= '1';
      wait for PERIOD;

      print_result(
        data_out     => s_data_out    ,
        data_in      => s_data_in     ,
        read_enable  => s_read_enable ,
        write_enable => s_write_enable,
        full         => s_full        ,
        empty        => s_empty       );
    end procedure read_from_memory;

    -------------------------------------
    -- VARIABLES
    -------------------------------------
    variable v_data_in  : std_logic_vector(G_LENGTH-1 downto 0);
    variable v_data_out : std_logic_vector(G_LENGTH-1 downto 0);
    variable v_read     : t_read_write_interface(address(G_DEPTH-1 downto 0));
    variable v_write    : t_read_write_interface(address(G_DEPTH-1 downto 0));

  begin
    -------------------------------------
    -- BEGIN TESTING
    -------------------------------------
    print("*****************************************");
    print("** Testing ram...");
    print("*****************************************");

    -------------------------------------
    -- Clear & reset memory
    -------------------------------------
    s_reset <= '0';
    wait for PERIOD;
    s_reset <= '1';
    wait for PERIOD;
    s_reset <= '0';
    wait for PERIOD;
    assert s_empty = '1' report "Not empty" severity FAILURE;

    -------------------------------------
    -- Read empty memory
    -------------------------------------
    print("Reading empty memory...");
    for i in 0 to 2**G_DEPTH-1 loop
      v_data_in := to_slv(0, s_data_in'length);
      read_from_memory;
      assert v_data_in = s_data_out report "Data mismatch" severity FAILURE;
      assert s_empty = '1'          report "Not empty" severity FAILURE;
    end loop;
    print("");

    -------------------------------------
    -- Fill memory
    -------------------------------------
    print("Writing to memory...");
    for i in 0 to 2**G_DEPTH-1 loop
      v_data_in := to_slv(i, s_data_in'length);
      write_to_memory(data_in => v_data_in);
    end loop;
    assert s_full = '1' report "Not completely filled" severity FAILURE;
    print("");

    -------------------------------------
    -- Read filled memory
    -------------------------------------
    print("Reading from memory...");
    for i in 0 to 2**G_DEPTH-1 loop
      v_data_in := to_slv(i, s_data_in'length);
      read_from_memory;
    end loop;
    assert s_empty = '1' report "Not emptied" severity FAILURE;
    print("");
    
    -------------------------------------
    -- END TESTING
    -------------------------------------
    print("*****************************************");
    print("** FINISHED ram test...");
    print("*****************************************");
    finish;
  end process stimulus;

end architecture behavior;
