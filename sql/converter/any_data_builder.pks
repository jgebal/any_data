create or replace package any_data_builder as
   function get_conversion_sql( p_any_data anydata ) return varchar2;
   function build( p_any_data anydata ) return any_data;
   function build( p_cursor sys_refcursor ) return any_data;
   function get_version return varchar2;
end;
/
