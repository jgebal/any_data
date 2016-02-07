create or replace package body any_data_formatter as

   function indent_lines( p_string varchar2, p_times integer := 1 ) return varchar2 is
      v_result        varchar2(32767);
      v_indent_string varchar2(30) := lpad( ' ', indent_amount*p_times );
      v_start_pos     integer := 1;
      v_newline_pos   integer := 0;
      begin
         loop
            v_newline_pos := instr( p_string, new_line, v_start_pos );
            exit when v_newline_pos = 0;
            v_result := v_result || v_indent_string ||
                        standard.substr( p_string, v_start_pos, v_newline_pos - v_start_pos + 1 );
            v_start_pos := v_newline_pos + 1;
         end loop;
         v_result := v_result || v_indent_string || standard.substr( p_string, v_start_pos );
         return v_result;
      end;

end;
/
