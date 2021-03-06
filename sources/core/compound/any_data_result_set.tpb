create or replace type body any_data_result_set as

   constructor function any_data_result_set(
      self in out nocopy any_data_result_set, data_values any_data_tab, column_names string_array
   ) return self as result is
      begin
         self.type_code := null;
         self.type_name := 'RESULT_SET';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_values := data_values;
         self.set_data_values( data_values );
         return;
      end;

   constructor function any_data_result_set(
      self in out nocopy any_data_result_set, type_code number, type_name varchar2,
      self_type_name varchar2, data_values any_data_tab, column_names string_array
   ) return self as result is
      begin
         self.type_code := null;
         self.type_name := 'RESULT_SET';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_values := data_values;
         self.set_data_values( data_values );
         return;
      end;

end;
/
