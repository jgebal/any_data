create or replace type any_data_result_set authid current_user under any_data_family_compound(
   column_names string_array,
   constructor function any_data_result_set(
      self in out nocopy any_data_result_set, data_values any_data_tab, column_names string_array
   ) return self as result,
   constructor function any_data_result_set(
      self in out nocopy any_data_result_set, type_code number, type_name varchar2,
      self_type_name varchar2, data_values any_data_tab, column_names string_array
   ) return self as result
);
/
