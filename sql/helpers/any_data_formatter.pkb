create or replace package body any_data_formatter as

   function indent_lines( p_string varchar2, p_times integer := 1 ) return varchar2 is
      v_result        varchar2(32767);
      v_lines         string_array;
      v_indent_string varchar2(30) := lpad( ' ', indent_amount * p_times );
      begin
         v_lines := split_nl_string_to_array( p_string );
         for i in 1 .. cardinality( v_lines ) loop
            v_result := v_result || v_indent_string || v_lines( i ) || new_line;
         end loop;
         return rtrim( v_result, new_line );
      end;

   function split_nl_string_to_array( p_string varchar2 ) return string_array is
      v_result      string_array := string_array( );
      v_start_pos   integer := 1;
      v_newline_pos integer := 0;
      begin
         if p_string is not null then
            loop
               v_newline_pos := instr( p_string, new_line, v_start_pos );
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

   --fastest??? solution
   function split_nl_clob_to_array( p_clob clob ) return string_array is
      v_result          string_array := string_array( );
      v_offset          integer := 1;
      v_newline_pos     integer := 0;
      v_str             varchar2(32767);
      v_substring_size  integer := 8000;
      v_clob_size       integer := dbms_lob.GETLENGTH( p_clob );
      v_remaining_size  integer := v_clob_size;
      v_tmp_result      string_array;
      begin
         if v_clob_size > 0 then
            loop
               --get a 32k string starting at start position
               v_str := substr( p_clob, v_offset, v_substring_size );
--               v_str := dbms_lob.substr( p_clob, v_substring_size, v_offset );

               --find last position of the newline in a 32k string
               v_newline_pos := instr( v_str, new_line, -1 ) - 1;
               --if clob size is above chunk size and a newline was found in string
               if v_remaining_size > v_substring_size and v_newline_pos > 0 then
                  v_str := substr( v_str, 1, v_newline_pos );
                  v_substring_size := v_newline_pos + 1;
               else
                  v_str := substr( v_str, 1, v_substring_size );
               end if;
               --build result list
--               v_result := v_result multiset union all split_nl_string_to_array( v_str );
               v_tmp_result := split_nl_string_to_array( v_str );
               v_result.extend( cardinality( v_tmp_result ) );
               for i in 1 .. cardinality( v_tmp_result ) loop
                  v_result( v_result.count -(cardinality( v_tmp_result ) - i) ) := v_tmp_result( i );
               end loop;
               v_offset := v_offset + v_substring_size;
               v_remaining_size := v_remaining_size - v_substring_size;
               exit when v_remaining_size <= 0;
            end loop;
         end if;
         return v_result;
      end;

---- this one is not so fast but faster than the below
--    function split_nl_clob_to_array( p_clob clob ) return string_array is
--       v_result      string_array := string_array( );
--       v_start_pos   integer := 1;
--       v_newline_pos integer := 0;
--       begin
--          if p_clob is not null then
--             loop
--                v_newline_pos := dbms_lob.instr( p_clob, new_line, v_start_pos );
--                exit when v_newline_pos = 0;
--                v_result.extend;
--                v_result( v_result.last ) := dbms_lob.substr( p_clob, v_newline_pos - v_start_pos, v_start_pos );
--                v_start_pos := v_newline_pos + 1;
--             end loop;
--             v_result.extend;
--             v_result( v_result.last ) := dbms_lob.substr( p_clob, offset=> v_start_pos );
--          end if;
--          return v_result;
--       end;

----   This works but is very slow
--    function split_nl_clob_to_array( p_clob clob ) return string_array is
--       v_result string_array := string_array();
--       v_start_pos     integer := 1;
--       v_newline_pos   integer := 0;
--       begin
--          if p_clob is not null then
--             loop
--                v_newline_pos := instr( p_clob, new_line, v_start_pos );
--                exit when v_newline_pos = 0;
--                v_result.extend; v_result(v_result.last) := substr( p_clob, v_start_pos, v_newline_pos - v_start_pos );
--                v_start_pos := v_newline_pos + 1;
--             end loop;
--             v_result.extend; v_result(v_result.last) := substr( p_clob, v_start_pos );
--          end if;
--          return v_result;
--       end;

end;
/
