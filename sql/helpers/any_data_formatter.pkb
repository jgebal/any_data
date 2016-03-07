create or replace package body any_data_formatter as

   function split_nl_string_to_array( p_string varchar2 ) return string_array is
      v_result      string_array := string_array( );
      v_start_pos   binary_integer := 1;
      v_newline_pos binary_integer := 0;
      begin
         if p_string is not null then
            loop
               v_newline_pos := instr( p_string, any_data_const.new_line, v_start_pos );
               exit when v_newline_pos = 0;
               v_result.extend;
               v_result( v_result.last ) := substr( p_string, v_start_pos, v_newline_pos - v_start_pos );
               v_start_pos := v_newline_pos + 1;
            end loop;
            v_result.extend;
            v_result( v_result.last ) := substr( p_string, v_start_pos );
         end if;
         return v_result;
      end;

   function indent_lines( p_string varchar2, p_times integer := 1 ) return varchar2 is
      v_result        varchar2(32767);
      v_lines         string_array;
      v_indent_string varchar2(30) := lpad( ' ', indent_amount * p_times );
      begin
         v_lines := split_nl_string_to_array( p_string );
         for i in 1 .. cardinality( v_lines ) loop
            v_result := v_result || v_indent_string || v_lines( i ) || any_data_const.new_line;
         end loop;
         return rtrim( v_result, any_data_const.new_line );
      end;

   function indent_lines( p_lines string_array, p_times integer := 1 ) return string_array is
      v_result        string_array := p_lines;
      v_indent_string varchar2(30) := lpad( ' ', indent_amount * p_times );
      v_results_count binary_integer := coalesce( cardinality( v_result), 0 );
      begin
         for i in 1 .. v_results_count loop
            v_result(i) := v_indent_string || v_result( i );
         end loop;
         return v_result;
      end;

end;
/
