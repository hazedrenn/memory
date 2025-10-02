library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

package my_package is
  procedure print(s: string);

  type t_sample_record is record
    signal_e: std_logic;
  end record t_sample_record;

  function to_slv(
    int: integer;
    size: integer)
    return std_logic_vector;

end package my_package;

package body my_package is
  procedure print(s: string) is
    variable l: line;
  begin
    write(l, s);
    writeline(output, l);
  end procedure print;

  function to_slv(
    int: integer;
    size: integer)
    return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(int, size));
  end function to_slv;
end package body my_package;
