create or replace package body any_type_sql_builder as
   function get_sql( p_type any_type_mapper ) return varchar2 is
      v_sql varchar2(32767);
      begin
         v_sql :='
         declare
         begin
         end;';
         return v_sql;
      end;
end;
/
