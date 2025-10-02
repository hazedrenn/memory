library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package register_file_package is
  type t_read_write_interface is record
    clock    : std_logic;
    enable   : std_logic;
    address  : std_logic_vector;
  end record t_read_write_interface;
  
  function int(
    slv: std_logic_vector)
    return integer;

end package register_file_package;

package body register_file_package is
  function int(
    slv: std_logic_vector)
    return integer is
  begin
    return to_integer(unsigned(slv));
  end function int;
end package body register_file_package;
