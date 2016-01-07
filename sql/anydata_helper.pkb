create or replace package body anydata_helper as

   function quote_str( p_what varchar2 ) return varchar2 is
      begin
         return case when p_what is not null then ''''||p_what||'''' end;
      end;

   function add_if_not_null( p_what varchar2, p_first boolean := false ) return varchar2 is
      begin
         return
            case when p_what is not null
               then case when not p_first then ', 'end || p_what
            end;
      end;

   function to_char( p_variable varchar2, p_format_string varchar2 := null )
      return varchar2 is
      begin
         return 'to_char( '||p_variable
                || add_if_not_null( quote_str( p_format_string ) )
                ||' )';
      end;

   function substr( p_variable varchar2, p_start int, p_how_many int := null)
      return varchar2 is
      begin
         return 'substr( '||p_variable
                ||add_if_not_null( p_start )
                ||add_if_not_null( p_how_many )
                ||' )';
      end;

   function dbms_lob_substr( p_variable varchar2, p_how_many int, p_start int := null)
      return varchar2 is
   begin
      return 'dbms_lob.'||substr( p_variable, p_how_many, p_start );
   end;

   function utl_raw_cast_to_varchar2( p_variable varchar2)
      return varchar2 is
      begin
         return 'utl_raw.cast_to_varchar2( ' || p_variable ||' )';
      end;

   function trim( p_variable varchar2 )
      return varchar2 is
      begin
         return 'trim( ' || p_variable ||' )';
      end;

   function indent_lines( p_string varchar2 )
      return varchar2 is
      v_result varchar2(32767);
      v_start_pos   integer := 1;
      v_newline_pos integer := 0;
      begin
         loop
            v_newline_pos := instr( p_string, new_line, v_start_pos );
            exit when v_newline_pos = 0;
            v_result := v_result || indent_string || standard.substr( p_string, v_start_pos, v_newline_pos - v_start_pos + 1 );
            v_start_pos := v_newline_pos + 1;
         end loop;
         v_result := v_result || indent_string || standard.substr( p_string, v_start_pos );
         return v_result;
      end;
end;
/
