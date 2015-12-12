create or replace package anydata_reporter is

   NEW_LINE constant varchar2(2) := CHR( 10 );
   INDENT_AMOUNT constant pls_integer := 2;

   function get_report( p_field_name varchar2, p_field_value ANYDATA, p_indent integer := 0 )
      return varchar2;

   function get_anydata_helper( p_field_name varchar2, p_field_value anydata )
      return anydata_helper_base;

end;
/
