create or replace type any_data_result_row authid current_user under any_data_family_compound(
   constructor function any_data_result_row(
      self in out nocopy any_data_result_row, data_values any_data_tab ) return self as result,
   constructor function any_data_result_row(
      self in out nocopy any_data_result_row, type_code number, type_name varchar2,
      self_type_name varchar2, data_values any_data_tab ) return self as result
);
/

create or replace type body any_data_result_row as

   constructor function any_data_result_row(
      self in out nocopy any_data_result_row, data_values any_data_tab
   ) return self as result is
      begin
         self.type_code := null;
         self.type_name := 'RESULT_ROW';
         self.self_type_name := 'any_data_result_row';
         self.data_values := data_values;
         return;
      end;

   constructor function any_data_result_row(
      self in out nocopy any_data_result_row, type_code number, type_name varchar2,
      self_type_name varchar2, data_values any_data_tab
   ) return self as result is
      begin
         self.type_code := null;
         self.type_name := 'RESULT_ROW';
         self.self_type_name := 'any_data_result_row';
         self.data_values := data_values;
         return;
      end;

end;
/

