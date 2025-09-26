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

--  function to_hstr(
--    slv: in std_logic_vector)
--    return string;

end package my_package;

package body my_package is
  procedure print(s: string) is
    variable l: line;
  begin
    write(l, s);
    writeline(output, l);
  end procedure print;

--  function to_hstr(
--    slv: in std_logic_vector)
--    return string is
--    variable l: line;
--  begin
--    hwrite(l, slv);
--    return l.all;
--  end function to_hstr;
end package body my_package;
