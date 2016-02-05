create or replace package any_data_mapper as
   function get_by_typecode( p_type_code integer ) return any_data;
--   function get_by_typecode( p_type_code integer, p_data anydata ) return any_data;
end;
/
