create or replace package body anydata_reporter is

   function get_report( p_field_name varchar2, p_field_value anydata ) return varchar2 is
      begin
         return anydata_base.construct( p_field_name, p_field_value ).get_report( );
      end;

end;
/
