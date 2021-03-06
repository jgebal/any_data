create or replace package any_data_formatter as

   indent_amount constant pls_integer := 3;
   indent_string constant varchar2(30) := lpad( ' ', indent_amount );

   function get_version return varchar2;

   function indent_lines( p_string varchar2, p_times integer := 1 ) return varchar2;

   function indent_lines( p_lines string_array, p_times integer := 1 ) return string_array;

end;
/
