create or replace type body any_data_collection as

   constructor function any_data_collection( self in out nocopy any_data_collection, type_name varchar2, data_values any_data_tab ) return self as result is
      begin
         self.type_code := dbms_types.typecode_table;
         self.type_name := type_name;
         self.self_type_name := 'any_data_collection';
         self.data_values := data_values;
         return;
      end;

   constructor function any_data_collection(
      self in out nocopy any_data_collection, type_code number, type_name varchar2, self_type_name varchar2, data_values any_data_tab
   ) return self as result is
      begin
         self.type_code := type_code;
         self.type_name := lower(type_name);
         self.self_type_name := 'any_data_collection';
         self.data_values := data_values;
         return;
      end;

end;
/
