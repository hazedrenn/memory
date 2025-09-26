library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.my_package.all;

entity rom_tb is
  generic(
    DATA_LENGTH : integer := 8;
    ADDRESS_LENGTH : integer := 4);
end entity rom_tb;

architecture behavior of rom_tb is

  procedure print_result(
    data_in     : in std_logic_vector(DATA_LENGTH-1 downto 0);
    write_enable: in std_logic;
    read_enable : in std_logic;
    address     : in std_logic_vector(2**ADDRESS_LENGTH-1 downto 0);
    data_out    : in std_logic_vector(DATA_LENGTH-1 downto 0) ) is
  begin
    if (write_enable) then
      print("WRITE"&
            " data_in: 0x"  &to_hstring(data_in)&
            " @ address: 0x"&to_hstring(address) );
    end if;
    if (read_enable) then
      print("READ"&
            " data_out: 0x" &to_hstring(data_out)&
            " @ address: 0x"&to_hstring(address) );
    end if;
  end procedure print_result;

  component rom is
    generic( 
      DATA_LENGTH : integer := DATA_LENGTH;
      ADDRESS_LENGTH : integer := ADDRESS_LENGTH);
    port(
      data_in : in std_logic_vector(DATA_LENGTH-1 downto 0);
      clock : in std_logic;
      write_enable: in std_logic;
      read_enable: in std_logic;
      address : in std_logic_vector(2**ADDRESS_LENGTH-1 downto 0);
      data_out : out std_logic_vector(DATA_LENGTH-1 downto 0));
  end component rom;

  signal s_data_in : std_logic_vector(DATA_LENGTH-1 downto 0);
  signal s_clock : std_logic;
  signal s_write_enable: std_logic;
  signal s_read_enable: std_logic;
  signal s_address : std_logic_vector(2**ADDRESS_LENGTH-1 downto 0);
  signal s_data_out : std_logic_vector(DATA_LENGTH-1 downto 0);

  signal PERIOD : time := 1 ns;
begin
  t_rom : rom port map(
    data_in => s_data_in,
    clock => s_clock,
    write_enable => s_write_enable,
    read_enable => s_read_enable,
    address => s_address,
    data_out => s_data_out);

  clock_proc: process
  begin
    s_clock <= '1';
    wait for PERIOD/2;
    s_clock <= '0';
    wait for PERIOD/2;
  end process;

  main_test_proc: process
    -------
    -- Procedure: Write to memory
    --------
    procedure write_to_memory(
      data_in : in std_logic_vector(DATA_LENGTH-1 downto 0);
      address : in std_logic_vector(2**ADDRESS_LENGTH-1 downto 0) ) is
    begin
      s_data_in <= data_in;
      s_write_enable <= '1';
      s_read_enable <= '0';
      s_address <= address;
      wait for PERIOD;
      --print_result(s_data_in, s_write_enable, s_read_enable, s_address, s_data_out);
    end procedure write_to_memory;

    -------
    -- Procedure: Read from memory
    --------
    procedure read_from_memory(
      address  : in std_logic_vector(2**ADDRESS_LENGTH-1 downto 0) ) is
    begin
      s_data_in <= (others => '0');
      s_write_enable <= '0';
      s_read_enable <= '1';
      s_address <= address;
      wait for PERIOD;
      --print_result(s_data_in, s_write_enable, s_read_enable, s_address, s_data_out);
    end procedure read_from_memory;

    variable v_data_in: std_logic_vector(DATA_LENGTH-1 downto 0);
    variable v_address: std_logic_vector(2**ADDRESS_LENGTH-1 downto 0);
  begin
    wait for PERIOD;
    -------
    -- Fill memory
    --------
    print("Writing to memory..."&lf);
    for i in 0 to 2**s_address'length-1 loop
      v_data_in := std_logic_vector(to_unsigned(i, s_data_in'length));
      v_address := std_logic_vector(to_unsigned(i, s_address'length));
      write_to_memory(data_in => v_data_in, address => v_address);
    end loop;

    -------
    -- Read memory
    --------
    print("Reading from memory..."&lf);
    for i in 0 to 2**s_address'length-1 loop
      v_data_in := std_logic_vector(to_unsigned(i, s_data_in'length));
      v_address := std_logic_vector(to_unsigned(i, s_address'length));
      read_from_memory(address => v_address );
      assert v_data_in = s_data_out report "Data mismatch" severity ERROR;
    end loop;
    
    print("TEST PASSED");
    finish;
  end process main_test_proc;

end architecture behavior;
