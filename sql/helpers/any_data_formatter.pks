create or replace package any_data_formatter as

   max_return_data_length constant integer := 100;
   new_line constant varchar2(2) := CHR( 10 );
   indent_amount constant pls_integer := 3;
   indent_string constant varchar2(30) := lpad( ' ', indent_amount );

   function indent_lines( p_string varchar2, p_times integer := 1 ) return varchar2;

   function split_nl_string_to_array( p_string varchar2 ) return string_array;
   function split_nl_clob_to_array( p_clob clob ) return string_array;

end;
/
