create or replace package any_data_builder as
   function get_conversion_sql( p_type any_type_mapper ) return varchar2;
   function build( p_any_data anydata ) return any_data;
   function build( p_any_data anydata, p_any_type any_type_mapper ) return any_data;
end;
/
