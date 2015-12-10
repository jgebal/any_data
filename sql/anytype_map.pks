create or replace package anytype_map as
   function get_element( p_typecode integer )
      return anydata_helper_base;
end;
/
