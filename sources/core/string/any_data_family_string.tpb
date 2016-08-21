create or replace type body any_data_family_string is

   overriding member function get_self_family_name return varchar2 is
      begin
         return $$PLSQL_UNIT;
      end;

end;
/
