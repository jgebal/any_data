create or replace package anydata_helper as

   to_sting_placeholder constant varchar2(30) := '{to_sting_placeholder}';
   piecewise_pos_placeholder constant varchar2(30) := '{piecewise_pos_placeholder}';
   typecode_placeholder constant varchar2(30) := '{typecode_placeholder}';
   max_return_data_length constant integer := 100;
   new_line constant varchar2(2) := CHR( 10 );
   indent_amount constant pls_integer := 2;
   indent_string constant varchar2(30) := lpad( ' ', indent_amount );


   function to_char( p_variable varchar2, p_format_string varchar2 := null )
      return varchar2;

   function substr( p_variable varchar2, p_start int, p_how_many int := null )
      return varchar2;

   function dbms_lob_substr( p_variable varchar2, p_how_many int, p_start int := null )
      return varchar2;

   function utl_raw_cast_to_varchar2( p_variable varchar2 )
      return varchar2;

   function trim( p_variable varchar2 )
      return varchar2;

   function indent_lines( p_string varchar2 )
      return varchar2;

end;
/
