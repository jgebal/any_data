create or replace package anydata_reporter is

   function get_report( p_field_name varchar2, p_field_value anydata ) return varchar2;

end;
/
