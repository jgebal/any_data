create or replace package body anydata_helper as

   function indent_lines( p_string varchar2 ) return varchar2 is
      v_result      varchar2(32767);
      v_start_pos   integer := 1;
      v_newline_pos integer := 0;
      begin
         loop
            v_newline_pos := instr( p_string, new_line, v_start_pos );
            exit when v_newline_pos = 0;
            v_result := v_result || indent_string ||
                        standard.substr( p_string, v_start_pos, v_newline_pos - v_start_pos + 1 );
            v_start_pos := v_newline_pos + 1;
         end loop;
         v_result := v_result || indent_string || standard.substr( p_string, v_start_pos );
         return v_result;
      end;

end;
/
