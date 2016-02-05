create or replace package any_type_sql_builder as
  function get_sql( p_type any_type_mapper ) return varchar2;
end;
/
