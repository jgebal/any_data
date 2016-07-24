create or replace type any_data_object authid current_user under any_data_family_compound(
   constructor function any_data_object( self in out nocopy any_data_object, type_name varchar2, data_values any_data_tab ) return self as result,
   constructor function any_data_object(
      self in out nocopy any_data_object, type_code number, type_name varchar2, self_type_name varchar2, data_values any_data_tab
   ) return self as result
);
/
